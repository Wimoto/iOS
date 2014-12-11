//
//  WimotoCentralManager.h
//  Wimoto
//
//  Created by MacBook on 25/06/2014.
//
//

#import <CoreBluetooth/CoreBluetooth.h>

@protocol WimotoCentralManagerDelegate <NSObject>

- (void)didConnectPeripheral:(CBPeripheral*)peripheral;
- (void)didDisconnectPeripheral:(CBPeripheral*)peripheral;

@end

@interface WimotoCentralManager : CBCentralManager <CBCentralManagerDelegate, CBPeripheralDelegate>

- (id)initWithDelegate:(id<WimotoCentralManagerDelegate>)wcmDelegate;

- (void)startScan;

@end
