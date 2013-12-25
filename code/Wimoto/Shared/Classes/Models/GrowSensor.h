//
//  GrowSensor.h
//  Wimoto
//
//  Created by Danny Kokarev on 25.12.13.
//
//

#import "Sensor.h"

#define OBSERVER_KEY_PATH_GROW_SENSOR_SOIL_TEMPERATURE            @"soilTemperature"
#define OBSERVER_KEY_PATH_GROW_SENSOR_SOIL_MOISTURE               @"soilMoisture"
#define OBSERVER_KEY_PATH_GROW_SENSOR_LIGHT                       @"light"

@interface GrowSensor : Sensor

@property (nonatomic) float soilTemperature;
@property (nonatomic) float soilMoisture;
@property (nonatomic) float light;

@end
