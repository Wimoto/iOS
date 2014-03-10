//
//  CBPeripheral+Util.m
//  Wimoto
//
//  Created by Danny Kokarev on 12.12.12.
//
//

#import "CBPeripheral+Util.h"

@implementation CBPeripheral (CBPeripheral_Util)

- (void)identifyWithDelegate:(id<CBPeripheralDelegate>)delegate {
    self.delegate = delegate;
    [self discoverServices:nil];
}

- (NSString*)systemId {
    for (CBService *aService in self.services) {
        if ([aService.UUID isEqual:[CBUUID UUIDWithString:BLE_GENERIC_SERVICE_UUID_DEVICE]]) {
            for (CBCharacteristic *aChar in aService.characteristics) {
                if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_GENERIC_CHAR_UUID_SYSTEM_ID]]) {
                    const uint64_t *byteArray = [aChar.value bytes];
                    if (byteArray) { //////////////////////////////
                        uint64_t value = byteArray[0];
                        return [NSString stringWithFormat:@"%llu", value];
                    }
                }
            }
        }
    }
    return @"";
}

- (PeripheralType)peripheralType {
    for (CBService *aService in self.services) {
        NSLog(@"aService - %@", aService.UUID);
        if ([aService.UUID isEqual:[CBUUID UUIDWithString:BLE_TEST_SERVICE_UUID_HEARTRATE]]) {
            return kPeripheralTypeTest;
        } else if ([aService.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_SERVICE_UUID_TEMPERATURE]]) {
            return kPeripheralTypeClimate;
        } else if ([aService.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_SERVICE_UUID_LIGHT]]) {
            return kPeripheralTypeClimate;
        } else if ([aService.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_SERVICE_UUID_HUMIDITY]]) {
            return kPeripheralTypeClimate;
        } else if ([aService.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_LIGHT]]) {
            return kPeripheralTypeGrow;
        } else if ([aService.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_SOIL_MOISTURE]]) {
            return kPeripheralTypeGrow;
        } else if ([aService.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_SOIL_TEMPERATURE]]) {
            return kPeripheralTypeGrow;
        } else if ([aService.UUID isEqual:[CBUUID UUIDWithString:BLE_THERMO_SERVICE_UUID_IR_TEMPERATURE]]) {
            return kPeripheralTypeThermo;
        } else if ([aService.UUID isEqual:[CBUUID UUIDWithString:BLE_THERMO_SERVICE_UUID_PROBE_TEMPERATURE]]) {
            return kPeripheralTypeThermo;
        } else if ([aService.UUID isEqual:[CBUUID UUIDWithString:BLE_SENTRY_SERVICE_UUID_ACCELEROMETER]]) {
            return kPeripheralTypeSentry;
        } else if ([aService.UUID isEqual:[CBUUID UUIDWithString:BLE_SENTRY_SERVICE_UUID_PASSIVE_INFRARED]]) {
            return kPeripheralTypeSentry;
        } else if ([aService.UUID isEqual:[CBUUID UUIDWithString:BLE_WATER_SERVICE_UUID_PRESENCE]]) {
            return kPeripheralTypeWater;
        } else if ([aService.UUID isEqual:[CBUUID UUIDWithString:BLE_WATER_SERVICE_UUID_LEVEL]]) {
            return kPeripheralTypeWater;
        }
    }
    return kPeripheralTypeUndefined;
}

@end
