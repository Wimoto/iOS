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

@property (nonatomic) AlarmState soilTempAlarmState;
@property (nonatomic) AlarmState soilMoistureAlarmState;
@property (nonatomic) AlarmState lightAlarmState;

@property (nonatomic, strong) AlarmService *soilTempAlarm;
@property (nonatomic, strong) AlarmService *soilMoistureAlarm;
@property (nonatomic, strong) AlarmService *lightAlarm;

- (void)enableAlarm:(BOOL)enable forCharacteristicWithUUIDString:(NSString *)UUIDString;
- (CGFloat)minimumAlarmValueForCharacteristicWithUUIDString:(NSString *)UUIDString;
- (CGFloat)maximumAlarmValueForCharacteristicWithUUIDString:(NSString *)UUIDString;
- (void)writeHighAlarmValue:(int)high forCharacteristicWithUUIDString:(NSString *)UUIDString;
- (void)writeLowAlarmValue:(int)low forCharacteristicWithUUIDString:(NSString *)UUIDString;

@end
