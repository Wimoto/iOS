//
//  SensorValue.m
//  Wimoto
//
//  Created by MC700 on 12/23/13.
//
//

#import "ValueEntity.h"

@implementation ValueEntity

@dynamic valueType;
@dynamic value;
@dynamic date;
@dynamic sensor;

+ (id)sensorValueForDocument:(CBLDocument*)document {
    return [CBLModel modelForDocument:document];
}

@end
