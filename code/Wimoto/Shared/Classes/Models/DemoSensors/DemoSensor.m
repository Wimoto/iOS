
//
//  DemoSensor.m
//  Wimoto
//
//  Created by MC700 on 30.10.14.
//
//

#import "DemoSensor.h"

@implementation DemoSensor

+ (id)demoSensorWithUniqueId:(NSString *)uniqueId {
    NSString *className = nil;
    if ([uniqueId isEqualToString:BLE_CLIMATE_DEMO_MODEL]) {
        className = @"DemoClimateSensor";
    }
    else if ([uniqueId isEqualToString:BLE_THERMO_DEMO_MODEL]) {
        className = @"DemoThermoSensor";
    }
    return [[NSClassFromString(className) alloc] init];
}

- (void)dealloc {
    [_timer invalidate];
    _timer = nil;
}

- (void)setEntity:(SensorEntity *)entity {
    [super setEntity:entity];
    if (entity) {
        _timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(sensorUpdate) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    else {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)sensorUpdate {}

@end
