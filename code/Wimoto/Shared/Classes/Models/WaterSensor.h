//
//  WaterSensor.h
//  Wimoto
//
//  Created by MC700 on 12/23/13.
//
//

#import "Sensor.h"

#define OBSERVER_KEY_PATH_WATER_SENSOR_PRESENCE             @"presense"
#define OBSERVER_KEY_PATH_WATER_SENSOR_LEVEL                @"level"

@interface WaterSensor : Sensor

@property (nonatomic) BOOL presense;
@property (nonatomic) float level;

@property (nonatomic) AlarmState presenseAlarmState;
@property (nonatomic) AlarmState levelAlarmState;

@property (nonatomic) float levelAlarmLow;
@property (nonatomic) float levelAlarmHigh;

@end
