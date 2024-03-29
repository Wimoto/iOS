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
@property (nonatomic, strong) NSMutableArray *sensorDataLogs;

@end

@implementation Sensor

+ (id)sensorWithPeripheral:(CBPeripheral*)peripheral {
    return [[[Sensor classForType:[peripheral peripheralType]] alloc] initWithPeripheral:peripheral];
}

+ (id)sensorWithEntity:(SensorEntity*)entity {
    return [[[Sensor classForType:[entity.sensorType intValue]] alloc] initWithEntity:entity];
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
    }
    return self;
}

- (PeripheralType)type {
    return kPeripheralTypeUndefined;
}

- (NSString *)codename {
    return nil;
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
        self.dataLoggerState = kDataLoggerStateUnknown;
        [_peripheral discoverServices:nil];
        [_peripheral readRSSI];
    } else {
        self.dataLoggerState = kDataLoggerStateNone;
        _rssi = nil;
        _batteryLevel = nil;
    }
}

- (void)setDataLoggerState:(DataLoggerState)dataLoggerState {
    _dataLoggerState = dataLoggerState;
    
    if (_dataLoggerState == kDataLoggerStateEnabled) {
        _sensorDataLogs = [NSMutableArray array];
    } else if (_dataLoggerState == kDataLoggerStateDisabled) {
        if (_sensorDataLogs) {
            [self.dataReadingDelegate didReadSensorDataLogger:_sensorDataLogs];
        }
        _sensorDataLogs = nil;
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

- (AlarmType)alarmTypeForCharacteristic:(CBCharacteristic *)characteristic {
    NSLog(@"ALARM NOTIFICATION HEX %@", [characteristic.value hexadecimalString]);
    
    uint8_t alarmValue  = 0;
    [[characteristic value] getBytes:&alarmValue length:1];
    NSLog(@"alarm!  0x%x", alarmValue);
    if (alarmValue & 0x02) {
        NSLog(@"ALARM HIGH VALUE");
        return kAlarmHigh;
    }
    else if (alarmValue & 0x01) {
        NSLog(@"ALARM LOW VALUE");
        return kAlarmLow;
    }
    return -1;
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
    self.dataLoggerState = kDataLoggerStateUnknown;
    
    char bytes[1] = { 0x01 };
    [self.peripheral writeValue:[NSData dataWithBytes:bytes length:sizeof(bytes)] forCharacteristic:_dataLoggerEnableCharacteristic type:CBCharacteristicWriteWithResponse];
}

- (void)readDataLogger {
    self.dataLoggerState = kDataLoggerStateRead;
    
    [self.peripheral setNotifyValue:YES forCharacteristic:self.dataLoggerReadNotificationCharacteristic];
    
    char bytes[1] = { 0x01 };
    [self.peripheral writeValue:[NSData dataWithBytes:bytes length:sizeof(bytes)] forCharacteristic:_dataLoggerReadEnableCharacteristic type:CBCharacteristicWriteWithResponse];
}

- (void)writeSensorDataLog:(NSDictionary *)dataLog {
    NSLog(@"write datalog %@", NSStringFromClass([dataLog class]));
    [_sensorDataLogs addObject:dataLog];
}

- (void)showAlarmNotification:(NSString *)message forUuid:(NSString *)uuidString {
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        localNotification.category = NOTIFICATION_ALARM_CATEGORY_ID; //  Same as category identifier
    }
    localNotification.alertAction = @"View";
    localNotification.alertBody = message;
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:self.uniqueIdentifier forKey:LOCAL_NOTIFICATION_ALARM_SENSOR];
    [userInfo setObject:uuidString forKey:LOCAL_NOTIFICATION_ALARM_UUID];
    localNotification.userInfo = userInfo;

    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

#pragma mark - CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"didWriteValueForCharacteristic __%@ __%@__", [characteristic UUID], error);
    if ([characteristic isEqual:_dfuModeSetCharacteristic]) {
        // does nothing so far
    } else if ([characteristic isEqual:_dataLoggerEnableCharacteristic]) {
        if (error) {
            self.dataLoggerState = kDataLoggerStateDisabled;
        } else {
            [peripheral readValueForCharacteristic:characteristic];            
        }
    } else if ([characteristic isEqual:_dataLoggerReadEnableCharacteristic]) {
        NSLog(@"didWriteValueForCharacteristic _dataLoggerReadEnableCharacteristic %@", error);
        if (error) {
            self.dataLoggerState = kDataLoggerStateDisabled;
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
}


@end
