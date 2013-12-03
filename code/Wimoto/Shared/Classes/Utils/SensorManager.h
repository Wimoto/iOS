//
//  SensorManager.h
//  Wimoto
//
//  Created by MC700 on 12/3/13.
//
//

#import "Sensor.h"

@interface SensorManager : NSObject

+ (NSArray*)getSensors;
+ (void)addSensor:(Sensor*)sensor;

@end
