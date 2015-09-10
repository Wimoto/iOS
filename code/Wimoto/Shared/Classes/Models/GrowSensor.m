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
    [super writeAlarmValue:_soilMoistureAlarmLow forCharacteristicWithUUIDString:BLE_GROW_CHAR_UUID_SOIL_MOISTURE_ALARM_LOW_VALUE];
}

- (void)setSoilMoistureAlarmHigh:(float)soilMoistureAlarmHigh {
    _soilMoistureAlarmHigh = soilMoistureAlarmHigh;
    [super writeAlarmValue:_soilMoistureAlarmHigh forCharacteristicWithUUIDString:BLE_GROW_CHAR_UUID_SOIL_MOISTURE_ALARM_HIGH_VALUE];
}

- (void)setSoilTemperatureAlarmLow:(float)soilTemperatureAlarmLow {
    _soilTemperatureAlarmLow = soilTemperatureAlarmLow;
    [super writeAlarmValue:_soilTemperatureAlarmLow forCharacteristicWithUUIDString:BLE_GROW_CHAR_UUID_SOIL_TEMPERATURE_ALARM_LOW_VALUE];
}

- (void)setSoilTemperatureAlarmHigh:(float)soilTemperatureAlarmHigh {
    _soilTemperatureAlarmHigh = soilTemperatureAlarmHigh;
    [super writeAlarmValue:_soilTemperatureAlarmHigh forCharacteristicWithUUIDString:BLE_GROW_CHAR_UUID_SOIL_TEMPERATURE_ALARM_HIGH_VALUE];
}

- (void)setLightAlarmLow:(float)lightAlarmLow {
    _lightAlarmLow = lightAlarmLow;
    [super writeAlarmValue:_lightAlarmLow forCharacteristicWithUUIDString:BLE_GROW_CHAR_UUID_LIGHT_ALARM_LOW_VALUE];
}

- (void)setLightAlarmHigh:(float)lightAlarmHigh {
    _lightAlarmHigh = lightAlarmHigh;
    [super writeAlarmValue:_lightAlarmLow forCharacteristicWithUUIDString:BLE_GROW_CHAR_UUID_LIGHT_ALARM_HIGH_VALUE];
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
    } else if (_calibrationState == kGrowCalibrationStateLowValueStarted) {
        char bytes[1] = { 0x00 };
        [self.peripheral writeValue:[NSData dataWithBytes:bytes length:1] forCharacteristic:_soilMoistureAlarmLowValueCharacteristic type:CBCharacteristicWriteWithResponse];
    }
}

#pragma mark - CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if ([characteristic isEqual:_soilMoistureAlarmLowValueCharacteristic]) {
        if ((!error) && (_calibrationState == kGrowCalibrationStateLowValueInProgress)) {
            [(GrowSensorEntity *)self.entity setLowHumidityCalibration:[NSNumber numberWithFloat:[self roundToOne:[self sensorValueForCharacteristic:characteristic]]]];
            self.calibrationState = kGrowCalibrationStateLowValueFinished;
        }
    } else if ([characteristic isEqual:_soilMoistureAlarmHighValueCharacteristic]) {
        if ((!error) && (_calibrationState == kGrowCalibrationStateHighValueInProgress)) {
            [(GrowSensorEntity *)self.entity setHighHumidityCalibration:[NSNumber numberWithFloat:[self roundToOne:[self sensorValueForCharacteristic:characteristic]]]];
            self.calibrationState = kGrowCalibrationStateHighValueFinished;
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
        self.soilTemperature = [self roundToOne:[self sensorValueForCharacteristic:characteristic]];
        [self.entity saveNewValueWithType:kValueTypeSoilTemperature value:_soilTemperature];
    } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_CHAR_UUID_LIGHT_CURRENT]]) {
        self.light = [self sensorValueForCharacteristic:characteristic];
        [self.entity saveNewValueWithType:kValueTypeGrowLight value:_light];
    } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_CHAR_UUID_SOIL_MOISTURE_CURRENT]]) {
        self.soilMoisture = [self roundToOne:[self sensorValueForCharacteristic:characteristic]];
        [self.entity saveNewValueWithType:kValueTypeSoilHumidity value:_soilMoisture];
        
        if (_calibrationState == kGrowCalibrationStateLowValueStarted) {
            self.calibrationState = kGrowCalibrationStateLowValueFinished;
            [(GrowSensorEntity *)self.entity setLowHumidityCalibration:[NSNumber numberWithFloat:[self roundToOne:[self sensorValueForCharacteristic:characteristic]]]];
        } else if (_calibrationState == kGrowCalibrationStateHighValueStarted) {
            self.calibrationState = kGrowCalibrationStateHighValueFinished;
            [(GrowSensorEntity *)self.entity setHighHumidityCalibration:[NSNumber numberWithFloat:[self roundToOne:[self sensorValueForCharacteristic:characteristic]]]];
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
        self.soilTemperatureAlarmLow = [self alarmValueForCharacteristic:characteristic];
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_CHAR_UUID_SOIL_TEMPERATURE_ALARM_HIGH_VALUE]]) {
        self.soilTemperatureAlarmHigh = [self alarmValueForCharacteristic:characteristic];
    }
}

@end
