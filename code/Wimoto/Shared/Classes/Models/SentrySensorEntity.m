//
//  SentrySensorEntity.m
//  Wimoto
//
//  Created by Mobitexoft on 08.07.15.
//
//

#import "SentrySensorEntity.h"

@implementation SentrySensorEntity

@dynamic accelerometerAlarmEnabledTime, accelerometerAlarmDisabledTime, infraredAlarmEnabledTime, infraredAlarmDisabledTime;

- (void)saveAccelerometerAlarmEnabledTime:(NSDate *)accelerometerAlarmEnabledTime {
    if (accelerometerAlarmEnabledTime) {
        self.accelerometerAlarmEnabledTime = accelerometerAlarmEnabledTime;
        dispatch_async([QueueManager databaseQueue], ^{
            [self save:nil];
        });
    }
}

- (void)saveAccelerometerAlarmDisabledTime:(NSDate *)accelerometerAlarmDisabledTime {
    if (accelerometerAlarmDisabledTime) {
        self.accelerometerAlarmDisabledTime = accelerometerAlarmDisabledTime;
        dispatch_async([QueueManager databaseQueue], ^{
            [self save:nil];
        });
    }
}

- (void)saveInfraredAlarmEnabledTime:(NSDate *)infraredAlarmEnabledTime {
    if (infraredAlarmEnabledTime) {
        self.infraredAlarmEnabledTime = infraredAlarmEnabledTime;
        dispatch_async([QueueManager databaseQueue], ^{
            [self save:nil];
        });
    }
}

- (void)saveInfraredAlarmDisabledTime:(NSDate *)infraredAlarmDisabledTime {
    if (infraredAlarmDisabledTime) {
        self.accelerometerAlarmDisabledTime = infraredAlarmDisabledTime;
        dispatch_async([QueueManager databaseQueue], ^{
            [self save:nil];
        });
    }
}

@end
