//
//  SentrySensor.h
//  Wimoto
//
//  Created by Danny Kokarev on 25.12.13.
//
//

#import "Sensor.h"

#define OBSERVER_KEY_PATH_SENTRY_SENSOR_X                                   @"x"
#define OBSERVER_KEY_PATH_SENTRY_SENSOR_Y                                   @"y"
#define OBSERVER_KEY_PATH_SENTRY_SENSOR_Z                                   @"z"

#define OBSERVER_KEY_PATH_SENTRY_SENSOR_PASSIVE_INFRARED                    @"pasInfrared"

#define OBSERVER_KEY_PATH_SENTRY_SENSOR_ACCELEROMETER_ALARM_STATE           @"accelerometerAlarmState"
#define OBSERVER_KEY_PATH_SENTRY_SENSOR_PAS_INFRARED_ALARM_STATE            @"pasInfraredAlarmState"

#define OBSERVER_KEY_PATH_SENTRY_SENSOR_ACCELEROMETER_ALARM_ENABLED         @"accelerometerAlarmEnabledTime"
#define OBSERVER_KEY_PATH_SENTRY_SENSOR_ACCELEROMETER_ALARM_DISABLED        @"accelerometerAlarmDisabledTime"

#define OBSERVER_KEY_PATH_SENTRY_SENSOR_INFRARED_ALARM_ENABLED              @"infraredAlarmEnabledTime"
#define OBSERVER_KEY_PATH_SENTRY_SENSOR_INFRARED_ALARM_DISABLED             @"infraredAlarmDisabledTime"

@interface SentrySensor : Sensor

@property (nonatomic) float x;
@property (nonatomic) float y;
@property (nonatomic) float z;

@property (nonatomic) float pasInfrared;

@property (nonatomic) AlarmState accelerometerAlarmState;
@property (nonatomic) AlarmState pasInfraredAlarmState;

@property (nonatomic) NSDate *accelerometerAlarmEnabledTime;
@property (nonatomic) NSDate *accelerometerAlarmDisabledTime;

@property (nonatomic) NSDate *infraredAlarmEnabledTime;
@property (nonatomic) NSDate *infraredAlarmDisabledTime;

@end
