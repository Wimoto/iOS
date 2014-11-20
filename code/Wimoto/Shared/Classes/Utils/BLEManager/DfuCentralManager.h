//
//  WimotoCentralManager.h
//  Wimoto
//
//  Created by MacBook on 25/06/2014.
//
//

#import <CoreBluetooth/CoreBluetooth.h>

@protocol DfuCentralManagerDelegate <NSObject>

- (void)didConnectDfuPeripheral:(CBPeripheral*)peripheral;

@end

@interface DfuCentralManager : CBCentralManager <CBCentralManagerDelegate, CBPeripheralDelegate>

- (id)initWithDelegate:(id<DfuCentralManagerDelegate>)dcmDelegate;

- (void)startScan;

@end
