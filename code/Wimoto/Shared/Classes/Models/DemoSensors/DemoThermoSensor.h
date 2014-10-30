//
//  DemoThermoSensor.h
//  Wimoto
//
//  Created by Alena Kokareva on 30.10.14.
//
//

#import "DemoSensor.h"

@interface DemoThermoSensor : DemoSensor

@property (nonatomic) float irTemp;
@property (nonatomic) float probeTemp;

@property (nonatomic) AlarmState irTempAlarmState;
@property (nonatomic) AlarmState probeTempAlarmState;

@property (nonatomic) float irTempAlarmLow;
@property (nonatomic) float irTempAlarmHigh;

@property (nonatomic) float probeTempAlarmLow;
@property (nonatomic) float probeTempAlarmHigh;

@end
