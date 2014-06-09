//
//  Sensor.m
//  Wimoto
//
//  Created by MC700 on 12/3/13.
//
//

#import "Sensor.h"

#import "ClimateSensor.h"
#import "TestSensor.h"

#define DICT_KEY_SENSOR_TYPE      @"type"
#define DICT_KEY_SENSOR_NAME      @"name"

@interface Sensor ()

@property (nonatomic, strong) NSTimer *rssiTimer;

@end

@implementation Sensor

@dynamic name, systemId;

+ (id)newSensorInDatabase:(CBLDatabase*)database withPeripheral:(CBPeripheral*)peripheral {
    Sensor *sensor = [[[Sensor classForPeripheral:peripheral] alloc] initWithNewDocumentInDatabase:database];
    [sensor setValue:NSStringFromClass([sensor class]) ofProperty:@"type"];
    sensor.peripheral = peripheral;
    return sensor;
}

+ (id)sensorForDocument:(CBLDocument*)document {
    Sensor *sensor = (Sensor*)[CBLModel modelForDocument:document];
    return sensor;
}

+ (id)sensorForDocument:(CBLDocument*)document withPeripheral:(CBPeripheral*)peripheral {
    Sensor *sensor = (Sensor*)[CBLModel modelForDocument:document];
    sensor.peripheral = peripheral;
    return sensor;
}

+ (Class)classForPeripheral:(CBPeripheral*)peripheral {
    PeripheralType type = [peripheral peripheralType];
    
    NSString *className = nil;
    switch (type) {
        case kPeripheralTypeTest:
            className = @"TestSensor";
            break;
        case kPeripheralTypeClimate:
            className = @"ClimateSensor";
            break;
        case kPeripheralTypeWater:
            className = @"WaterSensor";
            break;
        case kPeripheralTypeGrow:
            className = @"GrowSensor";
            break;
        case kPeripheralTypeSentry:
            className = @"SentrySensor";
            break;
        case kPeripheralTypeThermo:
            className = @"ThermoSensor";
            break;
        default:
            className = @"TestSensor";
            break;
    }
    
    NSLog(@"CLASS FOR PERIRHERAL = %@", className);
    
    return NSClassFromString(className);
}

- (void)setPeripheral:(CBPeripheral *)peripheral
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _peripheral.delegate = nil;
        if ([_rssiTimer isValid]) {
            [_rssiTimer invalidate];
            self.rssiTimer = nil;
        }
        _peripheral = peripheral;
    
        _peripheral.delegate = self;
        [_peripheral discoverServices:nil];
        [_peripheral readRSSI];
    
        self.name = _peripheral.name;
        self.systemId = [peripheral systemId];
        self.rssiTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:_peripheral selector:@selector(readRSSI) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_rssiTimer forMode:NSRunLoopCommonModes];
    });
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

- (void)writeHighAlarmValue:(int)high forCharacteristicWithUUIDString:(NSString *)UUIDString {
    NSData *data = nil;
    int16_t value = (int16_t)high;
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
    data = [NSData dataWithBytes:&value length:sizeof (value)];
    NSLog(@"ALARM WRITE HIGH VALUE - %@", data);
    [self.peripheral writeValue:data forCharacteristic:maxValueCharacteristic type:CBCharacteristicWriteWithResponse];
}

- (void)writeLowAlarmValue:(int)low forCharacteristicWithUUIDString:(NSString *)UUIDString {
    NSData *data = nil;
    int16_t value = (int16_t)low;
    if (!self.peripheral) {
        NSLog(@"Not connected to a peripheral");
    }
    CBCharacteristic *minValueCharacteristic;
    for (CBService *service in [self.peripheral services]) {
        for (CBCharacteristic *characteristic in [service characteristics]) {
            if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:UUIDString]]) {
                minValueCharacteristic = characteristic;
                break;
            }
        }
    }
    if (!minValueCharacteristic) {
        NSLog(@"No valid max characteristic");
        return;
    }
    data = [NSData dataWithBytes:&value length:sizeof(value)];
    NSLog(@"ALARM WRITE LOW VALUE - %@", data);
    [self.peripheral writeValue:data forCharacteristic:minValueCharacteristic type:CBCharacteristicWriteWithResponse];
}

- (void)enableAlarm:(BOOL)enable forCharacteristicWithUUIDString:(NSString *)UUIDString {
    unsigned char dat = (enable)?0x01:0x00;
    CBCharacteristic *alarmSetCharacteristic;
    for (CBService *service in [self.peripheral services]) {
        for (CBCharacteristic *characteristic in [service characteristics]) {
            if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:UUIDString]]) {
                alarmSetCharacteristic = characteristic;
                break;
            }
        }
    }
    NSLog(@"ENABLE ALARM, CHARACTERISTIC - %@", alarmSetCharacteristic);
    [self.peripheral writeValue:[NSData dataWithBytes:&dat length:sizeof(dat)] forCharacteristic:alarmSetCharacteristic type:CBCharacteristicWriteWithResponse];
}

- (CGFloat)minimumAlarmValueForCharacteristicWithUUID:(CBUUID *)uuid {
    CGFloat result  = NAN;
    int16_t value	= 0;
    CBCharacteristic *minValueCharacteristic;
    for (CBService *service in [self.peripheral services]) {
        for (CBCharacteristic *characteristic in [service characteristics]) {
            if ([characteristic.UUID isEqual:uuid]) {
                minValueCharacteristic = characteristic;
                break;
            }
        }
    }
    if (minValueCharacteristic) {
        [[minValueCharacteristic value] getBytes:&value length:sizeof (value)];
        result = (CGFloat)value / 10.0f;
    }
    return result;
}

- (CGFloat)maximumAlarmValueForCharacteristicWithUUID:(CBUUID *)uuid {
    CGFloat result  = NAN;
    int16_t value	= 0;
    CBCharacteristic *maxValueCharacteristic;
    for (CBService *service in [self.peripheral services]) {
        for (CBCharacteristic *characteristic in [service characteristics]) {
            if ([characteristic.UUID isEqual:uuid]) {
                maxValueCharacteristic = characteristic;
                break;
            }
        }
    }
    if (maxValueCharacteristic) {
        [[maxValueCharacteristic value] getBytes:&value length:sizeof (value)];
        result = (CGFloat)value / 10.0f;
    }
    return result;
}

#pragma mark - CBPeriferalDelegate

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"Did Update RSSI PERIPHERAL = %@", peripheral);
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
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_BATTERY_LEVEL_CHARACTERISTIC]]) {
            NSData *data = [characteristic value];
            const uint8_t *reportData = [data bytes];
            uint16_t level = 0;
            if ((reportData[0] & 0x01) == 0) {
                level = reportData[1];
            }
            else {
                level = CFSwapInt16LittleToHost(*(uint16_t *)(&reportData[1]));
            }
            if ((characteristic.value) || !error) {
                self.batteryLevel = [NSNumber numberWithUnsignedLongLong:level];
                NSLog(@"DID UPDATE BATERY CHARCTERISTIC VALUE = %@", _batteryLevel);
            }
        }
    });
}


@end
