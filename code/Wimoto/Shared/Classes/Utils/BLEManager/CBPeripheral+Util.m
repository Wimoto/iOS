//
//  CBPeripheral+Util.m
//  Wimoto
//
//  Created by Danny Kokarev on 12.12.12.
//
//

#import "CBPeripheral+Util.h"
#import "CBUUID+StringExtraction.h"
#import "NSString+Util.h"

@implementation CBPeripheral (CBPeripheral_Util)

- (NSString*)systemId
{
    for (CBService *aService in self.services) {
        if ([aService.UUID isEqual:[CBUUID UUIDWithString:BLE_GENERIC_SERVICE_UUID_DEVICE]]) {
            for (CBCharacteristic *aChar in aService.characteristics) {
                if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_GENERIC_CHAR_UUID_SYSTEM_ID]]) {
                    const uint64_t *byteArray = [aChar.value bytes];
                    if (byteArray) {
                        uint64_t value = byteArray[0];
                        NSLog(@"SystemID string ------- %@", [NSString stringWithFormat:@"%llu", value]);
                        return [NSString stringWithFormat:@"%llu", value];
                    }
                }
            }
        }
    }
    return @"";
}

- (PeripheralType)peripheralType
{
    NSLog(@"peripheralType: SERVICES COUNT === %d", [self.services count]);
    for (CBService *aService in self.services) {
        if ([aService.UUID isEqual:[CBUUID UUIDWithString:BLE_GENERIC_SERVICE_UUID_DEVICE]]) {
            for (CBCharacteristic *aChar in aService.characteristics) {
                if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_GENERIC_CHAR_UUID_MODEL_NUMBER]]) {
                    NSString *model = [[NSString alloc] initWithData:aChar.value encoding:NSASCIIStringEncoding];

                    NSLog(@"peripheralType: MODEL string ------- %@", model);
                    
                    if ([model rangeOfString:BLE_CLIMATE_MODEL options:NSCaseInsensitiveSearch].location != NSNotFound) {
                        return kPeripheralTypeClimate;
                    } else if ([model rangeOfString:BLE_WATER_MODEL options:NSCaseInsensitiveSearch].location != NSNotFound) {
                        return kPeripheralTypeWater;
                    } else if ([model rangeOfString:BLE_GROW_MODEL options:NSCaseInsensitiveSearch].location != NSNotFound) {
                        return kPeripheralTypeGrow;
                    } else if ([model rangeOfString:BLE_SENTRY_MODEL options:NSCaseInsensitiveSearch].location != NSNotFound) {
                        return kPeripheralTypeSentry;
                    } else if ([model rangeOfString:BLE_THERMO_MODEL options:NSCaseInsensitiveSearch].location != NSNotFound) {
                        return kPeripheralTypeThermo;
                    }
                }
            }
        }
    }
    return kPeripheralTypeUndefined;
}

- (BOOL)isIdentified {
    if (([self peripheralType] != kPeripheralTypeUndefined) && ([[self systemId] isNotEmpty])) {
        return YES;
    }
    return NO;
}

- (NSString*)uniqueIdentifier {
    NSString *identifier = [self systemId];
    // TODO temp fix for Eugene I. sensors
    if ([identifier isEqualToString:@"7383519721266824277"]) {
        identifier = [[self identifier] UUIDString];
    }
    return identifier;
}

@end
