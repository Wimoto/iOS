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
    }
    return self;
}

+ (Sensor*)sensorWithPeripheral:(CBPeripheral*)peripheral {
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
    
    [view setMapBlock:MAPBLOCK({
        emit(doc[@"systemId"], doc);
    }) version:@"1.0"];
    
    CBLQuery *query = [view query];
    
    NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:[query.rows count]];
    for (CBLQueryRow *row in query.rows) {
        [mutableArray addObject:[Sensor sensorForDocument:row.document]];
    }
    
    return mutableArray;
}

@end
