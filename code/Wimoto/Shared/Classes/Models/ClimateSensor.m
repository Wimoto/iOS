//
//  ClimateSensor.m
//  Wimoto
//
//  Created by MC700 on 12/13/13.
//
//

#import "ClimateSensor.h"
#import "DatabaseManager.h"

@interface ClimateSensor ()

@end

@implementation ClimateSensor

#pragma mark - CBPeriferalDelegate

- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error {
    for (CBService *aService in aPeripheral.services) {
        NSLog(@"ClimateSensor didDiscoverServices %@", aService);
        if ([aService.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_SERVICE_UUID_TEMPERATURE]]) {
            [aPeripheral discoverCharacteristics:[NSArray arrayWithObjects:
                                                  [CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_TEMPERATURE_CURRENT],
                                                  [CBUUID UUIDWithString:BLE_CLIMATE_SERVICE_UUID_TEMPERATURE_ALARM_LOW_VALUE],
                                                  [CBUUID UUIDWithString:BLE_CLIMATE_SERVICE_UUID_TEMPERATURE_ALARM_HIGH_VALUE],
                                                  [CBUUID UUIDWithString:BLE_CLIMATE_SERVICE_UUID_TEMPERATURE_ALARM_SET],
                                                  [CBUUID UUIDWithString:BLE_CLIMATE_SERVICE_UUID_TEMPERATURE_ALARM],
                                                  nil]
                                      forService:aService];
            
        } else if ([aService.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_SERVICE_UUID_LIGHT]]) {
            [aPeripheral discoverCharacteristics:[NSArray arrayWithObjects:
                                                  [CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_LIGHT_CURRENT],
                                                  [CBUUID UUIDWithString:BLE_CLIMATE_SERVICE_UUID_LIGHT_ALARM_LOW_VALUE],
                                                  [CBUUID UUIDWithString:BLE_CLIMATE_SERVICE_UUID_LIGHT_ALARM_HIGH_VALUE],
                                                  [CBUUID UUIDWithString:BLE_CLIMATE_SERVICE_UUID_LIGHT_ALARM_SET],
                                                  [CBUUID UUIDWithString:BLE_CLIMATE_SERVICE_UUID_LIGHT_ALARM],
                                                  nil]
                                      forService:aService];
            
        } else if ([aService.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_SERVICE_UUID_HUMIDITY]]) {
            [aPeripheral discoverCharacteristics:[NSArray arrayWithObjects:
                                                  [CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_HUMIDITY_CURRENT],
                                                  [CBUUID UUIDWithString:BLE_CLIMATE_SERVICE_UUID_HUMIDITY_ALARM_LOW_VALUE],
                                                  [CBUUID UUIDWithString:BLE_CLIMATE_SERVICE_UUID_HUMIDITY_ALARM_HIGH_VALUE],
                                                  [CBUUID UUIDWithString:BLE_CLIMATE_SERVICE_UUID_HUMIDITY_ALARM_SET],
                                                  [CBUUID UUIDWithString:BLE_CLIMATE_SERVICE_UUID_HUMIDITY_ALARM],
                                                  nil]
                                      forService:aService];
        }
    }
}

- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if ([service.UUID.UUIDString isEqualToString:BLE_CLIMATE_SERVICE_UUID_TEMPERATURE]) {
        for (CBCharacteristic *aChar in service.characteristics) {
            if (([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_TEMPERATURE_CURRENT]])||
                ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_SERVICE_UUID_TEMPERATURE_ALARM_LOW_VALUE]])||
                ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_SERVICE_UUID_TEMPERATURE_ALARM_HIGH_VALUE]])||
                ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_SERVICE_UUID_TEMPERATURE_ALARM_SET]])||
                ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_SERVICE_UUID_TEMPERATURE_ALARM]]))
            {
                [aPeripheral readValueForCharacteristic:aChar];
                [aPeripheral setNotifyValue:YES forCharacteristic:aChar];
            }
        }
    }
    else if ([service.UUID.UUIDString isEqualToString:BLE_CLIMATE_SERVICE_UUID_LIGHT]) {
        for (CBCharacteristic *aChar in service.characteristics) {
            if (([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_LIGHT_CURRENT]])||
                ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_SERVICE_UUID_LIGHT_ALARM_LOW_VALUE]])||
                ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_SERVICE_UUID_LIGHT_ALARM_HIGH_VALUE]])||
                ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_SERVICE_UUID_LIGHT_ALARM_SET]])||
                ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_SERVICE_UUID_LIGHT_ALARM]]))
            {
                NSLog(@"FOUND ALARM LOW HIGH VALUE CHARACTERISTIC - %@", aChar);
                [aPeripheral readValueForCharacteristic:aChar];
                [aPeripheral setNotifyValue:YES forCharacteristic:aChar];
            }
        }
    }
    else if ([service.UUID.UUIDString isEqualToString:BLE_CLIMATE_SERVICE_UUID_HUMIDITY]) {
        for (CBCharacteristic *aChar in service.characteristics) {
            if (([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_HUMIDITY_CURRENT]])||
                ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_SERVICE_UUID_HUMIDITY_ALARM_LOW_VALUE]])||
                ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_SERVICE_UUID_HUMIDITY_ALARM_HIGH_VALUE]])||
                ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_SERVICE_UUID_HUMIDITY_ALARM_SET]])||
                ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_SERVICE_UUID_HUMIDITY_ALARM]]))
            {
                NSLog(@"FOUND ALARM CHARACTERISTIC - %@", aChar);
                [aPeripheral readValueForCharacteristic:aChar];
                [aPeripheral setNotifyValue:YES forCharacteristic:aChar];
            }
        }
    }
}

- (void)peripheral:(CBPeripheral *)aPeripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ((characteristic.value)||(!error)) {
            if ([characteristic.UUID.UUIDString isEqualToString:BLE_CLIMATE_CHAR_UUID_TEMPERATURE_CURRENT]||
                [characteristic.UUID.UUIDString isEqualToString:BLE_CLIMATE_CHAR_UUID_LIGHT_CURRENT]||
                [characteristic.UUID.UUIDString isEqualToString:BLE_CLIMATE_CHAR_UUID_HUMIDITY_CURRENT]) {
                const uint8_t *data = [characteristic.value bytes];
                uint16_t value16_t = CFSwapInt16LittleToHost(*(uint16_t *)(&data[1]));
                if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_TEMPERATURE_CURRENT]]) {
                    self.temperature = value16_t;
                    [DatabaseManager saveNewSensorValueWithSensor:self valueType:kValueTypeTemperature value:value16_t];
                } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_HUMIDITY_CURRENT]]) {
                    self.humidity = value16_t;
                    [DatabaseManager saveNewSensorValueWithSensor:self valueType:kValueTypeHumidity value:value16_t];
                } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_LIGHT_CURRENT]]) {
                    self.light = value16_t;
                    [DatabaseManager saveNewSensorValueWithSensor:self valueType:kValueTypeLight value:value16_t];
                }
            }
            else if ([characteristic.UUID.UUIDString isEqualToString:BLE_CLIMATE_SERVICE_UUID_TEMPERATURE_ALARM_SET]||
                     [characteristic.UUID.UUIDString isEqualToString:BLE_CLIMATE_SERVICE_UUID_LIGHT_ALARM_SET]||
                     [characteristic.UUID.UUIDString isEqualToString:BLE_CLIMATE_SERVICE_UUID_HUMIDITY_ALARM_SET]) {
                uint8_t alarmSetValue  = 0;
                [[characteristic value] getBytes:&alarmSetValue length:sizeof (alarmSetValue)];
                NSLog(@"ALARM SET CHARACTERISTIC %@ WITH VALUE - %hhu", characteristic, alarmSetValue);
                if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_SERVICE_UUID_TEMPERATURE_ALARM_SET]]) {
                    if (_temperatureAlarmState == kAlarmStateUnknown) {
                        self.temperatureAlarmState = (alarmSetValue & 0x01)?kAlarmStateEnabled:kAlarmStateDisabled;
                        [self.delegate didUpdateAlarmStateWithUUIDString:BLE_CLIMATE_SERVICE_UUID_TEMPERATURE_ALARM];
                    }
                } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_SERVICE_UUID_LIGHT_ALARM_SET]]) {
                    if (_lightAlarmState == kAlarmStateUnknown) {
                        self.lightAlarmState = (alarmSetValue & 0x01)?kAlarmStateEnabled:kAlarmStateDisabled;
                        [self.delegate didUpdateAlarmStateWithUUIDString:BLE_CLIMATE_SERVICE_UUID_LIGHT_ALARM];
                    }
                } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_SERVICE_UUID_HUMIDITY_ALARM_SET]]) {
                    if (_humidityAlarmState == kAlarmStateUnknown) {
                        self.humidityAlarmState = (alarmSetValue & 0x01)?kAlarmStateEnabled:kAlarmStateDisabled;
                        [self.delegate didUpdateAlarmStateWithUUIDString:BLE_CLIMATE_SERVICE_UUID_HUMIDITY_ALARM];
                    }
                }
            }
            else if ([characteristic.UUID.UUIDString isEqualToString:BLE_CLIMATE_SERVICE_UUID_TEMPERATURE_ALARM]||
                     [characteristic.UUID.UUIDString isEqualToString:BLE_CLIMATE_SERVICE_UUID_LIGHT_ALARM]||
                     [characteristic.UUID.UUIDString isEqualToString:BLE_CLIMATE_SERVICE_UUID_HUMIDITY_ALARM]) {
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
                else {
                    [self alarmServiceDidStopAlarm:characteristic];
                }
            }
            else if ([characteristic.UUID.UUIDString isEqualToString:BLE_CLIMATE_SERVICE_UUID_TEMPERATURE_ALARM_LOW_VALUE]||
                     [characteristic.UUID.UUIDString isEqualToString:BLE_CLIMATE_SERVICE_UUID_LIGHT_ALARM_LOW_VALUE]||
                     [characteristic.UUID.UUIDString isEqualToString:BLE_CLIMATE_SERVICE_UUID_HUMIDITY_ALARM_LOW_VALUE]) {
                [self.delegate didReadMinAlarmValueFromCharacteristicUUID:characteristic.UUID.UUIDString];
            }
            else if ([characteristic.UUID.UUIDString isEqualToString:BLE_CLIMATE_SERVICE_UUID_TEMPERATURE_ALARM_HIGH_VALUE]||
                     [characteristic.UUID.UUIDString isEqualToString:BLE_CLIMATE_SERVICE_UUID_LIGHT_ALARM_HIGH_VALUE]||
                     [characteristic.UUID.UUIDString isEqualToString:BLE_CLIMATE_SERVICE_UUID_HUMIDITY_ALARM_HIGH_VALUE]) {
                [self.delegate didReadMaxAlarmValueFromCharacteristicUUID:characteristic.UUID.UUIDString];
            }
        }
    });
}

- (void)alarmActionWithCharacteristic:(CBCharacteristic *)characteristic alarmType:(AlarmType)alarmtype {
    NSString *alertString = nil;
    if ([characteristic.UUID.UUIDString isEqualToString:BLE_CLIMATE_SERVICE_UUID_TEMPERATURE_ALARM]) {
        if (_temperatureAlarmState != kAlarmStateEnabled) {
            return;
        }
        if (alarmtype == kAlarmHigh) {
            alertString = @"Climate Temperature high value";
        }
        else {
            alertString = @"Climate Temperature low value";
        }
    }
    else if ([characteristic.UUID.UUIDString isEqualToString:BLE_CLIMATE_SERVICE_UUID_LIGHT_ALARM]) {
        if (_lightAlarmState != kAlarmStateEnabled) {
            return;
        }
        if (alarmtype == kAlarmHigh) {
            alertString = @"Climate Light high value";
        }
        else {
            alertString = @"Climate Light low value";
        }
    }
    else if ([characteristic.UUID.UUIDString isEqualToString:BLE_CLIMATE_SERVICE_UUID_HUMIDITY_ALARM]) {
        if (_humidityAlarmState != kAlarmStateEnabled) {
            return;
        }
        if (alarmtype == kAlarmHigh) {
            alertString = @"Climate Humidity high value";
        }
        else {
            alertString = @"Climate Humidity low value";
        }
    }
    NSLog(@"ALERT MESSAGE - %@", alertString);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alarm" message:alertString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
}

@end
