//
//  SensorsManager.m
//  Wimoto
//
//  Created by MacBook on 24/06/2014.
//
//

#import "SensorsManager.h"
#import <Couchbaselite/CouchbaseLite.h>
#import "SensorEntity.h"
#import "QueueManager.h"
#import "Sensor.h"
#import "DemoThermoSensor.h"

@interface SensorsManager ()

@property (nonatomic, strong) NSMutableSet *sensors;

@property (nonatomic, strong) WimotoCentralManager *wimotoCentralManager;

@property (nonatomic, strong) NSMutableArray *unregisteredSensorObservers;
@property (nonatomic, strong) NSMutableArray *registeredSensorObservers;

@property (nonatomic, strong) CBLDatabase *cblDatabase;

- (void)addDemoSensors;

@end

@implementation SensorsManager

static SensorsManager *sensorsManager = nil;

+ (SensorsManager*)sharedManager {
	if (!sensorsManager) {
		sensorsManager = [[SensorsManager alloc] init];
	}
	return sensorsManager;
}

- (id)init {
    self = [super init];
    if (self) {
        _sensors                        = [NSMutableSet set];
        
        _unregisteredSensorObservers    = [NSMutableArray array];
        _registeredSensorObservers      = [NSMutableArray array];
        
        _wimotoCentralManager = [[WimotoCentralManager alloc] initWithDelegate:self];
        
        _cblDatabase = [[CBLManager sharedInstance] databaseNamed:@"wimoto" error:nil];
        
        dispatch_async([QueueManager databaseQueue], ^{
            CBLView *view = [_cblDatabase viewNamed:@"registeredSensors"];
            
            NSString* const kSensorEntityType = NSStringFromClass([SensorEntity class]);
            [view setMapBlock:MAPBLOCK({
                if ([doc[@"type"] isEqualToString:kSensorEntityType]) {
                    emit(doc[@"systemId"], doc);
                }
            }) version:@"1.0"];
            
            CBLQuery *query = [view createQuery];
            CBLQueryEnumerator *queryEnumerator = [query run:nil];
            
            for (CBLQueryRow *row in queryEnumerator) {
                [_sensors addObject:[Sensor sensorWithEntity:[SensorEntity modelForDocument:row.document]]];
            }
            [self addDemoSensors];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self notifyRegisteredSensorsObservers];
                
                [_wimotoCentralManager startScan];
            });
        });
    }
    return self;
}

- (void)addDemoSensors {
    NSArray *demoIds = @[BLE_THERMO_DEMO_MODEL, BLE_CLIMATE_DEMO_MODEL];
    for (NSString *uniqueId in demoIds) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uniqueIdentifier == %@", uniqueId];
        Sensor *sensor = [_sensors filteredSetUsingPredicate:predicate].anyObject;
        if (!sensor) {
            sensor = [Sensor demoSensorWithUniqueId:uniqueId];
            [_sensors addObject:sensor];
            [self notifyUnregisteredSensorsObservers];
        }
    }
}

+ (void)registerSensor:(Sensor*)sensor {
    SensorsManager *manager = [SensorsManager sharedManager];
    
    dispatch_async([QueueManager databaseQueue], ^{
        SensorEntity *sensorEntity = [[SensorEntity alloc] initWithNewDocumentInDatabase:manager.cblDatabase];
        [sensorEntity setValue:NSStringFromClass([SensorEntity class]) ofProperty:@"type"];
        sensorEntity.name        = sensor.name;
        sensorEntity.systemId    = sensor.uniqueIdentifier;
        sensorEntity.sensorType  = [NSNumber numberWithInt:[sensor type]];
        [sensorEntity save:nil];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            sensor.entity = sensorEntity;
        });
    });
    
    sensor.registered = YES;
    
    [manager notifyRegisteredSensorsObservers];
    [manager notifyUnregisteredSensorsObservers];
}

+ (void)unregisterSensor:(Sensor*)sensor {
    SensorsManager *manager = [SensorsManager sharedManager];
    dispatch_async([QueueManager databaseQueue], ^{
        [sensor.entity deleteDocument:nil];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            sensor.entity = nil;
        });
    });
    
    sensor.registered = NO;
        
    [manager notifyRegisteredSensorsObservers];
    [manager notifyUnregisteredSensorsObservers];
}

+ (void)addObserverForUnregisteredSensors:(id<SensorsObserver>)observer {
    SensorsManager *manager = [SensorsManager sharedManager];
    [manager.unregisteredSensorObservers addObject:observer];
    
    NSSet *set = [manager getUnregisteredSensors];
    dispatch_async(dispatch_get_main_queue(), ^{
        [observer didUpdateSensors:set];
    });
}

+ (void)removeObserverForUnregisteredSensors:(id<SensorsObserver>)observer {
    [[SensorsManager sharedManager].unregisteredSensorObservers removeObject:observer];
}

+ (void)addObserverForRegisteredSensors:(id<SensorsObserver>)observer {
    SensorsManager *manager = [SensorsManager sharedManager];
    [manager.registeredSensorObservers addObject:observer];
    
    NSSet *set = [manager getRegisteredSensors];
    dispatch_async(dispatch_get_main_queue(), ^{
        [observer didUpdateSensors:set];
    });
}

+ (void)removeObserverForRegisteredSensors:(id<SensorsObserver>)observer {
    [[SensorsManager sharedManager].registeredSensorObservers removeObject:observer];
}

- (NSSet*)getUnregisteredSensors {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"registered == %@", [NSNumber numberWithBool:NO]];
    return [_sensors filteredSetUsingPredicate:predicate];
}

- (NSSet*)getRegisteredSensors {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"registered == %@", [NSNumber numberWithBool:YES]];
    return [_sensors filteredSetUsingPredicate:predicate];
}

- (void)notifyRegisteredSensorsObservers {
    NSSet *registeredSensors = [self getRegisteredSensors];
    for (id<SensorsObserver> observer in _registeredSensorObservers) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [observer didUpdateSensors:registeredSensors];
        });
    }
}

- (void)notifyUnregisteredSensorsObservers {
    NSSet *unregisteredSensors = [self getUnregisteredSensors];
    for (id<SensorsObserver> observer in _unregisteredSensorObservers) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [observer didUpdateSensors:unregisteredSensors];
        });
    }
}

#pragma mark - WimotoCentralManagerDelegate

- (void)didConnectPeripheral:(CBPeripheral*)peripheral {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uniqueIdentifier == %@", [peripheral uniqueIdentifier]];
    Sensor *sensor = [_sensors filteredSetUsingPredicate:predicate].anyObject;
    
    if (sensor) {
        dispatch_async(dispatch_get_main_queue(), ^{
            sensor.peripheral = peripheral;
        });
    } else {
        [_sensors addObject:[Sensor sensorWithPeripheral:peripheral]];
        [self notifyUnregisteredSensorsObservers];
    }    
}

- (void)didDisconnectPeripheral:(CBPeripheral*)peripheral {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"peripheral == %@", peripheral];
    Sensor *sensor = [_sensors filteredSetUsingPredicate:predicate].anyObject;
    
    if ([sensor isRegistered]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            sensor.peripheral = nil;
        });
    } else if (sensor) {
        [_sensors removeObject:sensor];

        [self notifyUnregisteredSensorsObservers];
    }
}

@end