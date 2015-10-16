//
//  GrowSensor.m
//  Wimoto
//
//  Created by Danny Kokarev on 25.12.13.
//
//

#import "GrowSensor.h"
#import "AppConstants.h"

#import "GrowSensorEntity.h"

@interface GrowSensor ()

@property (nonatomic) NSTimeInterval soilMoistureAlarmTimeshot;
@property (nonatomic) NSTimeInterval soilTempAlarmTimeshot;
@property (nonatomic) NSTimeInterval lightAlarmTimeshot;

@property (nonatomic, strong) CBCharacteristic *soilMoistureAlarmLowValueCharacteristic;
@property (nonatomic, strong) CBCharacteristic *soilMoistureAlarmHighValueCharacteristic;
@property (nonatomic, strong) CBCharacteristic *soilMoistureAlarmSetCharacteristic;
@property (nonatomic, strong) CBCharacteristic *soilMoistureAlarmCharacteristic;

@property (nonatomic, strong) CBCharacteristic *soilMoistureCurrentValueCharacteristic;

@end

@implementation GrowSensor

@synthesize soilMoistureAlarmLow = _soilMoistureAlarmLow;
@synthesize soilMoistureAlarmHigh = _soilMoistureAlarmHigh;
@synthesize soilTemperatureAlarmLow = _soilTemperatureAlarmLow;
@synthesize soilTemperatureAlarmHigh = _soilTemperatureAlarmHigh;
@synthesize lightAlarmLow = _lightAlarmLow;
@synthesize lightAlarmHigh = _lightAlarmHigh;

- (id)initWithEntity:(SensorEntity *)entity {
    self = [super initWithEntity:entity];
    if (self) {
        _calibrationState = kGrowCalibrationStateDefault;
        _lowHumidityCalibration     = [(GrowSensorEntity *)entity lowHumidityCalibration];
        _highHumidityCalibration    = [(GrowSensorEntity *)entity highHumidityCalibration];
    }
    
    return self;
}

- (PeripheralType)type {
    return kPeripheralTypeGrow;
}

- (NSString *)codename {
    return @"Grow";
}

- (void)setSoilMoistureAlarmState:(AlarmState)soilMoistureAlarmState {
    _soilMoistureAlarmState = soilMoistureAlarmState;
    [super enableAlarm:(_soilMoistureAlarmState == kAlarmStateEnabled) forCharacteristicWithUUIDString:BLE_GROW_CHAR_UUID_SOIL_MOISTURE_ALARM_SET];
}

- (void)setSoilTempAlarmState:(AlarmState)soilTempAlarmState {
    _soilTempAlarmState = soilTempAlarmState;
    [super enableAlarm:(_soilTempAlarmState == kAlarmStateEnabled) forCharacteristicWithUUIDString:BLE_GROW_CHAR_UUID_SOIL_TEMPERATURE_ALARM_SET];
}

- (void)setLightAlarmState:(AlarmState)lightAlarmState {
    _lightAlarmState = lightAlarmState;
    [super enableAlarm:(_lightAlarmState == kAlarmStateEnabled) forCharacteristicWithUUIDString:BLE_GROW_CHAR_UUID_LIGHT_ALARM_SET];
}

- (void)setSoilMoistureAlarmLow:(float)soilMoistureAlarmLow {
    _soilMoistureAlarmLow = soilMoistureAlarmLow;
    [self writeAlarmValue:_soilMoistureAlarmLow forCharacteristicWithUUIDString:BLE_GROW_CHAR_UUID_SOIL_MOISTURE_ALARM_LOW_VALUE];
}

- (void)setSoilMoistureAlarmHigh:(float)soilMoistureAlarmHigh {
    _soilMoistureAlarmHigh = soilMoistureAlarmHigh;
    [self writeAlarmValue:_soilMoistureAlarmHigh forCharacteristicWithUUIDString:BLE_GROW_CHAR_UUID_SOIL_MOISTURE_ALARM_HIGH_VALUE];
}

- (void)setSoilTemperatureAlarmLow:(float)soilTemperatureAlarmLow {
    _soilTemperatureAlarmLow = soilTemperatureAlarmLow;
    [super writeAlarmValue:[self getSensorTemperatureFromTemperature:_soilTemperatureAlarmLow] forCharacteristicWithUUIDString:BLE_GROW_CHAR_UUID_SOIL_TEMPERATURE_ALARM_LOW_VALUE];
}

- (void)setSoilTemperatureAlarmHigh:(float)soilTemperatureAlarmHigh {
    _soilTemperatureAlarmHigh = soilTemperatureAlarmHigh;
    [super writeAlarmValue:[self getSensorTemperatureFromTemperature:_soilTemperatureAlarmHigh] forCharacteristicWithUUIDString:BLE_GROW_CHAR_UUID_SOIL_TEMPERATURE_ALARM_HIGH_VALUE];
}

- (void)setLightAlarmLow:(float)lightAlarmLow {
    _lightAlarmLow = lightAlarmLow;
    [super writeAlarmValue:_lightAlarmLow forCharacteristicWithUUIDString:BLE_GROW_CHAR_UUID_LIGHT_ALARM_LOW_VALUE];
}

- (void)setLightAlarmHigh:(float)lightAlarmHigh {
    _lightAlarmHigh = lightAlarmHigh;
    [super writeAlarmValue:_lightAlarmLow forCharacteristicWithUUIDString:BLE_GROW_CHAR_UUID_LIGHT_ALARM_HIGH_VALUE];
}

- (float)getTemperatureFromSensorTemperature:(int)sensorTemperature {
    float converted_temp = 0;
    if(sensorTemperature < 2048) {
        converted_temp = sensorTemperature * 0.0625;
    } else {
        converted_temp = ((~sensorTemperature + 1) & 0x00000FFF) * -0.0625;
    }
    
    return [self roundToOne:converted_temp];
}

- (int)getSensorTemperatureFromTemperature:(float)temperature {
    int converted_temp = 0;
    if (temperature >= 0) {
        converted_temp = temperature / 0.0625;
    } else {
        converted_temp = temperature / 0.0625;
        converted_temp = ( ~-converted_temp|2048 ) + 1;
    }
    
    return converted_temp;
}

- (void)enableAlarm:(BOOL)enable forCharacteristicWithUUIDString:(NSString *)UUIDString {
    if ([UUIDString isEqual:BLE_GROW_CHAR_UUID_SOIL_MOISTURE_ALARM_SET]) {
        self.soilMoistureAlarmState = (enable)?kAlarmStateEnabled:kAlarmStateDisabled;
    } else if ([UUIDString isEqual:BLE_GROW_CHAR_UUID_SOIL_TEMPERATURE_ALARM_SET]) {
        self.soilTempAlarmState = (enable)?kAlarmStateEnabled:kAlarmStateDisabled;
    } else if ([UUIDString isEqual:BLE_GROW_CHAR_UUID_LIGHT_ALARM_SET]) {
        self.lightAlarmState = (enable)?kAlarmStateEnabled:kAlarmStateDisabled;
    }
}

- (void)setCalibrationState:(GrowCalibrationState)calibrationState {
    GrowCalibrationState previousState = _calibrationState;
    _calibrationState = calibrationState;
    
    if ((previousState == kGrowCalibrationStateDefault) && (_calibrationState == kGrowCalibrationStateHighValueStarted)) {
        char bytes[1] = { 0xFF };
        [self.peripheral writeValue:[NSData dataWithBytes:bytes length:1] forCharacteristic:_soilMoistureAlarmHighValueCharacteristic type:CBCharacteristicWriteWithResponse];
        [self performSelector:@selector(readMoistureValue) withObject:nil afterDelay:2.0];
    } else if (_calibrationState == kGrowCalibrationStateLowValueStarted) {
        char bytes[1] = { 0x00 };
        [self.peripheral writeValue:[NSData dataWithBytes:bytes length:1] forCharacteristic:_soilMoistureAlarmLowValueCharacteristic type:CBCharacteristicWriteWithResponse];
    }
}

- (void)readMoistureValue {
    [self.peripheral readValueForCharacteristic:_soilMoistureCurrentValueCharacteristic];
}

- (void)writeAlarmValue:(int)alarmValue forCharacteristicWithUUIDString:(NSString *)UUIDString {
    if (([UUIDString isEqual:BLE_GROW_CHAR_UUID_SOIL_MOISTURE_ALARM_HIGH_VALUE]) || ([UUIDString isEqual:BLE_GROW_CHAR_UUID_SOIL_MOISTURE_ALARM_LOW_VALUE])) {
        CBCharacteristic *alarmCharacteristic;
        for (CBService *service in [self.peripheral services]) {
            for (CBCharacteristic *characteristic in [service characteristics]) {
                if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:UUIDString]]) {
                    alarmCharacteristic = characteristic;
                    break;
                }
            }
        }
        if (!alarmCharacteristic) {
            NSLog(@"No valid characteristic");
            return;
        }
        
        unsigned char value = (unsigned char)alarmValue;
        NSData *data = [NSData dataWithBytes:&value length:sizeof(value)];
        NSLog(@"GRowe ALARM WRITE HIGH VALUE - %d  %@   %@   %lu", alarmValue, UUIDString, data, sizeof(value));
        [self.peripheral writeValue:data forCharacteristic:alarmCharacteristic type:CBCharacteristicWriteWithResponse];
    } else {
        [super writeAlarmValue:alarmValue forCharacteristicWithUUIDString:UUIDString];
    }
}

- (void)save {
    GrowSensorEntity *sensorEntity = (GrowSensorEntity *)self.entity;
    sensorEntity.lowHumidityCalibration     = _lowHumidityCalibration;
    sensorEntity.highHumidityCalibration    = _highHumidityCalibration;
    dispatch_async([QueueManager databaseQueue], ^{
        [sensorEntity save:nil];
    });
}

#pragma mark - CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if ([characteristic isEqual:_soilMoistureAlarmHighValueCharacteristic]) {
        if ((!error) && (_calibrationState == kGrowCalibrationStateHighValueStarted)) {
            self.calibrationState = kGrowCalibrationStateHighValueInProgress;
        }
    } else if ([characteristic isEqual:_soilMoistureAlarmLowValueCharacteristic]) {
        if ((!error) && (_calibrationState == kGrowCalibrationStateLowValueStarted)) {
            self.calibrationState = kGrowCalibrationStateLowValueInProgress;
        }
    }
}

#pragma mark - CBPeriferalDelegate

- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error {
    [super peripheral:aPeripheral didDiscoverServices:error];
    for (CBService *aService in aPeripheral.services) {
        NSLog(@"GrowSensor didDiscoverServices %@", aService);
        if ([aService.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_LIGHT]]) {
            [aPeripheral discoverCharacteristics:[NSArray arrayWithObjects:
                                                  [CBUUID UUIDWithString:BLE_GROW_CHAR_UUID_LIGHT_CURRENT],
                                                  [CBUUID UUIDWithString:BLE_GROW_CHAR_UUID_LIGHT_ALARM_LOW_VALUE],
                                                  [CBUUID UUIDWithString:BLE_GROW_CHAR_UUID_LIGHT_ALARM_HIGH_VALUE],
                                                  [CBUUID UUIDWithString:BLE_GROW_CHAR_UUID_LIGHT_ALARM_SET],
                                                  [CBUUID UUIDWithString:BLE_GROW_CHAR_UUID_LIGHT_ALARM],
                                                  nil]
                                      forService:aService];
            
        } else if ([aService.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_SOIL_MOISTURE]]) {
            [aPeripheral discoverCharacteristics:[NSArray arrayWithObjects:
                                                  [CBUUID UUIDWithString:BLE_GROW_CHAR_UUID_SOIL_MOISTURE_CURRENT],
                                                  [CBUUID UUIDWithString:BLE_GROW_CHAR_UUID_SOIL_MOISTURE_ALARM_LOW_VALUE],
                                                  [CBUUID UUIDWithString:BLE_GROW_CHAR_UUID_SOIL_MOISTURE_ALARM_HIGH_VALUE],
                                                  [CBUUID UUIDWithString:BLE_GROW_CHAR_UUID_SOIL_MOISTURE_ALARM_SET],
                                                  [CBUUID UUIDWithString:BLE_GROW_CHAR_UUID_SOIL_MOISTURE_ALARM],
                                                  nil]
                                      forService:aService];
            
        } else if ([aService.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_SOIL_TEMPERATURE]]) {
            [aPeripheral discoverCharacteristics:[NSArray arrayWithObjects:
                                                  [CBUUID UUIDWithString:BLE_GROW_CHAR_UUID_SOIL_TEMPERATURE_CURRENT],
                                                  [CBUUID UUIDWithString:BLE_GROW_CHAR_UUID_SOIL_TEMPERATURE_ALARM_LOW_VALUE],
                                                  [CBUUID UUIDWithString:BLE_GROW_CHAR_UUID_SOIL_TEMPERATURE_ALARM_HIGH_VALUE],
                                                  [CBUUID UUIDWithString:BLE_GROW_CHAR_UUID_SOIL_TEMPERATURE_ALARM_SET],
                                                  [CBUUID UUIDWithString:BLE_GROW_CHAR_UUID_SOIL_TEMPERATURE_ALARM],
                                                  nil]
                                      forService:aService];
        }
    }
}

- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    [super peripheral:aPeripheral didDiscoverCharacteristicsForService:service error:error];
    if ([service.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_SOIL_TEMPERATURE]]) {
         for (CBCharacteristic *aChar in service.characteristics) {
             if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_CHAR_UUID_SOIL_TEMPERATURE_ALARM_LOW_VALUE]]||
                 [aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_CHAR_UUID_SOIL_TEMPERATURE_ALARM_HIGH_VALUE]]||
                 [aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_CHAR_UUID_SOIL_TEMPERATURE_ALARM_SET]]) {
                 [aPeripheral readValueForCharacteristic:aChar];
             }
             else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_CHAR_UUID_SOIL_TEMPERATURE_ALARM]]) {
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
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_CHAR_UUID_SOIL_MOISTURE_ALARM_LOW_VALUE]]) {
                _soilMoistureAlarmLowValueCharacteristic = aChar;
                [aPeripheral readValueForCharacteristic:_soilMoistureAlarmLowValueCharacteristic];
            } else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_CHAR_UUID_SOIL_MOISTURE_ALARM_HIGH_VALUE]]) {
                _soilMoistureAlarmHighValueCharacteristic = aChar;
                [aPeripheral readValueForCharacteristic:_soilMoistureAlarmHighValueCharacteristic];
            } else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_CHAR_UUID_SOIL_MOISTURE_ALARM_SET]]) {
                _soilMoistureAlarmSetCharacteristic = aChar;
                [aPeripheral readValueForCharacteristic:_soilMoistureAlarmSetCharacteristic];
            }
            else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_CHAR_UUID_SOIL_MOISTURE_ALARM]]) {
                _soilMoistureAlarmCharacteristic = aChar;
                [aPeripheral setNotifyValue:YES forCharacteristic:_soilMoistureAlarmCharacteristic];
            }
            else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_CHAR_UUID_SOIL_MOISTURE_CURRENT]]) {
                _soilMoistureCurrentValueCharacteristic = aChar;
                [aPeripheral readValueForCharacteristic:_soilMoistureCurrentValueCharacteristic];
                [aPeripheral setNotifyValue:YES forCharacteristic:_soilMoistureCurrentValueCharacteristic];
            }
        }
    }
    else if ([service.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_LIGHT]]) {
        for (CBCharacteristic *aChar in service.characteristics) {
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_CHAR_UUID_LIGHT_ALARM_LOW_VALUE]]||
                [aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_CHAR_UUID_LIGHT_ALARM_HIGH_VALUE]]||
                [aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_CHAR_UUID_LIGHT_ALARM_SET]]) {
                [aPeripheral readValueForCharacteristic:aChar];
            }
            else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_CHAR_UUID_LIGHT_ALARM]]) {
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
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_CHAR_UUID_SOIL_TEMPERATURE_CURRENT]]) {
        self.soilTemperature = [self getTemperatureFromSensorTemperature:[self sensorValueForCharacteristic:characteristic]];
        [self.entity saveNewValueWithType:kValueTypeSoilTemperature value:_soilTemperature];
    } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_CHAR_UUID_LIGHT_CURRENT]]) {
        self.light = [self sensorValueForCharacteristic:characteristic];
        [self.entity saveNewValueWithType:kValueTypeGrowLight value:_light];
    } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_CHAR_UUID_SOIL_MOISTURE_CURRENT]]) {
        self.soilMoisture = [self roundToOne:[self sensorValueForCharacteristic:characteristic]];
        [self.entity saveNewValueWithType:kValueTypeSoilHumidity value:_soilMoisture];
        
        if (_calibrationState == kGrowCalibrationStateLowValueInProgress) {
            self.lowHumidityCalibration = [NSNumber numberWithFloat:[self roundToOne:[self sensorValueForCharacteristic:characteristic]]];
            self.calibrationState = kGrowCalibrationStateLowValueFinished;
        } else if (_calibrationState == kGrowCalibrationStateHighValueInProgress) {
            self.highHumidityCalibration = [NSNumber numberWithFloat:[self roundToOne:[self sensorValueForCharacteristic:characteristic]]];
            self.calibrationState = kGrowCalibrationStateHighValueFinished;
        }
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_CHAR_UUID_LIGHT_ALARM_SET]]) {
        if (_lightAlarmState == kAlarmStateUnknown) {
            self.lightAlarmState = [self alarmStateForCharacteristic:characteristic];
        }
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_CHAR_UUID_SOIL_MOISTURE_ALARM_SET]]) {
        if (_soilMoistureAlarmState == kAlarmStateUnknown) {
            self.soilMoistureAlarmState = [self alarmStateForCharacteristic:characteristic];
        }
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_CHAR_UUID_SOIL_TEMPERATURE_ALARM_SET]]) {
        if (_soilTempAlarmState == kAlarmStateUnknown) {
            self.soilTempAlarmState = [self alarmStateForCharacteristic:characteristic];
        }
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_CHAR_UUID_LIGHT_ALARM]]) {
        if ((_lightAlarmState == kAlarmStateEnabled)&&([[NSDate date] timeIntervalSinceReferenceDate]>(_lightAlarmTimeshot+30))) {
            _lightAlarmTimeshot = [[NSDate date] timeIntervalSinceReferenceDate];
            
            AlarmType alarmType = [super alarmTypeForCharacteristic:characteristic];
            [super showAlarmNotification:[NSString stringWithFormat:@"%@ light %@", self.name, (alarmType == kAlarmHigh)?@"high value":@"low value"] forUuid:BLE_GROW_CHAR_UUID_LIGHT_ALARM_SET];
        }
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_CHAR_UUID_SOIL_MOISTURE_ALARM]]) {
        if ((_soilMoistureAlarmState == kAlarmStateEnabled)&&([[NSDate date] timeIntervalSinceReferenceDate]>(_soilMoistureAlarmTimeshot+30))) {
            _soilMoistureAlarmTimeshot = [[NSDate date] timeIntervalSinceReferenceDate];
            
            AlarmType alarmType = [super alarmTypeForCharacteristic:characteristic];
            [super showAlarmNotification:[NSString stringWithFormat:@"%@ soil moisture %@", self.name, (alarmType == kAlarmHigh)?@"high value":@"low value"] forUuid:BLE_GROW_CHAR_UUID_SOIL_MOISTURE_ALARM_SET];
        }
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_CHAR_UUID_SOIL_TEMPERATURE_ALARM]]) {
        if ((_soilTempAlarmState == kAlarmStateEnabled)&&([[NSDate date] timeIntervalSinceReferenceDate]>(_soilTempAlarmTimeshot+30))) {
            _soilTempAlarmTimeshot = [[NSDate date] timeIntervalSinceReferenceDate];
            
            AlarmType alarmType = [super alarmTypeForCharacteristic:characteristic];
            [super showAlarmNotification:[NSString stringWithFormat:@"%@ soil temperature %@", self.name, (alarmType == kAlarmHigh)?@"high value":@"low value"] forUuid:BLE_GROW_CHAR_UUID_SOIL_TEMPERATURE_ALARM_SET];
        }
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_CHAR_UUID_LIGHT_ALARM_LOW_VALUE]]) {
        self.lightAlarmLow = [self alarmValueForCharacteristic:characteristic];
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_CHAR_UUID_LIGHT_ALARM_HIGH_VALUE]]) {
        self.lightAlarmHigh = [self alarmValueForCharacteristic:characteristic];
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_CHAR_UUID_SOIL_MOISTURE_ALARM_LOW_VALUE]]) {
        self.soilMoistureAlarmLow = [self alarmValueForCharacteristic:characteristic];
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_CHAR_UUID_SOIL_MOISTURE_ALARM_HIGH_VALUE]]) {
        self.soilMoistureAlarmHigh = [self alarmValueForCharacteristic:characteristic];
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_CHAR_UUID_SOIL_TEMPERATURE_ALARM_LOW_VALUE]]) {
        int16_t rValue = CFSwapInt16BigToHost((int16_t)[self alarmValueForCharacteristic:characteristic]);
        NSLog(@"BLE_GROW_CHAR_UUID_SOIL_TEMPERATURE_ALARM_LOW_VALUE - %@ %d %f %@", aPeripheral.name, rValue, [self alarmValueForCharacteristic:characteristic], [characteristic value]);
        self.soilTemperatureAlarmLow = [self getTemperatureFromSensorTemperature:rValue];
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_CHAR_UUID_SOIL_TEMPERATURE_ALARM_HIGH_VALUE]]) {
        int16_t rValue = CFSwapInt16BigToHost((int16_t)[self alarmValueForCharacteristic:characteristic]);
        NSLog(@"BLE_GROW_CHAR_UUID_SOIL_TEMPERATURE_ALARM_HIGH_VALUE - %@ %d %f %@", aPeripheral.name, rValue, [self alarmValueForCharacteristic:characteristic], [characteristic value]);
        self.soilTemperatureAlarmHigh = [self getTemperatureFromSensorTemperature:rValue];
    }
}

@end
