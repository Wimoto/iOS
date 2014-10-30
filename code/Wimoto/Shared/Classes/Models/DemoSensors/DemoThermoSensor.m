//
//  DemoThermoSensor.m
//  Wimoto
//
//  Created by Alena Kokareva on 30.10.14.
//
//

#import "DemoThermoSensor.h"

@interface DemoThermoSensor ()

@property (nonatomic, strong) NSTimer *timer;

- (void)sensorUpdate;

@end

@implementation DemoThermoSensor

- (id)init {
    self = [super init];
    if (self) {
        self.name = @"Demo Thermo";
        self.uniqueIdentifier = BLE_THERMO_DEMO_MODEL;
    }
    return self;
}

- (PeripheralType)type {
    return kPeripheralTypeThermoDemo;
}

- (void)sensorUpdate {
    self.irTemp = arc4random()%40;
    self.probeTemp = arc4random()%100;
    [self.entity saveNewValueWithType:kValueTypeIRTemperature value:_irTemp];
    [self.entity saveNewValueWithType:kValueTypeProbeTemperature value:_probeTemp];
}

@end
