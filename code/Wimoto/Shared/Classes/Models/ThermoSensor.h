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

@interface ThermoSensor : Sensor

@property (nonatomic) float irTemp;
@property (nonatomic) float probeTemp;

@end
