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

@class Sensor, SensorValue, CBPeripheral, AlarmValue;

@interface DatabaseManager : NSObject

+ (void)sensorInstanceWithPeripheral:(CBPeripheral*)peripheral completionHandler:(void(^)(Sensor *item))completionHandler;
+ (void)storedSensorsWithCompletionHandler:(void(^)(NSMutableArray *item))completionHandler;
+ (void)lastSensorValuesForSensor:(Sensor*)sensor andType:(SensorValueType)type completionHandler:(void(^)(NSMutableArray *item))completionHandler;
+ (void)saveNewSensorValueWithSensor:(Sensor *)sensor valueType:(SensorValueType)valueType value:(double)value;
+ (void)alarmInstanceWithSensor:(Sensor *)sensor valueType:(SensorValueType)valueType completionHandler:(void(^)(AlarmValue *item))completionHandler;
+ (void)saveAlarm:(AlarmValue *)alarm;

+ (dispatch_queue_t)getSensorQueue;

@end
