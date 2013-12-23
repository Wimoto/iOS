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

@class Sensor, SensorValue, CBPeripheral;

@interface DatabaseManager : NSObject

+ (Sensor*)sensorInstanceWithPeripheral:(CBPeripheral*)peripheral;
+ (NSArray*)storedSensors;

+ (SensorValue*)sensorValueInstance;
+ (NSArray*)lastSensorValuesForSensor:(Sensor*)sensor andType:(SensorValueType)type;

@end
