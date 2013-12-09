//
//  BLEManager.h
//  Wimoto
//
//  Created by MC700 on 5/2/13.
//
//

#import <CoreBluetooth/CoreBluetooth.h>

@protocol BLEManagerDelegate;

@interface BLEManager : NSObject <CBCentralManagerDelegate>

@property (nonatomic, weak) id<BLEManagerDelegate> delegate;

+ (BLEManager*)sharedManager;

- (void)startScanForHRBelts;
- (void)stopScanForHRBelts;

- (void)connectPeripheral:(CBPeripheral*)peripheral;
- (void)disconnectPeripheral:(CBPeripheral*)peripheral;

@end

@protocol BLEManagerDelegate <NSObject>
@optional
- (void)didConnectPeripheral:(CBPeripheral*)peripheral;
- (void)didDisconnectPeripheral:(CBPeripheral*)peripheral;
@end