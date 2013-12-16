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
                    uint64_t value = byteArray[0];
                    
                    return [NSString stringWithFormat:@"%llu", value];
                }
            }
        }
    }
    return @"";
}

- (PeripheralType)peripheralType {
    NSLog(@"peripheralType");
    
    for (CBService *aService in self.services) {
        NSLog(@"aService %@", aService.UUID);
        if ([aService.UUID isEqual:[CBUUID UUIDWithString:BLE_TEST_SERVICE_UUID_HEARTRATE]]) {
            return kPeripheralTypeTest;
        } else if ([aService.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_SERVICE_UUID_TEMPERATURE]]) {
            return kPeripheralTypeClimate;
        } else if ([aService.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_SERVICE_UUID_LIGHT]]) {
            return kPeripheralTypeClimate;
        } else if ([aService.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_SERVICE_UUID_HUMIDITY]]) {
            return kPeripheralTypeClimate;
        }
    }
    return kPeripheralTypeUndefined;
}

@end
