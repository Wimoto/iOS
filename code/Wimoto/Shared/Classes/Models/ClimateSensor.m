//
//  ClimateSensor.m
//  Wimoto
//
//  Created by MC700 on 12/13/13.
//
//

#import "ClimateSensor.h"

#import "DatabaseManager.h"

@implementation ClimateSensor

#pragma mark - CBPeriferalDelegate

- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error
{
    for (CBService *aService in aPeripheral.services)
    {
        NSLog(@"ClimateSensor didDiscoverServices %@", aService);
        
        if ([aService.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_SERVICE_UUID_TEMPERATURE]]) {
            
            [aPeripheral discoverCharacteristics:[NSArray arrayWithObject:
                                                  [CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_TEMPERATURE_CURRENT]]
                                      forService:aService];
            
        } else if ([aService.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_SERVICE_UUID_LIGHT]]) {
            
            [aPeripheral discoverCharacteristics:[NSArray arrayWithObject:
                                                  [CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_LIGHT_CURRENT]]
                                      forService:aService];
            
        } else if ([aService.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_SERVICE_UUID_HUMIDITY]]) {
            
            [aPeripheral discoverCharacteristics:[NSArray arrayWithObject:
                                                  [CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_HUMIDITY_CURRENT]]
                                      forService:aService];
            
        }
    }
}

- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if ([service.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_SERVICE_UUID_TEMPERATURE]])
    {
        for (CBCharacteristic *aChar in service.characteristics)
        {
            NSLog(@"ClimateSensor didDiscoverCharacteristicsForService %@    %@", service, aChar);
            
            if (([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_TEMPERATURE_CURRENT]])||
                ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_HUMIDITY_CURRENT]])||
                ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_LIGHT_CURRENT]]))
            {
                NSLog(@"ClimateSensor didDiscoverTempChar");
                
                [aPeripheral readValueForCharacteristic:aChar];
                
                [aPeripheral setNotifyValue:YES forCharacteristic:aChar];
                
                uint8_t val = 1;
                NSData* valData = [NSData dataWithBytes:(void*)&val length:sizeof(val)];
                [aPeripheral writeValue:valData forCharacteristic:aChar type:CBCharacteristicWriteWithResponse];
            }
        }
    }
}

- (void)peripheral:(CBPeripheral *)aPeripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if ((characteristic.value)||(!error)) {
        const uint8_t *data = [characteristic.value bytes];
        uint16_t value16_t = CFSwapInt16LittleToHost(*(uint16_t *)(&data[1]));
        
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_TEMPERATURE_CURRENT]]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.temperature = value16_t;
            });
            [DatabaseManager saveNewSensorValueWithSensor:self valueType:kValueTypeTemperature value:value16_t];
        } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_HUMIDITY_CURRENT]]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.humidity = value16_t;
            });
            [DatabaseManager saveNewSensorValueWithSensor:self valueType:kValueTypeHumidity value:value16_t];
        } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_LIGHT_CURRENT]]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.light = value16_t;
            });
            [DatabaseManager saveNewSensorValueWithSensor:self valueType:kValueTypeLight value:value16_t];
        }
    }
}

@end
