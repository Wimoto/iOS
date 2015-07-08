//
//  SentrySensorEntity.h
//  Wimoto
//
//  Created by Mobitexoft on 08.07.15.
//
//

#import "SensorEntity.h"

@interface SentrySensorEntity : SensorEntity

@property (copy) NSDate     *accelerometerAlarmEnabledTime;
@property (copy) NSDate     *accelerometerAlarmDisabledTime;

@property (copy) NSDate     *infraredAlarmEnabledTime;
@property (copy) NSDate     *infraredAlarmDisabledTime;

- (void)saveAccelerometerAlarmEnabledTime:(NSDate *)accelerometerAlarmEnabledTime;
- (void)saveAccelerometerAlarmDisabledTime:(NSDate *)accelerometerAlarmDisabledTime;

- (void)saveInfraredAlarmEnabledTime:(NSDate *)infraredAlarmEnabledTime;
- (void)saveInfraredAlarmDisabledTime:(NSDate *)infraredAlarmDisabledTime;

@end
