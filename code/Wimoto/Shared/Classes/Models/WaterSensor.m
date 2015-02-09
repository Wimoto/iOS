//
//  WaterSensor.m
//  Wimoto
//
//  Created by MC700 on 12/23/13.
//
//

#import "WaterSensor.h"
#import "AppConstants.h"

@implementation WaterSensor

- (PeripheralType)type {
    return kPeripheralTypeWater;
}

- (NSString *)codename {
    return @"Water";
}

#pragma mark - CBPeriferalDelegate

- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error {
    [super peripheral:aPeripheral didDiscoverServices:error];
    for (CBService *aService in aPeripheral.services) {
        NSLog(@"WaterSensor didDiscoverServices %@", aService);
        if ([aService.UUID isEqual:[CBUUID UUIDWithString:BLE_WATER_SERVICE_UUID_LEVEL]]) {
            [aPeripheral discoverCharacteristics:[NSArray arrayWithObjects:
                                                  [CBUUID UUIDWithString:BLE_WATER_CHAR_UUID_LEVEL_CURRENT],
                                                  [CBUUID UUIDWithString:BLE_WATER_CHAR_UUID_LEVEL_ALARM_LOW_VALUE],
                                                  [CBUUID UUIDWithString:BLE_WATER_CHAR_UUID_LEVEL_ALARM_HIGH_VALUE],
                                                  [CBUUID UUIDWithString:BLE_WATER_CHAR_UUID_LEVEL_ALARM_SET],
                                                  [CBUUID UUIDWithString:BLE_WATER_CHAR_UUID_LEVEL_ALARM],
                                                  nil]
                                      forService:aService];
        } else if ([aService.UUID isEqual:[CBUUID UUIDWithString:BLE_WATER_SERVICE_UUID_PRESENCE]]) {
            [aPeripheral discoverCharacteristics:[NSArray arrayWithObjects:
                                                  [CBUUID UUIDWithString:BLE_WATER_CHAR_UUID_PRESENCE_CURRENT],
                                                  [CBUUID UUIDWithString:BLE_WATER_CHAR_UUID_PRESENCE_ALARM_SET],
                                                  [CBUUID UUIDWithString:BLE_WATER_CHAR_UUID_PRESENCE_ALARM],
                                                  nil]
                                      forService:aService];
        }
    }
}

- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    [super peripheral:aPeripheral didDiscoverCharacteristicsForService:service error:error];
    if ([service.UUID isEqual:[CBUUID UUIDWithString:BLE_WATER_SERVICE_UUID_LEVEL]]) {
        for (CBCharacteristic *aChar in service.characteristics) {
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_WATER_CHAR_UUID_LEVEL_ALARM_LOW_VALUE]]||
                [aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_WATER_CHAR_UUID_LEVEL_ALARM_HIGH_VALUE]]||
                [aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_WATER_CHAR_UUID_LEVEL_ALARM_SET]]) {
                [aPeripheral readValueForCharacteristic:aChar];
            }
            else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_WATER_CHAR_UUID_LEVEL_ALARM]]) {
                [aPeripheral setNotifyValue:YES forCharacteristic:aChar];
            }
            else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_WATER_CHAR_UUID_LEVEL_CURRENT]]) {
                [aPeripheral readValueForCharacteristic:aChar];
                [aPeripheral setNotifyValue:YES forCharacteristic:aChar];
            }
        }
    }
    else if ([service.UUID isEqual:[CBUUID UUIDWithString:BLE_WATER_SERVICE_UUID_PRESENCE]]) {
        for (CBCharacteristic *aChar in service.characteristics) {
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_WATER_CHAR_UUID_PRESENCE_ALARM_SET]]) {
                [aPeripheral readValueForCharacteristic:aChar];
            }
            else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_WATER_CHAR_UUID_PRESENCE_ALARM]]) {
                [aPeripheral setNotifyValue:YES forCharacteristic:aChar];
            }
            else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_WATER_CHAR_UUID_PRESENCE_CURRENT]]) {
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
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_WATER_CHAR_UUID_LEVEL_CURRENT]]) {
            self.level = [self sensorValueForCharacteristic:characteristic];
            [self.entity saveNewValueWithType:kValueTypeLevel value:_level];
        } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_WATER_CHAR_UUID_PRESENCE_CURRENT]]) {
            self.presense = [self sensorValueForCharacteristic:characteristic];
            [self.entity saveNewValueWithType:kValueTypePresence value:_presense];
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_WATER_CHAR_UUID_LEVEL_ALARM_SET]]) {
            if (_levelAlarmState == kAlarmStateUnknown) {
                self.levelAlarmState = [self alarmStateForCharacteristic:characteristic];
            }
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_WATER_CHAR_UUID_PRESENCE_ALARM_SET]]) {
            if (_presenseAlarmState == kAlarmStateUnknown) {
                self.presenseAlarmState = [self alarmStateForCharacteristic:characteristic];
            }
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_WATER_CHAR_UUID_LEVEL_ALARM]]||
                 [characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_WATER_CHAR_UUID_PRESENCE_ALARM]]) {
            uint8_t alarmValue  = 0;
            [[characteristic value] getBytes:&alarmValue length:sizeof (alarmValue)];
            NSLog(@"alarm!  0x%x", alarmValue);
            if (alarmValue & 0x01) {
                if (alarmValue & 0x02) {
                    NSLog(@"ALARM LOW VALUE");
                    [self alarmActionWithCharacteristic:characteristic alarmType:kAlarmLow];
                }
                else {
                    NSLog(@"ALARM HIGH VALUE");
                    [self alarmActionWithCharacteristic:characteristic alarmType:kAlarmHigh];
                }
            }
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_WATER_CHAR_UUID_LEVEL_ALARM_LOW_VALUE]]) {
            self.levelAlarmLow = [self alarmValueForCharacteristic:characteristic];
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_WATER_CHAR_UUID_LEVEL_ALARM_HIGH_VALUE]]) {
            self.levelAlarmHigh = [self alarmValueForCharacteristic:characteristic];
        }
    });
}

- (void)alarmActionWithCharacteristic:(CBCharacteristic *)characteristic alarmType:(AlarmType)alarmtype {
    NSString *alertString;
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_WATER_CHAR_UUID_PRESENCE_ALARM]]) {
        if (_presenseAlarmState != kAlarmStateEnabled) {
            return;
        }
        alertString = [NSString stringWithFormat:@"%@ presense %@", self.name, (alarmtype == kAlarmHigh)?@"high value":@"low value"];
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_WATER_CHAR_UUID_LEVEL_ALARM]]) {
        if (_levelAlarmState != kAlarmStateEnabled) {
            return;
        }
        alertString = [NSString stringWithFormat:@"%@ level %@", self.name, (alarmtype == kAlarmHigh)?@"high value":@"low value"];
    }
    if (alertString) {
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
            localNotification.category = NOTIFICATION_ALARM_CATEGORY_ID; //  Same as category identifier
        }
        localNotification.alertBody = alertString;
        localNotification.alertAction = @"View";
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    }
}

@end
