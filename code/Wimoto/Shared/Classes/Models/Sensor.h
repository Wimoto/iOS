//
//  Sensor.h
//  Wimoto
//
//  Created by MC700 on 12/3/13.
//
//

#import "CBPeripheral+Util.h"
#import "NSData+Conversion.h"
#import "SensorEntity.h"
#import "SensorValue.h"
#import "SensorsManager.h"

#define OBSERVER_KEY_PATH_SENSOR_PERIPHERAL     @"peripheral"
#define OBSERVER_KEY_PATH_SENSOR_RSSI           @"rssi"
#define OBSERVER_KEY_PATH_SENSOR_BATTERY_LEVEL  @"batteryLevel"

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
- (void)didReadMinAlarmValueFromCharacteristicUUID:(CBUUID *)uuid;
- (void)didReadMaxAlarmValueFromCharacteristicUUID:(CBUUID *)uuid;

@end

@interface Sensor : NSObject <CBPeripheralDelegate>

@property (nonatomic, getter = isRegistered) BOOL registered;

@property (nonatomic, strong) SensorEntity *entity;

@property (nonatomic, strong) CBPeripheral *peripheral;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *uniqueIdentifier;

@property (nonatomic, strong) NSNumber *batteryLevel;

@property (nonatomic, strong) NSNumber *rssi;
@property (nonatomic, weak) id<SensorDelegate>delegate;

+ (id)sensorWithPeripheral:(CBPeripheral*)peripheral;
+ (id)sensorWithEntity:(SensorEntity*)entity;

- (PeripheralType)type;

- (void)saveNewSensorValueWithType:(SensorValueType)valueType value:(double)value;
- (void)lastSensorValuesWithType:(SensorValueType)valueType completionHandler:(void(^)(NSMutableArray *item))completionHandler;

- (void)enableAlarm:(BOOL)enable forCharacteristicWithUUIDString:(NSString *)UUIDString;
- (CGFloat)minimumAlarmValueForCharacteristicWithUUID:(CBUUID *)uuid;
- (CGFloat)maximumAlarmValueForCharacteristicWithUUID:(CBUUID *)uuid;
- (void)writeHighAlarmValue:(int)high forCharacteristicWithUUIDString:(NSString *)UUIDString;
- (void)writeLowAlarmValue:(int)low forCharacteristicWithUUIDString:(NSString *)UUIDString;
- (void)alarmActionWithCharacteristic:(CBCharacteristic *)characteristic alarmType:(AlarmType)alarmtype;
- (void)alarmServiceDidStopAlarm:(CBCharacteristic *)characteristic;

- (void)saveActivityDate;

@end
