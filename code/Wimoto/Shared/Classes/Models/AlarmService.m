//
//  AlarmService.m
//  Wimoto
//
//  Created by Danny Kokarev on 22.05.14.
//
//

#import "AlarmService.h"
#import "CBPeripheral+Util.h"
#import "Sensor.h"

@interface AlarmService() <CBPeripheralDelegate> {
    CBPeripheral *servicePeripheral;
    CBService *alarmService;
    CBCharacteristic *alarmSetCharacteristic;
    CBCharacteristic *minValueCharacteristic;
    CBCharacteristic *maxValueCharacteristic;
    CBCharacteristic *alarmCharacteristic;
    CBUUID *alarmUUID;
    CBUUID *alarmMinimumUUID;
    CBUUID *alarmMaximumUUID;
    CBUUID *alarmCurrentUUID;
    id<AlarmServiceDelegate> peripheralDelegate;
    NSString *serviceUUIDString;
}
@end

@implementation AlarmService

- (id)initWithSensor:(id<AlarmServiceDelegate>)sensor serviceUUIDString:(NSString *)serviceUUID {
    self = [super init];
    if (self) {
        servicePeripheral = [[(Sensor *)sensor peripheral] copy];
        servicePeripheral.delegate = self;
        peripheralDelegate = sensor;
        serviceUUIDString = serviceUUID;
        
        if ([serviceUUID isEqualToString:BLE_CLIMATE_SERVICE_UUID_TEMPERATURE]) {
            alarmMinimumUUID = [CBUUID UUIDWithString:BLE_CLIMATE_SERVICE_UUID_TEMPERATURE_ALARM_LOW_VALUE];
            alarmMaximumUUID = [CBUUID UUIDWithString:BLE_CLIMATE_SERVICE_UUID_TEMPERATURE_ALARM_HIGH_VALUE];
            alarmUUID = [CBUUID UUIDWithString:BLE_CLIMATE_SERVICE_UUID_TEMPERATURE_ALARM];
        }
        else if ([serviceUUID isEqualToString:BLE_CLIMATE_SERVICE_UUID_LIGHT]) {
            alarmMinimumUUID = [CBUUID UUIDWithString:BLE_CLIMATE_SERVICE_UUID_LIGHT_ALARM_LOW_VALUE];
            alarmMaximumUUID = [CBUUID UUIDWithString:BLE_CLIMATE_SERVICE_UUID_LIGHT_ALARM_HIGH_VALUE];
            alarmUUID = [CBUUID UUIDWithString:BLE_CLIMATE_SERVICE_UUID_LIGHT_ALARM];
        }
        else if ([serviceUUID isEqualToString:BLE_CLIMATE_SERVICE_UUID_HUMIDITY]) {
            alarmMinimumUUID = [CBUUID UUIDWithString:BLE_CLIMATE_SERVICE_UUID_HUMIDITY_ALARM_LOW_VALUE];
            alarmMaximumUUID = [CBUUID UUIDWithString:BLE_CLIMATE_SERVICE_UUID_HUMIDITY_ALARM_HIGH_VALUE];
            alarmUUID = [CBUUID UUIDWithString:BLE_CLIMATE_SERVICE_UUID_HUMIDITY_ALARM];
        }
        else if ([serviceUUID isEqualToString:BLE_WATER_SERVICE_UUID_PRESENCE]) {
            alarmUUID = [CBUUID UUIDWithString:BLE_WATER_SERVICE_UUID_PRESENCE_ALARM];
        }
        else if ([serviceUUID isEqualToString:BLE_WATER_SERVICE_UUID_LEVEL]) {
            alarmMinimumUUID = [CBUUID UUIDWithString:BLE_WATER_SERVICE_UUID_LEVEL_ALARM_LOW_VALUE];
            alarmMaximumUUID = [CBUUID UUIDWithString:BLE_WATER_SERVICE_UUID_LEVEL_ALARM_HIGH_VALUE];
            alarmUUID = [CBUUID UUIDWithString:BLE_WATER_SERVICE_UUID_LEVEL_ALARM];
        }
        else if ([serviceUUID isEqualToString:BLE_GROW_SERVICE_UUID_LIGHT]) {
            alarmMinimumUUID = [CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_LIGHT_ALARM_LOW_VALUE];
            alarmMaximumUUID = [CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_LIGHT_ALARM_HIGH_VALUE];
            alarmUUID = [CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_LIGHT_ALARM];
        }
        else if ([serviceUUID isEqualToString:BLE_GROW_SERVICE_UUID_SOIL_MOISTURE]) {
            alarmMinimumUUID = [CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_SOIL_MOISTURE_ALARM_LOW_VALUE];
            alarmMaximumUUID = [CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_SOIL_MOISTURE_ALARM_HIGH_VALUE];
            alarmUUID = [CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_SOIL_MOISTURE_ALARM];
        }
        else if ([serviceUUID isEqualToString:BLE_GROW_SERVICE_UUID_SOIL_TEMPERATURE]) {
            alarmMinimumUUID = [CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_SOIL_TEMPERATURE_ALARM_LOW_VALUE];
            alarmMaximumUUID = [CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_SOIL_TEMPERATURE_ALARM_HIGH_VALUE];
            alarmUUID = [CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_SOIL_TEMPERATURE_ALARM];
        }
        else if ([serviceUUID isEqualToString:BLE_SENTRY_SERVICE_UUID_ACCELEROMETER]) {
            alarmUUID = [CBUUID UUIDWithString:BLE_SENTRY_SERVICE_UUID_ACCELEROMETER_ALARM];
        }
        else if ([serviceUUID isEqualToString:BLE_SENTRY_SERVICE_UUID_PASSIVE_INFRARED]) {
            alarmUUID = [CBUUID UUIDWithString:BLE_SENTRY_SERVICE_UUID_PASSIVE_INFRARED_ALARM];
        }
        else if ([serviceUUID isEqualToString:BLE_THERMO_SERVICE_UUID_IR_TEMPERATURE]) {
            alarmMinimumUUID = [CBUUID UUIDWithString:BLE_THERMO_SERVICE_UUID_IR_TEMPERATURE_ALARM_LOW_VALUE];
            alarmMaximumUUID = [CBUUID UUIDWithString:BLE_THERMO_SERVICE_UUID_IR_TEMPERATURE_ALARM_HIGH_VALUE];
            alarmUUID = [CBUUID UUIDWithString:BLE_THERMO_SERVICE_UUID_IR_TEMPERATURE_ALARM];
        }
        else if ([serviceUUID isEqualToString:BLE_THERMO_SERVICE_UUID_PROBE_TEMPERATURE]) {
            alarmMinimumUUID = [CBUUID UUIDWithString:BLE_THERMO_SERVICE_UUID_PROBE_TEMPERATURE_ALARM_LOW_VALUE];
            alarmMaximumUUID = [CBUUID UUIDWithString:BLE_THERMO_SERVICE_UUID_PROBE_TEMPERATURE_ALARM_HIGH_VALUE];
            alarmUUID = [CBUUID UUIDWithString:BLE_THERMO_SERVICE_UUID_PROBE_TEMPERATURE_ALARM];
        }
        [self findAlarmCharacteristics];
    }
    return self;
}

- (void)findAlarmCharacteristics {
    NSArray	*services = nil;
    NSMutableArray *uuids = [NSMutableArray array];
    if (alarmMinimumUUID) {
        [uuids addObject:alarmMinimumUUID];
    }
    if (alarmMaximumUUID) {
        [uuids addObject:alarmMaximumUUID];
    }
    if (alarmUUID) {
        [uuids addObject:alarmUUID];
    }
	services = [servicePeripheral services];
	if (!services || ![services count]) {
		return ;
	}
	alarmService = nil;
	for (CBService *service in services) {
		if ([[service UUID] isEqual:[CBUUID UUIDWithString:serviceUUIDString]]) {
			alarmService = service;
			break;
		}
	}
	if (alarmService) {
		[servicePeripheral discoverCharacteristics:uuids forService:alarmService];
	}
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
	NSArray	*services = nil;
    NSMutableArray *uuids = [NSMutableArray array];
    if (alarmMinimumUUID) {
        [uuids addObject:alarmMinimumUUID];
    }
    if (alarmMaximumUUID) {
        [uuids addObject:alarmMaximumUUID];
    }
    if (alarmUUID) {
        [uuids addObject:alarmUUID];
    }
    if (peripheral != servicePeripheral) {
		NSLog(@"Wrong Peripheral.\n");
		return ;
	}
    if (error != nil) {
        NSLog(@"Error %@\n", error);
		return ;
	}
	services = [peripheral services];
	if (!services || ![services count]) {
		return ;
	}
	alarmService = nil;
	for (CBService *service in services) {
		if ([[service UUID] isEqual:[CBUUID UUIDWithString:serviceUUIDString]]) {
			alarmService = service;
			break;
		}
	}
	if (alarmService) {
		[peripheral discoverCharacteristics:uuids forService:alarmService];
	}
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
	NSArray *characteristics = [service characteristics];
	CBCharacteristic *characteristic;
	if (peripheral != servicePeripheral) {
		NSLog(@"Wrong Peripheral.\n");
		return ;
	}
	if (service != alarmService) {
		NSLog(@"Wrong Service.\n");
		return ;
	}
    if (error != nil) {
		NSLog(@"Error %@\n", error);
		return ;
	}
	for (characteristic in characteristics) {
        NSLog(@"discovered characteristic %@", [characteristic UUID]);
		if ([[characteristic UUID] isEqual:alarmMinimumUUID]) { // Min Temperature.
            NSLog(@"Discovered Minimum Alarm Characteristic");
			minValueCharacteristic = characteristic;
			[peripheral readValueForCharacteristic:characteristic];
		}
        else if ([[characteristic UUID] isEqual:alarmMaximumUUID]) { // Max Temperature.
            NSLog(@"Discovered Maximum Alarm Characteristic");
			maxValueCharacteristic = characteristic;
			[peripheral readValueForCharacteristic:characteristic];
		}
        else if ([[characteristic UUID] isEqual:alarmUUID]) { // Alarm
            NSLog(@"Discovered Alarm Characteristic");
			alarmCharacteristic = characteristic;
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
		}
	}
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    uint8_t alarmValue  = 0;
	if (peripheral != servicePeripheral) {
		NSLog(@"Wrong peripheral\n");
		return ;
	}
    if ([error code] != 0) {
		NSLog(@"Error %@\n", error);
		return ;
	}
    /* Alarm change */
    if ([[characteristic UUID] isEqual:alarmUUID]) {
        /* get the value for the alarm */
        [[alarmCharacteristic value] getBytes:&alarmValue length:sizeof (alarmValue)];
        NSLog(@"alarm!  0x%x", alarmValue);
        if (alarmValue & 0x01) {
            /* Alarm is firing */
            if (alarmValue & 0x02) {
                [peripheralDelegate alarmService:self didSoundAlarmOfType:kAlarmLow];
			}
            else {
                [peripheralDelegate alarmService:self didSoundAlarmOfType:kAlarmHigh];
			}
        }
        else {
            [peripheralDelegate alarmServiceDidStopAlarm:self];
        }
        return;
    }
    /* Upper or lower bounds changed */
    if ([characteristic.UUID isEqual:alarmMinimumUUID] || [characteristic.UUID isEqual:alarmMaximumUUID]) {
        [peripheralDelegate alarmServiceDidChangeTemperatureBounds:self];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    /* When a write occurs, need to set off a re-read of the local CBCharacteristic to update its value */
    [peripheral readValueForCharacteristic:characteristic];
    /* Upper or lower bounds changed */
    if ([characteristic.UUID isEqual:alarmMinimumUUID] || [characteristic.UUID isEqual:alarmMaximumUUID]) {
        [peripheralDelegate alarmServiceDidChangeTemperatureBounds:self];
    }
}

- (void)writeLowAlarmValue:(int)low {
    NSData *data = nil;
    int16_t value = (int16_t)low;
    if (!servicePeripheral) {
        NSLog(@"Not connected to a peripheral");
		return ;
    }
    if (!minValueCharacteristic) {
        NSLog(@"No valid minTemp characteristic");
        return;
    }
    data = [NSData dataWithBytes:&value length:sizeof (value)];
    [servicePeripheral writeValue:data forCharacteristic:minValueCharacteristic type:CBCharacteristicWriteWithResponse];
}

- (void)writeHighAlarmValue:(int)high {
    NSData *data = nil;
    int16_t value = (int16_t)high;
    if (!servicePeripheral) {
        NSLog(@"Not connected to a peripheral");
    }
    
    if (!maxValueCharacteristic) {
        NSLog(@"No valid minTemp characteristic");
        return;
    }
    data = [NSData dataWithBytes:&value length:sizeof (value)];
    [servicePeripheral writeValue:data forCharacteristic:maxValueCharacteristic type:CBCharacteristicWriteWithResponse];
}

- (CGFloat)minimumAlarmValue {
    CGFloat result  = NAN;
    int16_t value	= 0;
    if (minValueCharacteristic) {
        [[minValueCharacteristic value] getBytes:&value length:sizeof (value)];
        result = (CGFloat)value / 10.0f;
    }
    return result;
}

- (CGFloat)maximumAlarmValue {
    CGFloat result  = NAN;
    int16_t	value	= 0;
    if (maxValueCharacteristic) {
        [[maxValueCharacteristic value] getBytes:&value length:sizeof (value)];
        result = (CGFloat)value / 10.0f;
    }
    return result;
}

@end
