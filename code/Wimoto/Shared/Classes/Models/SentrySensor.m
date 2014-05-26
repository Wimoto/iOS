//
//  SentrySensor.m
//  Wimoto
//
//  Created by Danny Kokarev on 25.12.13.
//
//

#import "SentrySensor.h"
#import "DatabaseManager.h"

@implementation SentrySensor

#pragma mark - CBPeriferalDelegate

- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error {
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
    if ([service.UUID.UUIDString isEqualToString:BLE_SENTRY_SERVICE_UUID_ACCELEROMETER]) {
        for (CBCharacteristic *aChar in service.characteristics) {
            if (([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_SENTRY_CHAR_UUID_ACCELEROMETER_CURRENT]])||
                ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_SENTRY_SERVICE_UUID_ACCELEROMETER_ALARM_SET]])||
                ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_SENTRY_SERVICE_UUID_ACCELEROMETER_ALARM_CLEAR]])||
                ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_SENTRY_SERVICE_UUID_ACCELEROMETER_ALARM]]))
            {
                [aPeripheral readValueForCharacteristic:aChar];
                [aPeripheral setNotifyValue:YES forCharacteristic:aChar];
            }
        }
    }
    else if ([service.UUID.UUIDString isEqualToString:BLE_SENTRY_SERVICE_UUID_PASSIVE_INFRARED]) {
        for (CBCharacteristic *aChar in service.characteristics) {
            if (([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_SENTRY_CHAR_UUID_PASSIVE_INFRARED_CURRENT]])||
                ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_SENTRY_SERVICE_UUID_PASSIVE_INFRARED_ALARM_SET]])||
                ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_SENTRY_SERVICE_UUID_PASSIVE_INFRARED_ALARM]]))
            {
                [aPeripheral readValueForCharacteristic:aChar];
                [aPeripheral setNotifyValue:YES forCharacteristic:aChar];
            }
        }
    }
}

- (void)peripheral:(CBPeripheral *)aPeripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ((characteristic.value)||(!error)) {
            if ([characteristic.UUID.UUIDString isEqualToString:BLE_SENTRY_CHAR_UUID_ACCELEROMETER_CURRENT]||
                [characteristic.UUID.UUIDString isEqualToString:BLE_SENTRY_CHAR_UUID_PASSIVE_INFRARED_CURRENT]) {
                const uint8_t *data = [characteristic.value bytes];
                uint16_t value16_t = CFSwapInt16LittleToHost(*(uint16_t *)(&data[1]));
                if ([characteristic.UUID.UUIDString isEqualToString:BLE_SENTRY_CHAR_UUID_ACCELEROMETER_CURRENT]) {
                    self.accelerometer = value16_t;
                    [DatabaseManager saveNewSensorValueWithSensor:self valueType:kValueTypeAccelerometer value:value16_t];
                } else if ([characteristic.UUID.UUIDString isEqualToString:BLE_SENTRY_CHAR_UUID_PASSIVE_INFRARED_CURRENT]) {
                    self.pasInfrared = value16_t;
                    [DatabaseManager saveNewSensorValueWithSensor:self valueType:kValueTypePassiveInfrared value:value16_t];
                }
            }
            else if ([characteristic.UUID.UUIDString isEqualToString:BLE_SENTRY_SERVICE_UUID_ACCELEROMETER_ALARM_SET]||
                     [characteristic.UUID.UUIDString isEqualToString:BLE_SENTRY_SERVICE_UUID_PASSIVE_INFRARED_ALARM_SET]) {
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
            else if ([characteristic.UUID.UUIDString isEqualToString:BLE_SENTRY_SERVICE_UUID_ACCELEROMETER_ALARM]||
                     [characteristic.UUID.UUIDString isEqualToString:BLE_SENTRY_SERVICE_UUID_PASSIVE_INFRARED_ALARM]) {
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
    if ([characteristic.UUID.UUIDString isEqualToString:BLE_SENTRY_SERVICE_UUID_ACCELEROMETER_ALARM]) {
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
    else if ([characteristic.UUID.UUIDString isEqualToString:BLE_SENTRY_SERVICE_UUID_PASSIVE_INFRARED_ALARM]) {
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
