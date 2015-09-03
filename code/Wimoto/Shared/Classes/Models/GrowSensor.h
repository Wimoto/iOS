//
//  GrowSensor.h
//  Wimoto
//
//  Created by Danny Kokarev on 25.12.13.
//
//

#import "Sensor.h"

#define OBSERVER_KEY_PATH_GROW_SENSOR_SOIL_TEMPERATURE                          @"soilTemperature"
#define OBSERVER_KEY_PATH_GROW_SENSOR_SOIL_MOISTURE                             @"soilMoisture"
#define OBSERVER_KEY_PATH_GROW_SENSOR_LIGHT                                     @"light"

#define OBSERVER_KEY_PATH_GROW_SENSOR_SOIL_TEMPERATURE_ALARM_STATE              @"soilTempAlarmState"
#define OBSERVER_KEY_PATH_GROW_SENSOR_SOIL_MOISTURE_ALARM_STATE                 @"soilMoistureAlarmState"
#define OBSERVER_KEY_PATH_GROW_SENSOR_LIGHT_ALARM_STATE                         @"lightAlarmState"

#define OBSERVER_KEY_PATH_GROW_SENSOR_SOIL_TEMPERATURE_ALARM_LOW                @"soilTemperatureAlarmLow"
#define OBSERVER_KEY_PATH_GROW_SENSOR_SOIL_TEMPERATURE_ALARM_HIGH               @"soilTemperatureAlarmHigh"

#define OBSERVER_KEY_PATH_GROW_SENSOR_SOIL_MOISTURE_ALARM_LOW                   @"soilMoistureAlarmLow"
#define OBSERVER_KEY_PATH_GROW_SENSOR_SOIL_MOISTURE_ALARM_HIGH                  @"soilMoistureAlarmHigh"

#define OBSERVER_KEY_PATH_GROW_SENSOR_LIGHT_ALARM_LOW                           @"lightAlarmLow"
#define OBSERVER_KEY_PATH_GROW_SENSOR_LIGHT_ALARM_HIGH                          @"lightAlarmHigh"

#define OBSERVER_KEY_PATH_GROW_SENSOR_CALIBRATION_STATE                         @"calibrationState"

typedef enum {
    kGrowCalibrationStateDefault = 0,
    kGrowCalibrationStateLowValueStarted,
    kGrowCalibrationStateLowValueInProgress,
    kGrowCalibrationStateLowValueFinished,
    kGrowCalibrationStateHighValueStarted,
    kGrowCalibrationStateHighValueInProgress,
    kGrowCalibrationStateHighValueFinished,
    kGrowCalibrationStateCompleted
} GrowCalibrationState;

@interface GrowSensor : Sensor

@property (nonatomic) float soilTemperature;
@property (nonatomic) float soilMoisture;
@property (nonatomic) float light;

@property (nonatomic) AlarmState soilTempAlarmState;
@property (nonatomic) AlarmState soilMoistureAlarmState;
@property (nonatomic) AlarmState lightAlarmState;

@property (nonatomic) float soilTemperatureAlarmLow;
@property (nonatomic) float soilTemperatureAlarmHigh;

@property (nonatomic) float soilMoistureAlarmLow;
@property (nonatomic) float soilMoistureAlarmHigh;

@property (nonatomic) float lightAlarmLow;
@property (nonatomic) float lightAlarmHigh;

@property (nonatomic) GrowCalibrationState calibrationState;

@end
