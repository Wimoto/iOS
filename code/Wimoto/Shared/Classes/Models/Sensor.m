//
//  Sensor.m
//  Wimoto
//
//  Created by MC700 on 12/3/13.
//
//

#import "Sensor.h"

#import "ClimateSensor.h"

#define DICT_KEY_SENSOR_TYPE      @"type"
#define DICT_KEY_SENSOR_NAME      @"name"

@interface Sensor ()

@property (nonatomic, strong) NSTimer *rssiTimer;

@end

@implementation Sensor

+ (id)sensorWithPeripheral:(CBPeripheral*)peripheral {
    PeripheralType type = [peripheral peripheralType];
    switch (type) {
        case kPeripheralTypeClimate:
            return [[ClimateSensor alloc] initWithPeripheral:peripheral];
            break;
        default:
            break;
    }
    return nil;
}

- (id)initWithPeripheral:(CBPeripheral*)peripheral {
    self = [super init];
    if (self) {
        _peripheral = peripheral;
        _peripheral.delegate = self;
        [_peripheral discoverServices:nil];
        
        _name = _peripheral.name;
        _systemId = [peripheral systemId];
        
        self.rssiTimer = [NSTimer timerWithTimeInterval:2.0 target:_peripheral selector:@selector(readRSSI) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_rssiTimer forMode:NSRunLoopCommonModes];
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary*)dictionary {
    self = [super init];
    if (self) {
        _type = [[dictionary objectForKey:DICT_KEY_SENSOR_TYPE] intValue];
        _name = [dictionary objectForKey:DICT_KEY_SENSOR_NAME];
    }
    return self;
}

- (void)dealloc {
    [_rssiTimer invalidate];
    _peripheral.delegate = nil;
}

- (NSDictionary*)dictionaryRepresentation {
    NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionaryWithCapacity:1];
    [mutableDictionary setObject:[NSNumber numberWithInt:_type] forKey:DICT_KEY_SENSOR_TYPE];
    if (_name) {
        [mutableDictionary setObject:_name forKey:DICT_KEY_SENSOR_NAME];
    }
    return mutableDictionary;
}

#pragma mark - CBPeriferalDelegate

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.rssi = [peripheral RSSI];
    });
}

@end
