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
        _entity = entity;
        
        _registered         = YES;
        _name               = _entity.name;
        _uniqueIdentifier   = _entity.systemId;
    }
    return self;
}

- (PeripheralType)type {
    return kPeripheralTypeUndefined;
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
    [_rssiTimer invalidate];
    _peripheral.delegate = nil;
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
    
    int16_t value = (int16_t)alarmValue;
    NSData *data = [NSData dataWithBytes:(void*)&value length:sizeof(value)];
    NSLog(@"ALARM WRITE HIGH VALUE - %@   %@   %lu", UUIDString, data, sizeof(value));
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
    return (float)value / 10.0f;
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

#pragma mark - CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"didWriteValueForCharacteristic %@", error);
}

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"peripheralDidUpdateRSSI %@", [peripheral RSSI]);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.rssi = [peripheral RSSI];
    });
}

- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error {
    for (CBService *aService in aPeripheral.services) {
        if ([aService.UUID isEqual:[CBUUID UUIDWithString:BLE_BATTERY_LEVEL_SERVICE]]) {
            [aPeripheral discoverCharacteristics:[NSArray arrayWithObjects:[CBUUID UUIDWithString:BLE_BATTERY_LEVEL_CHARACTERISTIC], nil]
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
    }
}

- (void)peripheral:(CBPeripheral *)aPeripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ((characteristic.value) || !error) {
            if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_BATTERY_LEVEL_CHARACTERISTIC]]) {
                const uint8_t *bytes = [characteristic.value bytes];
                int value = bytes[0];
                
                self.batteryLevel = [NSNumber numberWithInt:value];                
            }
        }
    });
}


@end
