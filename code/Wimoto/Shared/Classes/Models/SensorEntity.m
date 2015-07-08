//
//  SensorEntity.m
//  Wimoto
//
//  Created by MacBook on 24/06/2014.
//
//

#import "SensorEntity.h"
#import "NSString+Util.h"

@implementation SensorEntity

@dynamic name, systemId, lastActivityAt, sensorType;

- (void)saveNewName:(NSString *)nameString {
    if ([nameString isNotEmpty]) {
        self.name = nameString;
        dispatch_async([QueueManager databaseQueue], ^{
            [self save:nil];
        });
    }
}

- (void)saveNewValueWithType:(SensorValueType)valueType value:(double)value {
    dispatch_async([QueueManager databaseQueue], ^{
        ValueEntity *sensorValue = [[ValueEntity alloc] initWithNewDocumentInDatabase:self.database];
        [sensorValue setValue:NSStringFromClass([ValueEntity class]) ofProperty:@"type"];
        sensorValue.date = [NSDate date];
        sensorValue.valueType = valueType;
        sensorValue.value = value;
        sensorValue.sensor = self;
        [sensorValue save:nil];
        
        self.lastActivityAt = [NSDate date];
        [self save:nil];
    });
}

- (void)latestValuesWithType:(SensorValueType)valueType completionHandler:(void(^)(NSArray *result))completionHandler {
    dispatch_async([QueueManager databaseQueue], ^{
        CBLView *view = [self.database viewNamed:@"sensorValuesByDate"];
        if (!view.mapBlock) {
            NSString* const kValueEntityType = NSStringFromClass([ValueEntity class]);
            [view setMapBlock: MAPBLOCK({
                if ([doc[@"type"] isEqualToString:kValueEntityType]) {
                    id date = doc[@"date"];
                    NSString *sensor = doc[@"sensor"];
                    NSNumber *typeNumber = doc[@"valueType"];
                    emit(@[sensor, typeNumber, date], doc);
                }
            }) version: @"1.0"];
        }
        CBLQuery *query = [view createQuery];
        query.limit = 16;
        query.descending = YES;
        NSString *myListId = self.document.documentID;
        NSNumber *typeNumber = [NSNumber numberWithInt:valueType];
        query.startKey = @[myListId, typeNumber, @{}];
        query.endKey = @[myListId, typeNumber];
        
        //NSLog(@"Get last sensor values");
        
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

- (void)jsonRepresentation:(void(^)(NSData *result))completionHandler {
    dispatch_async([QueueManager databaseQueue], ^{
        CBLView *view = [self.database viewNamed:@"sensorValuesByDate"];
        if (!view.mapBlock) {
            NSString* const kValueEntityType = NSStringFromClass([ValueEntity class]);
            [view setMapBlock: MAPBLOCK({
                if ([doc[@"type"] isEqualToString:kValueEntityType]) {
                    id date = doc[@"date"];
                    NSString *sensor = doc[@"sensor"];
                    emit(@[sensor, date], doc);
                }
            }) version: @"1.0"];
        }
        CBLQuery *query = [view createQuery];
        query.descending = YES;
        NSString *myListId = self.document.documentID;
        query.startKey = @[myListId, @{}];
        query.endKey = @[myListId];
        
        //NSLog(@"Get last sensor values");
        
        CBLQueryEnumerator *queryEnumerator = [query run:nil];
        NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:[queryEnumerator count]];
        for (CBLQueryRow *row in queryEnumerator) {
            ValueEntity *valueEntity = [ValueEntity modelForDocument:row.document];
            if (valueEntity) {
                [mutableArray addObject:[valueEntity dictionaryRepresentation]];
            }
        }
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:mutableArray options:0 error:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(jsonData);
        });
    });
}

@end
