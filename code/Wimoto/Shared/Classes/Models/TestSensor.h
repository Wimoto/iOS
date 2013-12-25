//
//  TestSensor.h
//  Wimoto
//
//  Created by MC700 on 12/13/13.
//
//

#import "Sensor.h"

@interface TestSensor : Sensor

@property (nonatomic) float temperature;
@property (nonatomic) float humidity;
@property (nonatomic) float light;

@property (nonatomic) BOOL presense;
@property (nonatomic) float level;

@property (nonatomic) float soilTemperature;
@property (nonatomic) float soilMoisture;

@property (nonatomic) float accelerometer;
@property (nonatomic) float pasInfrared;

@end
