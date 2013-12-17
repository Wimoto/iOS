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
    sensor.peripheral = peripheral;
    return sensor;
}

+ (id)sensorForDocument:(CBLDocument*)document {
    Sensor *sensor = [TestSensor modelForDocument:document];
    return sensor;
}

+ (id)sensorForDocument:(CBLDocument*)document withPeripheral:(CBPeripheral*)peripheral {
    Sensor *sensor = [[Sensor classForPeripheral:peripheral] modelForDocument:document];
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
        default:
            className = @"Sensor";
            break;
    }
    return NSClassFromString(className);
}

- (void)setPeripheral:(CBPeripheral *)peripheral {
    _peripheral.delegate = nil;
    _peripheral = peripheral;
    
    _peripheral.delegate = self;
    [_peripheral discoverServices:nil];
    
    self.name = _peripheral.name;
    self.systemId = [peripheral systemId];
    
    self.rssiTimer = [NSTimer timerWithTimeInterval:2.0 target:_peripheral selector:@selector(readRSSI) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_rssiTimer forMode:NSRunLoopCommonModes];
}

- (void)dealloc {
    [_rssiTimer invalidate];
    _peripheral.delegate = nil;
}

#pragma mark - CBPeriferalDelegate

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.rssi = [peripheral RSSI];
    });
}

@end
