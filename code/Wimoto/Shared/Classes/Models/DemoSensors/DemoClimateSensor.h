//
//  DemoClimateSensor.h
//  Wimoto
//
//  Created by MC700 on 30.10.14.
//
//

#import "DemoSensor.h"

@interface DemoClimateSensor : DemoSensor

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

- (float)temperatureFromMeasure;
- (float)temperatureAlarmLowFromMeasure;
- (float)temperatureAlarmHighFromMeasure;

@end
