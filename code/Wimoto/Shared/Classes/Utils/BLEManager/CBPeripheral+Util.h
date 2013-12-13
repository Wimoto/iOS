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
    kPeripheralTypeTest,
    kPeripheralTypeClimate,
    kPeripheralTypeGrow,
    kPeripheralTypeThermo,
    kPeripheralTypeSentry,
    kPeripheralTypeWater
} PeripheralType;

#define BLE_CLIMATE_SERVICE_UUID_TEMPERATURE        @"E0035608-EC48-4ED0-9F3B-5419C00A94FD"
#define BLE_CLIMATE_SERVICE_UUID_LIGHT              @"E003560E-EC48-4ED0-9F3B-5419C00A94FD"
#define BLE_CLIMATE_SERVICE_UUID_HUMIDITY           @"E0035614-EC48-4ED0-9F3B-5419C00A94FD"

#define BLE_CLIMATE_CHAR_UUID_TEMPERATURE_CURRENT        @"E0035609-EC48-4ED0-9F3B-5419C00A94FD"
#define BLE_CLIMATE_CHAR_UUID_LIGHT_CURRENT              @"E003560F-EC48-4ED0-9F3B-5419C00A94FD"
#define BLE_CLIMATE_CHAR_UUID_HUMIDITY_CURRENT           @"E0035615-EC48-4ED0-9F3B-5419C00A94FD"

@interface CBPeripheral (CBPeripheral_Util)

- (void)identifyWithDelegate:(id<CBPeripheralDelegate>)delegate;

- (NSString*)systemId;
- (PeripheralType)peripheralType;

@end
