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

#define OBSERVER_KEY_PATH_CLIMATE_SENSOR_TEMPERATURE_ALARM_STATE            @"temperatureAlarmState"
#define OBSERVER_KEY_PATH_CLIMATE_SENSOR_HUMIDITY_ALARM_STATE               @"humidityAlarmState"
#define OBSERVER_KEY_PATH_CLIMATE_SENSOR_LIGHT_ALARM_STATE                  @"lightAlarmState"

#define OBSERVER_KEY_PATH_CLIMATE_SENSOR_TEMPERATURE_ALARM_LOW              @"temperatureAlarmLow"
#define OBSERVER_KEY_PATH_CLIMATE_SENSOR_TEMPERATURE_ALARM_HIGH             @"temperatureAlarmHigh"

#define OBSERVER_KEY_PATH_CLIMATE_SENSOR_HUMIDITY_ALARM_LOW                 @"humidityAlarmLow"
#define OBSERVER_KEY_PATH_CLIMATE_SENSOR_HUMIDITY_ALARM_HIGH                @"humidityAlarmHigh"

#define OBSERVER_KEY_PATH_CLIMATE_SENSOR_LIGHT_ALARM_LOW                    @"lightAlarmLow"
#define OBSERVER_KEY_PATH_CLIMATE_SENSOR_LIGHT_ALARM_HIGH                   @"lightAlarmHigh"

@interface ClimateSensor : Sensor

@property (nonatomic) float temperature;
@property (nonatomic) float humidity;
@property (nonatomic) float light;

@property (nonatomic) AlarmState temperatureAlarmState;
@property (nonatomic) AlarmState humidityAlarmState;
@property (nonatomic) AlarmState lightAlarmState;

@property (nonatomic) float temperatureAlarmLow;
@property (nonatomic) float temperatureAlarmHigh;

@property (nonatomic) float humidityAlarmLow;
@property (nonatomic) float humidityAlarmHigh;

@property (nonatomic) float lightAlarmLow;
@property (nonatomic) float lightAlarmHigh;

@end
