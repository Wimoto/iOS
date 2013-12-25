//
//  SentrySensor.m
//  Wimoto
//
//  Created by Danny Kokarev on 25.12.13.
//
//

#import "SentrySensor.h"
#import "DatabaseManager.h"

@implementation SentrySensor

#pragma mark - CBPeriferalDelegate

- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error
{
    for (CBService *aService in aPeripheral.services)
    {
        NSLog(@"GrowSensor didDiscoverServices %@", aService);
        
        if ([aService.UUID isEqual:[CBUUID UUIDWithString:BLE_SENTRY_SERVICE_UUID_ACCELEROMETER]]) {
            
            [aPeripheral discoverCharacteristics:[NSArray arrayWithObject:
                                                  [CBUUID UUIDWithString:BLE_SENTRY_CHAR_UUID_ACCELEROMETER_CURRENT]]
                                      forService:aService];
            
        } else if ([aService.UUID isEqual:[CBUUID UUIDWithString:BLE_SENTRY_SERVICE_UUID_PASSIVE_INFRARED]]) {
            
            [aPeripheral discoverCharacteristics:[NSArray arrayWithObject:
                                                  [CBUUID UUIDWithString:BLE_SENTRY_CHAR_UUID_PASSIVE_INFRARED_CURRENT]]
                                      forService:aService];
            
        }
    }
}

- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if ([service.UUID isEqual:[CBUUID UUIDWithString:BLE_SENTRY_SERVICE_UUID_ACCELEROMETER]])
    {
        for (CBCharacteristic *aChar in service.characteristics)
        {
            NSLog(@"SentrySensor didDiscoverCharacteristicsForService %@    %@", service, aChar);
            
            if (([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_SENTRY_CHAR_UUID_ACCELEROMETER_CURRENT]])||
                ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_SENTRY_CHAR_UUID_PASSIVE_INFRARED_CURRENT]])) {
                NSLog(@"SentrySensor didDiscoverTempChar");
                
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
        
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_SENTRY_CHAR_UUID_ACCELEROMETER_CURRENT]]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.accelerometer = value16_t;
            });
            
            SensorValue *sensorValue = [DatabaseManager sensorValueInstance];
            sensorValue.sensor = self;
            sensorValue.valueType = kValueTypeAccelerometer;
            sensorValue.value = _accelerometer;
            [sensorValue save:nil];
        } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_SENTRY_CHAR_UUID_PASSIVE_INFRARED_CURRENT]]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.pasInfrared = value16_t;
            });
            
            SensorValue *sensorValue = [DatabaseManager sensorValueInstance];
            sensorValue.sensor = self;
            sensorValue.valueType = kValueTypePassiveInfrared;
            sensorValue.value = _pasInfrared;
            [sensorValue save:nil];
        }
    }
}

@end
