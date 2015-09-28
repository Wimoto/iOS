//
//  SentrySensor.m
//  Wimoto
//
//  Created by Danny Kokarev on 25.12.13.
//
//

#import "SentrySensor.h"
#import "AppConstants.h"
#import "SentrySensorEntity.h"

#define DICTIONARY_KEY_ID               @"id"
#define DICTIONARY_KEY_ANGLE_XY         @"angleXY"
#define DICTIONARY_KEY_ANGLE_Z          @"angleZ"
#define DICTIONARY_KEY_ANGLE_G          @"gVal"

@interface ValueFactor : NSObject

@property (nonatomic) int16_t factorId;
@property (nonatomic) NSString *angleXY;
@property (nonatomic) NSString *angleZ;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end

@implementation ValueFactor

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _factorId   = [[dictionary objectForKey:DICTIONARY_KEY_ID] intValue];
        _angleXY    = [dictionary objectForKey:DICTIONARY_KEY_ANGLE_XY];
        _angleZ     = [dictionary objectForKey:DICTIONARY_KEY_ANGLE_Z];
    }
    return self;
}

@end

@interface SentrySensor()

@property (nonatomic) NSTimeInterval accelerometerAlarmTimeshot;
@property (nonatomic) NSTimeInterval infraredAlarmTimeshot;

@end

@implementation SentrySensor

static NSArray *valueFactors = nil;

+ (NSArray *)valueFactors {
    @synchronized(valueFactors) {
        if (!valueFactors) {
            NSArray *array = [NSArray arrayWithContentsOfFile:[[NSBundle  mainBundle] pathForResource:@"sentryLookup" ofType:@"plist"]];
            
            NSMutableArray *factors = [NSMutableArray array];
            for (NSDictionary *dictionary in array) {
                [factors addObject:[[ValueFactor alloc] initWithDictionary:dictionary]];
            }
            valueFactors = [NSArray arrayWithArray:factors];
        }
        return valueFactors;
    }
}

- (id)initWithEntity:(SensorEntity *)entity {
    SentrySensorEntity *sentryEntity = (SentrySensorEntity *)entity;
    
    self = [super initWithEntity:sentryEntity];
    if (self) {
        _accelerometerAlarmEnabledTime   = [(SentrySensorEntity *)self.entity accelerometerAlarmEnabledTime];
        _accelerometerAlarmDisabledTime  = [(SentrySensorEntity *)self.entity accelerometerAlarmDisabledTime];
        
        _infraredAlarmEnabledTime        = [(SentrySensorEntity *)self.entity infraredAlarmEnabledTime];
        _infraredAlarmDisabledTime       = [(SentrySensorEntity *)self.entity infraredAlarmDisabledTime];
    }
    
    return self;
}

- (PeripheralType)type {
    return kPeripheralTypeSentry;
}

- (NSString *)codename {
    return @"Sentry";
}

- (void)save {
    SentrySensorEntity *sentryEntity = (SentrySensorEntity *)self.entity;
    sentryEntity.accelerometerAlarmDisabledTime = _accelerometerAlarmDisabledTime;
    sentryEntity.accelerometerAlarmEnabledTime = _accelerometerAlarmEnabledTime;
    sentryEntity.infraredAlarmEnabledTime = _infraredAlarmEnabledTime;
    sentryEntity.infraredAlarmDisabledTime = _infraredAlarmDisabledTime;
    dispatch_async([QueueManager databaseQueue], ^{
        [sentryEntity save:nil];
    });
}

#pragma mark - CBPeriferalDelegate

- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error {
    [super peripheral:aPeripheral didDiscoverServices:error];
    for (CBService *aService in aPeripheral.services) {
        if ([aService.UUID isEqual:[CBUUID UUIDWithString:BLE_SENTRY_SERVICE_UUID_ACCELEROMETER]]) {
            [aPeripheral discoverCharacteristics:[NSArray arrayWithObjects:
                                                  [CBUUID UUIDWithString:BLE_SENTRY_CHAR_UUID_ACCELEROMETER_CURRENT],
                                                  [CBUUID UUIDWithString:BLE_SENTRY_CHAR_UUID_ACCELEROMETER_ALARM_SET],
                                                  [CBUUID UUIDWithString:BLE_SENTRY_CHAR_UUID_ACCELEROMETER_ALARM_CLEAR],
                                                  [CBUUID UUIDWithString:BLE_SENTRY_CHAR_UUID_ACCELEROMETER_ALARM],
                                                  nil]
                                      forService:aService];
        } else if ([aService.UUID isEqual:[CBUUID UUIDWithString:BLE_SENTRY_SERVICE_UUID_PASSIVE_INFRARED]]) {
            [aPeripheral discoverCharacteristics:[NSArray arrayWithObjects:
                                                  [CBUUID UUIDWithString:BLE_SENTRY_CHAR_UUID_PASSIVE_INFRARED_CURRENT],
                                                  [CBUUID UUIDWithString:BLE_SENTRY_CHAR_UUID_PASSIVE_INFRARED_ALARM_SET],
                                                  [CBUUID UUIDWithString:BLE_SENTRY_CHAR_UUID_PASSIVE_INFRARED_ALARM],
                                                  nil]
                                      forService:aService];
        }
    }
}

- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    [super peripheral:aPeripheral didDiscoverCharacteristicsForService:service error:error];
    if ([service.UUID isEqual:[CBUUID UUIDWithString:BLE_SENTRY_SERVICE_UUID_ACCELEROMETER]]) {
        for (CBCharacteristic *aChar in service.characteristics) {
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_SENTRY_CHAR_UUID_ACCELEROMETER_ALARM_SET]]||
                [aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_SENTRY_CHAR_UUID_ACCELEROMETER_ALARM_CLEAR]]) {
                [aPeripheral readValueForCharacteristic:aChar];
            }
            else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_SENTRY_CHAR_UUID_ACCELEROMETER_ALARM]]) {
                [aPeripheral setNotifyValue:YES forCharacteristic:aChar];
            }
            else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_SENTRY_CHAR_UUID_ACCELEROMETER_CURRENT]]) {
                [aPeripheral readValueForCharacteristic:aChar];
                [aPeripheral setNotifyValue:YES forCharacteristic:aChar];
            }
        }
    }
    else if ([service.UUID isEqual:[CBUUID UUIDWithString:BLE_SENTRY_SERVICE_UUID_PASSIVE_INFRARED]]) {
        for (CBCharacteristic *aChar in service.characteristics) {
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_SENTRY_CHAR_UUID_PASSIVE_INFRARED_ALARM_SET]]) {
                [aPeripheral readValueForCharacteristic:aChar];
            }
            else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_SENTRY_CHAR_UUID_PASSIVE_INFRARED_ALARM]]) {
                [aPeripheral setNotifyValue:YES forCharacteristic:aChar];
            }
            else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_SENTRY_CHAR_UUID_PASSIVE_INFRARED_CURRENT]]) {
                [aPeripheral readValueForCharacteristic:aChar];
                [aPeripheral setNotifyValue:YES forCharacteristic:aChar];
            }
        }
    }
}

- (void)peripheral:(CBPeripheral *)aPeripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        return;
    }
    [super peripheral:aPeripheral didUpdateValueForCharacteristic:characteristic error:error];
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_SENTRY_CHAR_UUID_ACCELEROMETER_CURRENT]]) {
        NSLog(@"hex Sentry %@", [[characteristic value] hexadecimalString]);
        
        int16_t xValue	= 0;
        [[characteristic value] getBytes:&xValue range:NSMakeRange(0, 1)];
        
        NSPredicate *xPredicate = [NSPredicate predicateWithFormat:@"factorId == %d", xValue];
        ValueFactor *xFactor = [[SentrySensor valueFactors] filteredArrayUsingPredicate:xPredicate].lastObject;
        self.x = [xFactor.angleXY floatValue];
        
        int16_t yValue	= 0;
        [[characteristic value] getBytes:&yValue range:NSMakeRange(1, 1)];
        
        NSPredicate *yPredicate = [NSPredicate predicateWithFormat:@"factorId == %d", yValue];
        ValueFactor *yFactor = [[SentrySensor valueFactors] filteredArrayUsingPredicate:yPredicate].lastObject;
        self.y = [yFactor.angleXY floatValue];
        
        int16_t zValue	= 0;
        [[characteristic value] getBytes:&zValue range:NSMakeRange(2, 1)];
        
        NSPredicate *zPredicate = [NSPredicate predicateWithFormat:@"factorId == %d", zValue];
        ValueFactor *zFactor = [[SentrySensor valueFactors] filteredArrayUsingPredicate:zPredicate].lastObject;
        self.z = [zFactor.angleZ floatValue];
        
        NSLog(@"val Sentry %d   %d   %d", xValue, yValue, zValue);
    } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_SENTRY_CHAR_UUID_PASSIVE_INFRARED_CURRENT]]) {
        self.pasInfrared = [self sensorValueForCharacteristic:characteristic];;
        [self.entity saveNewValueWithType:kValueTypePassiveInfrared value:_pasInfrared];
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_SENTRY_CHAR_UUID_ACCELEROMETER_ALARM_SET]]) {
        if (_accelerometerAlarmState == kAlarmStateUnknown) {
            self.accelerometerAlarmState = [self alarmStateForCharacteristic:characteristic];
        }
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_SENTRY_CHAR_UUID_PASSIVE_INFRARED_ALARM_SET]]) {
        if (_pasInfraredAlarmState == kAlarmStateUnknown) {
            self.pasInfraredAlarmState = [self alarmStateForCharacteristic:characteristic];
        }
    } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_SENTRY_CHAR_UUID_ACCELEROMETER_ALARM]]) {
        NSTimeInterval currentTimeshot = [NSDate timeIntervalSinceReferenceDate];
        if ((currentTimeshot > [_accelerometerAlarmEnabledTime timeIntervalSinceReferenceDate]) && (currentTimeshot < [_accelerometerAlarmDisabledTime timeIntervalSinceReferenceDate])) {
            if ((_accelerometerAlarmState == kAlarmStateEnabled)&&([[NSDate date] timeIntervalSinceReferenceDate]>(_accelerometerAlarmTimeshot+30))) {
                _accelerometerAlarmTimeshot = [[NSDate date] timeIntervalSinceReferenceDate];
                
                [super showAlarmNotification:[NSString stringWithFormat:@"%@ accelerometer alarm", self.name] forUuid:BLE_SENTRY_CHAR_UUID_ACCELEROMETER_ALARM];
            }
        }
    } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_SENTRY_CHAR_UUID_PASSIVE_INFRARED_ALARM]]) {
        NSTimeInterval currentTimeshot = [NSDate timeIntervalSinceReferenceDate];
        if ((currentTimeshot > [_infraredAlarmEnabledTime timeIntervalSinceReferenceDate]) && (currentTimeshot < [_infraredAlarmDisabledTime timeIntervalSinceReferenceDate])) {
            if ((_pasInfraredAlarmState == kAlarmStateEnabled)&&([[NSDate date] timeIntervalSinceReferenceDate]>(_infraredAlarmTimeshot+30))) {
                _infraredAlarmTimeshot = [[NSDate date] timeIntervalSinceReferenceDate];
                
                [super showAlarmNotification:[NSString stringWithFormat:@"%@ infrared alarm", self.name] forUuid:BLE_SENTRY_CHAR_UUID_PASSIVE_INFRARED_ALARM];
            }
        }
    }
}

@end
