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
    NSLog(@"peripheralType: SERVICES COUNT === %i", [self.services count]);
    for (CBService *aService in self.services) {
        if ([aService.UUID isEqual:[CBUUID UUIDWithString:BLE_GENERIC_SERVICE_UUID_DEVICE]]) {
            for (CBCharacteristic *aChar in aService.characteristics) {
                if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_GENERIC_CHAR_UUID_MODEL_NUMBER]]) {
                    NSString *model = [[NSString alloc] initWithData:aChar.value encoding:NSASCIIStringEncoding];

                    NSLog(@"peripheralType: MODEL string ------- %@", model);
                    
                    if ([model isEqual:BLE_CLIMATE_MODEL]) {
                        return kPeripheralTypeClimate;
                    } else if ([model isEqual:BLE_WATER_MODEL]) {
                        return kPeripheralTypeWater;
                    } else if ([model isEqual:BLE_GROW_MODEL]) {
                        return kPeripheralTypeGrow;
                    } else if ([model isEqual:BLE_SENTRY_MODEL]) {
                        return kPeripheralTypeSentry;
                    } else if ([model isEqual:BLE_THERMO_MODEL]) {
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
#ifdef DEBUG
    identifier = [[self identifier] UUIDString];
#endif
    return identifier;
}

@end
