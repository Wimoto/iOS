//
//  WaterSensor.h
//  Wimoto
//
//  Created by MC700 on 12/23/13.
//
//

#import "Sensor.h"

#define OBSERVER_KEY_PATH_WATER_SENSOR_PRESENCE                                 @"presense"
#define OBSERVER_KEY_PATH_WATER_SENSOR_LEVEL                                    @"level"

#define OBSERVER_KEY_PATH_WATER_SENSOR_PRESENSE_ALARM_STATE                     @"presenseAlarmState"
#define OBSERVER_KEY_PATH_WATER_SENSOR_LEVEL_ALARM_STATE                        @"levelAlarmState"

#define OBSERVER_KEY_PATH_WATER_SENSOR_LEVEL_ALARM_LOW                          @"levelAlarmLow"
#define OBSERVER_KEY_PATH_WATER_SENSOR_LEVEL_ALARM_HIGH                         @"levelAlarmHigh"

@interface WaterSensor : Sensor

@property (nonatomic) BOOL presense;
@property (nonatomic) float level;

@property (nonatomic) AlarmState presenseAlarmState;
@property (nonatomic) AlarmState levelAlarmState;

@property (nonatomic) float levelAlarmLow;
@property (nonatomic) float levelAlarmHigh;

@end
