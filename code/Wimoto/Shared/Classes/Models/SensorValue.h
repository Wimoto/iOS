//
//  SensorValue.h
//  Wimoto
//
//  Created by MC700 on 12/23/13.
//
//

#import <Couchbaselite/Couchbaselite.h>

@class Sensor;

typedef enum {
    kValueTypeTemperature = 0,
    kValueTypeHumidity,
    kValueTypeLight,
    kValueTypePresence,
    kValueTypeLevel,
    kValueTypeSoilTemp,
    kValueTypeSoilMoisure
} SensorValueType;

@interface SensorValue : CBLModel

@property SensorValueType valueType;
@property double value;
@property (strong) NSDate *date;
@property (copy) Sensor *sensor;

+ (id)sensorValueForDocument:(CBLDocument*)document;

@end
