//
//  WaterSensor.m
//  Wimoto
//
//  Created by MC700 on 12/23/13.
//
//

#import "WaterSensor.h"

#import "DatabaseManager.h"

@implementation WaterSensor

#pragma mark - CBPeriferalDelegate

- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error
{
    for (CBService *aService in aPeripheral.services)
    {
        NSLog(@"WaterSensor didDiscoverServices %@", aService);
        
        if ([aService.UUID isEqual:[CBUUID UUIDWithString:BLE_WATER_SERVICE_UUID_LEVEL]]) {
            
            [aPeripheral discoverCharacteristics:[NSArray arrayWithObject:
                                                  [CBUUID UUIDWithString:BLE_WATER_CHAR_UUID_LEVEL_CURRENT]]
                                      forService:aService];
            
        } else if ([aService.UUID isEqual:[CBUUID UUIDWithString:BLE_WATER_SERVICE_UUID_PRESENCE]]) {
            
            [aPeripheral discoverCharacteristics:[NSArray arrayWithObject:
                                                  [CBUUID UUIDWithString:BLE_WATER_CHAR_UUID_PRESENCE_CURRENT]]
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
            NSLog(@"WaterSensor didDiscoverCharacteristicsForService %@    %@", service, aChar);
            
            if (([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_WATER_CHAR_UUID_LEVEL_CURRENT]])||
                ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_WATER_CHAR_UUID_PRESENCE_CURRENT]]))
            {
                NSLog(@"WaterSensor didDiscoverTempChar");
                
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
        
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_WATER_CHAR_UUID_LEVEL_CURRENT]]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.level = value16_t;
            });
            
            SensorValue *sensorValue = [DatabaseManager sensorValueInstance];
            sensorValue.sensor = self;
            sensorValue.valueType = kValueTypeLevel;
            sensorValue.value = _level;
            [sensorValue save:nil];
        } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_WATER_CHAR_UUID_PRESENCE_CURRENT]]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.presense = value16_t;
            });
            
            SensorValue *sensorValue = [DatabaseManager sensorValueInstance];
            sensorValue.sensor = self;
            sensorValue.valueType = kValueTypePresence;
            sensorValue.value = _presense;
            [sensorValue save:nil];
        }
    }
}

@end
