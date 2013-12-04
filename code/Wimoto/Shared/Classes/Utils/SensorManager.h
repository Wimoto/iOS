//
//  SensorManager.h
//  Wimoto
//
//  Created by MC700 on 12/3/13.
//
//

#import "Sensor.h"

@interface SensorManager : NSObject

+ (NSMutableArray*)getSensors;
+ (void)addSensor:(Sensor*)sensor;
+ (void)setSensores:(NSArray *)array;

@end
