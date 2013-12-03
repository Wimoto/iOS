//
//  Sensor.h
//  Wimoto
//
//  Created by MC700 on 12/3/13.
//
//

typedef enum {
    kSensorTypeClimate = 0,
    kSensorTypeGrow,
    kSensorTypeThermo,
    kSensorTypeSentry,
    kSensorTypeWater
} SensorType;

@interface Sensor : NSObject

@property (nonatomic) SensorType type;

- (id)initWithDictionary:(NSDictionary*)dictionary;
- (NSDictionary*)dictionaryRepresentation;

@end
