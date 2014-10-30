//
//  DemoSensor.h
//  Wimoto
//
//  Created by Alena Kokareva on 30.10.14.
//
//

#import "Sensor.h"

@interface DemoSensor : Sensor

@property (nonatomic, strong) NSTimer *timer;

- (void)sensorUpdate;

@end
