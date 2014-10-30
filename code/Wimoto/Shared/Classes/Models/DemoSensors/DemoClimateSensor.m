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
        self.demo = YES;
        self.name = @"Demo Climate";
        self.uniqueIdentifier = BLE_CLIMATE_DEMO_MODEL;
    }
    return self;
}

- (PeripheralType)type {
    return kPeripheralTypeClimateDemo;
}

- (void)sensorUpdate {
    self.temperature = arc4random()%50;
    self.humidity = arc4random()%100;
    self.light = arc4random()%120;
    [self.entity saveNewValueWithType:kValueTypeTemperature value:_temperature];
    [self.entity saveNewValueWithType:kValueTypeHumidity value:_humidity];
    [self.entity saveNewValueWithType:kValueTypeLight value:_light];
}

@end
