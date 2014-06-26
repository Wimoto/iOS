//
//  DatabaseManager.h
//  Wimoto
//
//  Created by MC700 on 12/16/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "SensorValue.h"

@class SensorEntity, SensorValue;

@interface DatabaseManager : NSObject

+ (void)sensorEntityWithSensor:(Sensor*)sensor completionHandler:(void(^)(SensorEntity *sensorEntity))completionHandler;
+ (void)getSensorEntities:(void(^)(NSArray *resultsArray))completionHandler;

+ (void)lastSensorValuesForSensor:(Sensor*)sensor andType:(SensorValueType)type completionHandler:(void(^)(NSMutableArray *item))completionHandler;
+ (void)saveNewSensorValueWithSensor:(Sensor *)sensor valueType:(SensorValueType)valueType value:(double)value;

+ (dispatch_queue_t)getSensorQueue;

@end
