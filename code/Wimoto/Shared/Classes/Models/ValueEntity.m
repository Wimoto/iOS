//
//  SensorValue.m
//  Wimoto
//
//  Created by MC700 on 12/23/13.
//
//

#import "ValueEntity.h"

#define DICTIONARY_KEY_PARAMETER        @"Parameter"
#define DICTIONARY_KEY_VALUE            @"Value"
#define DICTIONARY_KEY_DATE             @"Date"

@implementation ValueEntity

@dynamic valueType;
@dynamic value;
@dynamic date;
@dynamic sensor;

+ (id)sensorValueForDocument:(CBLDocument*)document {
    return [CBLModel modelForDocument:document];
}

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionary];
    
    NSString *parameter = @"";
    switch (self.valueType) {
        case kValueTypeTemperature:
            parameter = @"Temperature";
            break;
        case kValueTypeHumidity:
            parameter = @"Humidity";
            break;
        case kValueTypeLight:
            parameter = @"Light";
            break;
        case kValueTypePresence:
            parameter = @"Presence";
            break;
        case kValueTypeLevel:
            parameter = @"Level";
            break;
        case kValueTypeSoilTemperature:
            parameter = @"Temperature";
            break;
        case kValueTypeSoilMoisture:
            parameter = @"Moisture";
            break;
        case kValueTypeGrowLight:
            parameter = @"Light";
            break;
        case kValueTypeAccelerometer:
            parameter = @"Accelerometer";
            break;            
        case kValueTypePassiveInfrared:
            parameter = @"Infrared";
            break;
        case kValueTypeIRTemperature:
            parameter = @"IRTemperature";
            break;
        case kValueTypeProbeTemperature:
            parameter = @"Probe Temperature";
            break;
        default:
            break;
    }
    
    [mutableDictionary setObject:parameter forKey:DICTIONARY_KEY_PARAMETER];
    [mutableDictionary setObject:[NSString stringWithFormat:@"%.2f", self.value] forKey:DICTIONARY_KEY_VALUE];
    
    NSString *dateString = [NSDateFormatter localizedStringFromDate:self.date
                                                          dateStyle:NSDateFormatterShortStyle
                                                          timeStyle:NSDateFormatterMediumStyle];
    
    [mutableDictionary setObject:dateString forKey:DICTIONARY_KEY_DATE];

    return mutableDictionary;
}

@end
