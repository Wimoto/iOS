//
//  Sensor.h
//  Wimoto
//
//  Created by MC700 on 12/3/13.
//
//

#import "CBPeripheral+Util.h"

#define OBSERVER_KEY_PATH_SENSOR_RSSI           @"rssi"

@interface Sensor : NSObject<CBPeripheralDelegate>

@property (nonatomic, strong) CBPeripheral *peripheral;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *systemId;
@property (nonatomic, strong) NSNumber *rssi;

+ (id)sensorWithPeripheral:(CBPeripheral*)peripheral;

- (id)initWithDictionary:(NSDictionary*)dictionary;
- (id)initWithPeripheral:(CBPeripheral*)peripheral;

- (NSDictionary*)dictionaryRepresentation;

@end
