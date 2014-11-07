//
//  ThermoSensor.m
//  Wimoto
//
//  Created by Danny Kokarev on 25.12.13.
//
//

#import "ThermoSensor.h"
#import "AppConstants.h"

@implementation ThermoSensor

- (PeripheralType)type {
    return kPeripheralTypeThermo;
}

- (NSString *)codename {
    return @"Thermo";
}

#pragma mark - CBPeriferalDelegate

- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error {
    [super peripheral:aPeripheral didDiscoverServices:error];
    for (CBService *aService in aPeripheral.services) {
        NSLog(@"ThermoSensor didDiscoverServices %@", aService);
        if ([aService.UUID isEqual:[CBUUID UUIDWithString:BLE_THERMO_SERVICE_UUID_IR_TEMPERATURE]]) {
            [aPeripheral discoverCharacteristics:[NSArray arrayWithObjects:
                                                  [CBUUID UUIDWithString:BLE_THERMO_CHAR_UUID_IR_TEMPERATURE_CURRENT],
                                                  [CBUUID UUIDWithString:BLE_THERMO_SERVICE_UUID_IR_TEMPERATURE_ALARM_LOW_VALUE],
                                                  [CBUUID UUIDWithString:BLE_THERMO_SERVICE_UUID_IR_TEMPERATURE_ALARM_HIGH_VALUE],
                                                  [CBUUID UUIDWithString:BLE_THERMO_SERVICE_UUID_IR_TEMPERATURE_ALARM_SET],
                                                  [CBUUID UUIDWithString:BLE_THERMO_SERVICE_UUID_IR_TEMPERATURE_ALARM],
                                                  nil]
                                      forService:aService];
            
        } else if ([aService.UUID isEqual:[CBUUID UUIDWithString:BLE_THERMO_SERVICE_UUID_PROBE_TEMPERATURE]]) {
            [aPeripheral discoverCharacteristics:[NSArray arrayWithObjects:
                                                  [CBUUID UUIDWithString:BLE_THERMO_CHAR_UUID_PROBE_TEMPERATURE_CURRENT],
                                                  [CBUUID UUIDWithString:BLE_THERMO_SERVICE_UUID_PROBE_TEMPERATURE_ALARM_LOW_VALUE],
                                                  [CBUUID UUIDWithString:BLE_THERMO_SERVICE_UUID_PROBE_TEMPERATURE_ALARM_HIGH_VALUE],
                                                  [CBUUID UUIDWithString:BLE_THERMO_SERVICE_UUID_PROBE_TEMPERATURE_ALARM_SET],
                                                  [CBUUID UUIDWithString:BLE_THERMO_SERVICE_UUID_PROBE_TEMPERATURE_ALARM],
                                                  nil]
                                      forService:aService];
        }
    }
}

- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    [super peripheral:aPeripheral didDiscoverCharacteristicsForService:service error:error];
    if ([service.UUID isEqual:[CBUUID UUIDWithString:BLE_THERMO_SERVICE_UUID_IR_TEMPERATURE]]) {
        for (CBCharacteristic *aChar in service.characteristics) {
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_THERMO_SERVICE_UUID_IR_TEMPERATURE_ALARM_LOW_VALUE]]||
                [aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_THERMO_SERVICE_UUID_IR_TEMPERATURE_ALARM_HIGH_VALUE]]||
                [aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_THERMO_SERVICE_UUID_IR_TEMPERATURE_ALARM_SET]]) {
                [aPeripheral readValueForCharacteristic:aChar];
            }
            else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_THERMO_SERVICE_UUID_IR_TEMPERATURE_ALARM]]) {
                [aPeripheral setNotifyValue:YES forCharacteristic:aChar];
            }
            else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_THERMO_CHAR_UUID_IR_TEMPERATURE_CURRENT]]) {
                [aPeripheral readValueForCharacteristic:aChar];
                [aPeripheral setNotifyValue:YES forCharacteristic:aChar];
            }
        }
    }
    else if ([service.UUID isEqual:[CBUUID UUIDWithString:BLE_THERMO_SERVICE_UUID_PROBE_TEMPERATURE]]) {
        for (CBCharacteristic *aChar in service.characteristics) {
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_THERMO_SERVICE_UUID_PROBE_TEMPERATURE_ALARM_LOW_VALUE]]||
                [aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_THERMO_SERVICE_UUID_PROBE_TEMPERATURE_ALARM_HIGH_VALUE]]||
                [aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_THERMO_SERVICE_UUID_PROBE_TEMPERATURE_ALARM_SET]]) {
                [aPeripheral readValueForCharacteristic:aChar];
            }
            else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_THERMO_SERVICE_UUID_PROBE_TEMPERATURE_ALARM]]) {
                [aPeripheral setNotifyValue:YES forCharacteristic:aChar];
            }
            else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_THERMO_CHAR_UUID_PROBE_TEMPERATURE_CURRENT]]) {
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
    NSLog(@"ThermoSensor didUpdateValueForCharacteristic start");
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_THERMO_CHAR_UUID_IR_TEMPERATURE_CURRENT]]) {
            self.irTemp = [self roundToOne:[[self sensorStringValueForCharacteristic:characteristic] floatValue]];
            [self.entity saveNewValueWithType:kValueTypeIRTemperature value:_irTemp];
        } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_THERMO_CHAR_UUID_PROBE_TEMPERATURE_CURRENT]]) {
            self.probeTemp = [self roundToOne:[self sensorValueForCharacteristic:characteristic]];
            [self.entity saveNewValueWithType:kValueTypeProbeTemperature value:_probeTemp];
        } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_THERMO_SERVICE_UUID_IR_TEMPERATURE_ALARM_SET]]) {
            if (_irTempAlarmState == kAlarmStateUnknown) {
                self.irTempAlarmState = [self alarmStateForCharacteristic:characteristic];
            }
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_THERMO_SERVICE_UUID_PROBE_TEMPERATURE_ALARM_SET]]) {
            if (_probeTempAlarmState == kAlarmStateUnknown) {
                self.probeTempAlarmState = [self alarmStateForCharacteristic:characteristic];
            }
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_THERMO_SERVICE_UUID_IR_TEMPERATURE_ALARM]]||
                [characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_THERMO_SERVICE_UUID_PROBE_TEMPERATURE_ALARM]]) {
            uint8_t alarmValue  = 0;
            [[characteristic value] getBytes:&alarmValue length:sizeof (alarmValue)];
            NSLog(@"alarm!  0x%x", alarmValue);
            if (alarmValue & 0x01) {
                if (alarmValue & 0x02) {
                    [self alarmActionWithCharacteristic:characteristic alarmType:kAlarmLow];
                }
                else {
                    [self alarmActionWithCharacteristic:characteristic alarmType:kAlarmHigh];
                }
            }
            else {
                    //[self alarmServiceDidStopAlarm:characteristic];
            }
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_THERMO_SERVICE_UUID_IR_TEMPERATURE_ALARM_LOW_VALUE]]) {
            self.irTempAlarmLow = [self alarmValueForCharacteristic:characteristic];
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_THERMO_SERVICE_UUID_IR_TEMPERATURE_ALARM_HIGH_VALUE]]) {
            self.irTempAlarmHigh = [self alarmValueForCharacteristic:characteristic];
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_THERMO_SERVICE_UUID_PROBE_TEMPERATURE_ALARM_LOW_VALUE]]) {
            self.probeTempAlarmLow = [self alarmValueForCharacteristic:characteristic];
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_THERMO_SERVICE_UUID_PROBE_TEMPERATURE_ALARM_HIGH_VALUE]]) {
            self.probeTempAlarmHigh = [self alarmValueForCharacteristic:characteristic];
        }
    });
}

- (void)alarmActionWithCharacteristic:(CBCharacteristic *)characteristic alarmType:(AlarmType)alarmtype {
    NSString *alertString;
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_THERMO_SERVICE_UUID_IR_TEMPERATURE_ALARM]]) {
        if (_irTempAlarmState != kAlarmStateEnabled) {
            return;
        }
        alertString = [NSString stringWithFormat:@"%@ IR Temperature %@", self.name, (alarmtype == kAlarmHigh)?@"high value":@"low value"];
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_THERMO_SERVICE_UUID_PROBE_TEMPERATURE_ALARM]]) {
        if (_probeTempAlarmState != kAlarmStateEnabled) {
            return;
        }
        alertString = [NSString stringWithFormat:@"%@ probe Temperature %@", self.name, (alarmtype == kAlarmHigh)?@"high value":@"low value"];
    }
    if (alertString) {
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
            localNotification.category = NOTIFICATION_ALARM_CATEGORY_ID; //  Same as category identifier
        }
        localNotification.alertBody = alertString;
        localNotification.alertAction = @"View";
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    }
}


@end
