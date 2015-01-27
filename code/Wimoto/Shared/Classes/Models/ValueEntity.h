//
//  SensorValue.h
//  Wimoto
//
//  Created by MC700 on 12/23/13.
//
//

#import <Couchbaselite/Couchbaselite.h>

@class SensorEntity;

typedef enum {
    kValueTypeTemperature = 0,
    kValueTypeHumidity,
    kValueTypeLight,
    kValueTypePresence,
    kValueTypeLevel,
    kValueTypeSoilTemperature,
    kValueTypeSoilHumidity,
    kValueTypeGrowLight,
    kValueTypeAccelerometer,
    kValueTypePassiveInfrared,
    kValueTypeIRTemperature,
    kValueTypeProbeTemperature
} SensorValueType;

@interface ValueEntity : CBLModel

@property SensorValueType valueType;
@property double value;
@property (strong) NSDate *date;
@property (copy) SensorEntity *sensor;

+ (id)sensorValueForDocument:(CBLDocument*)document;

- (NSDictionary *)dictionaryRepresentation;

@end
