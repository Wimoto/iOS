//
//  DatabaseManager.m
//  Wimoto
//
//  Created by MC700 on 12/16/13.
//
//

#import "DatabaseManager.h"

#import <Couchbaselite/CouchbaseLite.h>

#import "SensorEntity.h"
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
        _sensorQueue = dispatch_queue_create("com.wimoto.sensor", DISPATCH_QUEUE_SERIAL);
        
        _cblDatabase = [[CBLManager sharedInstance] databaseNamed:@"wimoto" error:nil];
    }
    return self;
}

+ (dispatch_queue_t)getSensorQueue
{
    return [[DatabaseManager sharedManager] sensorQueue];
}

+ (void)sensorEntityWithSensor:(Sensor*)sensor completionHandler:(void(^)(SensorEntity *sensorEntity))completionHandler
{
//    DatabaseManager *manager = [DatabaseManager sharedManager];
//    
//    dispatch_async([manager sensorQueue], ^{
//        CBLView *view = [manager.cblDatabase viewNamed:@"sensorsBySystemId"];
//        [view setMapBlock:MAPBLOCK({
//            if ([doc[@"systemId"] isEqualToString:sensor.uniqueIdentifier]) {
//                emit(doc[@"systemId"], doc);
//            }
//        }) version:@"1.0"];
//        
//        CBLQuery *query = [view createQuery];
//        query.limit = 1;
//        
//        NSArray *rows = [[query run:nil] allObjects];
//        if ([rows count]==0) {
//            NSLog(@"New sensor for document with peripheral");
//            SensorEntity *sensorEntity = [[SensorEntity alloc] initWithNewDocumentInDatabase:manager.cblDatabase];
//            sensorEntity.sensor = sensor;
//            [sensorEntity save:nil];
//
//            dispatch_async(dispatch_get_main_queue(), ^{
//                completionHandler(sensorEntity);
//            });
//        }
//        else {
//            NSLog(@"Get sensor for document with peripheral");
//            
//            CBLQueryRow *row = [rows objectAtIndex:0];
//            SensorEntity *sensorEntity = (SensorEntity*)[CBLModel modelForDocument:row.document];
//            sensorEntity.sensor = sensor;
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                completionHandler(sensorEntity);
//            });
//        }
//    });
}

+ (void)getSensorEntities:(void(^)(NSArray *resultsArray))completionHandler {
//    DatabaseManager *manager = [DatabaseManager sharedManager];
//    dispatch_async([manager sensorQueue], ^{
//        CBLView *view = [manager.cblDatabase viewNamed:@"sensors"];
//        [view setMapBlock:MAPBLOCK({
//            emit(doc[@"systemId"], doc);
//        }) version:@"1.0"];
//        
//        CBLQuery *query = [view createQuery];
//        CBLQueryEnumerator *queryEnumerator = [query run:nil];
//        
//        NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:[queryEnumerator count]];
//        for (CBLQueryRow *row in queryEnumerator) {
//            SensorEntity *sensorEntity = [SensorEntity modelForDocument:row.document];
//            [mutableArray addObject:sensorEntity];
//        }
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            completionHandler([NSArray arrayWithArray:mutableArray]);
//        });
//    });
}

+ (void)saveNewSensorValueWithSensor:(Sensor *)sensor valueType:(SensorValueType)valueType value:(double)value
{
//    DatabaseManager *manager = [DatabaseManager sharedManager];
//    NSLog(@"Save new value for sensor");
//    dispatch_async([manager sensorQueue], ^{
//        SensorValue *sensorValue = [[SensorValue alloc] initWithNewDocumentInDatabase:manager.cblDatabase];
//        [sensorValue setValue:NSStringFromClass([SensorValue class]) ofProperty:@"type"];
//        sensorValue.date = [NSDate date];
//        sensorValue.valueType = valueType;
//        sensorValue.value = value;
//        [sensorValue save:nil];
//    });
}

+ (void)lastSensorValuesForSensor:(Sensor*)sensor andType:(SensorValueType)type completionHandler:(void(^)(NSMutableArray *item))completionHandler
{
//    DatabaseManager *manager = [DatabaseManager sharedManager];
//    dispatch_async([manager sensorQueue], ^{
//        CBLView *view = [manager.cblDatabase viewNamed:@"sensorValuesByDate"];
//        if (!view.mapBlock) {
//            NSString* const kSensorValueType = NSStringFromClass([SensorValue class]);
//            [view setMapBlock: MAPBLOCK({
//                if ([doc[@"type"] isEqualToString:kSensorValueType]) {
//                    id date = doc[@"date"];
//                    NSString *sensor = doc[@"sensor"];
//                    NSNumber *typeNumber = doc[@"valueType"];
//                    emit(@[sensor, typeNumber, date], doc);
//                }
//            }) version: @"1.1"];
//        }
//    
//        CBLQuery *query = [view createQuery];
//        query.limit = 16;
//        query.descending = YES;
//        NSString *myListId = sensor.document.documentID;
//        NSNumber *typeNumber = [NSNumber numberWithInt:type];
//        query.startKey = @[myListId, typeNumber, @{}];
//        query.endKey = @[myListId, typeNumber];
//        
//        NSLog(@"Get last sensor values");
//
//        CBLQueryEnumerator *queryEnumerator = [query run:nil];
//        NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:[queryEnumerator count]];
//        for (CBLQueryRow *row in queryEnumerator) {
//            NSObject *value = row.document[@"value"];
//            if (value) {
//                [mutableArray addObject:value];
//            }
//        }
//        dispatch_async(dispatch_get_main_queue(), ^{
//            completionHandler(mutableArray);
//        });
//    });
}

@end
