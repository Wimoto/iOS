//
//  Sensor.h
//  Wimoto
//
//  Created by MC700 on 12/3/13.
//
//

#import "CBPeripheral+Util.h"
#import <Couchbaselite/Couchbaselite.h>
#import "AlarmService.h"

#define OBSERVER_KEY_PATH_SENSOR_RSSI           @"rssi"

typedef enum {
    kAlarmStateUnknown = 0,
    kAlarmStateDisabled = 1,
    kAlarmStateEnabled
} AlarmState;

@protocol SensorDelegate <NSObject>

- (void)didUpdateAlarmStateWithUUIDString:(NSString *)UUIDString;

@end

@interface Sensor : CBLModel<CBPeripheralDelegate, AlarmServiceDelegate>

@property (copy) NSString *name;
@property (copy) NSString *systemId;

@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong) CBService *service;
@property (nonatomic, strong) NSNumber *rssi;
@property (nonatomic, weak) id<SensorDelegate>delegate;

+ (id)newSensorInDatabase:(CBLDatabase*)database withPeripheral:(CBPeripheral*)peripheral;
+ (id)sensorForDocument:(CBLDocument*)document;
+ (id)sensorForDocument:(CBLDocument*)document withPeripheral:(CBPeripheral*)peripheral;

@end
