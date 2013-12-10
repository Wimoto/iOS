//
//  Sensor.m
//  Wimoto
//
//  Created by MC700 on 12/3/13.
//
//

#import "Sensor.h"

#define DICTIONARY_SENSOR_TYPE      @"type"

@interface Sensor ()

@property (nonatomic, strong) CBPeripheral *peripheral;

@end

@implementation Sensor

- (id)initWithPeripheral:(CBPeripheral*)peripheral {
    self = [super init];
    if (self) {
        _peripheral = peripheral;
        _peripheral.delegate = self;
        [_peripheral discoverServices:nil];
            
        _name = _peripheral.name;
        
        CFStringRef uuidString = CFUUIDCreateString(NULL, peripheral.UUID);
        if (uuidString) {
            _uuid = [NSString stringWithFormat:@"%@", uuidString];
            CFRelease(uuidString);
        }
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary*)dictionary {
    self = [super init];
    if (self) {
        _type = [[dictionary objectForKey:DICTIONARY_SENSOR_TYPE] intValue];
    }
    return self;
}

- (void)dealloc {
    _peripheral.delegate = nil;
}

- (NSDictionary*)dictionaryRepresentation {
    NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionaryWithCapacity:1];
    [mutableDictionary setObject:[NSNumber numberWithInt:_type] forKey:DICTIONARY_SENSOR_TYPE];
    return mutableDictionary;
}

#pragma mark - CBPeriferalDelegate

- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error
{
    for (CBService *aService in aPeripheral.services)
    {
        if ([aService.UUID isEqual:[CBUUID UUIDWithString:@"180D"]]) {
            [aPeripheral discoverCharacteristics:[NSArray arrayWithObject:[CBUUID UUIDWithString:@"2A37"]] forService:aService];
        } else if ([aService.UUID isEqual:[CBUUID UUIDWithString:@"180A"]]) {
            [aPeripheral discoverCharacteristics:[NSArray arrayWithObject:[CBUUID UUIDWithString:@"2A23"]] forService:aService];
        }
    }
}

- (void) peripheral:(CBPeripheral *)aPeripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if ([service.UUID isEqual:[CBUUID UUIDWithString:@"180D"]])
    {
        for (CBCharacteristic *aChar in service.characteristics)
        {
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"2A37"]])
            {
                [aPeripheral setNotifyValue:YES forCharacteristic:aChar];
                
                uint8_t val = 1;
                NSData* valData = [NSData dataWithBytes:(void*)&val length:sizeof(val)];
                [aPeripheral writeValue:valData forCharacteristic:aChar type:CBCharacteristicWriteWithResponse];
            }
        }
    }
    else if ([service.UUID isEqual:[CBUUID UUIDWithString:@"180A"]]) {
        for (CBCharacteristic *aChar in service.characteristics)
        {
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"2A23"]]) {
                [aPeripheral readValueForCharacteristic:aChar];
            }
        }
    }
}

- (void) peripheral:(CBPeripheral *)aPeripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A37"]])
    {
        if( (characteristic.value)  || !error )
        {
            const uint8_t *reportData = [characteristic.value bytes];
            uint16_t bpm = 0;
            
            if ((reportData[0] & 0x01) == 0)
            {
                bpm = reportData[1];
            }
            else
            {
                bpm = CFSwapInt16LittleToHost(*(uint16_t *)(&reportData[1]));
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.value = [NSNumber numberWithFloat:bpm];
            });
        }
    } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A23"]]) {
        if (characteristic.value) {
            const uint64_t *vll = [characteristic.value bytes];
            uint64_t mk = vll[0];
            //_uuid = [NSString stringWithFormat:@"%llu", mk];
        }
    }
}

@end
