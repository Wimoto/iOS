//
//  AlarmService.h
//  Wimoto
//
//  Created by Danny Kokarev on 22.05.14.
//
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "Sensor.h"

@class AlarmService;

typedef enum {
    kAlarmHigh  = 0,
    kAlarmLow   = 1,
} AlarmType;

@protocol AlarmServiceDelegate<NSObject>
- (void) alarmService:(AlarmService*)service didSoundAlarmOfType:(AlarmType)alarm;
- (void) alarmServiceDidStopAlarm:(AlarmService*)service;
- (void) alarmServiceDidChangeTemperature:(AlarmService*)service;
- (void) alarmServiceDidChangeTemperatureBounds:(AlarmService*)service;
- (void) alarmServiceDidChangeStatus:(AlarmService*)service;
- (void) alarmServiceDidReset;
@end

@interface AlarmService : NSObject

@property (readonly) CGFloat minimumAlarmValue;
@property (readonly) CGFloat maximumAlarmValue;

- (id)initWithSensor:(Sensor<AlarmServiceDelegate>*)sensor serviceUUIDString:(NSString *)serviceUUID;
- (void)writeLowAlarmValue:(int)low;
- (void)writeHighAlarmValue:(int)high;

@end
