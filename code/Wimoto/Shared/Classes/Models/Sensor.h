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
#import "ValueEntity.h"
#import "SensorsManager.h"

#define OBSERVER_KEY_PATH_SENSOR_PERIPHERAL     @"peripheral"
#define OBSERVER_KEY_PATH_SENSOR_RSSI           @"rssi"
#define OBSERVER_KEY_PATH_SENSOR_BATTERY_LEVEL  @"batteryLevel"

#define OBSERVER_KEY_PATH_SENSOR_DFU_MODE       @"dfuModeOn"

#define OBSERVER_KEY_PATH_SENSOR_DL_STATE       @"dataLoggerState"

#define LOCAL_NOTIFICATION_ALARM_SENSOR         @"alarmSensor"
#define LOCAL_NOTIFICATION_ALARM_UUID           @"alarmUuid"

typedef enum {
    kAlarmStateUnknown = 0,
    kAlarmStateDisabled,
    kAlarmStateEnabled
} AlarmState;

typedef enum {
    kDataLoggerStateNone = 0,
    kDataLoggerStateUnknown,
    kDataLoggerStateDisabled,
    kDataLoggerStateEnabled,
    kDataLoggerStateRead
} DataLoggerState;

typedef enum {
    kAlarmLow = 0,
    kAlarmHigh = 1,
} AlarmType;

@protocol SensorDataReadingDelegate <NSObject>

- (void)didReadSensorDataLogger:(NSArray *)data;
- (void)didUpdateSensorReadingData:(NSData *)data error:(NSError *)error;

@end

@interface Sensor : NSObject <CBPeripheralDelegate>

@property (nonatomic, getter = isRegistered) BOOL registered;

@property (nonatomic, strong) SensorEntity *entity;

@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong) CBCharacteristic *dfuModeSetCharacteristic;
@property (nonatomic, strong) CBCharacteristic *dataLoggerEnableCharacteristic;
@property (nonatomic, strong) CBCharacteristic *dataLoggerReadEnableCharacteristic;
@property (nonatomic, strong) CBCharacteristic *dataLoggerReadNotificationCharacteristic;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *uniqueIdentifier;
@property (nonatomic, strong) NSString *uuidString;

@property (nonatomic, getter=isDfuModeOn) BOOL dfuModeOn;

@property (nonatomic, strong) NSNumber *batteryLevel;

@property (nonatomic, strong) NSNumber *rssi;

@property (nonatomic) DataLoggerState dataLoggerState;
@property (nonatomic, weak) id<SensorDataReadingDelegate> dataReadingDelegate;

+ (id)sensorWithPeripheral:(CBPeripheral*)peripheral;
+ (id)sensorWithDemoPeripheral:(DemoCBPeripheral*)demoPeripheral;
+ (id)sensorWithEntity:(SensorEntity*)entity;
- (id)initWithEntity:(SensorEntity*)entity;

- (float)roundToOne:(float)value;

- (PeripheralType)type;
- (NSString *)codename;

- (void)enableAlarm:(BOOL)enable forCharacteristicWithUUIDString:(NSString *)UUIDString;
- (void)writeAlarmValue:(int)alarmValue forCharacteristicWithUUIDString:(NSString *)UUIDString;
//- (void)alarmActionWithCharacteristic:(CBCharacteristic *)characteristic alarmType:(AlarmType)alarmtype;

- (void)switchToDfuMode;
- (void)enableDataLogger:(BOOL)doEnable;
- (void)readDataLogger;
- (void)writeSensorDataLog:(NSString *)dataLog;

- (AlarmState)alarmStateForCharacteristic:(CBCharacteristic *)characteristic;
- (float)alarmValueForCharacteristic:(CBCharacteristic *)characteristic;
- (AlarmType)alarmTypeForCharacteristic:(CBCharacteristic *)characteristic;

- (int)sensorValueForCharacteristic:(CBCharacteristic *)characteristic;
- (NSString *)sensorStringValueForCharacteristic:(CBCharacteristic *)characteristic;

- (DataLoggerState)dataLoggerStateForCharacteristic:(CBCharacteristic *)characteristic;

- (void)settingsNotification:(NSNotification *)notification;
- (void)showAlarmNotification:(NSString *)message forUuid:(NSString *)uuidString;

@end
