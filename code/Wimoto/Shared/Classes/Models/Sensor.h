//
//  Sensor.h
//  Wimoto
//
//  Created by MC700 on 12/3/13.
//
//

#import <CoreBluetooth/CoreBluetooth.h>

typedef enum {
    kSensorTypeClimate = 0,
    kSensorTypeGrow,
    kSensorTypeThermo,
    kSensorTypeSentry,
    kSensorTypeWater
} SensorType;

#define OBSERVER_KEY_PATH_SENSOR_VALUE          @"value"
#define OBSERVER_KEY_PATH_SENSOR_RSSI           @"rssi"

@interface Sensor : NSObject<CBPeripheralDelegate>

@property (nonatomic) SensorType type;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) NSNumber *value;
@property (nonatomic, strong) NSNumber *rssi;

- (id)initWithDictionary:(NSDictionary*)dictionary;
- (id)initWithPeripheral:(CBPeripheral*)peripheral;

- (NSDictionary*)dictionaryRepresentation;

@end
