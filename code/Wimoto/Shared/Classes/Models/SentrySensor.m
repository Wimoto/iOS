//
//  SentrySensor.m
//  Wimoto
//
//  Created by Danny Kokarev on 25.12.13.
//
//

#import "SentrySensor.h"

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
    if (error) {
        return;
    }
    [super peripheral:aPeripheral didUpdateValueForCharacteristic:characteristic error:error];
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_SENTRY_CHAR_UUID_ACCELEROMETER_CURRENT]]) {
            
            const void *bytes = [characteristic.value bytes];
            NSMutableArray *ary = [NSMutableArray array];
            for (NSUInteger i = 0; i < [characteristic.value length]; i += sizeof(int32_t)) {
                int32_t elem = OSReadLittleInt32(bytes, i);
                [ary addObject:[NSNumber numberWithInt:elem]];
            }
            NSLog(@"ACCELEROMETER VALUES - %@", ary);
            
            //self.accelerometer = [self sensorValueForCharacteristic:characteristic];
            //[self.entity saveNewValueWithType:kValueTypeAccelerometer value:_accelerometer];
        } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_SENTRY_CHAR_UUID_PASSIVE_INFRARED_CURRENT]]) {
            self.pasInfrared = [self sensorValueForCharacteristic:characteristic];;
            [self.entity saveNewValueWithType:kValueTypePassiveInfrared value:_pasInfrared];
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_SENTRY_SERVICE_UUID_ACCELEROMETER_ALARM_SET]]) {
            if (_accelerometerAlarmState == kAlarmStateUnknown) {
                self.accelerometerAlarmState = [self alarmStateForCharacteristic:characteristic];
            }
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_SENTRY_SERVICE_UUID_PASSIVE_INFRARED_ALARM_SET]]) {
            if (_pasInfraredAlarmState == kAlarmStateUnknown) {
                self.pasInfraredAlarmState = [self alarmStateForCharacteristic:characteristic];
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
    });
}

- (void)alarmActionWithCharacteristic:(CBCharacteristic *)characteristic alarmType:(AlarmType)alarmtype {
    NSString *alertString;
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_SENTRY_SERVICE_UUID_ACCELEROMETER_ALARM]]) {
        if (_accelerometerAlarmState != kAlarmStateEnabled) {
            return;
        }
        alertString = [NSString stringWithFormat:@"Sentry: %@ accelerometer %@", self.name, (alarmtype == kAlarmHigh)?@"high value":@"low value"];
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_SENTRY_SERVICE_UUID_PASSIVE_INFRARED_ALARM]]) {
        if (_pasInfraredAlarmState != kAlarmStateEnabled) {
            return;
        }
        alertString = [NSString stringWithFormat:@"%@: %@ infrared alarm triggered", self.name, (alarmtype == kAlarmHigh)?@"high value":@"low value"];
    }
    if (alertString) {
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
            localNotification.category = NOTIFICATION_ALARM_CATEGORY_ID; //  Same as category identifier
        }
        localNotification.alertBody = alertString;
        localNotification.alertAction = @"View";
        localNotification.soundName = @"alarm.aifc";
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];

    }
}

@end
