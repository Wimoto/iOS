//
//  GrowSensor.m
//  Wimoto
//
//  Created by Danny Kokarev on 25.12.13.
//
//

#import "GrowSensor.h"

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
    if (error) {
        return;
    }
    [super peripheral:aPeripheral didUpdateValueForCharacteristic:characteristic error:error];
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_CHAR_UUID_SOIL_TEMPERATURE_CURRENT]]) {
            self.soilTemperature = [self sensorValueForCharacteristic:characteristic];
            [self.entity saveNewValueWithType:kValueTypeSoilTemperature value:_soilTemperature];
        } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_CHAR_UUID_LIGHT_CURRENT]]) {
            self.light = [self sensorValueForCharacteristic:characteristic];
            [self.entity saveNewValueWithType:kValueTypeGrowLight value:_light];
        } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_CHAR_UUID_SOIL_MOISTURE_CURRENT]]) {
            self.soilMoisture = [self sensorValueForCharacteristic:characteristic];
            [self.entity saveNewValueWithType:kValueTypeSoilHumidity value:_soilMoisture];
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_LIGHT_ALARM_SET]]) {
            if (_lightAlarmState == kAlarmStateUnknown) {
                self.lightAlarmState = [self alarmStateForCharacteristic:characteristic];
            }
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_SOIL_MOISTURE_ALARM_SET]]) {
            if (_soilMoistureAlarmState == kAlarmStateUnknown) {
                self.soilMoistureAlarmState = [self alarmStateForCharacteristic:characteristic];
            }
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_SOIL_TEMPERATURE_ALARM_SET]]) {
            if (_soilTempAlarmState == kAlarmStateUnknown) {
                self.soilTempAlarmState = [self alarmStateForCharacteristic:characteristic];
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
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_LIGHT_ALARM_LOW_VALUE]]) {
            self.lightAlarmLow = [self alarmValueForCharacteristic:characteristic];
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_LIGHT_ALARM_HIGH_VALUE]]) {
            self.lightAlarmHigh = [self alarmValueForCharacteristic:characteristic];
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_SOIL_MOISTURE_ALARM_LOW_VALUE]]) {
            self.soilMoistureAlarmLow = [self alarmValueForCharacteristic:characteristic];
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_SOIL_MOISTURE_ALARM_HIGH_VALUE]]) {
            self.soilMoistureAlarmHigh = [self alarmValueForCharacteristic:characteristic];
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_SOIL_TEMPERATURE_ALARM_LOW_VALUE]]) {
            self.soilTemperatureAlarmLow = [self alarmValueForCharacteristic:characteristic];
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_SOIL_TEMPERATURE_ALARM_HIGH_VALUE]]) {
            self.soilTemperatureAlarmHigh = [self alarmValueForCharacteristic:characteristic];
        }
    });
}

- (void)alarmActionWithCharacteristic:(CBCharacteristic *)characteristic alarmType:(AlarmType)alarmtype {
    NSString *alertString = nil;
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

    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.alertBody = alertString;
    localNotification.alertAction = @"View";
    localNotification.category = @"Sensor";
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

@end
