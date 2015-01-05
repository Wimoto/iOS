//
//  Sensor.m
//  Wimoto
//
//  Created by MC700 on 12/3/13.
//
//

#import "Sensor.h"
#import "ClimateSensor.h"
#import "WaterSensor.h"
#import "GrowSensor.h"
#import "SentrySensor.h"
#import "ThermoSensor.h"

#define DICT_KEY_SENSOR_TYPE      @"type"
#define DICT_KEY_SENSOR_NAME      @"name"

@interface Sensor ()

@property (nonatomic, strong) NSTimer *rssiTimer;

- (void)detectTempMeasureAndSubscribeToNotifications;

@end

@implementation Sensor

+ (id)sensorWithPeripheral:(CBPeripheral*)peripheral {
    return [[[Sensor classForType:[peripheral peripheralType]] alloc] initWithPeripheral:peripheral];
}

+ (id)sensorWithEntity:(SensorEntity*)entity {
    return [[[Sensor classForType:[entity.sensorType intValue]] alloc] initWithEntity:entity];
}

+ (id)demoSensorWithUniqueId:(NSString *)uniqueId {
    NSString *className = nil;
    if ([uniqueId isEqualToString:BLE_CLIMATE_DEMO_MODEL]) {
        className = @"DemoClimateSensor";
    }
    else if ([uniqueId isEqualToString:BLE_THERMO_DEMO_MODEL]) {
        className = @"DemoThermoSensor";
    }
    return [[NSClassFromString(className) alloc] init];
}

+ (Class)classForType:(PeripheralType)type {
    switch (type) {
        case kPeripheralTypeClimate:
            return NSClassFromString(@"ClimateSensor");
            break;
        case kPeripheralTypeWater:
            return NSClassFromString(@"WaterSensor");
            break;
        case kPeripheralTypeGrow:
            return NSClassFromString(@"GrowSensor");
            break;
        case kPeripheralTypeSentry:
            return NSClassFromString(@"SentrySensor");
            break;
        case kPeripheralTypeThermo:
            return NSClassFromString(@"ThermoSensor");
            break;
        case kPeripheralTypeThermoDemo:
            return NSClassFromString(@"DemoThermoSensor");
            break;
        case kPeripheralTypeClimateDemo:
            return NSClassFromString(@"DemoClimateSensor");
            break;
        default:
            return nil;
            break;
    }
}

- (id)initWithPeripheral:(CBPeripheral*)peripheral {
    self = [super init];
    if (self) {
        self.peripheral     = peripheral;
        
        _name               = _peripheral.name;
        _uniqueIdentifier   = [_peripheral uniqueIdentifier];
        
        [self detectTempMeasureAndSubscribeToNotifications];
    }
    return self;
}

- (id)initWithEntity:(SensorEntity*)entity {
    self = [super init];
    if (self) {
        self.entity = entity;
        
        _registered         = YES;
        _name               = _entity.name;
        _uniqueIdentifier   = _entity.systemId;
        
        [self detectTempMeasureAndSubscribeToNotifications];
    }
    return self;
}
- (id)init {
    self = [super init];
    if (self) {
        [self detectTempMeasureAndSubscribeToNotifications];
    }
    return self;
}

- (void)detectTempMeasureAndSubscribeToNotifications {
    BOOL isCelsius = [[NSUserDefaults standardUserDefaults] boolForKey:@"temperature_conversion"];
    self.tempMeasure = (isCelsius)?kTemperatureMeasureCelsius:kTemperatureMeasureFahrenheit;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(settingsNotification:)
                                                 name:NSUserDefaultsDidChangeNotification
                                               object:nil];
}

- (void)settingsNotification:(NSNotification *)notification {
    NSUserDefaults *userDefaults = [notification object];
    BOOL isCelsiusValue = [userDefaults boolForKey:@"temperature_conversion"];
    TemperatureMeasure measure = isCelsiusValue?kTemperatureMeasureCelsius:kTemperatureMeasureFahrenheit;
    if (_tempMeasure != measure) {
        self.tempMeasure = measure;
    }
}

- (PeripheralType)type {
    return kPeripheralTypeUndefined;
}

- (NSString *)codename {
    return nil;
}

- (NSString *)temperatureSymbol {
    return (_tempMeasure == kTemperatureMeasureCelsius)?@"˚C":@"˚F";
}

- (float)convertToFahrenheit:(float)value {
    return (value * 9.0/5.0 + 32.0);
}

- (float)convertToCelsius:(float)value {
    return ((value - 32.0) * 5.0/9.0);
}

- (void)setName:(NSString *)name {
    _name = name;
    [_entity saveNewName:name];
}

- (void)setPeripheral:(CBPeripheral *)peripheral {
    dispatch_async(dispatch_get_main_queue(), ^{
        [_rssiTimer invalidate];
        _rssiTimer = nil;
    });
    
    _peripheral.delegate = nil;
    
    _peripheral = peripheral;
    _peripheral.delegate = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        _rssiTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:_peripheral selector:@selector(readRSSI) userInfo:nil repeats:YES];
    });
    
    if (peripheral) {
        [_peripheral discoverServices:nil];
        [_peripheral readRSSI];
    } else {
        _rssi = nil;
        _batteryLevel = nil;
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSUserDefaultsDidChangeNotification object:nil];
    [_rssiTimer invalidate];
    _peripheral.delegate = nil;
}

- (float)roundToOne:(float)value {
    return roundf(value * 10) / 10;
}

- (void)alarmActionWithCharacteristic:(CBCharacteristic *)characteristic alarmType:(AlarmType)alarmtype {
    //Implement in child
}

- (void)alarmServiceDidStopAlarm:(CBCharacteristic *)characteristic {
    NSLog(@"ALARM DID STOPE, CHARACTERISTIC - %@", characteristic);
}

- (void)writeAlarmValue:(int)alarmValue forCharacteristicWithUUIDString:(NSString *)UUIDString {
    if (!self.peripheral) {
        NSLog(@"Not connected to a peripheral");
    }
    CBCharacteristic *maxValueCharacteristic;
    for (CBService *service in [self.peripheral services]) {
        for (CBCharacteristic *characteristic in [service characteristics]) {
            if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:UUIDString]]) {
                maxValueCharacteristic = characteristic;
                break;
            }
        }
    }
    if (!maxValueCharacteristic) {
        NSLog(@"No valid max characteristic");
        return;
    }
    
    int16_t value = CFSwapInt16BigToHost((int16_t)alarmValue);
    NSData *data = [NSData dataWithBytes:(void*)&value length:sizeof(value)];
    NSLog(@"ALARM WRITE HIGH VALUE - %d  %@   %@   %lu", alarmValue, UUIDString, data, sizeof(value));
    [self.peripheral writeValue:data forCharacteristic:maxValueCharacteristic type:CBCharacteristicWriteWithResponse];
}

- (void)enableAlarm:(BOOL)enable forCharacteristicWithUUIDString:(NSString *)UUIDString {
    int8_t value	= (enable)?1:0;
    CBCharacteristic *alarmSetCharacteristic;
    for (CBService *service in [self.peripheral services]) {
        for (CBCharacteristic *characteristic in [service characteristics]) {
            if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:UUIDString]]) {
                alarmSetCharacteristic = characteristic;
                break;
            }
        }
    }
    NSLog(@"ENABLE ALARM, CHARACTERISTIC - %@ ___ %@ ___ %lu", alarmSetCharacteristic, alarmSetCharacteristic.UUID, sizeof(value));
    
    NSData *data = [NSData dataWithBytes:&value length:sizeof(value)];
    NSLog(@"#6data %@     %lu", data, sizeof(value));
    [self.peripheral writeValue:data forCharacteristic:alarmSetCharacteristic type:CBCharacteristicWriteWithResponse];
}

- (AlarmState)alarmStateForCharacteristic:(CBCharacteristic *)characteristic {
    uint8_t alarmSetValue = 0;
    [[characteristic value] getBytes:&alarmSetValue length:sizeof(alarmSetValue)];
    return (alarmSetValue & 0x01)?kAlarmStateEnabled:kAlarmStateDisabled;
}

- (float)alarmValueForCharacteristic:(CBCharacteristic *)characteristic {
    int16_t value	= 0;
    [[characteristic value] getBytes:&value length:sizeof(value)];
    return value;
}

- (int)sensorValueForCharacteristic:(CBCharacteristic *)characteristic {
    NSScanner *scanner = [NSScanner scannerWithString:[characteristic.value hexadecimalString]];
    unsigned int decimalValue;
    [scanner scanHexInt:&decimalValue];
    return decimalValue;
}

- (NSString *)sensorStringValueForCharacteristic:(CBCharacteristic *)characteristic {
    return [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
}

- (DataLoggerState)dataLoggerStateForCharacteristic:(CBCharacteristic *)characteristic {
    uint8_t dataLoggerEnabled = 0;
    [[characteristic value] getBytes:&dataLoggerEnabled length:sizeof(dataLoggerEnabled)];
    return (dataLoggerEnabled & 0x01)?kDataLoggerStateEnabled:kDataLoggerStateDisabled;
}

- (void)switchToDfuMode {
    _uuidString = [self.peripheral.identifier UUIDString];
    
    char bytes[1] = { 0x01 };
    [self.peripheral writeValue:[NSData dataWithBytes:bytes length:sizeof(bytes)] forCharacteristic:_dfuModeSetCharacteristic type:CBCharacteristicWriteWithResponse];
}

- (void)enableDataLogger:(BOOL)doEnable {
    char bytes[1] = {(doEnable) ? 0x01:0x00 };
    [self.peripheral writeValue:[NSData dataWithBytes:bytes length:sizeof(bytes)] forCharacteristic:_dataLoggerEnableCharacteristic type:CBCharacteristicWriteWithResponse];
}

- (void)readDataLogger {
    char bytes[1] = { 0x01 };
    [self.peripheral writeValue:[NSData dataWithBytes:bytes length:sizeof(bytes)] forCharacteristic:_dataLoggerReadEnableCharacteristic type:CBCharacteristicWriteWithResponse];
}

#pragma mark - CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if ([characteristic isEqual:_dfuModeSetCharacteristic]) {
        // does nothing so far
    } else if ([characteristic isEqual:_dataLoggerEnableCharacteristic]) {
        [peripheral readValueForCharacteristic:characteristic];
    } else if ([characteristic isEqual:_dataLoggerReadEnableCharacteristic]) {
        if (error) {
            [_dataReadingDelegate didUpdateSensorReadingData:nil error:error];
        } else {
            [peripheral setNotifyValue:YES forCharacteristic:_dataLoggerReadNotificationCharacteristic];
        }
    }
}

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.rssi = [peripheral RSSI];
    });
}

- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error {
    for (CBService *aService in aPeripheral.services) {
        if ([aService.UUID isEqual:[CBUUID UUIDWithString:BLE_BATTERY_LEVEL_SERVICE]]) {
            [aPeripheral discoverCharacteristics:[NSArray arrayWithObjects:[CBUUID UUIDWithString:BLE_BATTERY_LEVEL_CHARACTERISTIC], nil]
                                      forService:aService];
        } else if ([aService.UUID isEqual:[CBUUID UUIDWithString:BLE_GENERIC_SERVICE_UUID_DEVICE]]) {
            [aPeripheral discoverCharacteristics:[NSArray arrayWithObjects:[CBUUID UUIDWithString:BLE_GENERIC_CHAR_UUID_DFU], nil]
                                      forService:aService];
        }
    }
}

- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if ([service.UUID isEqual:[CBUUID UUIDWithString:BLE_BATTERY_LEVEL_SERVICE]]) {
        for (CBCharacteristic *aChar in service.characteristics) {
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_BATTERY_LEVEL_CHARACTERISTIC]]) {
                [aPeripheral readValueForCharacteristic:aChar];
                [aPeripheral setNotifyValue:YES forCharacteristic:aChar];
            }
        }
    } else if ([service.UUID isEqual:[CBUUID UUIDWithString:BLE_GENERIC_SERVICE_UUID_DEVICE]]) {
        for (CBCharacteristic *aChar in service.characteristics) {
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_GENERIC_CHAR_UUID_DFU]]) {
                NSLog(@"Sensor didDiscoverCharacteristicsForService BLE_GENERIC_CHAR_UUID_DFU");
                [aPeripheral setNotifyValue:YES forCharacteristic:aChar];
            }
        }
    }
}

- (void)peripheral:(CBPeripheral *)aPeripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ((characteristic.value) || !error) {
            if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_BATTERY_LEVEL_CHARACTERISTIC]]) {
                const uint8_t *bytes = [characteristic.value bytes];
                int value = bytes[0];
                
                self.batteryLevel = [NSNumber numberWithInt:value];                
            } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_GENERIC_CHAR_UUID_DFU]]) {
                NSLog(@"Sensor didUpdateValueForCharacteristic BLE_GENERIC_CHAR_UUID_DFU");
                //self.dfuModeOn = YES;
            }
        }
    });
}


@end
