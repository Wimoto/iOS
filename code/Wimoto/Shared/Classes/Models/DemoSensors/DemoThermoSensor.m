//
//  DemoThermoSensor.m
//  Wimoto
//
//  Created by MC700 on 30.10.14.
//
//

#import "DemoThermoSensor.h"

@interface DemoThermoSensor ()

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic) NSTimeInterval irTempAlarmTimeshot;
@property (nonatomic) NSTimeInterval probeTempAlarmTimeshot;

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
        
        self.irTempAlarmLow = 11.2;
        self.irTempAlarmHigh = 34.7;
        
        self.probeTempAlarmLow = 23.9;
        self.probeTempAlarmHigh = 35.5;
    }
    return self;
}

- (void)setEntity:(SensorEntity *)entity {
    _irTemp = 20.0;
    _probeTemp = 30.0;
    
    self.irTempAlarmLow = 11.2;
    self.irTempAlarmHigh = 34.7;
    
    self.probeTempAlarmLow = 23.9;
    self.probeTempAlarmHigh = 35.5;
    
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
    
    if ((self.irTempAlarmState == kAlarmStateEnabled)&&([[NSDate date] timeIntervalSinceReferenceDate]>(_irTempAlarmTimeshot+30))) {
        NSString *alarmType = nil;
        if (self.irTemp > self.irTempAlarmHigh) {
            alarmType = @"high value";
        }
        else if (self.irTemp < self.irTempAlarmLow) {
            alarmType = @"low value";
        }
        if (alarmType) {
            _irTempAlarmTimeshot = [[NSDate date] timeIntervalSinceReferenceDate];
            
            [super showAlarmNotification:[NSString stringWithFormat:@"%@ IR temperature %@", self.name, alarmType] forUuid:BLE_THERMO_CHAR_UUID_IR_TEMPERATURE_ALARM_SET];
        }
    }
    if ((self.probeTempAlarmState == kAlarmStateEnabled)&&([[NSDate date] timeIntervalSinceReferenceDate]>(_probeTempAlarmTimeshot+30))) {
        NSString *alarmType = nil;
        if (self.probeTemp > self.probeTempAlarmHigh) {
            alarmType = @"high value";
        }
        else if (self.probeTemp < self.probeTempAlarmLow) {
            alarmType = @"low value";
        }
        if (alarmType) {
            _probeTempAlarmTimeshot = [[NSDate date] timeIntervalSinceReferenceDate];
            
            [super showAlarmNotification:[NSString stringWithFormat:@"%@ probe temperature %@", self.name, alarmType] forUuid:BLE_THERMO_CHAR_UUID_PROBE_TEMPERATURE_ALARM_SET];
        }
    }
    
    [self.entity saveNewValueWithType:kValueTypeIRTemperature value:_irTemp];
    [self.entity saveNewValueWithType:kValueTypeProbeTemperature value:_probeTemp];
}

- (void)enableAlarm:(BOOL)enable forCharacteristicWithUUIDString:(NSString *)UUIDString {
    if ([UUIDString isEqual:BLE_THERMO_CHAR_UUID_IR_TEMPERATURE_ALARM_SET]) {
        self.irTempAlarmState = (enable)?kAlarmStateEnabled:kAlarmStateDisabled;
    } else if ([UUIDString isEqual:BLE_THERMO_CHAR_UUID_PROBE_TEMPERATURE_ALARM_SET]) {
        self.probeTempAlarmState = (enable)?kAlarmStateEnabled:kAlarmStateDisabled;
    }
}

@end
