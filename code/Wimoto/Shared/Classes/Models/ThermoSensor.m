//
//  ThermoSensor.m
//  Wimoto
//
//  Created by Danny Kokarev on 25.12.13.
//
//

#import "ThermoSensor.h"
#import "AppConstants.h"

@interface ThermoSensor ()

@property (nonatomic) NSTimeInterval irTempAlarmTimeshot;;
@property (nonatomic) NSTimeInterval probeTempAlarmTimeshot;

@end

@implementation ThermoSensor

@synthesize irTempAlarmLow = _irTempAlarmLow;
@synthesize irTempAlarmHigh = _irTempAlarmHigh;
@synthesize probeTempAlarmLow = _probeTempAlarmLow;
@synthesize probeTempAlarmHigh = _probeTempAlarmHigh;

- (PeripheralType)type {
    return kPeripheralTypeThermo;
}

- (NSString *)codename {
    return @"Thermo";
}

- (void)setIrTempAlarmState:(AlarmState)irTempAlarmState {
    _irTempAlarmState = irTempAlarmState;
    [super enableAlarm:(_irTempAlarmState == kAlarmStateEnabled) forCharacteristicWithUUIDString:BLE_THERMO_CHAR_UUID_IR_TEMPERATURE_ALARM_SET];
}

- (void)setProbeTempAlarmState:(AlarmState)probeTempAlarmState {
    _probeTempAlarmState = probeTempAlarmState;
    [super enableAlarm:(_probeTempAlarmState == kAlarmStateEnabled) forCharacteristicWithUUIDString:BLE_THERMO_CHAR_UUID_PROBE_TEMPERATURE_ALARM_SET];
}

- (void)setIrTempAlarmLow:(float)irTempAlarmLow {
    _irTempAlarmLow = irTempAlarmLow;
    [super writeAlarmValue:_irTempAlarmLow forCharacteristicWithUUIDString:BLE_THERMO_CHAR_UUID_IR_TEMPERATURE_ALARM_LOW_VALUE];
}

- (void)setIrTempAlarmHigh:(float)irTempAlarmHigh {
    _irTempAlarmHigh = irTempAlarmHigh;
    [super writeAlarmValue:_irTempAlarmHigh forCharacteristicWithUUIDString:BLE_THERMO_CHAR_UUID_IR_TEMPERATURE_ALARM_HIGH_VALUE];
}

- (void)setProbeTempAlarmLow:(float)probeTempAlarmLow {
    _probeTempAlarmLow = probeTempAlarmLow;
    [super writeAlarmValue:_probeTempAlarmLow forCharacteristicWithUUIDString:BLE_THERMO_CHAR_UUID_PROBE_TEMPERATURE_ALARM_LOW_VALUE];
}

- (void)setProbeTempAlarmHigh:(float)probeTempAlarmHigh {
    _probeTempAlarmHigh = probeTempAlarmHigh;
    [super writeAlarmValue:_probeTempAlarmHigh forCharacteristicWithUUIDString:BLE_THERMO_CHAR_UUID_PROBE_TEMPERATURE_ALARM_HIGH_VALUE];
}



- (void)writeAlarmValue:(int)alarmValue forCharacteristicWithUUIDString:(NSString *)UUIDString {
    int value = alarmValue;
    if ([UUIDString isEqualToString:BLE_THERMO_CHAR_UUID_IR_TEMPERATURE_ALARM_HIGH_VALUE] || [UUIDString isEqualToString:BLE_THERMO_CHAR_UUID_IR_TEMPERATURE_ALARM_LOW_VALUE] || [UUIDString isEqualToString:BLE_THERMO_CHAR_UUID_PROBE_TEMPERATURE_ALARM_HIGH_VALUE] || [UUIDString isEqualToString:BLE_THERMO_CHAR_UUID_PROBE_TEMPERATURE_ALARM_LOW_VALUE]) {
    }
    [super writeAlarmValue:value forCharacteristicWithUUIDString:UUIDString];
}

- (void)enableAlarm:(BOOL)enable forCharacteristicWithUUIDString:(NSString *)UUIDString {
    if ([UUIDString isEqual:BLE_THERMO_CHAR_UUID_IR_TEMPERATURE_ALARM_SET]) {
        self.irTempAlarmState = (enable)?kAlarmStateEnabled:kAlarmStateDisabled;
    } else if ([UUIDString isEqual:BLE_THERMO_CHAR_UUID_PROBE_TEMPERATURE_ALARM_SET]) {
        self.probeTempAlarmState = (enable)?kAlarmStateEnabled:kAlarmStateDisabled;
    }
}

#pragma mark - CBPeriferalDelegate

- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error {
    [super peripheral:aPeripheral didDiscoverServices:error];
    for (CBService *aService in aPeripheral.services) {
        NSLog(@"ThermoSensor didDiscoverServices %@", aService);
        if ([aService.UUID isEqual:[CBUUID UUIDWithString:BLE_THERMO_SERVICE_UUID_IR_TEMPERATURE]]) {
            [aPeripheral discoverCharacteristics:[NSArray arrayWithObjects:
                                                  [CBUUID UUIDWithString:BLE_THERMO_CHAR_UUID_IR_TEMPERATURE_CURRENT],
                                                  [CBUUID UUIDWithString:BLE_THERMO_CHAR_UUID_IR_TEMPERATURE_ALARM_LOW_VALUE],
                                                  [CBUUID UUIDWithString:BLE_THERMO_CHAR_UUID_IR_TEMPERATURE_ALARM_HIGH_VALUE],
                                                  [CBUUID UUIDWithString:BLE_THERMO_CHAR_UUID_IR_TEMPERATURE_ALARM_SET],
                                                  [CBUUID UUIDWithString:BLE_THERMO_CHAR_UUID_IR_TEMPERATURE_ALARM],
                                                  nil]
                                      forService:aService];
            
        } else if ([aService.UUID isEqual:[CBUUID UUIDWithString:BLE_THERMO_SERVICE_UUID_PROBE_TEMPERATURE]]) {
            [aPeripheral discoverCharacteristics:[NSArray arrayWithObjects:
                                                  [CBUUID UUIDWithString:BLE_THERMO_CHAR_UUID_PROBE_TEMPERATURE_CURRENT],
                                                  [CBUUID UUIDWithString:BLE_THERMO_CHAR_UUID_PROBE_TEMPERATURE_ALARM_LOW_VALUE],
                                                  [CBUUID UUIDWithString:BLE_THERMO_CHAR_UUID_PROBE_TEMPERATURE_ALARM_HIGH_VALUE],
                                                  [CBUUID UUIDWithString:BLE_THERMO_CHAR_UUID_PROBE_TEMPERATURE_ALARM_SET],
                                                  [CBUUID UUIDWithString:BLE_THERMO_CHAR_UUID_PROBE_TEMPERATURE_ALARM],
                                                  nil]
                                      forService:aService];
        }
    }
}

- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    [super peripheral:aPeripheral didDiscoverCharacteristicsForService:service error:error];
    if ([service.UUID isEqual:[CBUUID UUIDWithString:BLE_THERMO_SERVICE_UUID_IR_TEMPERATURE]]) {
        for (CBCharacteristic *aChar in service.characteristics) {
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_THERMO_CHAR_UUID_IR_TEMPERATURE_ALARM_LOW_VALUE]]||
                [aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_THERMO_CHAR_UUID_IR_TEMPERATURE_ALARM_HIGH_VALUE]]||
                [aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_THERMO_CHAR_UUID_IR_TEMPERATURE_ALARM_SET]]) {
                [aPeripheral readValueForCharacteristic:aChar];
            }
            else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_THERMO_CHAR_UUID_IR_TEMPERATURE_ALARM]]) {
                [aPeripheral setNotifyValue:YES forCharacteristic:aChar];
            }
            else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_THERMO_CHAR_UUID_IR_TEMPERATURE_CURRENT]]) {
                [aPeripheral readValueForCharacteristic:aChar];
                [aPeripheral setNotifyValue:YES forCharacteristic:aChar];
            }
        }
    }
    else if ([service.UUID isEqual:[CBUUID UUIDWithString:BLE_THERMO_SERVICE_UUID_PROBE_TEMPERATURE]]) {
        for (CBCharacteristic *aChar in service.characteristics) {
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_THERMO_CHAR_UUID_PROBE_TEMPERATURE_ALARM_LOW_VALUE]]||
                [aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_THERMO_CHAR_UUID_PROBE_TEMPERATURE_ALARM_HIGH_VALUE]]||
                [aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_THERMO_CHAR_UUID_PROBE_TEMPERATURE_ALARM_SET]]) {
                [aPeripheral readValueForCharacteristic:aChar];
            }
            else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_THERMO_CHAR_UUID_PROBE_TEMPERATURE_ALARM]]) {
                [aPeripheral setNotifyValue:YES forCharacteristic:aChar];
            }
            else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_THERMO_CHAR_UUID_PROBE_TEMPERATURE_CURRENT]]) {
                [aPeripheral readValueForCharacteristic:aChar];
                [aPeripheral setNotifyValue:YES forCharacteristic:aChar];
            }
            
        }
    }
}

- (void)peripheral:(CBPeripheral *)aPeripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        return;
    }
    [super peripheral:aPeripheral didUpdateValueForCharacteristic:characteristic error:error];
    NSLog(@"ThermoSensor didUpdateValueForCharacteristic start");
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_THERMO_CHAR_UUID_IR_TEMPERATURE_CURRENT]]) {
            self.irTemp = [self roundToOne:[[self sensorStringValueForCharacteristic:characteristic] floatValue]];
            [self.entity saveNewValueWithType:kValueTypeIRTemperature value:_irTemp];
        } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_THERMO_CHAR_UUID_PROBE_TEMPERATURE_CURRENT]]) {
            self.probeTemp = [self roundToOne:[self sensorValueForCharacteristic:characteristic]];
            [self.entity saveNewValueWithType:kValueTypeProbeTemperature value:_probeTemp];
        } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_THERMO_CHAR_UUID_IR_TEMPERATURE_ALARM_SET]]) {
            if (_irTempAlarmState == kAlarmStateUnknown) {
                self.irTempAlarmState = [self alarmStateForCharacteristic:characteristic];
            }
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_THERMO_CHAR_UUID_PROBE_TEMPERATURE_ALARM_SET]]) {
            if (_probeTempAlarmState == kAlarmStateUnknown) {
                self.probeTempAlarmState = [self alarmStateForCharacteristic:characteristic];
            }
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_THERMO_CHAR_UUID_IR_TEMPERATURE_ALARM]]) {
            if ((_irTempAlarmState == kAlarmStateEnabled)&&([[NSDate date] timeIntervalSinceReferenceDate]>(_irTempAlarmTimeshot+30))) {
                _irTempAlarmTimeshot = [[NSDate date] timeIntervalSinceReferenceDate];
                
                AlarmType alarmType = [super alarmTypeForCharacteristic:characteristic];
                [super showAlarmNotification:[NSString stringWithFormat:@"%@ ir temperature %@", self.name, (alarmType == kAlarmHigh)?@"high value":@"low value"] forUuid:BLE_THERMO_CHAR_UUID_IR_TEMPERATURE_ALARM_SET];
            }
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_THERMO_CHAR_UUID_PROBE_TEMPERATURE_ALARM]]) {
            if ((_probeTempAlarmState == kAlarmStateEnabled)&&([[NSDate date] timeIntervalSinceReferenceDate]>(_probeTempAlarmTimeshot+30))) {
                _probeTempAlarmTimeshot = [[NSDate date] timeIntervalSinceReferenceDate];
                
                AlarmType alarmType = [super alarmTypeForCharacteristic:characteristic];
                [super showAlarmNotification:[NSString stringWithFormat:@"%@ probe temperature %@", self.name, (alarmType == kAlarmHigh)?@"high value":@"low value"] forUuid:BLE_THERMO_CHAR_UUID_PROBE_TEMPERATURE_ALARM_SET];
            }
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_THERMO_CHAR_UUID_IR_TEMPERATURE_ALARM_LOW_VALUE]]) {
            self.irTempAlarmLow = [self alarmValueForCharacteristic:characteristic];
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_THERMO_CHAR_UUID_IR_TEMPERATURE_ALARM_HIGH_VALUE]]) {
            self.irTempAlarmHigh = [self alarmValueForCharacteristic:characteristic];
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_THERMO_CHAR_UUID_PROBE_TEMPERATURE_ALARM_LOW_VALUE]]) {
            self.probeTempAlarmLow = [self alarmValueForCharacteristic:characteristic];
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_THERMO_CHAR_UUID_PROBE_TEMPERATURE_ALARM_HIGH_VALUE]]) {
            self.probeTempAlarmHigh = [self alarmValueForCharacteristic:characteristic];
        }
    });
}

@end
