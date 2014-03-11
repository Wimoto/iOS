//
//  ThermoSensor.m
//  Wimoto
//
//  Created by Danny Kokarev on 25.12.13.
//
//

#import "ThermoSensor.h"
#import "DatabaseManager.h"

@implementation ThermoSensor

#pragma mark - CBPeriferalDelegate

- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error
{
    for (CBService *aService in aPeripheral.services)
    {
        NSLog(@"ThermoSensor didDiscoverServices %@", aService);
        
        if ([aService.UUID isEqual:[CBUUID UUIDWithString:BLE_THERMO_SERVICE_UUID_IR_TEMPERATURE]]) {
            
            [aPeripheral discoverCharacteristics:[NSArray arrayWithObject:
                                                  [CBUUID UUIDWithString:BLE_THERMO_CHAR_UUID_IR_TEMPERATURE_CURRENT]]
                                      forService:aService];
            
        } else if ([aService.UUID isEqual:[CBUUID UUIDWithString:BLE_THERMO_SERVICE_UUID_PROBE_TEMPERATURE]]) {
            
            [aPeripheral discoverCharacteristics:[NSArray arrayWithObject:
                                                  [CBUUID UUIDWithString:BLE_THERMO_CHAR_UUID_PROBE_TEMPERATURE_CURRENT]]
                                      forService:aService];
            
        }
    }
}

- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if ([service.UUID isEqual:[CBUUID UUIDWithString:BLE_THERMO_SERVICE_UUID_IR_TEMPERATURE]])
    {
        for (CBCharacteristic *aChar in service.characteristics)
        {
            NSLog(@"ThermoSensor didDiscoverCharacteristicsForService %@    %@", service, aChar);
            
            if (([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_THERMO_CHAR_UUID_IR_TEMPERATURE_CURRENT]])||
                ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_THERMO_CHAR_UUID_PROBE_TEMPERATURE_CURRENT]])) {
                NSLog(@"ThermoSensor didDiscoverTempChar");
                
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
        
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_THERMO_CHAR_UUID_IR_TEMPERATURE_CURRENT]]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.irTemp = value16_t;
            });
            [DatabaseManager saveNewSensorValueWithSensor:self valueType:kValueTypeIRTemperature value:value16_t];
        } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_THERMO_CHAR_UUID_PROBE_TEMPERATURE_CURRENT]]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.probeTemp = value16_t;
            });
            [DatabaseManager saveNewSensorValueWithSensor:self valueType:kValueTypeProbeTemperature value:value16_t];
        }
    }
}

@end
