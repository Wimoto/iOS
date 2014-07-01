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
    return [[[Sensor classForType:[entity.type intValue]] alloc] initWithEntity:entity];
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

- (void)saveNewSensorValueWithType:(SensorValueType)valueType value:(double)value {
    dispatch_async([SensorsManager queue], ^{
        SensorValue *sensorValue = [[SensorValue alloc] initWithNewDocumentInDatabase:[SensorsManager managerDatabase]];
        [sensorValue setValue:NSStringFromClass([SensorValue class]) ofProperty:@"type"];
        sensorValue.date = [NSDate date];
        sensorValue.valueType = valueType;
        sensorValue.value = value;
        [sensorValue save:nil];
    });
}

- (void)lastSensorValuesWithType:(SensorValueType)valueType completionHandler:(void(^)(NSMutableArray *item))completionHandler {
    if (_entity) {
        dispatch_async([SensorsManager queue], ^{
            CBLView *view = [[SensorsManager managerDatabase] viewNamed:@"sensorValuesByDate"];
            if (!view.mapBlock) {
                NSString* const kSensorValueType = NSStringFromClass([SensorValue class]);
                [view setMapBlock: MAPBLOCK({
                    if ([doc[@"type"] isEqualToString:kSensorValueType]) {
                        id date = doc[@"date"];
                        NSString *sensor = doc[@"sensor"];
                        NSNumber *typeNumber = doc[@"valueType"];
                        emit(@[sensor, typeNumber, date], doc);
                    }
                }) version: @"1.1"];
            }
            CBLQuery *query = [view createQuery];
            query.limit = 16;
            query.descending = YES;
            NSString *myListId = _entity.document.documentID;
            NSNumber *typeNumber = [NSNumber numberWithInt:valueType];
            query.startKey = @[myListId, typeNumber, @{}];
            query.endKey = @[myListId, typeNumber];
    
            NSLog(@"Get last sensor values");
    
            CBLQueryEnumerator *queryEnumerator = [query run:nil];
            NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:[queryEnumerator count]];
            for (CBLQueryRow *row in queryEnumerator) {
                NSObject *value = row.document[@"value"];
                if (value) {
                    [mutableArray addObject:value];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(mutableArray);
            });
        });
    }
}

- (void)saveActivityDate {
    if ([self isRegistered]) {
        dispatch_async([SensorsManager queue], ^{
            self.entity.lastActivityAt = [NSDate date];
            [self.entity save:nil];
        });
    }
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

- (SensorEntity*)entity {
    _entity.name        = _name;
    _entity.systemId    = _uniqueIdentifier;
    _entity.type        = [NSNumber numberWithInt:[self type]];
    
    return _entity;
}

- (PeripheralType)type {
    return kPeripheralTypeUndefined;
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

#pragma mark - CBPeripheralDelegate

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
