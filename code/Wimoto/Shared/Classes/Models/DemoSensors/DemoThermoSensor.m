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

- (float)irTemp {
    return (self.tempMeasure == kTemperatureMeasureCelsius)?_irTemp:[self convertToFahrenheit:_irTemp];
}

- (float)probeTemp {
    return (self.tempMeasure == kTemperatureMeasureCelsius)?_probeTemp:[self convertToFahrenheit:_probeTemp];
}

- (float)irTempAlarmHigh {
    return (self.tempMeasure == kTemperatureMeasureCelsius)?_irTempAlarmHigh:[self convertToFahrenheit:_irTempAlarmHigh];
}

- (float)irTempAlarmLow {
    return (self.tempMeasure == kTemperatureMeasureCelsius)?_irTempAlarmLow:[self convertToFahrenheit:_irTempAlarmLow];
}

- (float)probeTempAlarmHigh {
    return (self.tempMeasure == kTemperatureMeasureCelsius)?_probeTempAlarmHigh:[self convertToFahrenheit:_probeTempAlarmHigh];
}

- (float)probeTempAlarmLow {
    return (self.tempMeasure == kTemperatureMeasureCelsius)?_probeTempAlarmLow:[self convertToFahrenheit:_probeTempAlarmLow];
}

- (void)sensorUpdate {
    int irTempStep = arc4random()%4 + 1 - 4/2;
    if ((_irTemp + irTempStep) < (-5)) {
        self.irTemp = _irTemp + 2.0;
    }
    else if ((_irTemp + irTempStep) > 50) {
        self.irTemp = _irTemp - 2.0;
    }
    else {
        self.irTemp = _irTemp + irTempStep;
    }
    int probeTempStep = arc4random()%4 + 1 - 4/2;
    if ((_probeTemp + probeTempStep) < (-5)) {
        self.probeTemp = _probeTemp + 2.0;
    }
    else if ((_probeTemp + probeTempStep) > 70) {
        self.probeTemp = _probeTemp - 2.0;
    }
    else {
        self.probeTemp = _probeTemp + probeTempStep;
    }
    [self.entity saveNewValueWithType:kValueTypeIRTemperature value:_irTemp];
    [self.entity saveNewValueWithType:kValueTypeProbeTemperature value:_probeTemp];
}

@end
