//
//  ThermoSensor.h
//  Wimoto
//
//  Created by Danny Kokarev on 25.12.13.
//
//

#import "Sensor.h"

#define OBSERVER_KEY_PATH_THERMO_SENSOR_IR_TEMP                         @"irTemp"
#define OBSERVER_KEY_PATH_THERMO_SENSOR_PROBE_TEMP                      @"probeTemp"

#define OBSERVER_KEY_PATH_THERMO_SENSOR_IR_TEMP_ALARM_STATE             @"irTempAlarmState"
#define OBSERVER_KEY_PATH_THERMO_SENSOR_PROBE_TEMP_ALARM_STATE          @"probeTempAlarmState"

#define OBSERVER_KEY_PATH_THERMO_SENSOR_IR_TEMP_ALARM_LOW               @"irTempAlarmLow"
#define OBSERVER_KEY_PATH_THERMO_SENSOR_IR_TEMP_ALARM_HIGH              @"irTempAlarmHigh"

#define OBSERVER_KEY_PATH_THERMO_SENSOR_PROBE_TEMP_ALARM_LOW            @"probeTempAlarmLow"
#define OBSERVER_KEY_PATH_THERMO_SENSOR_PROBE_TEMP_ALARM_HIGH           @"probeTempAlarmHigh"

@interface ThermoSensor : Sensor

@property (nonatomic) float irTemp;
@property (nonatomic) float probeTemp;

@property (nonatomic) AlarmState irTempAlarmState;
@property (nonatomic) AlarmState probeTempAlarmState;

@property (nonatomic) float irTempAlarmLow;
@property (nonatomic) float irTempAlarmHigh;

@property (nonatomic) float probeTempAlarmLow;
@property (nonatomic) float probeTempAlarmHigh;

@end
