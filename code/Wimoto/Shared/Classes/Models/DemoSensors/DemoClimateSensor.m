//
//  DemoClimateSensor.m
//  Wimoto
//
//  Created by Alena Kokareva on 30.10.14.
//
//

#import "DemoClimateSensor.h"

@interface DemoClimateSensor ()

@property (nonatomic, strong) NSTimer *timer;

- (void)sensorUpdate;

@end

@implementation DemoClimateSensor

- (id)init {
    self = [super init];
    if (self) {
        self.name = @"Demo Climate";
        self.uniqueIdentifier = BLE_CLIMATE_DEMO_MODEL;
        _temperature = 22.0;
        _humidity = 50.0;
        _light = 60.0;
    }
    return self;
}

- (void)setEntity:(SensorEntity *)entity {
    _temperature = 22.0;
    _humidity = 50.0;
    _light = 60.0;
    [super setEntity:entity];
}

- (PeripheralType)type {
    return kPeripheralTypeClimateDemo;
}

- (void)sensorUpdate {
    int temperatureStep = arc4random()%4 + 1 - 4/2;
    if ((_temperature + temperatureStep) < (-5)) {
        self.temperature+=2.0;
    }
    else if ((_temperature + temperatureStep) > 50) {
        self.temperature-=2.0;
    }
    else {
        self.temperature+=temperatureStep;
    }
    
    int humidityStep = arc4random()%4 + 1 - 4/2;
    if ((_humidity + humidityStep) < (0)) {
        self.humidity+=2.0;
    }
    else if ((_humidity + humidityStep) > 100) {
        self.humidity-=2.0;
    }
    else {
        self.humidity+=humidityStep;
    }
    
    int lightStep = arc4random()%4 + 1 - 4/2;
    if ((_light + lightStep) < 0) {
        self.light+=2.0;
    }
    else if ((_light + lightStep) > 200) {
        self.light-=2.0;
    }
    else {
        self.light+=lightStep;
    }
    
    [self.entity saveNewValueWithType:kValueTypeTemperature value:_temperature];
    [self.entity saveNewValueWithType:kValueTypeHumidity value:_humidity];
    [self.entity saveNewValueWithType:kValueTypeLight value:_light];
}

@end
