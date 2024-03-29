//
//  SensorsManager.m
//  Wimoto
//
//  Created by MacBook on 24/06/2014.
//
//

#import "SensorsManager.h"

#import <Couchbaselite/CouchbaseLite.h>
#import <FacebookSDK/FacebookSDK.h>

#import "SensorEntity.h"
#import "QueueManager.h"
#import "Sensor.h"
#import "DemoThermoSensor.h"

#import "SentrySensor.h"
#import "SentrySensorEntity.h"

#import "GrowSensor.h"
#import "GrowSensorEntity.h"

#define kServerDbURL @"http://146.148.72.228:4984/wimoto"

@interface SensorsManager ()

@property (nonatomic, strong) NSMutableSet *sensors;

@property (nonatomic, strong) WimotoCentralManager *wimotoCentralManager;
@property (nonatomic, strong) DemoWimotoCentralManager *demoWimotoCentralManager;

@property (nonatomic, strong) NSMutableArray *unregisteredSensorObservers;
@property (nonatomic, strong) NSMutableArray *registeredSensorObservers;

@property (nonatomic, strong) CBLDatabase *cblDatabase;
@property (nonatomic, strong) CBLReplication *push;
@property (nonatomic, weak) id<AuthentificationObserver>authObserver;

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
        _demoWimotoCentralManager = [[DemoWimotoCentralManager alloc] initWithDelegate:self];
        
        _cblDatabase = [[CBLManager sharedInstance] databaseNamed:@"wimoto" error:nil];
        CBLModelFactory* factory = _cblDatabase.modelFactory;
        [factory registerClass:[SensorEntity class] forDocumentType:NSStringFromClass([SensorEntity class])];
        [factory registerClass:[SentrySensorEntity class] forDocumentType:NSStringFromClass([SentrySensorEntity class])];
        [factory registerClass:[GrowSensorEntity class] forDocumentType:NSStringFromClass([GrowSensorEntity class])];
        
        NSURL* serverDbURL = [NSURL URLWithString: kServerDbURL];
        _push = [_cblDatabase createPushReplication: serverDbURL];
        _push.continuous = YES;
        
        // Observe replication progress changes, in both directions
        NSNotificationCenter* nctr = [NSNotificationCenter defaultCenter];
        [nctr addObserver: self selector: @selector(replicationProgress:)
                     name: kCBLReplicationChangeNotification object: _push];
        
        dispatch_async([QueueManager databaseQueue], ^{
            CBLView *view = [_cblDatabase viewNamed:@"registeredSensors"];
            
            NSString* const kSensorEntityType = NSStringFromClass([SensorEntity class]);
            NSString* const kSentrySensorEntityType = NSStringFromClass([SentrySensorEntity class]);
            NSString* const kGrowSensorEntityType = NSStringFromClass([GrowSensorEntity class]);
            [view setMapBlock:MAPBLOCK({
                if (([doc[@"type"] isEqualToString:kSensorEntityType]) ||
                    ([doc[@"type"] isEqualToString:kSentrySensorEntityType]) ||
                    ([doc[@"type"] isEqualToString:kGrowSensorEntityType])){
                    emit(doc[@"systemId"], doc);
                }
            }) version:@"1.0"];
            
            CBLQuery *query = [view createQuery];
            CBLQueryEnumerator *queryEnumerator = [query run:nil];
            
            for (CBLQueryRow *row in queryEnumerator) {
                NSLog(@"CBLQueryRow %@", row);
                
                Sensor *sensor = [Sensor sensorWithEntity:(SensorEntity *)[CBLModel modelForDocument:row.document]];
                //[sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_SENSOR_DFU_MODE options:NSKeyValueObservingOptionNew context:nil];
                [_sensors addObject:sensor];
            }
            [self addDemoSensors];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self notifyRegisteredSensorsObservers];
                
                [_wimotoCentralManager startScan];
            //  [_demoWimotoCentralManager startDemoScan];
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
            sensor = [DemoSensor demoSensorWithUniqueId:uniqueId];
            [_sensors addObject:sensor];
            [self notifyUnregisteredSensorsObservers];
        }
    }
}

+ (void)registerSensor:(Sensor*)sensor {
    SensorsManager *manager = [SensorsManager sharedManager];
    
    dispatch_async([QueueManager databaseQueue], ^{
        SensorEntity *sensorEntity = nil;
        if ([sensor isKindOfClass:[SentrySensor class]]) {
            sensorEntity = [[SentrySensorEntity alloc] initWithNewDocumentInDatabase:manager.cblDatabase];
            [sensorEntity setValue:NSStringFromClass([SentrySensorEntity class]) ofProperty:@"type"];
        } else if ([sensor isKindOfClass:[GrowSensor class]]) {
            sensorEntity = [[GrowSensorEntity alloc] initWithNewDocumentInDatabase:manager.cblDatabase];
            [sensorEntity setValue:NSStringFromClass([GrowSensorEntity class]) ofProperty:@"type"];
        } else {
            sensorEntity = [[SensorEntity alloc] initWithNewDocumentInDatabase:manager.cblDatabase];
            [sensorEntity setValue:NSStringFromClass([SensorEntity class]) ofProperty:@"type"];
        }
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


+ (void)switchOffAlarm:(NSString *)UUID forSensor:(NSString *)sensorId {
    [[SensorsManager sharedManager] switchOffAlarm:UUID forSensor:sensorId];
}

- (void)switchOffAlarm:(NSString *)UUID forSensor:(NSString *)sensorId {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uniqueIdentifier == %@", sensorId];
    Sensor *sensor = [_sensors filteredSetUsingPredicate:predicate].anyObject;
    
    NSLog(@"Sensors Manager switchOffAlarm %@   ____%@", sensor, sensorId);
    
    [sensor enableAlarm:NO forCharacteristicWithUUIDString:UUID];
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
        Sensor *sensor = [Sensor sensorWithPeripheral:peripheral];
        [_sensors addObject:sensor];
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

- (void)didConnectDfuPeripheral:(CBPeripheral*)peripheral {
    NSLog(@"SensorsManager didConnectDfuPeripheral");
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uuidString == %@", [[peripheral identifier] UUIDString]];
    Sensor *sensor = [_sensors filteredSetUsingPredicate:predicate].anyObject;
    
    NSLog(@"SensorsManager didConnectDfuPeripheral #320 %@", sensor);
    if (sensor) {
        dispatch_async(dispatch_get_main_queue(), ^{
            sensor.peripheral = peripheral;
            sensor.dfuModeOn = YES;
        });
    }
}

#pragma mark - WimotoCentralManagerDelegate

- (void)didConnectDemoPeripheral:(DemoCBPeripheral *)peripheral {
    NSLog(@"SensorsManager didConnectDemoPeripheral");
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uniqueIdentifier == %@", [peripheral uniqueIdentifier]];
    Sensor *sensor = [_sensors filteredSetUsingPredicate:predicate].anyObject;
    
    if (sensor) {
        dispatch_async(dispatch_get_main_queue(), ^{
            sensor.peripheral = peripheral;
        });
    } else {
        Sensor *sensor = [Sensor sensorWithPeripheral:peripheral];
        //Sensor *sensor = [DemoSensor demoSensorWithUniqueId:[peripheral uniqueIdentifier]];
        [_sensors addObject:sensor];
        [self notifyUnregisteredSensorsObservers];
    }
}

#pragma mark - Replication

+ (void)setAuthentificationObserver:(id<AuthentificationObserver>)observer {
    SensorsManager *manager = [SensorsManager sharedManager];
    manager.authObserver = observer;
    
    [observer didAuthentificate:([[FBSession activeSession] state] == FBSessionStateOpen)?YES:NO];
}

+ (void)activate {
    SensorsManager *manager = [SensorsManager sharedManager];
    if ([FBSession activeSession].state == FBSessionStateCreatedTokenLoaded) {
        [manager openActiveSessionWithPermissions:nil allowLoginUI:NO];
    }
    [FBAppCall handleDidBecomeActive];
}

+ (BOOL)handleOpenURL:(NSURL *)URL sourceApplication:(NSString *)sourceApplication {
    return [FBAppCall handleOpenURL:URL sourceApplication:sourceApplication];
}

+ (void)authSwitch {
    SensorsManager *manager = [SensorsManager sharedManager];
    if ([FBSession activeSession].state != FBSessionStateOpen &&
        [FBSession activeSession].state != FBSessionStateOpenTokenExtended) {
        [manager openActiveSessionWithPermissions:@[@"email"] allowLoginUI:YES];
    }
    else {
        [[FBSession activeSession] closeAndClearTokenInformation];
    }
}

- (void)openActiveSessionWithPermissions:(NSArray *)permissions allowLoginUI:(BOOL)allowLoginUI {
    [FBSession openActiveSessionWithReadPermissions:permissions
                                       allowLoginUI:allowLoginUI
                                  completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                      if ((!error) && (status == FBSessionStateOpen)) {
                                          _push.authenticator = [CBLAuthenticator facebookAuthenticatorWithToken:[[session accessTokenData] accessToken]];
                                          [_push start];
                                          [_authObserver didAuthentificate:YES];
                                      }
                                      else  {
                                          _push.authenticator = nil;
                                          [_push stop];
                                          
                                          [_authObserver didAuthentificate:NO];
                                      }
                                  }];
}

- (void) replicationProgress: (NSNotificationCenter*)n {
    if (_push.status == kCBLReplicationActive) {
        // Sync is active -- aggregate the progress of both replications and compute a fraction:
        unsigned completed = _push.completedChangesCount;
        unsigned total = _push.changesCount;
        NSLog(@"SYNC progress: %u / %u", completed, total);
        // Update the progress bar, avoiding divide-by-zero exceptions:
    } else {
        // Sync is idle -- hide the progress bar and show the config button:
        NSLog(@"SYNC idle");
    }
    
//    // Check for any change in error status and display new errors:
//    NSError* error = _pull.lastError ? _pull.lastError : _push.lastError;
//    if (error != _syncError) {
//        _syncError = error;
//        if (error) {
//            [self showAlert: @"Error syncing" error: error fatal: NO];
//        }
//    }
}


// Display an error alert, without blocking.
// If 'fatal' is true, the app will quit when it's dismissed.
- (void)showAlert: (NSString*)message error: (NSError*)error fatal: (BOOL)fatal {
    if (error) {
        message = [message stringByAppendingFormat: @"\n\n%@", error.localizedDescription];
    }
    NSLog(@"ALERT: %@ (error=%@)", message, error);
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle: (fatal ? @"Fatal Error" : @"Error")
                                                    message: message
                                                   delegate: (fatal ? self : nil)
                                          cancelButtonTitle: (fatal ? @"Quit" : @"Sorry")
                                          otherButtonTitles: nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    exit(0);
}


@end