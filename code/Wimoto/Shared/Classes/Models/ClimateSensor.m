//
//  ClimateSensor.m
//  Wimoto
//
//  Created by MC700 on 12/13/13.
//
//

#import "ClimateSensor.h"

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
            
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_TEMPERATURE_CURRENT]])
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
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_CHAR_UUID_TEMPERATURE_CURRENT]])
    {
        if( (characteristic.value)  || !error )
        {
            const uint8_t *reportData = [characteristic.value bytes];
            uint16_t temperature = 0;
            
            if ((reportData[0] & 0x01) == 0)
            {
                temperature = reportData[1];
            }
            else
            {
                temperature = CFSwapInt16LittleToHost(*(uint16_t *)(&reportData[1]));
            }
            
            NSLog(@"ClimateSensor didUpdateValueForCharacteristic");
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.temperature = temperature;
            });
        }
    }
}

@end
