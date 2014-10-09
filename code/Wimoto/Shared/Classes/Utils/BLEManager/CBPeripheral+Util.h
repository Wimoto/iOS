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


#define BLE_CLIMATE_BASE_SERVICE_UUID                       @"1523"
#define BLE_WATER_BASE_SERVICE_UUID                         @"CE6E65C5-DEF4-4110-91F1-ACC0C82928BC"

#define BLE_CLIMATE_LIGHT_CHARACTERISTIC_UUID               @"1624"
#define BLE_CLIMATE_TEMPERATURE_CHARACTERISTIC_UUID         @"1524"
#define BLE_CLIMATE_HUMIDITY_CHARACTERISTIC_UUID            @"1724"

#define BLE_WATER_PRESENCE_CHARACTERISTIC_UUID              @"2024"
#define BLE_WATER_LEVEL_CHARACTERISTIC_UUID                 @"2124"


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#define BLE_BATTERY_LEVEL_SERVICE                                   @"180F"
#define BLE_BATTERY_LEVEL_CHARACTERISTIC                            @"2A19"

#define BLE_GENERIC_SERVICE_UUID_DEVICE                             @"180A"

#define BLE_GENERIC_CHAR_UUID_SYSTEM_ID                             @"2A23"
#define BLE_GENERIC_CHAR_UUID_MODEL_NUMBER                          @"2A24"

#define BLE_CLIMATE_MODEL                                           @"Wimoto_Climate"
#define BLE_CLIMATE_CHAR_UUID_TEMPERATURE_CURRENT                   @"E0035609-EC48-4ED0-9F3B-5419C00A94FD"
#define BLE_CLIMATE_AD_SERVICE_UUID_TEMPERATURE                     @"5608"
#define BLE_CLIMATE_SERVICE_UUID_TEMPERATURE                        @"E0035608-EC48-4ED0-9F3B-5419C00A94FD"
#define BLE_CLIMATE_SERVICE_UUID_TEMPERATURE_ALARM_LOW_VALUE        @"E003560A-EC48-4ED0-9F3B-5419C00A94FD"
#define BLE_CLIMATE_SERVICE_UUID_TEMPERATURE_ALARM_HIGH_VALUE       @"E003560B-EC48-4ED0-9F3B-5419C00A94FD"
#define BLE_CLIMATE_SERVICE_UUID_TEMPERATURE_ALARM_SET              @"E003560C-EC48-4ED0-9F3B-5419C00A94FD"
#define BLE_CLIMATE_SERVICE_UUID_TEMPERATURE_ALARM                  @"E003560D-EC48-4ED0-9F3B-5419C00A94FD"

#define BLE_CLIMATE_CHAR_UUID_LIGHT_CURRENT                         @"E003560F-EC48-4ED0-9F3B-5419C00A94FD"
#define BLE_CLIMATE_AD_SERVICE_UUID_LIGHT                           @"560E"
#define BLE_CLIMATE_SERVICE_UUID_LIGHT                              @"E003560E-EC48-4ED0-9F3B-5419C00A94FD"
#define BLE_CLIMATE_SERVICE_UUID_LIGHT_ALARM_LOW_VALUE              @"E0035610-EC48-4ED0-9F3B-5419C00A94FD"
#define BLE_CLIMATE_SERVICE_UUID_LIGHT_ALARM_HIGH_VALUE             @"E0035611-EC48-4ED0-9F3B-5419C00A94FD"
#define BLE_CLIMATE_SERVICE_UUID_LIGHT_ALARM_SET                    @"E0035612-EC48-4ED0-9F3B-5419C00A94FD"
#define BLE_CLIMATE_SERVICE_UUID_LIGHT_ALARM                        @"E0035613-EC48-4ED0-9F3B-5419C00A94FD"

#define BLE_CLIMATE_CHAR_UUID_HUMIDITY_CURRENT                      @"E0035615-EC48-4ED0-9F3B-5419C00A94FD"
#define BLE_CLIMATE_AD_SERVICE_UUID_HUMIDITY                        @"5614"
#define BLE_CLIMATE_SERVICE_UUID_HUMIDITY                           @"E0035614-EC48-4ED0-9F3B-5419C00A94FD"
#define BLE_CLIMATE_SERVICE_UUID_HUMIDITY_ALARM_LOW_VALUE           @"E0035616-EC48-4ED0-9F3B-5419C00A94FD"
#define BLE_CLIMATE_SERVICE_UUID_HUMIDITY_ALARM_HIGH_VALUE          @"E0035617-EC48-4ED0-9F3B-5419C00A94FD"
#define BLE_CLIMATE_SERVICE_UUID_HUMIDITY_ALARM_SET                 @"E0035618-EC48-4ED0-9F3B-5419C00A94FD"
#define BLE_CLIMATE_SERVICE_UUID_HUMIDITY_ALARM                     @"E0035619-EC48-4ED0-9F3B-5419C00A94FD"


#define BLE_WATER_MODEL                                             @"Wimoto_Water"
#define BLE_WATER_CHAR_UUID_PRESENCE_CURRENT                        @"35D8C7DC-9D78-43C2-AB2E-0E48CAC2DBDA"
#define BLE_WATER_AD_SERVICE_UUID_PRESENCE                          @"C7DB"
#define BLE_WATER_SERVICE_UUID_PRESENCE                             @"35D8C7DB-9D78-43C2-AB2E-0E48CAC2DBDA"
#define BLE_WATER_SERVICE_UUID_PRESENCE_ALARM_SET                   @"35D8C7DD-9D78-43C2-AB2E-0E48CAC2DBDA"
#define BLE_WATER_SERVICE_UUID_PRESENCE_ALARM                       @"35D8C7DE-9D78-43C2-AB2E-0E48CAC2DBDA"

#define BLE_WATER_CHAR_UUID_LEVEL_CURRENT                           @"35D8C7E0-9D78-43C2-AB2E-0E48CAC2DBDA"
#define BLE_WATER_AD_SERVICE_UUID_LEVEL                             @"C7DF"
#define BLE_WATER_SERVICE_UUID_LEVEL                                @"35D8C7DF-9D78-43C2-AB2E-0E48CAC2DBDA"
#define BLE_WATER_SERVICE_UUID_LEVEL_ALARM_LOW_VALUE                @"35D8C7E1-9D78-43C2-AB2E-0E48CAC2DBDA"
#define BLE_WATER_SERVICE_UUID_LEVEL_ALARM_HIGH_VALUE               @"35D8C7E2-9D78-43C2-AB2E-0E48CAC2DBDA"
#define BLE_WATER_SERVICE_UUID_LEVEL_ALARM_SET                      @"35D8C7E3-9D78-43C2-AB2E-0E48CAC2DBDA"
#define BLE_WATER_SERVICE_UUID_LEVEL_ALARM                          @"35D8C7E4-9D78-43C2-AB2E-0E48CAC2DBDA"


#define BLE_GROW_MODEL                                              @"Wimoto_Grow"
#define BLE_GROW_CHAR_UUID_LIGHT_CURRENT                            @"DAF4470D-BFB0-4DD8-9293-62AF5F545E31"
#define BLE_GROW_AD_SERVICE_UUID_LIGHT                              @"470C"
#define BLE_GROW_SERVICE_UUID_LIGHT                                 @"DAF4470C-BFB0-4DD8-9293-62AF5F545E31"
#define BLE_GROW_SERVICE_UUID_LIGHT_ALARM_LOW_VALUE                 @"DAF4470E-BFB0-4DD8-9293-62AF5F545E31"
#define BLE_GROW_SERVICE_UUID_LIGHT_ALARM_HIGH_VALUE                @"DAF4470F-BFB0-4DD8-9293-62AF5F545E31"
#define BLE_GROW_SERVICE_UUID_LIGHT_ALARM_SET                       @"DAF44710-BFB0-4DD8-9293-62AF5F545E31"
#define BLE_GROW_SERVICE_UUID_LIGHT_ALARM                           @"DAF44711-BFB0-4DD8-9293-62AF5F545E31"

#define BLE_GROW_CHAR_UUID_SOIL_MOISTURE_CURRENT                    @"DAF44713-BFB0-4DD8-9293-62AF5F545E31"
#define BLE_GROW_AD_SERVICE_UUID_SOIL_MOISTURE                      @"4712"
#define BLE_GROW_SERVICE_UUID_SOIL_MOISTURE                         @"DAF44712-BFB0-4DD8-9293-62AF5F545E31"
#define BLE_GROW_SERVICE_UUID_SOIL_MOISTURE_ALARM_LOW_VALUE         @"DAF44714-BFB0-4DD8-9293-62AF5F545E31"
#define BLE_GROW_SERVICE_UUID_SOIL_MOISTURE_ALARM_HIGH_VALUE        @"DAF44715-BFB0-4DD8-9293-62AF5F545E31"
#define BLE_GROW_SERVICE_UUID_SOIL_MOISTURE_ALARM_SET               @"DAF44716-BFB0-4DD8-9293-62AF5F545E31"
#define BLE_GROW_SERVICE_UUID_SOIL_MOISTURE_ALARM                   @"DAF44717-BFB0-4DD8-9293-62AF5F545E31"

#define BLE_GROW_CHAR_UUID_SOIL_TEMPERATURE_CURRENT                 @"DAF44707-BFB0-4DD8-9293-62AF5F545E31"
#define BLE_GROW_AD_SERVICE_UUID_SOIL_TEMPERATURE                   @"4706"
#define BLE_GROW_SERVICE_UUID_SOIL_TEMPERATURE                      @"DAF44706-BFB0-4DD8-9293-62AF5F545E31"
#define BLE_GROW_SERVICE_UUID_SOIL_TEMPERATURE_ALARM_LOW_VALUE      @"DAF44708-BFB0-4DD8-9293-62AF5F545E31"
#define BLE_GROW_SERVICE_UUID_SOIL_TEMPERATURE_ALARM_HIGH_VALUE     @"DAF44709-BFB0-4DD8-9293-62AF5F545E31"
#define BLE_GROW_SERVICE_UUID_SOIL_TEMPERATURE_ALARM_SET            @"DAF4470A-BFB0-4DD8-9293-62AF5F545E31"
#define BLE_GROW_SERVICE_UUID_SOIL_TEMPERATURE_ALARM                @"DAF4470B-BFB0-4DD8-9293-62AF5F545E31"


#define BLE_SENTRY_MODEL                                            @"Wimoto_Sentry"
#define BLE_SENTRY_CHAR_UUID_ACCELEROMETER_CURRENT                  @"4209DC69-E433-4420-83D8-CDAACCD2E312"
#define BLE_SENTRY_AD_SERVICE_UUID_ACCELEROMETER                    @"DC68"
#define BLE_SENTRY_SERVICE_UUID_ACCELEROMETER                       @"4209DC68-E433-4420-83D8-CDAACCD2E312"
#define BLE_SENTRY_SERVICE_UUID_ACCELEROMETER_ALARM_SET             @"4209DC6A-E433-4420-83D8-CDAACCD2E312"
#define BLE_SENTRY_SERVICE_UUID_ACCELEROMETER_ALARM_CLEAR           @"4209DC6B-E433-4420-83D8-CDAACCD2E312"
#define BLE_SENTRY_SERVICE_UUID_ACCELEROMETER_ALARM                 @"4209DC6C-E433-4420-83D8-CDAACCD2E312"

#define BLE_SENTRY_CHAR_UUID_PASSIVE_INFRARED_CURRENT               @"4209DC6E-E433-4420-83D8-CDAACCD2E312"
#define BLE_SENTRY_AD_SERVICE_UUID_PASSIVE_INFRARED                 @"DC6D"
#define BLE_SENTRY_SERVICE_UUID_PASSIVE_INFRARED                    @"4209DC6D-E433-4420-83D8-CDAACCD2E312"
#define BLE_SENTRY_SERVICE_UUID_PASSIVE_INFRARED_ALARM_SET          @"4209DC6F-E433-4420-83D8-CDAACCD2E312"
#define BLE_SENTRY_SERVICE_UUID_PASSIVE_INFRARED_ALARM              @"4209DC70-E433-4420-83D8-CDAACCD2E312"


#define BLE_THERMO_MODEL                                            @"Wimoto_Thermo"
#define BLE_THERMO_CHAR_UUID_IR_TEMPERATURE_CURRENT                 @"497B8E4F-B61E-4F82-8FE9-B12CF2497338"
#define BLE_THERMO_AD_SERVICE_UUID_IR_TEMPERATURE                   @"8E4E"
#define BLE_THERMO_SERVICE_UUID_IR_TEMPERATURE                      @"497B8E4E-B61E-4F82-8FE9-B12CF2497338"
#define BLE_THERMO_SERVICE_UUID_IR_TEMPERATURE_ALARM_LOW_VALUE      @"497B8E50-B61E-4F82-8FE9-B12CF2497338"
#define BLE_THERMO_SERVICE_UUID_IR_TEMPERATURE_ALARM_HIGH_VALUE     @"497B8E51-B61E-4F82-8FE9-B12CF2497338"
#define BLE_THERMO_SERVICE_UUID_IR_TEMPERATURE_ALARM_SET            @"497B8E52-B61E-4F82-8FE9-B12CF2497338"
#define BLE_THERMO_SERVICE_UUID_IR_TEMPERATURE_ALARM                @"497B8E53-B61E-4F82-8FE9-B12CF2497338"


#define BLE_THERMO_CHAR_UUID_PROBE_TEMPERATURE_CURRENT              @"497B8E55-B61E-4F82-8FE9-B12CF2497338"
#define BLE_THERMO_AD_SERVICE_UUID_PROBE_TEMPERATURE                @"8E54"
#define BLE_THERMO_SERVICE_UUID_PROBE_TEMPERATURE                   @"497B8E54-B61E-4F82-8FE9-B12CF2497338"
#define BLE_THERMO_SERVICE_UUID_PROBE_TEMPERATURE_ALARM_LOW_VALUE   @"497B8E56-B61E-4F82-8FE9-B12CF2497338"
#define BLE_THERMO_SERVICE_UUID_PROBE_TEMPERATURE_ALARM_HIGH_VALUE  @"497B8E57-B61E-4F82-8FE9-B12CF2497338"
#define BLE_THERMO_SERVICE_UUID_PROBE_TEMPERATURE_ALARM_SET         @"497B8E58-B61E-4F82-8FE9-B12CF2497338"
#define BLE_THERMO_SERVICE_UUID_PROBE_TEMPERATURE_ALARM             @"497B8E59-B61E-4F82-8FE9-B12CF2497338"


@interface CBPeripheral (CBPeripheral_Util)

- (NSString*)systemId;
- (NSString*)uniqueIdentifier;
- (PeripheralType)peripheralType;

- (BOOL)isIdentified;

@end
