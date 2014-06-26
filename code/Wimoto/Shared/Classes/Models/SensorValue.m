//
//  SensorValue.m
//  Wimoto
//
//  Created by MC700 on 12/23/13.
//
//

#import "SensorValue.h"

@implementation SensorValue

@dynamic valueType;
@dynamic value;
@dynamic date;

+ (id)sensorValueForDocument:(CBLDocument*)document {
    return [CBLModel modelForDocument:document];
}

@end
