//
//  AlarmValue.h
//  Wimoto
//
//  Created by Danny Kokarev on 11.03.14.
//
//

#import <Couchbaselite/Couchbaselite.h>
#import "SensorValue.h"

@interface AlarmValue : CBLModel

@property SensorValueType valueType;
@property NSInteger value;
@property (copy) Sensor *sensor;
@property BOOL isActive;

+ (id)alarmValueForDocument:(CBLDocument*)document;
+ (id)newAlarmValueInDatabase:(CBLDatabase*)database sensor:(Sensor *)sensor valueType:(SensorValueType)valueType;

@end
