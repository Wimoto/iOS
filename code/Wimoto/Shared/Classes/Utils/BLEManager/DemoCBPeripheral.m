//
//  DemoCBPeripheral.m
//  Wimoto
//
//  Created by Mobitexoft on 17.07.15.
//
//

#import "DemoCBPeripheral.h"

@implementation DemoCBPeripheral

- (PeripheralType)peripheralType {
    return _demoPeripheralType;
}

- (NSString *)uniqueIdentifier {
    NSString *identifier = @"";
    
    switch ([self peripheralType]) {
        case kPeripheralTypeClimateDemo:
            identifier = BLE_CLIMATE_DEMO_MODEL;
        break;
        case kPeripheralTypeThermoDemo:
            identifier = BLE_THERMO_DEMO_MODEL;
        break;
    }
}

@end
