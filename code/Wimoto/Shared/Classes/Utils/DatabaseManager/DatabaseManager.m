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

#import "SensorValue.h"

@interface DatabaseManager ()

@property (nonatomic, strong) CBLDatabase *cblDatabase;

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
        _cblDatabase = [[CBLManager sharedInstance] createDatabaseNamed:@"wimoto"
                                                                  error:nil];
        
        CBLModelFactory *modelFactory = [CBLModelFactory sharedInstance];
        [modelFactory registerClass:[TestSensor class] forDocumentType:NSStringFromClass([TestSensor class])];
        [modelFactory registerClass:[ClimateSensor class] forDocumentType:NSStringFromClass([ClimateSensor class])];
        [modelFactory registerClass:[SensorValue class] forDocumentType:NSStringFromClass([SensorValue class])];
    }
    return self;
}

+ (Sensor*)sensorInstanceWithPeripheral:(CBPeripheral*)peripheral {
    DatabaseManager *manager = [DatabaseManager sharedManager];
    
    CBLView *view = [manager.cblDatabase viewNamed:@"sensorsBySystemId"];
    
    [view setMapBlock:MAPBLOCK({
        if ([doc[@"systemId"] isEqualToString:[peripheral systemId]]) {
            emit(doc[@"systemId"], doc);
        }
    }) version:@"1.0"];
    
    CBLQuery *query = [view query];
    query.limit = 1;
    
    NSArray *rows = [query.rows allObjects];
    
    if ([rows count]==0) {
        return [Sensor newSensorInDatabase:manager.cblDatabase withPeripheral:peripheral];
    } else {
        CBLQueryRow *row = [rows objectAtIndex:0];
        return [Sensor sensorForDocument:row.document withPeripheral:peripheral];
    }
}

+ (NSArray*)storedSensors {
    DatabaseManager *manager = [DatabaseManager sharedManager];
    
    CBLView *view = [manager.cblDatabase viewNamed:@"storedSensors"];
    
    NSString* const kSensorValueType = NSStringFromClass([SensorValue class]);
    [view setMapBlock:MAPBLOCK({
        if (![doc[@"type"] isEqualToString:kSensorValueType]) {
            emit(doc[@"systemId"], doc);
        }
    }) version:@"1.3"];
    
    CBLQuery *query = [view query];
    
    NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:[query.rows count]];
    for (CBLQueryRow *row in query.rows) {
        [mutableArray addObject:[Sensor sensorForDocument:row.document]];
    }
    
    return mutableArray;
}

+ (SensorValue*)sensorValueInstance {
    DatabaseManager *manager = [DatabaseManager sharedManager];

    SensorValue *sensorValue = [[SensorValue alloc] initWithNewDocumentInDatabase:manager.cblDatabase];
    [sensorValue setValue:NSStringFromClass([SensorValue class]) ofProperty:@"type"];
    sensorValue.date = [NSDate date];
    return sensorValue;

}

+ (NSArray*)lastSensorValuesForSensor:(Sensor*)sensor andType:(SensorValueType)type {
    DatabaseManager *manager = [DatabaseManager sharedManager];
    
    CBLView* view = [manager.cblDatabase viewNamed: @"sensorValuesByDate"];
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
    
    CBLQuery *query = [view query];
    query.limit = 16;
    query.descending = YES;
    NSString* myListId = sensor.document.documentID;
    NSNumber *typeNumber = [NSNumber numberWithInt:type];
    query.startKey = @[myListId, typeNumber, @{}];
    query.endKey = @[myListId, typeNumber];

    NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:[query.rows count]];
    for (CBLQueryRow *row in query.rows) {
        [mutableArray addObject:row.document[@"value"]];
    }
    
    return mutableArray;
}

@end
