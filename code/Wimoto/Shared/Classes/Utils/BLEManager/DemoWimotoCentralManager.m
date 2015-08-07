//
//  DemoWimotoCentralManager.m
//  Wimoto
//
//  Created by Mobitexoft on 17.07.15.
//
//

#import "DemoWimotoCentralManager.h"

@implementation DemoWimotoCentralManager

- (void)startDemoScan {
    DemoCBPeripheral *climateDemoPeripheral = [[DemoCBPeripheral alloc] init];
    climateDemoPeripheral.demoPeripheralType = kPeripheralTypeClimateDemo;
    [(id<DemoWimotoCentralManagerDelegate>)self.wcmDelegate didConnectDemoPeripheral:climateDemoPeripheral];
    
    DemoCBPeripheral *thermoDemoPeripheral = [[DemoCBPeripheral alloc] init];
    climateDemoPeripheral.demoPeripheralType = kPeripheralTypeThermoDemo;
    [(id<DemoWimotoCentralManagerDelegate>)self.wcmDelegate didConnectDemoPeripheral:thermoDemoPeripheral];
}

@end
