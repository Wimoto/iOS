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

@interface Sensor : CBLModel<CBPeripheralDelegate, AlarmServiceDelegate>

@property (copy) NSString *name;
@property (copy) NSString *systemId;

@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong) NSNumber *rssi;

+ (id)newSensorInDatabase:(CBLDatabase*)database withPeripheral:(CBPeripheral*)peripheral;
+ (id)sensorForDocument:(CBLDocument*)document;
+ (id)sensorForDocument:(CBLDocument*)document withPeripheral:(CBPeripheral*)peripheral;

@end
