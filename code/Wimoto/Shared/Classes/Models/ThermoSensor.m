//
//  ThermoSensor.m
//  Wimoto
//
//  Created by Danny Kokarev on 25.12.13.
//
//

#import "ThermoSensor.h"
#import "DatabaseManager.h"

@implementation ThermoSensor

#pragma mark - CBPeriferalDelegate

- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error {
    for (CBService *aService in aPeripheral.services) {
        NSLog(@"ThermoSensor didDiscoverServices %@", aService);
        if ([aService.UUID isEqual:[CBUUID UUIDWithString:BLE_THERMO_SERVICE_UUID_IR_TEMPERATURE]]) {
            [aPeripheral discoverCharacteristics:[NSArray arrayWithObjects:
                                                  [CBUUID UUIDWithString:BLE_THERMO_CHAR_UUID_IR_TEMPERATURE_CURRENT],
                                                  [CBUUID UUIDWithString:BLE_THERMO_SERVICE_UUID_IR_TEMPERATURE_ALARM_LOW_VALUE],
                                                  [CBUUID UUIDWithString:BLE_THERMO_SERVICE_UUID_IR_TEMPERATURE_ALARM_HIGH_VALUE],
                                                  [CBUUID UUIDWithString:BLE_THERMO_SERVICE_UUID_IR_TEMPERATURE_ALARM_SET],
                                                  [CBUUID UUIDWithString:BLE_THERMO_SERVICE_UUID_IR_TEMPERATURE_ALARM],
                                                  nil]
                                      forService:aService];
            
        } else if ([aService.UUID isEqual:[CBUUID UUIDWithString:BLE_THERMO_SERVICE_UUID_PROBE_TEMPERATURE]]) {
            [aPeripheral discoverCharacteristics:[NSArray arrayWithObjects:
                                                  [CBUUID UUIDWithString:BLE_THERMO_CHAR_UUID_PROBE_TEMPERATURE_CURRENT],
                                                  [CBUUID UUIDWithString:BLE_THERMO_SERVICE_UUID_PROBE_TEMPERATURE_ALARM_LOW_VALUE],
                                                  [CBUUID UUIDWithString:BLE_THERMO_SERVICE_UUID_PROBE_TEMPERATURE_ALARM_HIGH_VALUE],
                                                  [CBUUID UUIDWithString:BLE_THERMO_SERVICE_UUID_PROBE_TEMPERATURE_ALARM_SET],
                                                  [CBUUID UUIDWithString:BLE_THERMO_SERVICE_UUID_PROBE_TEMPERATURE_ALARM],
                                                  nil]
                                      forService:aService];
        }
    }
}

- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if ([service.UUID.UUIDString isEqualToString:BLE_THERMO_SERVICE_UUID_IR_TEMPERATURE]) {
        for (CBCharacteristic *aChar in service.characteristics) {
            if (([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_THERMO_CHAR_UUID_IR_TEMPERATURE_CURRENT]])||
                ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_THERMO_SERVICE_UUID_IR_TEMPERATURE_ALARM_LOW_VALUE]])||
                ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_THERMO_SERVICE_UUID_IR_TEMPERATURE_ALARM_HIGH_VALUE]])||
                ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_THERMO_SERVICE_UUID_IR_TEMPERATURE_ALARM_SET]])||
                ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_THERMO_SERVICE_UUID_IR_TEMPERATURE_ALARM]]))
            {
                [aPeripheral readValueForCharacteristic:aChar];
                [aPeripheral setNotifyValue:YES forCharacteristic:aChar];
            }
        }
    }
    else if ([service.UUID.UUIDString isEqualToString:BLE_THERMO_SERVICE_UUID_PROBE_TEMPERATURE]) {
        for (CBCharacteristic *aChar in service.characteristics) {
            if (([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_THERMO_CHAR_UUID_PROBE_TEMPERATURE_CURRENT]])||
                ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_THERMO_SERVICE_UUID_PROBE_TEMPERATURE_ALARM_LOW_VALUE]])||
                ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_THERMO_SERVICE_UUID_PROBE_TEMPERATURE_ALARM_HIGH_VALUE]])||
                ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_THERMO_SERVICE_UUID_PROBE_TEMPERATURE_ALARM_SET]])||
                ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_THERMO_SERVICE_UUID_PROBE_TEMPERATURE_ALARM]]))
            {
                [aPeripheral readValueForCharacteristic:aChar];
                [aPeripheral setNotifyValue:YES forCharacteristic:aChar];
            }
        }
    }
}

- (void)peripheral:(CBPeripheral *)aPeripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"ThermoSensor didUpdateValueForCharacteristic start");
    if ((characteristic.value)||(!error)) {
        if ([characteristic.UUID.UUIDString isEqualToString:BLE_THERMO_CHAR_UUID_IR_TEMPERATURE_CURRENT]||
            [characteristic.UUID.UUIDString isEqualToString:BLE_THERMO_CHAR_UUID_PROBE_TEMPERATURE_CURRENT]) {
            if ([characteristic.UUID.UUIDString isEqualToString:BLE_THERMO_CHAR_UUID_IR_TEMPERATURE_CURRENT]) {
                NSString *irTemp = [[NSString alloc] initWithData:characteristic.value encoding:NSASCIIStringEncoding];
                NSLog(@"ThermoSensor didUpdateValueForCharacteristic irTemp %@", irTemp);
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.irTemp = irTemp;
                });
                [DatabaseManager saveNewSensorValueWithSensor:self valueType:kValueTypeIRTemperature value:[irTemp doubleValue]];
            } else if ([characteristic.UUID.UUIDString isEqualToString:BLE_THERMO_CHAR_UUID_PROBE_TEMPERATURE_CURRENT]) {
                const uint8_t *data = [characteristic.value bytes];
                uint16_t value16_t = CFSwapInt16LittleToHost(*(uint16_t *)(&data[1]));
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.probeTemp = value16_t;
                });
                [DatabaseManager saveNewSensorValueWithSensor:self valueType:kValueTypeProbeTemperature value:value16_t];
            }
        }
        else if ([characteristic.UUID.UUIDString isEqualToString:BLE_THERMO_SERVICE_UUID_IR_TEMPERATURE_ALARM_SET]||
                 [characteristic.UUID.UUIDString isEqualToString:BLE_THERMO_SERVICE_UUID_PROBE_TEMPERATURE_ALARM_SET]) {
            uint8_t alarmSetValue  = 0;
            [[characteristic value] getBytes:&alarmSetValue length:sizeof (alarmSetValue)];
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_THERMO_SERVICE_UUID_IR_TEMPERATURE_ALARM_SET]]) {
                    if (_irTempAlarmState == kAlarmStateUnknown) {
                        self.irTempAlarmState = (alarmSetValue & 0x01)?kAlarmStateEnabled:kAlarmStateDisabled;
                        [self.delegate didUpdateAlarmStateWithUUIDString:BLE_THERMO_SERVICE_UUID_IR_TEMPERATURE_ALARM];
                    }
                }
                else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_THERMO_SERVICE_UUID_PROBE_TEMPERATURE_ALARM_SET]]) {
                    if (_probeTempAlarmState == kAlarmStateUnknown) {
                        self.probeTempAlarmState = (alarmSetValue & 0x01)?kAlarmStateEnabled:kAlarmStateDisabled;
                        [self.delegate didUpdateAlarmStateWithUUIDString:BLE_THERMO_SERVICE_UUID_PROBE_TEMPERATURE_ALARM];
                    }
                }
            });
        }
        else if ([characteristic.UUID.UUIDString isEqualToString:BLE_THERMO_SERVICE_UUID_IR_TEMPERATURE_ALARM]||
                 [characteristic.UUID.UUIDString isEqualToString:BLE_THERMO_SERVICE_UUID_PROBE_TEMPERATURE_ALARM]) {
            uint8_t alarmValue  = 0;
            [[characteristic value] getBytes:&alarmValue length:sizeof (alarmValue)];
            NSLog(@"alarm!  0x%x", alarmValue);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (alarmValue & 0x01) {
                    if (alarmValue & 0x02) {
                        [self alarmActionWithCharacteristic:characteristic alarmType:kAlarmLow];
                    }
                    else {
                        [self alarmActionWithCharacteristic:characteristic alarmType:kAlarmHigh];
                    }
                }
                else {
                    [self alarmServiceDidStopAlarm:characteristic];
                }
            });
        }
    }
}

- (void)alarmActionWithCharacteristic:(CBCharacteristic *)characteristic alarmType:(AlarmType)alarmtype {
    NSString *alertString;
    if ([characteristic.UUID.UUIDString isEqualToString:BLE_THERMO_SERVICE_UUID_IR_TEMPERATURE_ALARM]) {
        if (_irTempAlarmState != kAlarmStateEnabled) {
            return;
        }
        if (alarm == kAlarmHigh) {
            alertString = @"IR Temperature high value";
        }
        else {
            alertString = @"IR Temperature low value";
        }
    }
    else if ([characteristic.UUID.UUIDString isEqualToString:BLE_THERMO_SERVICE_UUID_PROBE_TEMPERATURE_ALARM]) {
        if (_probeTempAlarmState != kAlarmStateEnabled) {
            return;
        }
        if (alarm == kAlarmHigh) {
            alertString = @"Probe Temperature high value";
        }
        else {
            alertString = @"Probe Temperature low value";
        }
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alarm" message:alertString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
}

@end
