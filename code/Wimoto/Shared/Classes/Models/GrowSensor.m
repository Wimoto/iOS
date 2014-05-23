//
//  GrowSensor.m
//  Wimoto
//
//  Created by Danny Kokarev on 25.12.13.
//
//

#import "GrowSensor.h"
#import "DatabaseManager.h"

@implementation GrowSensor

#pragma mark - CBPeriferalDelegate

- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error
{
    for (CBService *aService in aPeripheral.services) {
        NSLog(@"GrowSensor didDiscoverServices %@", aService);
        if ([aService.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_LIGHT]]) {
            [aPeripheral discoverCharacteristics:[NSArray arrayWithObjects:
                                                  [CBUUID UUIDWithString:BLE_GROW_CHAR_UUID_LIGHT_CURRENT],
                                                  [CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_LIGHT_ALARM_LOW_VALUE],
                                                  [CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_LIGHT_ALARM_HIGH_VALUE],
                                                  [CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_LIGHT_ALARM_SET],
                                                  [CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_LIGHT_ALARM],
                                                  nil]
                                      forService:aService];
            
        } else if ([aService.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_SOIL_MOISTURE]]) {
            [aPeripheral discoverCharacteristics:[NSArray arrayWithObjects:
                                                  [CBUUID UUIDWithString:BLE_GROW_CHAR_UUID_SOIL_MOISTURE_CURRENT],
                                                  [CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_SOIL_MOISTURE_ALARM_LOW_VALUE],
                                                  [CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_SOIL_MOISTURE_ALARM_HIGH_VALUE],
                                                  [CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_SOIL_MOISTURE_ALARM_SET],
                                                  [CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_SOIL_MOISTURE_ALARM],
                                                  nil]
                                      forService:aService];
            
        } else if ([aService.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_SOIL_TEMPERATURE]]) {
            [aPeripheral discoverCharacteristics:[NSArray arrayWithObjects:
                                                  [CBUUID UUIDWithString:BLE_GROW_CHAR_UUID_SOIL_TEMPERATURE_CURRENT],
                                                  [CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_SOIL_TEMPERATURE_ALARM_LOW_VALUE],
                                                  [CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_SOIL_TEMPERATURE_ALARM_HIGH_VALUE],
                                                  [CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_SOIL_TEMPERATURE_ALARM_SET],
                                                  [CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_SOIL_TEMPERATURE_ALARM],
                                                  nil]
                                      forService:aService];
        }
    }
}

- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if ([service.UUID.UUIDString isEqualToString:BLE_GROW_SERVICE_UUID_SOIL_TEMPERATURE]) {
         for (CBCharacteristic *aChar in service.characteristics) {
             if (([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_CHAR_UUID_SOIL_TEMPERATURE_CURRENT]])||
                 ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_SOIL_TEMPERATURE_ALARM_LOW_VALUE]])||
                 ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_SOIL_TEMPERATURE_ALARM_HIGH_VALUE]])||
                 ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_SOIL_TEMPERATURE_ALARM_SET]])||
                 ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_SOIL_TEMPERATURE_ALARM]]))
             {
                 [aPeripheral readValueForCharacteristic:aChar];
                 [aPeripheral setNotifyValue:YES forCharacteristic:aChar];
             }
         }
    }
    else if ([service.UUID.UUIDString isEqualToString:BLE_GROW_SERVICE_UUID_SOIL_MOISTURE]) {
        for (CBCharacteristic *aChar in service.characteristics) {
            if (([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_CHAR_UUID_SOIL_MOISTURE_CURRENT]])||
                ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_SOIL_MOISTURE_ALARM_LOW_VALUE]])||
                ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_SOIL_MOISTURE_ALARM_HIGH_VALUE]])||
                ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_SOIL_MOISTURE_ALARM_SET]])||
                ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_SOIL_MOISTURE_ALARM]]))
            {
                [aPeripheral readValueForCharacteristic:aChar];
                [aPeripheral setNotifyValue:YES forCharacteristic:aChar];
            }
        }
    }
    else if ([service.UUID.UUIDString isEqualToString:BLE_GROW_SERVICE_UUID_LIGHT]) {
        for (CBCharacteristic *aChar in service.characteristics) {
            if (([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_CHAR_UUID_LIGHT_CURRENT]])||
                ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_LIGHT_ALARM_LOW_VALUE]])||
                ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_LIGHT_ALARM_HIGH_VALUE]])||
                ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_LIGHT_ALARM_SET]])||
                ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_LIGHT_ALARM]]))
            {
                [aPeripheral readValueForCharacteristic:aChar];
                [aPeripheral setNotifyValue:YES forCharacteristic:aChar];
            }
        }
    }
}

- (void)peripheral:(CBPeripheral *)aPeripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if ((characteristic.value)||(!error)) {
        if ([characteristic.UUID.UUIDString isEqualToString:BLE_GROW_CHAR_UUID_SOIL_TEMPERATURE_CURRENT]||
            [characteristic.UUID.UUIDString isEqualToString:BLE_GROW_CHAR_UUID_LIGHT_CURRENT]||
            [characteristic.UUID.UUIDString isEqualToString:BLE_GROW_CHAR_UUID_SOIL_MOISTURE_CURRENT]) {
            const uint8_t *data = [characteristic.value bytes];
            uint16_t value16_t = CFSwapInt16LittleToHost(*(uint16_t *)(&data[1]));
            if ([characteristic.UUID.UUIDString isEqualToString:BLE_GROW_CHAR_UUID_SOIL_TEMPERATURE_CURRENT]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.soilTemperature = value16_t;
                });
                [DatabaseManager saveNewSensorValueWithSensor:self valueType:kValueTypeSoilTemperature value:value16_t];
            } else if ([characteristic.UUID.UUIDString isEqualToString:BLE_GROW_CHAR_UUID_LIGHT_CURRENT]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.light = value16_t;
                });
                [DatabaseManager saveNewSensorValueWithSensor:self valueType:kValueTypeGrowLight value:value16_t];
            } else if ([characteristic.UUID.UUIDString isEqualToString:BLE_GROW_CHAR_UUID_SOIL_MOISTURE_CURRENT]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.soilMoisture = value16_t;
                });
                [DatabaseManager saveNewSensorValueWithSensor:self valueType:kValueTypeSoilHumidity value:value16_t];
            }
        }
        else if ([characteristic.UUID.UUIDString isEqualToString:BLE_GROW_SERVICE_UUID_LIGHT_ALARM_SET]||
                 [characteristic.UUID.UUIDString isEqualToString:BLE_GROW_SERVICE_UUID_SOIL_MOISTURE_ALARM_SET]||
                 [characteristic.UUID.UUIDString isEqualToString:BLE_GROW_SERVICE_UUID_SOIL_TEMPERATURE_ALARM_SET]) {
            uint8_t alarmSetValue  = 0;
            [[characteristic value] getBytes:&alarmSetValue length:sizeof (alarmSetValue)];
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_LIGHT_ALARM_SET]]) {
                    if (_lightAlarmState == kAlarmStateUnknown) {
                        self.lightAlarmState = (alarmSetValue & 0x01)?kAlarmStateEnabled:kAlarmStateDisabled;
                        [self.delegate didUpdateAlarmStateWithUUIDString:BLE_GROW_SERVICE_UUID_LIGHT_ALARM];
                    }
                } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_SOIL_MOISTURE_ALARM_SET]]) {
                    if (_soilMoistureAlarmState == kAlarmStateUnknown) {
                        self.soilMoistureAlarmState = (alarmSetValue & 0x01)?kAlarmStateEnabled:kAlarmStateDisabled;
                        [self.delegate didUpdateAlarmStateWithUUIDString:BLE_GROW_SERVICE_UUID_SOIL_MOISTURE_ALARM];
                    }
                } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_SOIL_TEMPERATURE_ALARM_SET]]) {
                    if (_soilTempAlarmState == kAlarmStateUnknown) {
                        self.soilTempAlarmState = (alarmSetValue & 0x01)?kAlarmStateEnabled:kAlarmStateDisabled;
                        [self.delegate didUpdateAlarmStateWithUUIDString:BLE_GROW_SERVICE_UUID_SOIL_TEMPERATURE_ALARM];
                    }
                }
            });
        }
        else if ([characteristic.UUID.UUIDString isEqualToString:BLE_GROW_SERVICE_UUID_LIGHT_ALARM]||
                 [characteristic.UUID.UUIDString isEqualToString:BLE_GROW_SERVICE_UUID_SOIL_MOISTURE_ALARM]||
                 [characteristic.UUID.UUIDString isEqualToString:BLE_GROW_SERVICE_UUID_SOIL_TEMPERATURE_ALARM]) {
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
    if ([characteristic.UUID.UUIDString isEqualToString:BLE_GROW_SERVICE_UUID_LIGHT_ALARM]) {
        if (_lightAlarmState != kAlarmStateEnabled) {
            return;
        }
        if (alarm == kAlarmHigh) {
            alertString = @"Light high value";
        }
        else {
            alertString = @"Light low value";
        }
    }
    else if ([characteristic.UUID.UUIDString isEqualToString:BLE_GROW_SERVICE_UUID_SOIL_MOISTURE_ALARM]) {
        if (_soilMoistureAlarmState != kAlarmStateEnabled) {
            return;
        }
        if (alarm == kAlarmHigh) {
            alertString = @"Soil moisture high value";
        }
        else {
            alertString = @"Soil moisture low value";
        }
    }
    else if ([characteristic.UUID.UUIDString isEqualToString:BLE_GROW_SERVICE_UUID_SOIL_TEMPERATURE_ALARM]) {
        if (_soilTempAlarmState != kAlarmStateEnabled) {
            return;
        }
        if (alarm == kAlarmHigh) {
            alertString = @"Soil temperature high value";
        }
        else {
            alertString = @"Soil temperature low value";
        }
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alarm" message:alertString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
}

@end
