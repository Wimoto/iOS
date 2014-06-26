//
//  SentrySensor.m
//  Wimoto
//
//  Created by Danny Kokarev on 25.12.13.
//
//

#import "SentrySensor.h"
//#import "DatabaseManager.h"

@implementation SentrySensor

- (PeripheralType)type {
    return kPeripheralTypeSentry;
}

#pragma mark - CBPeriferalDelegate

- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error {
    [super peripheral:aPeripheral didDiscoverServices:error];
    for (CBService *aService in aPeripheral.services) {
        NSLog(@"SentrySensor didDiscoverServices %@", aService);
        if ([aService.UUID isEqual:[CBUUID UUIDWithString:BLE_SENTRY_SERVICE_UUID_ACCELEROMETER]]) {
            [aPeripheral discoverCharacteristics:[NSArray arrayWithObjects:
                                                  [CBUUID UUIDWithString:BLE_SENTRY_CHAR_UUID_ACCELEROMETER_CURRENT],
                                                  [CBUUID UUIDWithString:BLE_SENTRY_SERVICE_UUID_ACCELEROMETER_ALARM_SET],
                                                  [CBUUID UUIDWithString:BLE_SENTRY_SERVICE_UUID_ACCELEROMETER_ALARM_CLEAR],
                                                  [CBUUID UUIDWithString:BLE_SENTRY_SERVICE_UUID_ACCELEROMETER_ALARM],
                                                  nil]
                                      forService:aService];
        } else if ([aService.UUID isEqual:[CBUUID UUIDWithString:BLE_SENTRY_SERVICE_UUID_PASSIVE_INFRARED]]) {
            [aPeripheral discoverCharacteristics:[NSArray arrayWithObjects:
                                                  [CBUUID UUIDWithString:BLE_SENTRY_CHAR_UUID_PASSIVE_INFRARED_CURRENT],
                                                  [CBUUID UUIDWithString:BLE_SENTRY_SERVICE_UUID_PASSIVE_INFRARED_ALARM_SET],
                                                  [CBUUID UUIDWithString:BLE_SENTRY_SERVICE_UUID_PASSIVE_INFRARED_ALARM],
                                                  nil]
                                      forService:aService];
        }
    }
}

- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    [super peripheral:aPeripheral didDiscoverCharacteristicsForService:service error:error];
    if ([service.UUID isEqual:[CBUUID UUIDWithString:BLE_SENTRY_SERVICE_UUID_ACCELEROMETER]]) {
        for (CBCharacteristic *aChar in service.characteristics) {
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_SENTRY_SERVICE_UUID_ACCELEROMETER_ALARM_SET]]||
                [aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_SENTRY_SERVICE_UUID_ACCELEROMETER_ALARM_CLEAR]]) {
                [aPeripheral readValueForCharacteristic:aChar];
            }
            else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_SENTRY_SERVICE_UUID_ACCELEROMETER_ALARM]]) {
                [aPeripheral setNotifyValue:YES forCharacteristic:aChar];
            }
            else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_SENTRY_CHAR_UUID_ACCELEROMETER_CURRENT]]) {
                [aPeripheral readValueForCharacteristic:aChar];
                [aPeripheral setNotifyValue:YES forCharacteristic:aChar];
            }
        }
    }
    else if ([service.UUID isEqual:[CBUUID UUIDWithString:BLE_SENTRY_SERVICE_UUID_PASSIVE_INFRARED]]) {
        for (CBCharacteristic *aChar in service.characteristics) {
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_SENTRY_SERVICE_UUID_PASSIVE_INFRARED_ALARM_SET]]) {
                [aPeripheral readValueForCharacteristic:aChar];
            }
            else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_SENTRY_SERVICE_UUID_PASSIVE_INFRARED_ALARM]]) {
                [aPeripheral setNotifyValue:YES forCharacteristic:aChar];
            }
            else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_SENTRY_CHAR_UUID_PASSIVE_INFRARED_CURRENT]]) {
                [aPeripheral readValueForCharacteristic:aChar];
                [aPeripheral setNotifyValue:YES forCharacteristic:aChar];
            }
        }
    }
}

- (void)peripheral:(CBPeripheral *)aPeripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    [super peripheral:aPeripheral didUpdateValueForCharacteristic:characteristic error:error];
    dispatch_async(dispatch_get_main_queue(), ^{
        if ((characteristic.value)||(!error)) {
            if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_SENTRY_CHAR_UUID_ACCELEROMETER_CURRENT]]||
                [characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_SENTRY_CHAR_UUID_PASSIVE_INFRARED_CURRENT]]) {
                
                NSString *hexString = [characteristic.value hexadecimalString];
                NSScanner *scanner = [NSScanner scannerWithString:hexString];
                unsigned int decimalValue;
                [scanner scanHexInt:&decimalValue];
                
                if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_SENTRY_CHAR_UUID_ACCELEROMETER_CURRENT]]) {
                    NSLog(@"SENTRY ACCELEROMETER CURRENT HEX VALUE = %@", hexString);
                    //self.lastUpdateDate = [NSDate date];
                    //[self save:nil];
                    self.accelerometer = decimalValue;
                    //[DatabaseManager saveNewSensorValueWithSensor:self valueType:kValueTypeAccelerometer value:decimalValue];
                } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_SENTRY_CHAR_UUID_PASSIVE_INFRARED_CURRENT]]) {
                    NSLog(@"SENTRY PASSIVE INFRARED CURRENT HEX VALUE = %@", hexString);
                    self.pasInfrared = decimalValue;
                    //[DatabaseManager saveNewSensorValueWithSensor:self valueType:kValueTypePassiveInfrared value:decimalValue];
                }
            }
            else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_SENTRY_SERVICE_UUID_ACCELEROMETER_ALARM_SET]]||
                     [characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_SENTRY_SERVICE_UUID_PASSIVE_INFRARED_ALARM_SET]]) {
                uint8_t alarmSetValue  = 0;
                [[characteristic value] getBytes:&alarmSetValue length:sizeof (alarmSetValue)];
                if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_SENTRY_SERVICE_UUID_ACCELEROMETER_ALARM_SET]]) {
                    if (_accelerometerAlarmState == kAlarmStateUnknown) {
                        self.accelerometerAlarmState = (alarmSetValue & 0x01)?kAlarmStateEnabled:kAlarmStateDisabled;
                        [self.delegate didUpdateAlarmStateWithUUIDString:BLE_SENTRY_SERVICE_UUID_ACCELEROMETER_ALARM];
                    }
                } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_SENTRY_SERVICE_UUID_PASSIVE_INFRARED_ALARM_SET]]) {
                    if (_pasInfraredAlarmState == kAlarmStateUnknown) {
                        self.pasInfraredAlarmState = (alarmSetValue & 0x01)?kAlarmStateEnabled:kAlarmStateDisabled;
                        [self.delegate didUpdateAlarmStateWithUUIDString:BLE_SENTRY_SERVICE_UUID_PASSIVE_INFRARED_ALARM];
                    }
                }
            }
            else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_SENTRY_SERVICE_UUID_ACCELEROMETER_ALARM]]||
                     [characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_SENTRY_SERVICE_UUID_PASSIVE_INFRARED_ALARM]]) {
                uint8_t alarmValue = 0;
                [[characteristic value] getBytes:&alarmValue length:sizeof (alarmValue)];
                NSLog(@"alarm!  0x%x", alarmValue);
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
            }
        }
    });
}

- (void)alarmActionWithCharacteristic:(CBCharacteristic *)characteristic alarmType:(AlarmType)alarmtype {
    NSString *alertString;
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_SENTRY_SERVICE_UUID_ACCELEROMETER_ALARM]]) {
        if (_accelerometerAlarmState != kAlarmStateEnabled) {
            return;
        }
        if (alarmtype == kAlarmHigh) {
            alertString = @"Sentry Accelerometer high value";
        }
        else {
            alertString = @"Sentry Accelerometer low value";
        }
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_SENTRY_SERVICE_UUID_PASSIVE_INFRARED_ALARM]]) {
        if (_pasInfraredAlarmState != kAlarmStateEnabled) {
            return;
        }
        if (alarmtype == kAlarmHigh) {
            alertString = @"Sentry Infrared high value";
        }
        else {
            alertString = @"Sentry Infrared low value";
        }
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alarm" message:alertString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
}

@end
