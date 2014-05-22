//
//  DatabaseManager.m
//  Wimoto
//
//  Created by MC700 on 12/16/13.
//
//

#import "DatabaseManager.h"

#import <Couchbaselite/CouchbaseLite.h>

#import "Sensor.h"
#import "TestSensor.h"
#import "ClimateSensor.h"
#import "GrowSensor.h"
#import "ThermoSensor.h"
#import "SentrySensor.h"
#import "WaterSensor.h"
#import "SensorValue.h"

@interface DatabaseManager ()

@property (nonatomic, strong) CBLDatabase *cblDatabase;
@property (nonatomic, strong) dispatch_queue_t sensorQueue;

@end

@implementation DatabaseManager

static DatabaseManager *databaseManager = nil;

+ (DatabaseManager*)sharedManager {
	if (!databaseManager) {
		databaseManager = [[DatabaseManager alloc] init];
	}
	return databaseManager;
}

- (id)init {
    self = [super init];
    if (self) {
        self.sensorQueue = dispatch_queue_create("com.wimoto.sensor", DISPATCH_QUEUE_SERIAL);
        _cblDatabase = [[CBLManager sharedInstance] databaseNamed:@"wimoto" error:nil];
        CBLModelFactory *modelFactory = [CBLModelFactory sharedInstance];
        [modelFactory registerClass:[SensorValue class] forDocumentType:NSStringFromClass([SensorValue class])];
        [modelFactory registerClass:[TestSensor class] forDocumentType:NSStringFromClass([TestSensor class])];
        [modelFactory registerClass:[ClimateSensor class] forDocumentType:NSStringFromClass([ClimateSensor class])];
        [modelFactory registerClass:[GrowSensor class] forDocumentType:NSStringFromClass([GrowSensor class])];
        [modelFactory registerClass:[ThermoSensor class] forDocumentType:NSStringFromClass([ThermoSensor class])];
        [modelFactory registerClass:[SentrySensor class] forDocumentType:NSStringFromClass([SentrySensor class])];
        [modelFactory registerClass:[WaterSensor class] forDocumentType:NSStringFromClass([WaterSensor class])];
    }
    return self;
}

+ (dispatch_queue_t)getSensorQueue
{
    return [[DatabaseManager sharedManager] sensorQueue];
}

+ (void)sensorInstanceWithPeripheral:(CBPeripheral*)peripheral completionHandler:(void(^)(Sensor *item))completionHandler
{
    DatabaseManager *manager = [DatabaseManager sharedManager];
    dispatch_async([manager sensorQueue], ^{
        CBLView *view = [manager.cblDatabase viewNamed:@"sensorsBySystemId"];
        [view setMapBlock:MAPBLOCK({
            if ([doc[@"systemId"] isEqualToString:[peripheral systemId]]) {
                emit(doc[@"systemId"], doc);
            }
        }) version:@"1.0"];
        CBLQuery *query = [view createQuery];
        query.limit = 1;
        NSArray *rows = [[query run:nil] allObjects];
        if ([rows count]==0) {
            NSLog(@"New sensor for document with peripheral");
            Sensor *sensor = [Sensor newSensorInDatabase:manager.cblDatabase withPeripheral:peripheral];
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(sensor);
            });
        }
        else {
            CBLQueryRow *row = [rows objectAtIndex:0];
            NSLog(@"Get sensor for document with peripheral");
            Sensor *sensor = [Sensor sensorForDocument:row.document withPeripheral:peripheral];
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(sensor);
            });
        }
    });
}

+ (void)storedSensorsWithCompletionHandler:(void(^)(NSMutableArray *item))completionHandler
{
    DatabaseManager *manager = [DatabaseManager sharedManager];
    dispatch_async([manager sensorQueue], ^{
        CBLView *view = [manager.cblDatabase viewNamed:@"storedSensors"];
        NSString *const kSensorValueType = NSStringFromClass([SensorValue class]);
        [view setMapBlock:MAPBLOCK({
            if (![doc[@"type"] isEqualToString:kSensorValueType]) {
                emit(doc[@"systemId"], doc);
            }
        }) version:@"1.3"];
        CBLQuery *query = [view createQuery];
        CBLQueryEnumerator *queryEnumerator = [query run:nil];
        NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:[queryEnumerator count]];
        NSLog(@"Get stored sensors");
        for (CBLQueryRow *row in queryEnumerator) {
            [mutableArray addObject:[Sensor sensorForDocument:row.document]];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(mutableArray);
        });
    });
}

+ (void)saveNewSensorValueWithSensor:(Sensor *)sensor valueType:(SensorValueType)valueType value:(double)value
{
    DatabaseManager *manager = [DatabaseManager sharedManager];
    NSLog(@"Save new value for sensor");
    dispatch_async([manager sensorQueue], ^{
        SensorValue *sensorValue = [[SensorValue alloc] initWithNewDocumentInDatabase:manager.cblDatabase];
        [sensorValue setValue:NSStringFromClass([SensorValue class]) ofProperty:@"type"];
        sensorValue.date = [NSDate date];
        sensorValue.sensor = sensor;
        sensorValue.valueType = valueType;
        sensorValue.value = value;
        [sensorValue save:nil];
    });
}

+ (void)lastSensorValuesForSensor:(Sensor*)sensor andType:(SensorValueType)type completionHandler:(void(^)(NSMutableArray *item))completionHandler
{
    DatabaseManager *manager = [DatabaseManager sharedManager];
    dispatch_async([manager sensorQueue], ^{
        CBLView *view = [manager.cblDatabase viewNamed:@"sensorValuesByDate"];
        if (!view.mapBlock) {
            NSString* const kSensorValueType = NSStringFromClass([SensorValue class]);
            [view setMapBlock: MAPBLOCK({
                if ([doc[@"type"] isEqualToString:kSensorValueType]) {
                    id date = doc[@"date"];
                    NSString *sensor = doc[@"sensor"];
                    NSNumber *typeNumber = doc[@"valueType"];
                    emit(@[sensor, typeNumber, date], doc);
                }
            }) version: @"1.1"];
        }
    
        CBLQuery *query = [view createQuery];
        query.limit = 16;
        query.descending = YES;
        NSString *myListId = sensor.document.documentID;
        NSNumber *typeNumber = [NSNumber numberWithInt:type];
        query.startKey = @[myListId, typeNumber, @{}];
        query.endKey = @[myListId, typeNumber];
        
        NSLog(@"Get last sensor values");

        CBLQueryEnumerator *queryEnumerator = [query run:nil];
        NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:[queryEnumerator count]];
        for (CBLQueryRow *row in queryEnumerator) {
            NSObject *value = row.document[@"value"];
            if (value) {
                [mutableArray addObject:value];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(mutableArray);
        });
    });
}

@end
