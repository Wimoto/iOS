
//
//  DemoSensor.m
//  Wimoto
//
//  Created by Alena Kokareva on 30.10.14.
//
//

#import "DemoSensor.h"

@implementation DemoSensor

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
