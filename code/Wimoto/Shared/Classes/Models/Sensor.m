//
//  Sensor.m
//  Wimoto
//
//  Created by MC700 on 12/3/13.
//
//

#import "Sensor.h"

#define DICTIONARY_SENSOR_TYPE      @"type"

@implementation Sensor

- (id)initWithDictionary:(NSDictionary*)dictionary {
    self = [super init];
    if (self) {
        _type = [[dictionary objectForKey:DICTIONARY_SENSOR_TYPE] intValue];
    }
    return self;
}

- (NSDictionary*)dictionaryRepresentation {
    NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionaryWithCapacity:1];
    [mutableDictionary setObject:[NSNumber numberWithInt:_type] forKey:DICTIONARY_SENSOR_TYPE];
    return mutableDictionary;
}

@end
