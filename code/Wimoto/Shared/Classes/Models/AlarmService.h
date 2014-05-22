//
//  AlarmService.h
//  Wimoto
//
//  Created by Danny Kokarev on 22.05.14.
//
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

typedef enum {
    kAlarmHigh  = 0,
    kAlarmLow   = 1,
} AlarmType;

@protocol AlarmServiceDelegate<NSObject>

- (void)alarmService:(id)service didSoundAlarmOfType:(AlarmType)alarm;
- (void)alarmServiceDidStopAlarm:(id)service;
- (void)alarmServiceDidChangeTemperature:(id)service;
- (void)alarmServiceDidChangeTemperatureBounds:(id)service;
- (void)alarmServiceDidChangeStatus:(id)service;
- (void)alarmServiceDidReset;

@end

@interface AlarmService : NSObject

@property (readonly) CGFloat minimumAlarmValue;
@property (readonly) CGFloat maximumAlarmValue;

- (id)initWithSensor:(id<AlarmServiceDelegate>)sensor serviceUUIDString:(NSString *)serviceUUID;
- (void)writeLowAlarmValue:(int)low;
- (void)writeHighAlarmValue:(int)high;
- (void)findAlarmCharacteristics;

@end
