//
//  Sensor.m
//  Wimoto
//
//  Created by MC700 on 12/3/13.
//
//

#import "Sensor.h"

#define DICT_KEY_SENSOR_TYPE      @"type"
#define DICT_KEY_SENSOR_NAME      @"name"
#define DICT_KEY_SENSOR_UUID      @"uuid"

@interface Sensor ()

@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong) NSTimer *rssiTimer;

@end

@implementation Sensor

- (id)initWithPeripheral:(CBPeripheral*)peripheral {
    self = [super init];
    if (self) {
        _peripheral = peripheral;
        _peripheral.delegate = self;
        [_peripheral discoverServices:nil];
        
        _name = _peripheral.name;
        self.rssiTimer = [NSTimer timerWithTimeInterval:2.0 target:_peripheral selector:@selector(readRSSI) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop]addTimer:_rssiTimer forMode:NSRunLoopCommonModes];
        
        _uuid = [[peripheral identifier] UUIDString];
        
        /*
         CFStringRef uuidString = CFUUIDCreateString(NULL, peripheral.UUID);
         if (uuidString) {
         _uuid = [NSString stringWithFormat:@"%@", uuidString];
         CFRelease(uuidString);
         }
         */
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary*)dictionary {
    self = [super init];
    if (self) {
        _type = [[dictionary objectForKey:DICT_KEY_SENSOR_TYPE] intValue];
        _name = [dictionary objectForKey:DICT_KEY_SENSOR_NAME];
        _uuid = [dictionary objectForKey:DICT_KEY_SENSOR_UUID];
    }
    return self;
}

- (void)dealloc {
    [_rssiTimer invalidate];
    _peripheral.delegate = nil;
}

- (void)updateWithPeripheral:(CBPeripheral*)peripheral
{
    _peripheral = peripheral;
    _peripheral.delegate = self;
    [_peripheral discoverServices:nil];
    self.rssiTimer = [NSTimer timerWithTimeInterval:2.0 target:_peripheral selector:@selector(readRSSI) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop]addTimer:_rssiTimer forMode:NSRunLoopCommonModes];
}

- (NSDictionary*)dictionaryRepresentation {
    NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionaryWithCapacity:1];
    [mutableDictionary setObject:[NSNumber numberWithInt:_type] forKey:DICT_KEY_SENSOR_TYPE];
    if (_name) {
        [mutableDictionary setObject:_name forKey:DICT_KEY_SENSOR_NAME];
    }
    if ((_uuid)) {
        [mutableDictionary setObject:_uuid forKey:DICT_KEY_SENSOR_UUID];
    }
    return mutableDictionary;
}

#pragma mark - CBPeriferalDelegate

- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error
{
    for (CBService *aService in aPeripheral.services) {
        NSLog(@"didDiscoverServices %@ in peripheral %@", aService.UUID, aPeripheral);
        
        if ([aService.UUID isEqual:[CBUUID UUIDWithString:@"180D"]]) {
            [aPeripheral discoverCharacteristics:[NSArray arrayWithObject:[CBUUID UUIDWithString:@"2A37"]] forService:aService];
        }
        else if ([aService.UUID isEqual:[CBUUID UUIDWithString:@"180A"]]) {
            [aPeripheral discoverCharacteristics:[NSArray arrayWithObject:[CBUUID UUIDWithString:@"2A23"]] forService:aService];
        }
    }
}

- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    for (CBCharacteristic *aChar in service.characteristics) {
        NSLog(@"didDiscoverCharacteristicsForService %@ chrs %@", service.UUID, aChar.UUID);
    }
    
    if ([service.UUID isEqual:[CBUUID UUIDWithString:@"180D"]]) {
        for (CBCharacteristic *aChar in service.characteristics) {
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"2A37"]]) {
                [aPeripheral setNotifyValue:YES forCharacteristic:aChar];
                uint8_t val = 1;
                NSData* valData = [NSData dataWithBytes:(void*)&val length:sizeof(val)];
                [aPeripheral writeValue:valData forCharacteristic:aChar type:CBCharacteristicWriteWithResponse];
            }
        }
    }
    else if ([service.UUID isEqual:[CBUUID UUIDWithString:@"180A"]]) {
        for (CBCharacteristic *aChar in service.characteristics) {
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"2A23"]]) {
                [aPeripheral readValueForCharacteristic:aChar];
            }
        }
    }
}

- (void)peripheral:(CBPeripheral *)aPeripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A37"]]) {
        if( (characteristic.value)  || !error ) {
            const uint8_t *reportData = [characteristic.value bytes];
            uint16_t bpm = 0;
            if ((reportData[0] & 0x01) == 0) {
                bpm = reportData[1];
            }
            else {
                bpm = CFSwapInt16LittleToHost(*(uint16_t *)(&reportData[1]));
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                self.value = [NSNumber numberWithFloat:bpm];
            });
        }
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A23"]]) {
        if (characteristic.value) {
            const uint64_t *vll = [characteristic.value bytes];
            uint64_t mk = vll[0];
            //_uuid = [NSString stringWithFormat:@"%llu", mk];
        }
    }
}

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.rssi = [peripheral RSSI];
    });
}

@end
