//
//  DemoWimotoCentralManager.h
//  Wimoto
//
//  Created by Mobitexoft on 17.07.15.
//
//

#import "WimotoCentralManager.h"
#import "DemoCBPeripheral.h"
#import "CBPeripheral+Util.h"

@protocol DemoWimotoCentralManagerDelegate <WimotoCentralManagerDelegate>

- (void)didConnectDemoPeripheral:(DemoCBPeripheral*)peripheral;

@end

@interface DemoWimotoCentralManager : WimotoCentralManager

- (void)startDemoScan;

@end
