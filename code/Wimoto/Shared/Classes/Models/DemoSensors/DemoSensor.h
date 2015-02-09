//
//  DemoSensor.h
//  Wimoto
//
//  Created by MC700 on 30.10.14.
//
//

#import "Sensor.h"

@interface DemoSensor : Sensor

@property (nonatomic, strong) NSTimer *timer;

+ (id)demoSensorWithUniqueId:(NSString *)uniqueId;

- (void)showLocalNotificationWithMessage:(NSString *)message;
- (void)sensorUpdate;

@end
