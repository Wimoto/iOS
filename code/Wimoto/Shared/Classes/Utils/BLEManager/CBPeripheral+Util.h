//
//  CBPeripheral+Util.h
//  Wimoto
//
//  Created by Danny Kokarev on 12.12.12.
//
//

#import <CoreBluetooth/CoreBluetooth.h>

typedef enum {
    kPeripheralTypeUndefined = 0,
    kPeripheralTypeClimate,
    kPeripheralTypeGrow,
    kPeripheralTypeThermo,
    kPeripheralTypeSentry,
    kPeripheralTypeWater
} PeripheralType;

@interface CBPeripheral (CBPeripheral_Util)

- (void)identifyWithDelegate:(id<CBPeripheralDelegate>)delegate;

- (NSString*)systemId;
- (PeripheralType)peripheralType;

@end
