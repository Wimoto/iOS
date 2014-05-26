//
//  Sensor.h
//  Wimoto
//
//  Created by MC700 on 12/3/13.
//
//

#import "CBPeripheral+Util.h"
#import <Couchbaselite/Couchbaselite.h>

#define OBSERVER_KEY_PATH_SENSOR_RSSI           @"rssi"

typedef enum {
    kAlarmStateUnknown = 0,
    kAlarmStateDisabled = 1,
    kAlarmStateEnabled
} AlarmState;

typedef enum {
    kAlarmLow = 0,
    kAlarmHigh = 1,
} AlarmType;

@protocol SensorDelegate <NSObject>

- (void)didUpdateAlarmStateWithUUIDString:(NSString *)UUIDString;
- (void)didReadMinAlarmValueFromCharacteristicUUID:(NSString *)UUIDString;
- (void)didReadMaxAlarmValueFromCharacteristicUUID:(NSString *)UUIDString;

@end

@interface Sensor : CBLModel <CBPeripheralDelegate>

@property (copy) NSString *name;
@property (copy) NSString *systemId;

@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong) NSNumber *rssi;
@property (nonatomic, weak) id<SensorDelegate>delegate;

+ (id)newSensorInDatabase:(CBLDatabase*)database withPeripheral:(CBPeripheral*)peripheral;
+ (id)sensorForDocument:(CBLDocument*)document;
+ (id)sensorForDocument:(CBLDocument*)document withPeripheral:(CBPeripheral*)peripheral;

- (void)enableAlarm:(BOOL)enable forCharacteristicWithUUIDString:(NSString *)UUIDString;
- (CGFloat)minimumAlarmValueForCharacteristicWithUUIDString:(NSString *)UUIDString;
- (CGFloat)maximumAlarmValueForCharacteristicWithUUIDString:(NSString *)UUIDString;
- (void)writeHighAlarmValue:(int)high forCharacteristicWithUUIDString:(NSString *)UUIDString;
- (void)writeLowAlarmValue:(int)low forCharacteristicWithUUIDString:(NSString *)UUIDString;
- (void)alarmActionWithCharacteristic:(CBCharacteristic *)characteristic alarmType:(AlarmType)alarmtype;
- (void)alarmServiceDidStopAlarm:(CBCharacteristic *)characteristic;

@end
