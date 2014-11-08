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
        _irTemp = 20.0;
        _probeTemp = 30.0;
    }
    return self;
}

- (void)setEntity:(SensorEntity *)entity {
    _irTemp = 20.0;
    _probeTemp = 30.0;
    [super setEntity:entity];
}

- (PeripheralType)type {
    return kPeripheralTypeThermoDemo;
}

- (NSString *)codename {
    return @"Thermo";
}

- (void)sensorUpdate {
    int irTempStep = arc4random()%4 + 1 - 4/2;
    if ((_irTemp + irTempStep) < (-5)) {
        self.irTemp+=2.0;
    }
    else if ((_irTemp + irTempStep) > 50) {
        self.irTemp-=2.0;
    }
    else {
        self.irTemp+=irTempStep;
    }
    int probeTempStep = arc4random()%4 + 1 - 4/2;
    if ((_probeTemp + probeTempStep) < (-5)) {
        self.probeTemp+=2.0;
    }
    else if ((_probeTemp + probeTempStep) > 70) {
        self.probeTemp-=2.0;
    }
    else {
        self.probeTemp+=probeTempStep;
    }
    [self.entity saveNewValueWithType:kValueTypeIRTemperature value:_irTemp];
    [self.entity saveNewValueWithType:kValueTypeProbeTemperature value:_probeTemp];
}

@end
