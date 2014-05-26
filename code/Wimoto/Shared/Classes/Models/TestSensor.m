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
    for (CBService *aService in aPeripheral.services) {
        NSLog(@"TEST SENSOR SERVICE UUID ------ %@", aService.UUID);
        if ([aService.UUID isEqual:[CBUUID UUIDWithString:@"180D"]]) {
            [aPeripheral discoverCharacteristics:[NSArray arrayWithObject:[CBUUID UUIDWithString:@"2A37"]] forService:aService];
        }
    }
}

- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if ([service.UUID isEqual:[CBUUID UUIDWithString:@"180D"]]) {
        for (CBCharacteristic *aChar in service.characteristics) {
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"2A37"]]) {
                [aPeripheral readValueForCharacteristic:aChar];
                
                [aPeripheral setNotifyValue:YES forCharacteristic:aChar];
                
                //uint8_t val = 1;
                //NSData* valData = [NSData dataWithBytes:(void*)&val length:sizeof(val)];
                //[aPeripheral writeValue:valData forCharacteristic:aChar type:CBCharacteristicWriteWithResponse];
            }
        }
    }
}

- (void)peripheral:(CBPeripheral *)aPeripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A37"]]) {
        NSLog(@"WORK!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!eeee!!!!!!!!!!!!!!!!!!!!!! %@", error);
        if( (characteristic.value)  || !error ) {
            NSLog(@"WORK!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
            
            const uint8_t *reportData = [characteristic.value bytes];
            uint16_t bpm = 0;
            
            if ((reportData[0] & 0x01) == 0) {
                bpm = reportData[1];
            }
            else {
                bpm = CFSwapInt16LittleToHost(*(uint16_t *)(&reportData[1]));
            }
            
            float temperatureValue = bpm;
            
            float humidityValue = bpm+5;
            float lightValue = bpm-3;
            float presence = bpm;
            float level = bpm-3;
            
            [DatabaseManager saveNewSensorValueWithSensor:self valueType:kValueTypeTemperature value:temperatureValue];
            [DatabaseManager saveNewSensorValueWithSensor:self valueType:kValueTypeHumidity value:humidityValue];
            [DatabaseManager saveNewSensorValueWithSensor:self valueType:kValueTypeLight value:lightValue];
            [DatabaseManager saveNewSensorValueWithSensor:self valueType:kValueTypePresence value:((int)presence%2==0)?1:0];
            [DatabaseManager saveNewSensorValueWithSensor:self valueType:kValueTypeLevel value:level];
            [DatabaseManager saveNewSensorValueWithSensor:self valueType:kValueTypeGrowLight value:lightValue];
            [DatabaseManager saveNewSensorValueWithSensor:self valueType:kValueTypeSoilHumidity value:humidityValue];
            [DatabaseManager saveNewSensorValueWithSensor:self valueType:kValueTypeSoilTemperature value:temperatureValue];
            [DatabaseManager saveNewSensorValueWithSensor:self valueType:kValueTypeAccelerometer value:humidityValue];
            [DatabaseManager saveNewSensorValueWithSensor:self valueType:kValueTypePassiveInfrared value:temperatureValue];
            [DatabaseManager saveNewSensorValueWithSensor:self valueType:kValueTypeIRTemperature value:humidityValue];
            [DatabaseManager saveNewSensorValueWithSensor:self valueType:kValueTypeProbeTemperature value:temperatureValue];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.temperature = temperatureValue;
                self.humidity = humidityValue;
                self.light = lightValue;
                self.presense = presence;
                self.level = level;
                self.soilMoisture = humidityValue;
                self.soilTemperature = temperatureValue;
                self.accelerometer = humidityValue;
                self.pasInfrared = temperatureValue;
                self.irTemp = humidityValue;
                self.probeTemp = temperatureValue;
            });
        }
    }
}

@end
