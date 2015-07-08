//
//  SensorEntity.h
//  Wimoto
//
//  Created by MacBook on 24/06/2014.
//
//

#import <Couchbaselite/Couchbaselite.h>
#import "CBPeripheral+Util.h"
#import "ValueEntity.h"
#import "QueueManager.h"

#define SENSOR_ENTITY_NAME                  @"name"

@interface SensorEntity : CBLModel

@property (copy) NSString   *name;
@property (copy) NSString   *systemId;
@property (copy) NSDate     *lastActivityAt;
@property (copy) NSNumber   *sensorType;

- (void)saveNewName:(NSString *)nameString;
- (void)saveNewValueWithType:(SensorValueType)valueType value:(double)value;
- (void)latestValuesWithType:(SensorValueType)valueType completionHandler:(void(^)(NSArray *result))completionHandler;

- (void)jsonRepresentation:(void(^)(NSData *result))completionHandler;

@end
