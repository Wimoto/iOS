//
//  GrowSensor.m
//  Wimoto
//
//  Created by Danny Kokarev on 25.12.13.
//
//

#import "GrowSensor.h"
//#import "DatabaseManager.h"

@implementation GrowSensor

- (PeripheralType)type {
    return kPeripheralTypeGrow;
}

#pragma mark - CBPeriferalDelegate

- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error {
    [super peripheral:aPeripheral didDiscoverServices:error];
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

- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    [super peripheral:aPeripheral didDiscoverCharacteristicsForService:service error:error];
    if ([service.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_SOIL_TEMPERATURE]]) {
         for (CBCharacteristic *aChar in service.characteristics) {
             if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_SOIL_TEMPERATURE_ALARM_LOW_VALUE]]||
                 [aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_SOIL_TEMPERATURE_ALARM_HIGH_VALUE]]||
                 [aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_SOIL_TEMPERATURE_ALARM_SET]]) {
                 [aPeripheral readValueForCharacteristic:aChar];
             }
             else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_SOIL_TEMPERATURE_ALARM]]) {
                 [aPeripheral setNotifyValue:YES forCharacteristic:aChar];
             }
             else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_CHAR_UUID_SOIL_TEMPERATURE_CURRENT]]) {
                 [aPeripheral readValueForCharacteristic:aChar];
                 [aPeripheral setNotifyValue:YES forCharacteristic:aChar];
             }
         }
    }
    else if ([service.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_SOIL_MOISTURE]]) {
        for (CBCharacteristic *aChar in service.characteristics) {
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_SOIL_MOISTURE_ALARM_LOW_VALUE]]||
                [aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_SOIL_MOISTURE_ALARM_HIGH_VALUE]]||
                [aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_SOIL_MOISTURE_ALARM_SET]]) {
                [aPeripheral readValueForCharacteristic:aChar];
            }
            else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_SOIL_MOISTURE_ALARM]]) {
                [aPeripheral setNotifyValue:YES forCharacteristic:aChar];
            }
            else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_CHAR_UUID_SOIL_MOISTURE_CURRENT]]) {
                [aPeripheral readValueForCharacteristic:aChar];
                [aPeripheral setNotifyValue:YES forCharacteristic:aChar];
            }
        }
    }
    else if ([service.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_LIGHT]]) {
        for (CBCharacteristic *aChar in service.characteristics) {
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_LIGHT_ALARM_LOW_VALUE]]||
                [aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_LIGHT_ALARM_HIGH_VALUE]]||
                [aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_LIGHT_ALARM_SET]]) {
                [aPeripheral readValueForCharacteristic:aChar];
            }
            else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_LIGHT_ALARM]]) {
                [aPeripheral setNotifyValue:YES forCharacteristic:aChar];
            }
            else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_CHAR_UUID_LIGHT_CURRENT]]) {
                [aPeripheral readValueForCharacteristic:aChar];
                [aPeripheral setNotifyValue:YES forCharacteristic:aChar];
            }
        }
    }
}

- (void)peripheral:(CBPeripheral *)aPeripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if ((characteristic.value)||(!error)) {
        [super peripheral:aPeripheral didUpdateValueForCharacteristic:characteristic error:error];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_CHAR_UUID_SOIL_TEMPERATURE_CURRENT]]||
                [characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_CHAR_UUID_LIGHT_CURRENT]]||
                [characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_CHAR_UUID_SOIL_MOISTURE_CURRENT]]) {
                
                NSString *hexString = [characteristic.value hexadecimalString];
                NSScanner *scanner = [NSScanner scannerWithString:hexString];
                unsigned int decimalValue;
                [scanner scanHexInt:&decimalValue];
                
                if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_CHAR_UUID_SOIL_TEMPERATURE_CURRENT]]) {
                    NSLog(@"GROW SOIL TEMPERATURE CURRENT HEX VALUE = %@", hexString);
                    //self.lastUpdateDate = [NSDate date];
                    //[self save:nil];
                    self.soilTemperature = decimalValue;
                    NSLog(@"GROW SOIL TEMPERATURE CURRENT VALUE = %i", decimalValue);
                    //[DatabaseManager saveNewSensorValueWithSensor:self valueType:kValueTypeSoilTemperature value:decimalValue];
                } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_CHAR_UUID_LIGHT_CURRENT]]) {
                    NSLog(@"GROW LIGHT CURRENT HEX VALUE = %@", hexString);
                    self.light = decimalValue;
                    NSLog(@"GROW LIGHT CURRENT VALUE = %i", decimalValue);
                    //[DatabaseManager saveNewSensorValueWithSensor:self valueType:kValueTypeGrowLight value:decimalValue];
                } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_CHAR_UUID_SOIL_MOISTURE_CURRENT]]) {
                    NSLog(@"GROW SOIL MOISTURE CURRENT HEX VALUE = %@", hexString);
                    self.soilMoisture = decimalValue;
                    NSLog(@"GROW SOIL MOISTURE CURRENT VALUE = %i", decimalValue);
                    //[DatabaseManager saveNewSensorValueWithSensor:self valueType:kValueTypeSoilHumidity value:decimalValue];
                }
            }
            else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_LIGHT_ALARM_SET]]||
                     [characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_SOIL_MOISTURE_ALARM_SET]]||
                     [characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_SOIL_TEMPERATURE_ALARM_SET]]) {
                uint8_t alarmSetValue  = 0;
                [[characteristic value] getBytes:&alarmSetValue length:sizeof (alarmSetValue)];
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
            }
            else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_LIGHT_ALARM]]||
                     [characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_SOIL_MOISTURE_ALARM]]||
                     [characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_SOIL_TEMPERATURE_ALARM]]) {
                uint8_t alarmValue  = 0;
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
            else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_LIGHT_ALARM_LOW_VALUE]]||
                     [characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_SOIL_MOISTURE_ALARM_LOW_VALUE]]||
                     [characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_SOIL_TEMPERATURE_ALARM_LOW_VALUE]]) {
                [self.delegate didReadMinAlarmValueFromCharacteristicUUID:characteristic.UUID];
            
            }
            else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_LIGHT_ALARM_HIGH_VALUE]]||
                     [characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_SOIL_MOISTURE_ALARM_HIGH_VALUE]]||
                     [characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_SOIL_TEMPERATURE_ALARM_HIGH_VALUE]]) {
                [self.delegate didReadMaxAlarmValueFromCharacteristicUUID:characteristic.UUID];
            }
        });
    }
}

- (void)alarmActionWithCharacteristic:(CBCharacteristic *)characteristic alarmType:(AlarmType)alarmtype {
    NSString *alertString;
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_LIGHT_ALARM]]) {
        if (_lightAlarmState != kAlarmStateEnabled) {
            return;
        }
        if (alarmtype == kAlarmHigh) {
            alertString = @"Light high value";
        }
        else {
            alertString = @"Light low value";
        }
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_SOIL_MOISTURE_ALARM]]) {
        if (_soilMoistureAlarmState != kAlarmStateEnabled) {
            return;
        }
        if (alarmtype == kAlarmHigh) {
            alertString = @"Soil moisture high value";
        }
        else {
            alertString = @"Soil moisture low value";
        }
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_SOIL_TEMPERATURE_ALARM]]) {
        if (_soilTempAlarmState != kAlarmStateEnabled) {
            return;
        }
        if (alarmtype == kAlarmHigh) {
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
