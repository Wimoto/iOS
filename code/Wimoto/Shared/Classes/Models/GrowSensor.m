//
//  GrowSensor.m
//  Wimoto
//
//  Created by Danny Kokarev on 25.12.13.
//
//

#import "GrowSensor.h"
#import "DatabaseManager.h"

@implementation GrowSensor

#pragma mark - CBPeriferalDelegate

- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error
{
    for (CBService *aService in aPeripheral.services)
    {
        NSLog(@"GrowSensor didDiscoverServices %@", aService);
        
        if ([aService.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_LIGHT]]) {
            
            [aPeripheral discoverCharacteristics:[NSArray arrayWithObject:
                                                  [CBUUID UUIDWithString:BLE_GROW_CHAR_UUID_LIGHT_CURRENT]]
                                      forService:aService];
            
        } else if ([aService.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_SOIL_MOISTURE]]) {
            
            [aPeripheral discoverCharacteristics:[NSArray arrayWithObject:
                                                  [CBUUID UUIDWithString:BLE_GROW_CHAR_UUID_SOIL_MOISTURE_CURRENT]]
                                      forService:aService];
            
        } else if ([aService.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_SOIL_TEMPERATURE]]) {
            
            [aPeripheral discoverCharacteristics:[NSArray arrayWithObject:
                                                  [CBUUID UUIDWithString:BLE_GROW_CHAR_UUID_SOIL_TEMPERATURE_CURRENT]]
                                      forService:aService];
            
        }
    }
}

- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if ([service.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_SERVICE_UUID_SOIL_TEMPERATURE]])
    {
        for (CBCharacteristic *aChar in service.characteristics)
        {
            NSLog(@"GrowSensor didDiscoverCharacteristicsForService %@    %@", service, aChar);
            
            if (([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_CHAR_UUID_SOIL_TEMPERATURE_CURRENT]])||
                ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_CHAR_UUID_SOIL_MOISTURE_CURRENT]])||
                ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_CHAR_UUID_LIGHT_CURRENT]]))
            {
                NSLog(@"GROWSensor didDiscoverTempChar");
                
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
        
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_CHAR_UUID_SOIL_TEMPERATURE_CURRENT]]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.soilTemperature = value16_t;
            });
            
            SensorValue *sensorValue = [DatabaseManager sensorValueInstance];
            sensorValue.sensor = self;
            sensorValue.valueType = kValueTypeSoilTemp;
            sensorValue.value = _soilTemperature;
            [sensorValue save:nil];
        } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_CHAR_UUID_LIGHT_CURRENT]]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.light = value16_t;
            });
            
            SensorValue *sensorValue = [DatabaseManager sensorValueInstance];
            sensorValue.sensor = self;
            sensorValue.valueType = kValueTypeLight;
            sensorValue.value = _light;
            [sensorValue save:nil];
        } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_GROW_CHAR_UUID_SOIL_MOISTURE_CURRENT]]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.soilMoisture = value16_t;
            });
            
            SensorValue *sensorValue = [DatabaseManager sensorValueInstance];
            sensorValue.sensor = self;
            sensorValue.valueType = kValueTypeSoilMoisure;
            sensorValue.value = _soilMoisture;
            [sensorValue save:nil];
        }
    }
}

@end
