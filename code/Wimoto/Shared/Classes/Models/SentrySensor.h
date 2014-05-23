//
//  SentrySensor.h
//  Wimoto
//
//  Created by Danny Kokarev on 25.12.13.
//
//

#import "Sensor.h"

#define OBSERVER_KEY_PATH_SENTRY_SENSOR_ACCELEROMETER                       @"accelerometer"
#define OBSERVER_KEY_PATH_SENTRY_SENSOR_PASSIVE_INFRARED                    @"pasInfrared"

@interface SentrySensor : Sensor

@property (nonatomic) float accelerometer;
@property (nonatomic) float pasInfrared;

@property (nonatomic) AlarmState accelerometerAlarmState;
@property (nonatomic) AlarmState pasInfraredAlarmState;

@end
