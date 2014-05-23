//
//  ClimateSensor.h
//  Wimoto
//
//  Created by MC700 on 12/13/13.
//
//

#import "Sensor.h"

#define OBSERVER_KEY_PATH_CLIMATE_SENSOR_TEMPERATURE            @"temperature"
#define OBSERVER_KEY_PATH_CLIMATE_SENSOR_HUMIDITY               @"humidity"
#define OBSERVER_KEY_PATH_CLIMATE_SENSOR_LIGHT                  @"light"

@interface ClimateSensor : Sensor

@property (nonatomic) float temperature;
@property (nonatomic) float humidity;
@property (nonatomic) float light;

@property (nonatomic) AlarmState temperatureAlarmState;
@property (nonatomic) AlarmState humidityAlarmState;
@property (nonatomic) AlarmState lightAlarmState;

@end
