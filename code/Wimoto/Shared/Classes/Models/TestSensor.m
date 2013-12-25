//
//  TestSensor.m
//  Wimoto
//
//  Created by MC700 on 12/13/13.
//
//

#import "TestSensor.h"

#import "DatabaseManager.h"
#import "SensorValue.h"

@implementation TestSensor

#pragma mark - CBPeriferalDelegate

- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error
{
    for (CBService *aService in aPeripheral.services)
    {
        if ([aService.UUID isEqual:[CBUUID UUIDWithString:@"180D"]]) {
            [aPeripheral discoverCharacteristics:[NSArray arrayWithObject:[CBUUID UUIDWithString:@"2A37"]] forService:aService];
        }
    }
}

- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if ([service.UUID isEqual:[CBUUID UUIDWithString:@"180D"]])
    {
        for (CBCharacteristic *aChar in service.characteristics)
        {
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"2A37"]])
            {
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
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A37"]])
    {
        if( (characteristic.value)  || !error )
        {
            const uint8_t *reportData = [characteristic.value bytes];
            uint16_t bpm = 0;
            
            if ((reportData[0] & 0x01) == 0)
            {
                bpm = reportData[1];
            }
            else
            {
                bpm = CFSwapInt16LittleToHost(*(uint16_t *)(&reportData[1]));
            }
            
            float temperatureValue = bpm;
            
            SensorValue *sensorValue = [DatabaseManager sensorValueInstance];
            sensorValue.sensor = self;
            sensorValue.valueType = kValueTypeTemperature;
            sensorValue.value = temperatureValue;
            [sensorValue save:nil];
            
            float humidityValue = bpm+5;
            
            sensorValue = [DatabaseManager sensorValueInstance];
            sensorValue.sensor = self;
            sensorValue.valueType = kValueTypeHumidity;
            sensorValue.value = humidityValue;
            [sensorValue save:nil];
            
            float lightValue = bpm-3;
            
            sensorValue = [DatabaseManager sensorValueInstance];
            sensorValue.sensor = self;
            sensorValue.valueType = kValueTypeLight;
            sensorValue.value = lightValue;
            [sensorValue save:nil];
            
            float presence = bpm;
            
            sensorValue = [DatabaseManager sensorValueInstance];
            sensorValue.sensor = self;
            sensorValue.valueType = kValueTypePresence;
            sensorValue.value = ((int)presence%2==0)?1:0;
            [sensorValue save:nil];
            
            float level = bpm-3;
            
            sensorValue = [DatabaseManager sensorValueInstance];
            sensorValue.sensor = self;
            sensorValue.valueType = kValueTypeLevel;
            sensorValue.value = level;
            [sensorValue save:nil];
            
            sensorValue = [DatabaseManager sensorValueInstance];
            sensorValue.sensor = self;
            sensorValue.valueType = kValueTypeGrowLight;
            sensorValue.value = lightValue;
            [sensorValue save:nil];

            sensorValue = [DatabaseManager sensorValueInstance];
            sensorValue.sensor = self;
            sensorValue.valueType = kValueTypeSoilHumidity;
            sensorValue.value = humidityValue;
            [sensorValue save:nil];

            sensorValue = [DatabaseManager sensorValueInstance];
            sensorValue.sensor = self;
            sensorValue.valueType = kValueTypeSoilTemperature;
            sensorValue.value = temperatureValue;
            [sensorValue save:nil];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.temperature = temperatureValue;
                self.humidity = humidityValue;
                self.light = lightValue;
                
                self.presense = presence;
                self.level = level;
                
                self.soilMoisture = humidityValue;
                self.soilTemperature = temperatureValue;                
            });
        }
    }
}

@end
