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

@interface ClimateSensor ()

@property (nonatomic) NSTimeInterval temperatureAlarmTimeshot;
@property (nonatomic) NSTimeInterval humidityAlarmTimeshot;
@property (nonatomic) NSTimeInterval lightAlarmTimeshot;

@end

@implementation ClimateSensor

@synthesize temperatureAlarmLow = _temperatureAlarmLow;
@synthesize temperatureAlarmHigh = _temperatureAlarmHigh;

- (PeripheralType)type {
    return kPeripheralTypeClimate;
}

- (NSString *)codename {
    return @"Climate";
}

- (float)temperatureFromMeasure {
    return (self.tempMeasure == kTemperatureMeasureCelsius)?_temperature:[self convertToFahrenheit:_temperature];
}

- (void)setTemperatureAlarmState:(AlarmState)temperatureAlarmState {
    _temperatureAlarmState = temperatureAlarmState;
    
    [super enableAlarm:(_temperatureAlarmState == kAlarmStateEnabled) forCharacteristicWithUUIDString:BLE_CLIMATE_CHAR_UUID_TEMPERATURE_ALARM_SET];
}

- (void)setHumidityAlarmState:(AlarmState)humidityAlarmState {
    _humidityAlarmState = humidityAlarmState;
    
    [super enableAlarm:(_humidityAlarmState == kAlarmStateEnabled) forCharacteristicWithUUIDString:BLE_CLIMATE_CHAR_UUID_HUMIDITY_ALARM_SET];
}

- (void)setLightAlarmState:(AlarmState)lightAlarmState {
    _lightAlarmState = lightAlarmState;
    
    [super enableAlarm:(_lightAlarmState == kAlarmStateEnabled) forCharacteristicWithUUIDString:BLE_CLIMATE_CHAR_UUID_LIGHT_ALARM_SET];
}

- (float)temperatureAlarmLow {
    return (self.tempMeasure == kTemperatureMeasureCelsius)?_temperatureAlarmLow:[self convertToFahrenheit:_temperatureAlarmLow];
}

- (void)setTemperatureAlarmLow:(float)temperatureAlarmLow {
    _temperatureAlarmLow = temperatureAlarmLow;
    
    [super writeAlarmValue:[self getSensorTemperatureFromTemperature:_temperatureAlarmLow] forCharacteristicWithUUIDString:BLE_CLIMATE_CHAR_UUID_TEMPERATURE_ALARM_LOW_VALUE];
}

- (float)temperatureAlarmHigh {
    return (self.tempMeasure == kTemperatureMeasureCelsius)?_temperatureAlarmHigh:[self convertToFahrenheit:_temperatureAlarmHigh];
}

- (void)setTemperatureAlarmHigh:(float)temperatureAlarmHigh {
    _temperatureAlarmHigh = temperatureAlarmHigh;
    
    [super writeAlarmValue:[self getSensorTemperatureFromTemperature:_temperatureAlarmHigh] forCharacteristicWithUUIDString:BLE_CLIMATE_CHAR_UUID_TEMPERATURE_ALARM_HIGH_VALUE];
}

- (void)setHumidityAlarmLow:(float)humidityAlarmLow {
    _humidityAlarmLow = humidityAlarmLow;
    
    [super writeAlarmValue:[self getSensorHumidityFromHumidity:_humidityAlarmLow] forCharacteristicWithUUIDString:BLE_CLIMATE_CHAR_UUID_HUMIDITY_ALARM_LOW_VALUE];
}

- (void)setHumidityAlarmHigh:(float)humidityAlarmHigh {
    _humidityAlarmHigh = humidityAlarmHigh;
    
    [super writeAlarmValue:[self getSensorHumidityFromHumidity:_humidityAlarmHigh] forCharacteristicWithUUIDString:BLE_CLIMATE_CHAR_UUID_HUMIDITY_ALARM_HIGH_VALUE];
}

- (void)setLightAlarmLow:(float)lightAlarmLow {
    _lightAlarmLow = lightAlarmLow;
    
    [super writeAlarmValue:_lightAlarmLow forCharacteristicWithUUIDString:BLE_CLIMATE_CHAR_UUID_LIGHT_ALARM_LOW_VALUE];
}

- (void)setLightAlarmHigh:(float)lightAlarmHigh {
    _lightAlarmHigh = lightAlarmHigh;
    
    [super writeAlarmValue:_lightAlarmHigh forCharacteristicWithUUIDString:BLE_CLIMATE_CHAR_UUID_LIGHT_ALARM_HIGH_VALUE];
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

- (void)enableAlarm:(BOOL)enable forCharacteristicWithUUIDString:(NSString *)UUIDString {
    if ([UUIDString isEqual:BLE_CLIMATE_CHAR_UUID_TEMPERATURE_ALARM_SET]) {
        self.temperatureAlarmState = (enable)?kAlarmStateEnabled:kAlarmStateDisabled;
    } else if ([UUIDString isEqual:BLE_CLIMATE_CHAR_UUID_LIGHT_ALARM_SET]) {
        self.lightAlarmState = (enable)?kAlarmStateEnabled:kAlarmStateDisabled;
    } else if ([UUIDString isEqual:BLE_CLIMATE_CHAR_UUID_HUMIDITY_ALARM_SET]) {
        self.humidityAlarmState = (enable)?kAlarmStateEnabled:kAlarmStateDisabled;
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
        } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_TEMPERATURE_ALARM]]) {
            if ((_temperatureAlarmState == kAlarmStateEnabled)&&([[NSDate date] timeIntervalSinceReferenceDate]>(_temperatureAlarmTimeshot+30))) {
                _temperatureAlarmTimeshot = [[NSDate date] timeIntervalSinceReferenceDate];
                
                AlarmType alarmType = [super alarmTypeForCharacteristic:characteristic];
                [super showAlarmNotification:[NSString stringWithFormat:@"%@ temperature %@", self.name, (alarmType == kAlarmHigh)?@"high value":@"low value"] forUuid:BLE_CLIMATE_CHAR_UUID_TEMPERATURE_ALARM_SET];
            }
        } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_LIGHT_ALARM]]) {
            if ((_lightAlarmState == kAlarmStateEnabled)&&([[NSDate date] timeIntervalSinceReferenceDate]>(_lightAlarmTimeshot+30))) {
                _lightAlarmTimeshot = [[NSDate date] timeIntervalSinceReferenceDate];
                
                AlarmType alarmType = [super alarmTypeForCharacteristic:characteristic];
                [super showAlarmNotification:[NSString stringWithFormat:@"%@ light %@", self.name, (alarmType == kAlarmHigh)?@"high value":@"low value"] forUuid:BLE_CLIMATE_CHAR_UUID_LIGHT_ALARM_SET];
            }
        } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_HUMIDITY_ALARM]]) {
            if ((_humidityAlarmState == kAlarmStateEnabled)&&([[NSDate date] timeIntervalSinceReferenceDate]>(_humidityAlarmTimeshot+30))) {
                _humidityAlarmTimeshot = [[NSDate date] timeIntervalSinceReferenceDate];
                
                AlarmType alarmType = [super alarmTypeForCharacteristic:characteristic];
                [super showAlarmNotification:[NSString stringWithFormat:@"%@ humidity %@", self.name, (alarmType == kAlarmHigh)?@"high value":@"low value"] forUuid:BLE_CLIMATE_CHAR_UUID_HUMIDITY_ALARM_SET];
            }
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_TEMPERATURE_ALARM_LOW_VALUE]]) {
            int16_t rValue = CFSwapInt16BigToHost((int16_t)[self alarmValueForCharacteristic:characteristic]);
            NSLog(@"BLE_CLIMATE_CHAR_UUID_TEMPERATURE_ALARM_LOW_VALUE - %@ %d %f %@", aPeripheral.name, rValue, [self alarmValueForCharacteristic:characteristic], [characteristic value]);
            self.temperatureAlarmLow = [self getTemperatureFromSensorTemperature:rValue];
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_TEMPERATURE_ALARM_HIGH_VALUE]]) {
            int16_t rValue = CFSwapInt16BigToHost((int16_t)[self alarmValueForCharacteristic:characteristic]);
            NSLog(@"BLE_CLIMATE_CHAR_UUID_TEMPERATURE_ALARM_HIGH_VALUE - %@ %d %f %@", aPeripheral.name, rValue, [self alarmValueForCharacteristic:characteristic], [characteristic value]);
            self.temperatureAlarmHigh = [self getTemperatureFromSensorTemperature:rValue];
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

@end
