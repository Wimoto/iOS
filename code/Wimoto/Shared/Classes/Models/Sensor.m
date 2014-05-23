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

- (void)writeHighAlarmValue:(int)high forCharacteristicWithUUIDString:(NSString *)UUIDString {
    NSData *data = nil;
    int16_t value = (int16_t)high;
    if (!self.service) {
        NSLog(@"Not connected to a peripheral");
    }
    CBCharacteristic *maxValueCharacteristic;
    for (CBCharacteristic *characteristic in [self.service characteristics]) {
        if ([characteristic.UUID.UUIDString isEqualToString:UUIDString]) {
            maxValueCharacteristic = characteristic;
            break;
        }
    }
    if (!maxValueCharacteristic) {
        NSLog(@"No valid max characteristic");
        return;
    }
    data = [NSData dataWithBytes:&value length:sizeof (value)];
    [self.peripheral writeValue:data forCharacteristic:maxValueCharacteristic type:CBCharacteristicWriteWithResponse];
}

- (void)writeLowAlarmValue:(int)low forCharacteristicWithUUIDString:(NSString *)UUIDString {
    NSData *data = nil;
    int16_t value = (int16_t)low;
    if (!self.service) {
        NSLog(@"Not connected to a peripheral");
    }
    CBCharacteristic *minValueCharacteristic;
    for (CBCharacteristic *characteristic in [self.service characteristics]) {
        if ([characteristic.UUID.UUIDString isEqualToString:UUIDString]) {
            minValueCharacteristic = characteristic;
            break;
        }
    }
    if (!minValueCharacteristic) {
        NSLog(@"No valid max characteristic");
        return;
    }
    data = [NSData dataWithBytes:&value length:sizeof(value)];
    [self.peripheral writeValue:data forCharacteristic:minValueCharacteristic type:CBCharacteristicWriteWithResponse];
}

- (void)enableAlarm:(BOOL)enable forCharacteristicWithUUIDString:(NSString *)UUIDString {
    unsigned char dat = (enable)?0x01:0x00;
    CBCharacteristic *alarmSetCharacteristic;
    for (CBCharacteristic *characteristic in [self.service characteristics]) {
        if ([characteristic.UUID.UUIDString isEqualToString:UUIDString]) {
            alarmSetCharacteristic = characteristic;
            break;
        }
    }
    [self.peripheral writeValue:[NSData dataWithBytes:&dat length:sizeof(dat)] forCharacteristic:alarmSetCharacteristic type:CBCharacteristicWriteWithResponse];
}

- (CGFloat)minimumAlarmValueForCharacteristicWithUUIDString:(NSString *)UUIDString {
    CGFloat result  = NAN;
    int16_t value	= 0;
    CBCharacteristic *minValueCharacteristic;
    for (CBCharacteristic *characteristic in [self.service characteristics]) {
        if ([characteristic.UUID.UUIDString isEqualToString:UUIDString]) {
            minValueCharacteristic = characteristic;
            break;
        }
    }
    if (minValueCharacteristic) {
        [[minValueCharacteristic value] getBytes:&value length:sizeof (value)];
        result = (CGFloat)value / 10.0f;
    }
    return result;
}

- (CGFloat)maximumAlarmValueForCharacteristicWithUUIDString:(NSString *)UUIDString {
    CGFloat result  = NAN;
    int16_t value	= 0;
    CBCharacteristic *maxValueCharacteristic;
    for (CBCharacteristic *characteristic in [self.service characteristics]) {
        if ([characteristic.UUID.UUIDString isEqualToString:UUIDString]) {
            maxValueCharacteristic = characteristic;
            break;
        }
    }
    if (maxValueCharacteristic) {
        [[maxValueCharacteristic value] getBytes:&value length:sizeof (value)];
        result = (CGFloat)value / 10.0f;
    }
    return result;
}

#pragma mark - CBPeriferalDelegate

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"Did Update RSSI PERIPHERAL = %@", peripheral);
        self.rssi = [peripheral RSSI];
    });
}

@end
