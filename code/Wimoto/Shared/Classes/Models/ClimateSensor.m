//
//  ClimateSensor.m
//  Wimoto
//
//  Created by MC700 on 12/13/13.
//
//

#import "ClimateSensor.h"
#import "SensorHelper.h"
#import "AppConstants.h"

@implementation ClimateSensor

- (PeripheralType)type {
    return kPeripheralTypeClimate;
}

- (NSString *)codename {
    return @"Climate";
}

- (float)temperature {
    return (self.tempMeasure == kTemperatureMeasureCelsius)?_temperature:[self convertToFahrenheit:_temperature];
}

- (float)temperatureAlarmHigh {
    return (self.tempMeasure == kTemperatureMeasureCelsius)?_temperatureAlarmHigh:[self convertToFahrenheit:_temperatureAlarmHigh];
}

- (float)temperatureAlarmLow {
    return (self.tempMeasure == kTemperatureMeasureCelsius)?_temperatureAlarmLow:[self convertToFahrenheit:_temperatureAlarmLow];
}

- (float)getTemperatureFromSensorTemperature:(int)sensorTemperature {
    return [self roundToOne:-46.85 + (175.72*sensorTemperature/65536)];
}

- (int)getSensorTemperatureFromTemperature:(float)temperature {
    return ((46.85+temperature)*65536)/175.72;
}

- (float)getHumidityFromSensorHumidity:(int)sensorHumidity {
    return [self roundToOne:-6.0 + (125.0*sensorHumidity/65536)];
}

- (int)getSensorHumidityFromHumidity:(float)humidity {
    return ((6+humidity)*65536)/125;
}

- (void)writeAlarmValue:(int)alarmValue forCharacteristicWithUUIDString:(NSString *)UUIDString {
    if (([BLE_CLIMATE_CHAR_UUID_TEMPERATURE_ALARM_HIGH_VALUE isEqualToString:UUIDString]) ||
        ([BLE_CLIMATE_CHAR_UUID_TEMPERATURE_ALARM_LOW_VALUE isEqualToString:UUIDString])) {
        [super writeAlarmValue:[self getSensorTemperatureFromTemperature:alarmValue] forCharacteristicWithUUIDString:UUIDString];
    } else if (([BLE_CLIMATE_CHAR_UUID_HUMIDITY_ALARM_HIGH_VALUE isEqualToString:UUIDString]) ||
               ([BLE_CLIMATE_CHAR_UUID_HUMIDITY_ALARM_LOW_VALUE isEqualToString:UUIDString])) {
        [super writeAlarmValue:[self getSensorHumidityFromHumidity:alarmValue] forCharacteristicWithUUIDString:UUIDString];
    } else {
        [super writeAlarmValue:alarmValue forCharacteristicWithUUIDString:UUIDString];
    }
}

#pragma mark - CBPeriferalDelegate

- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error {
    [super peripheral:aPeripheral didDiscoverServices:error];
    for (CBService *aService in aPeripheral.services) {
        if ([aService.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_SERVICE_UUID_TEMPERATURE]]) {
            [aPeripheral discoverCharacteristics:[NSArray arrayWithObjects:
                                                  [CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_TEMPERATURE_CURRENT],
                                                  [CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_TEMPERATURE_ALARM_LOW_VALUE],
                                                  [CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_TEMPERATURE_ALARM_HIGH_VALUE],
                                                  [CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_TEMPERATURE_ALARM_SET],
                                                  [CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_TEMPERATURE_ALARM],
                                                  nil]
                                      forService:aService];
            
        } else if ([aService.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_SERVICE_UUID_LIGHT]]) {
            [aPeripheral discoverCharacteristics:[NSArray arrayWithObjects:
                                                  [CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_LIGHT_CURRENT],
                                                  [CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_LIGHT_ALARM_LOW_VALUE],
                                                  [CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_LIGHT_ALARM_HIGH_VALUE],
                                                  [CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_LIGHT_ALARM_SET],
                                                  [CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_LIGHT_ALARM],
                                                  nil]
                                      forService:aService];
            
        } else if ([aService.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_SERVICE_UUID_HUMIDITY]]) {
            [aPeripheral discoverCharacteristics:[NSArray arrayWithObjects:
                                                  [CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_HUMIDITY_CURRENT],
                                                  [CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_HUMIDITY_ALARM_LOW_VALUE],
                                                  [CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_HUMIDITY_ALARM_HIGH_VALUE],
                                                  [CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_HUMIDITY_ALARM_SET],
                                                  [CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_HUMIDITY_ALARM],
                                                  nil]
                                      forService:aService];
        } else if ([aService.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_SERVICE_UUID_DFU]]) {
            [aPeripheral discoverCharacteristics:[NSArray arrayWithObjects:
                                                  [CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_DFU_MODE_SET],
                                                  [CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_DFU_TIMESTAMP],
                                                  nil]
                                      forService:aService];
        } else if ([aService.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_SERVICE_UUID_DATA_LOGGER]]) {
            [aPeripheral discoverCharacteristics:[NSArray arrayWithObjects:
                                                  [CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_DATA_LOGGER_ENABLE],
                                                  [CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_DATA_LOGGER_READ_ENABLE],
                                                  [CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_DATA_LOGGER_READ],
                                                  nil]
                                      forService:aService];
        }
    }
}

- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    [super peripheral:aPeripheral didDiscoverCharacteristicsForService:service error:error];
    if ([service.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_SERVICE_UUID_TEMPERATURE]]) {
        for (CBCharacteristic *aChar in service.characteristics) {
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_TEMPERATURE_ALARM_LOW_VALUE]]||
                [aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_TEMPERATURE_ALARM_HIGH_VALUE]]||
                [aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_TEMPERATURE_ALARM_SET]]) {
                [aPeripheral readValueForCharacteristic:aChar];
            }
            else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_TEMPERATURE_ALARM]]) {
                [aPeripheral setNotifyValue:YES forCharacteristic:aChar];
            }
            else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_TEMPERATURE_CURRENT]]) {
                [aPeripheral readValueForCharacteristic:aChar];
                [aPeripheral setNotifyValue:YES forCharacteristic:aChar];
            }
        }
    }
    else if ([service.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_SERVICE_UUID_LIGHT]]) {
        for (CBCharacteristic *aChar in service.characteristics) {
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_LIGHT_ALARM_LOW_VALUE]]||
                [aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_LIGHT_ALARM_HIGH_VALUE]]||
                [aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_LIGHT_ALARM_SET]]) {
                [aPeripheral readValueForCharacteristic:aChar];
            }
            else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_LIGHT_ALARM]]) {
                [aPeripheral setNotifyValue:YES forCharacteristic:aChar];
            }
            else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_LIGHT_CURRENT]]) {
                [aPeripheral readValueForCharacteristic:aChar];
                [aPeripheral setNotifyValue:YES forCharacteristic:aChar];
            }
        }
    }
    else if ([service.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_SERVICE_UUID_HUMIDITY]]) {
        for (CBCharacteristic *aChar in service.characteristics) {
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_HUMIDITY_ALARM_LOW_VALUE]]||
                [aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_HUMIDITY_ALARM_HIGH_VALUE]]||
                [aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_HUMIDITY_ALARM_SET]]) {
                [aPeripheral readValueForCharacteristic:aChar];
            }
            else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_HUMIDITY_ALARM]]) {
                [aPeripheral setNotifyValue:YES forCharacteristic:aChar];
            }
            else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_HUMIDITY_CURRENT]]) {
                [aPeripheral readValueForCharacteristic:aChar];
                [aPeripheral setNotifyValue:YES forCharacteristic:aChar];
            }
            
        }
    }
    else if ([service.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_SERVICE_UUID_DFU]]) {
        for (CBCharacteristic *aChar in service.characteristics) {
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_DFU_MODE_SET]]) {
                self.dfuModeSetCharacteristic = aChar;
            }
        }
    }
    else if ([service.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_SERVICE_UUID_DATA_LOGGER]]) {
        for (CBCharacteristic *aChar in service.characteristics) {
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_DATA_LOGGER_ENABLE]]) {
                self.dataLoggerEnableCharacteristic = aChar;
                [aPeripheral readValueForCharacteristic:aChar];
            }
            else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_DATA_LOGGER_READ_ENABLE]]) {
                self.dataLoggerReadEnableCharacteristic = aChar;
            }
            else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_DATA_LOGGER_READ]]) {
                self.dataLoggerReadNotificationCharacteristic = aChar;
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
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_TEMPERATURE_CURRENT]]) {
            self.temperature = [self getTemperatureFromSensorTemperature:[self sensorValueForCharacteristic:characteristic]];
            [self.entity saveNewValueWithType:kValueTypeTemperature value:_temperature];
        } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_HUMIDITY_CURRENT]]) {
            self.humidity = [self getHumidityFromSensorHumidity:[self sensorValueForCharacteristic:characteristic]];
            [self.entity saveNewValueWithType:kValueTypeHumidity value:_humidity];
        } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_LIGHT_CURRENT]]) {
            self.light = 0.96 * [self sensorValueForCharacteristic:characteristic];
            [self.entity saveNewValueWithType:kValueTypeLight value:_light];
        } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_TEMPERATURE_ALARM_SET]]) {
            if (_temperatureAlarmState == kAlarmStateUnknown) {
                self.temperatureAlarmState = [self alarmStateForCharacteristic:characteristic];
            }
        } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_LIGHT_ALARM_SET]]) {
            if (_lightAlarmState == kAlarmStateUnknown) {
                self.lightAlarmState = [self alarmStateForCharacteristic:characteristic];
            }
        } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_HUMIDITY_ALARM_SET]]) {
            if (_humidityAlarmState == kAlarmStateUnknown) {
                self.humidityAlarmState = [self alarmStateForCharacteristic:characteristic];
            }
        } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_TEMPERATURE_ALARM]]||
                 [characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_LIGHT_ALARM]]||
                 [characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_HUMIDITY_ALARM]]) {
            NSLog(@"ALARM NOTIFICATION HEX %@", [characteristic.value hexadecimalString]);
            
            uint8_t alarmValue  = 0;
            [[characteristic value] getBytes:&alarmValue length:1];
            NSLog(@"alarm!  0x%x", alarmValue);
            if (alarmValue & 0x02) {
                NSLog(@"ALARM HIGH VALUE");
                [self alarmActionWithCharacteristic:characteristic alarmType:kAlarmHigh];
            }
            else if (alarmValue & 0x01) {
                NSLog(@"ALARM LOW VALUE");
                [self alarmActionWithCharacteristic:characteristic alarmType:kAlarmLow];
            }
            else {
                [self alarmServiceDidStopAlarm:characteristic];
            }
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_TEMPERATURE_ALARM_LOW_VALUE]]) {
            NSLog(@"BLE_CLIMATE_CHAR_UUID_TEMPERATURE_ALARM_LOW_VALUE %@", characteristic.value);
            
            self.temperatureAlarmLow = [self getTemperatureFromSensorTemperature:[self alarmValueForCharacteristic:characteristic]];
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_TEMPERATURE_ALARM_HIGH_VALUE]]) {
            NSLog(@"BLE_CLIMATE_CHAR_UUID_TEMPERATURE_ALARM_HIGH_VALUE %@", characteristic.value);

            self.temperatureAlarmHigh = [self getTemperatureFromSensorTemperature:[self alarmValueForCharacteristic:characteristic]];
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_HUMIDITY_ALARM_LOW_VALUE]]) {
            self.humidityAlarmLow = [self getHumidityFromSensorHumidity:[self alarmValueForCharacteristic:characteristic]];
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_HUMIDITY_ALARM_HIGH_VALUE]]) {
            self.humidityAlarmHigh = [self getHumidityFromSensorHumidity:[self alarmValueForCharacteristic:characteristic]];
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_LIGHT_ALARM_LOW_VALUE]]) {
            self.lightAlarmLow = [self alarmValueForCharacteristic:characteristic];
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_LIGHT_ALARM_HIGH_VALUE]]) {
            self.lightAlarmHigh = [self alarmValueForCharacteristic:characteristic];
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_DATA_LOGGER_ENABLE]]) {
            self.dataLoggerState = [self dataLoggerStateForCharacteristic:characteristic];
        }
        else if ([characteristic isEqual:self.dataLoggerReadNotificationCharacteristic]) {
            NSString *dataLogger = [[NSString alloc] initWithData:characteristic.value encoding:NSASCIIStringEncoding];
            
            NSLog(@"dataLogger is %@", dataLogger);
            [self.dataReadingDelegate didUpdateSensorReadingData:characteristic.value error:error];
        }
    });
}

- (void)alarmActionWithCharacteristic:(CBCharacteristic *)characteristic alarmType:(AlarmType)alarmtype {
    NSString *alertString = nil;
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_TEMPERATURE_ALARM]]) {
        if (_temperatureAlarmState != kAlarmStateEnabled) {
            return;
        }
        alertString = [NSString stringWithFormat:@"%@ temperature %@", self.name, (alarmtype == kAlarmHigh)?@"high value":@"low value"];
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_LIGHT_ALARM]]) {
        if (_lightAlarmState != kAlarmStateEnabled) {
            return;
        }
        alertString = [NSString stringWithFormat:@"%@ light %@", self.name, (alarmtype == kAlarmHigh)?@"high value":@"low value"];
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_HUMIDITY_ALARM]]) {
        if (_humidityAlarmState != kAlarmStateEnabled) {
            return;
        }
        alertString = [NSString stringWithFormat:@"%@ humidity %@", self.name, (alarmtype == kAlarmHigh)?@"high value":@"low value"];
    }
    NSLog(@"ALERT MESSAGE - %@", alertString);
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
