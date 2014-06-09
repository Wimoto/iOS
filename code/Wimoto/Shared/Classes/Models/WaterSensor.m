//
//  WaterSensor.m
//  Wimoto
//
//  Created by MC700 on 12/23/13.
//
//

#import "WaterSensor.h"

#import "DatabaseManager.h"

@implementation WaterSensor

#pragma mark - CBPeriferalDelegate

- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error {
    [super peripheral:aPeripheral didDiscoverServices:error];
    for (CBService *aService in aPeripheral.services) {
        NSLog(@"WaterSensor didDiscoverServices %@", aService);
        if ([aService.UUID isEqual:[CBUUID UUIDWithString:BLE_WATER_SERVICE_UUID_LEVEL]]) {
            [aPeripheral discoverCharacteristics:[NSArray arrayWithObjects:
                                                  [CBUUID UUIDWithString:BLE_WATER_CHAR_UUID_LEVEL_CURRENT],
                                                  [CBUUID UUIDWithString:BLE_WATER_SERVICE_UUID_LEVEL_ALARM_LOW_VALUE],
                                                  [CBUUID UUIDWithString:BLE_WATER_SERVICE_UUID_LEVEL_ALARM_HIGH_VALUE],
                                                  [CBUUID UUIDWithString:BLE_WATER_SERVICE_UUID_LEVEL_ALARM_SET],
                                                  [CBUUID UUIDWithString:BLE_WATER_SERVICE_UUID_LEVEL_ALARM],
                                                  nil]
                                      forService:aService];
        } else if ([aService.UUID isEqual:[CBUUID UUIDWithString:BLE_WATER_SERVICE_UUID_PRESENCE]]) {
            [aPeripheral discoverCharacteristics:[NSArray arrayWithObjects:
                                                  [CBUUID UUIDWithString:BLE_WATER_CHAR_UUID_PRESENCE_CURRENT],
                                                  [CBUUID UUIDWithString:BLE_WATER_SERVICE_UUID_PRESENCE_ALARM_SET],
                                                  [CBUUID UUIDWithString:BLE_WATER_SERVICE_UUID_PRESENCE_ALARM],
                                                  nil]
                                      forService:aService];
        }
    }
}

- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    [super peripheral:aPeripheral didDiscoverCharacteristicsForService:service error:error];
    if ([service.UUID isEqual:[CBUUID UUIDWithString:BLE_WATER_SERVICE_UUID_LEVEL]]) {
        for (CBCharacteristic *aChar in service.characteristics) {
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_WATER_SERVICE_UUID_LEVEL_ALARM_LOW_VALUE]]||
                [aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_WATER_SERVICE_UUID_LEVEL_ALARM_HIGH_VALUE]]||
                [aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_WATER_SERVICE_UUID_LEVEL_ALARM_SET]]) {
                [aPeripheral readValueForCharacteristic:aChar];
            }
            else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_WATER_SERVICE_UUID_LEVEL_ALARM]]) {
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
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_WATER_SERVICE_UUID_PRESENCE_ALARM_SET]]) {
                [aPeripheral readValueForCharacteristic:aChar];
            }
            else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_WATER_SERVICE_UUID_PRESENCE_ALARM]]) {
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
    [super peripheral:aPeripheral didUpdateValueForCharacteristic:characteristic error:error];
    dispatch_async(dispatch_get_main_queue(), ^{
        if ((characteristic.value)||(!error)) {
            if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_WATER_CHAR_UUID_LEVEL_CURRENT]]||
                [characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_WATER_CHAR_UUID_PRESENCE_CURRENT]]) {
                const uint8_t *data = [characteristic.value bytes];
                uint16_t value16_t = CFSwapInt16LittleToHost(*(uint16_t *)(&data[1]));
                if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_WATER_CHAR_UUID_LEVEL_CURRENT]]) {
                    self.level = value16_t;
                    [DatabaseManager saveNewSensorValueWithSensor:self valueType:kValueTypeLevel value:value16_t];
                } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_WATER_CHAR_UUID_PRESENCE_CURRENT]]) {
                    self.presense = value16_t;
                    [DatabaseManager saveNewSensorValueWithSensor:self valueType:kValueTypePresence value:value16_t];
                }
            }
        }
    });
}

- (void)alarmActionWithCharacteristic:(CBCharacteristic *)characteristic alarmType:(AlarmType)alarmtype {
    NSString *alertString;
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_WATER_SERVICE_UUID_PRESENCE_ALARM]]) {
        if (_presenseAlarmState != kAlarmStateEnabled) {
            return;
        }
        if (alarmtype == kAlarmHigh) {
            alertString = @"Water Presense high value";
        }
        else {
            alertString = @"Water Presense low value";
        }
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_WATER_SERVICE_UUID_LEVEL_ALARM]]) {
        if (_levelAlarmState != kAlarmStateEnabled) {
            return;
        }
        if (alarmtype == kAlarmHigh) {
            alertString = @"Water Level high value";
        }
        else {
            alertString = @"Water Level low value";
        }
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alarm" message:alertString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
}

@end
