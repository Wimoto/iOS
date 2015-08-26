//
//  WaterSensor.m
//  Wimoto
//
//  Created by MC700 on 12/23/13.
//
//

#import "WaterSensor.h"
#import "AppConstants.h"

@interface WaterSensor ()

@property (nonatomic) NSTimeInterval presenceAlarmTimeshot;

@end

@implementation WaterSensor

- (PeripheralType)type {
    return kPeripheralTypeWater;
}

- (NSString *)codename {
    return @"Water";
}

- (void)setPresenseAlarmState:(AlarmState)presenseAlarmState {
    _presenseAlarmState = presenseAlarmState;
    
    [super enableAlarm:(_presenseAlarmState == kAlarmStateEnabled) forCharacteristicWithUUIDString:BLE_WATER_CHAR_UUID_PRESENCE_ALARM_SET];
}

#pragma mark - CBPeriferalDelegate

- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error {
    [super peripheral:aPeripheral didDiscoverServices:error];
    for (CBService *aService in aPeripheral.services) {
        NSLog(@"WaterSensor didDiscoverServices %@", aService);
        if ([aService.UUID isEqual:[CBUUID UUIDWithString:BLE_WATER_SERVICE_UUID_LEVEL]]) {
            [aPeripheral discoverCharacteristics:[NSArray arrayWithObjects:
                                                  [CBUUID UUIDWithString:BLE_WATER_CHAR_UUID_LEVEL_CURRENT],
                                                  [CBUUID UUIDWithString:BLE_WATER_CHAR_UUID_LEVEL_ALARM_LOW_VALUE],
                                                  [CBUUID UUIDWithString:BLE_WATER_CHAR_UUID_LEVEL_ALARM_HIGH_VALUE],
                                                  [CBUUID UUIDWithString:BLE_WATER_CHAR_UUID_LEVEL_ALARM_SET],
                                                  [CBUUID UUIDWithString:BLE_WATER_CHAR_UUID_LEVEL_ALARM],
                                                  nil]
                                      forService:aService];
        } else if ([aService.UUID isEqual:[CBUUID UUIDWithString:BLE_WATER_SERVICE_UUID_PRESENCE]]) {
            [aPeripheral discoverCharacteristics:[NSArray arrayWithObjects:
                                                  [CBUUID UUIDWithString:BLE_WATER_CHAR_UUID_PRESENCE_CURRENT],
                                                  [CBUUID UUIDWithString:BLE_WATER_CHAR_UUID_PRESENCE_ALARM_SET],
                                                  [CBUUID UUIDWithString:BLE_WATER_CHAR_UUID_PRESENCE_ALARM],
                                                  nil]
                                      forService:aService];
        }
    }
}

- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    [super peripheral:aPeripheral didDiscoverCharacteristicsForService:service error:error];
    if ([service.UUID isEqual:[CBUUID UUIDWithString:BLE_WATER_SERVICE_UUID_LEVEL]]) {
        for (CBCharacteristic *aChar in service.characteristics) {
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_WATER_CHAR_UUID_LEVEL_ALARM_LOW_VALUE]]||
                [aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_WATER_CHAR_UUID_LEVEL_ALARM_HIGH_VALUE]]||
                [aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_WATER_CHAR_UUID_LEVEL_ALARM_SET]]) {
                [aPeripheral readValueForCharacteristic:aChar];
            }
            else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_WATER_CHAR_UUID_LEVEL_ALARM]]) {
                [aPeripheral setNotifyValue:YES forCharacteristic:aChar];
            }
            else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_WATER_CHAR_UUID_LEVEL_CURRENT]]) {
                [aPeripheral readValueForCharacteristic:aChar];
                [aPeripheral setNotifyValue:YES forCharacteristic:aChar];
            }
        }
    }
    else if ([service.UUID isEqual:[CBUUID UUIDWithString:BLE_WATER_SERVICE_UUID_PRESENCE]]) {
        for (CBCharacteristic *aChar in service.characteristics) {
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_WATER_CHAR_UUID_PRESENCE_ALARM_SET]]) {
                [aPeripheral readValueForCharacteristic:aChar];
            }
            else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_WATER_CHAR_UUID_PRESENCE_ALARM]]) {
                [aPeripheral setNotifyValue:YES forCharacteristic:aChar];
            }
            else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_WATER_CHAR_UUID_PRESENCE_CURRENT]]) {
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
    
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_WATER_CHAR_UUID_LEVEL_CURRENT]]) {
        self.level = [self sensorValueForCharacteristic:characteristic];
        [self.entity saveNewValueWithType:kValueTypeLevel value:_level];
    } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_WATER_CHAR_UUID_PRESENCE_CURRENT]]) {
        self.presense = [self sensorValueForCharacteristic:characteristic];
        [self.entity saveNewValueWithType:kValueTypePresence value:_presense];
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_WATER_CHAR_UUID_LEVEL_ALARM_SET]]) {
        if (_levelAlarmState == kAlarmStateUnknown) {
            self.levelAlarmState = [self alarmStateForCharacteristic:characteristic];
        }
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_WATER_CHAR_UUID_PRESENCE_ALARM_SET]]) {
        if (_presenseAlarmState == kAlarmStateUnknown) {
            self.presenseAlarmState = [self alarmStateForCharacteristic:characteristic];
        }
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_WATER_CHAR_UUID_PRESENCE_ALARM]]) {
        if ((_presenseAlarmState == kAlarmStateEnabled)&&([[NSDate date] timeIntervalSinceReferenceDate]>(_presenceAlarmTimeshot+30))) {
            _presenceAlarmTimeshot = [[NSDate date] timeIntervalSinceReferenceDate];
            
            [super showAlarmNotification:@"Water Presence" forUuid:BLE_WATER_CHAR_UUID_PRESENCE_ALARM_SET];
        }
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_WATER_CHAR_UUID_LEVEL_ALARM_LOW_VALUE]]) {
        self.levelAlarmLow = [self alarmValueForCharacteristic:characteristic];
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_WATER_CHAR_UUID_LEVEL_ALARM_HIGH_VALUE]]) {
        self.levelAlarmHigh = [self alarmValueForCharacteristic:characteristic];
    }
}

@end
