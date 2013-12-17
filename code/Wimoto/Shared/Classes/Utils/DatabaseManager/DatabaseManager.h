//
//  DatabaseManager.h
//  Wimoto
//
//  Created by MC700 on 12/16/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@class Sensor, CBPeripheral;

@interface DatabaseManager : NSObject

+ (Sensor*)sensorWithPeripheral:(CBPeripheral*)peripheral;
+ (NSArray*)storedSensors;

@end
