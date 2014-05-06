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

#pragma mark - CBPeriferalDelegate

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"Did Update RSSI PERIPHERAL = %@", peripheral);
        self.rssi = [peripheral RSSI];
    });
}

@end
