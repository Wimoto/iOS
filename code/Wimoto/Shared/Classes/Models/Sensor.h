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
#define OBSERVER_KEY_PATH_SENSOR_TEMP_MEASURE   @"tempMeasure"

typedef enum {
    kAlarmStateUnknown = 0,
    kAlarmStateDisabled = 1,
    kAlarmStateEnabled
} AlarmState;

typedef enum {
    kAlarmLow = 0,
    kAlarmHigh = 1,
} AlarmType;

typedef enum {
    kTemperatureMeasureFahrenheit = 0,
    kTemperatureMeasureCelsius
}TemperatureMeasure;

@interface Sensor : NSObject <CBPeripheralDelegate>

@property (nonatomic, getter = isRegistered) BOOL registered;

@property (nonatomic, strong) SensorEntity *entity;

@property (nonatomic, strong) CBPeripheral *peripheral;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *uniqueIdentifier;

@property (nonatomic, strong) NSNumber *batteryLevel;

@property (nonatomic, strong) NSNumber *rssi;

@property (nonatomic) TemperatureMeasure tempMeasure;

+ (id)sensorWithPeripheral:(CBPeripheral*)peripheral;
+ (id)sensorWithEntity:(SensorEntity*)entity;
+ (id)demoSensorWithUniqueId:(NSString *)uniqueId;

- (id)initWithEntity:(SensorEntity*)entity;

- (float)roundToOne:(float)value;

- (PeripheralType)type;
- (NSString *)codename;

- (void)enableAlarm:(BOOL)enable forCharacteristicWithUUIDString:(NSString *)UUIDString;
- (void)writeAlarmValue:(int)alarmValue forCharacteristicWithUUIDString:(NSString *)UUIDString;
- (void)alarmActionWithCharacteristic:(CBCharacteristic *)characteristic alarmType:(AlarmType)alarmtype;
- (void)alarmServiceDidStopAlarm:(CBCharacteristic *)characteristic;

- (void)writeDfuData:(NSData *)dfuData;

- (AlarmState)alarmStateForCharacteristic:(CBCharacteristic *)characteristic;
- (float)alarmValueForCharacteristic:(CBCharacteristic *)characteristic;

- (int)sensorValueForCharacteristic:(CBCharacteristic *)characteristic;
- (NSString *)sensorStringValueForCharacteristic:(CBCharacteristic *)characteristic;

- (void)settingsNotification:(NSNotification *)notification;
- (float)convertToFahrenheit:(float)value;
- (float)convertToCelsius:(float)value;

@end
