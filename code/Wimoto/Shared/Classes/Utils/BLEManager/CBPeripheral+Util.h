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

#define BLE_GENERIC_SERVICE_UUID_DEVICE                     @"180A"

#define BLE_GENERIC_CHAR_UUID_SYSTEM_ID                     @"2A23"

#define BLE_CLIMATE_SERVICE_UUID_TEMPERATURE                @"E0035608-EC48-4ED0-9F3B-5419C00A94FD"
#define BLE_CLIMATE_SERVICE_UUID_LIGHT                      @"E003560E-EC48-4ED0-9F3B-5419C00A94FD"
#define BLE_CLIMATE_SERVICE_UUID_HUMIDITY                   @"E0035614-EC48-4ED0-9F3B-5419C00A94FD"

#define BLE_CLIMATE_CHAR_UUID_TEMPERATURE_CURRENT           @"E0035609-EC48-4ED0-9F3B-5419C00A94FD"
#define BLE_CLIMATE_CHAR_UUID_LIGHT_CURRENT                 @"E003560F-EC48-4ED0-9F3B-5419C00A94FD"
#define BLE_CLIMATE_CHAR_UUID_HUMIDITY_CURRENT              @"E0035615-EC48-4ED0-9F3B-5419C00A94FD"

#define BLE_WATER_SERVICE_UUID_PRESENCE                     @"2024"
#define BLE_WATER_SERVICE_UUID_LEVEL                        @"2124"

#define BLE_WATER_CHAR_UUID_PRESENCE_CURRENT                @"2024"
#define BLE_WATER_CHAR_UUID_LEVEL_CURRENT                   @"2124"

#define BLE_GROW_SERVICE_UUID_LIGHT                         @""
#define BLE_GROW_SERVICE_UUID_SOIL_MOISTURE                 @""
#define BLE_GROW_SERVICE_UUID_SOIL_TEMPERATURE              @""

#define BLE_GROW_CHAR_UUID_LIGHT_CURRENT                    @""
#define BLE_GROW_CHAR_UUID_SOIL_MOISTURE_CURRENT            @""
#define BLE_GROW_CHAR_UUID_SOIL_TEMPERATURE_CURRENT         @""

#define BLE_TEST_SERVICE_UUID_HEARTRATE                     @"180D"

@interface CBPeripheral (CBPeripheral_Util)

- (void)identifyWithDelegate:(id<CBPeripheralDelegate>)delegate;

- (NSString*)systemId;
- (PeripheralType)peripheralType;

@end
