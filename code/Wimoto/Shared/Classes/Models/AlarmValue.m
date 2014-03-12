//
//  AlarmValue.m
//  Wimoto
//
//  Created by Danny Kokarev on 11.03.14.
//
//

#import "AlarmValue.h"

@implementation AlarmValue

@dynamic valueType;
@dynamic value;
@dynamic sensor;
@dynamic isActive;

+ (id)alarmValueForDocument:(CBLDocument*)document
{
    return [CBLModel modelForDocument:document];
}

+ (id)newAlarmValueInDatabase:(CBLDatabase*)database sensor:(Sensor *)sensor valueType:(SensorValueType)valueType
{
    AlarmValue *alarmValue = [[AlarmValue alloc] initWithNewDocumentInDatabase:database];
    alarmValue.sensor = sensor;
    alarmValue.valueType = valueType;
    alarmValue.value = 0;
    return alarmValue;
}

@end
