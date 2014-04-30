//
//  BLEManager.h
//  Wimoto
//
//  Created by MC700 on 5/2/13.
//
//

#import <CoreBluetooth/CoreBluetooth.h>

@interface BLEManager : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, strong) NSMutableArray *managedPeripherals;

+ (void)initialize;
+ (BLEManager*)sharedManager;
+ (NSArray*)identifiedPeripherals;

@end