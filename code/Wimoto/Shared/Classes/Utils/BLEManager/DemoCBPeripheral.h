//
//  DemoCBPeripheral.h
//  Wimoto
//
//  Created by Mobitexoft on 17.07.15.
//
//

#import <CoreBluetooth/CoreBluetooth.h>
#import "CBPeripheral+Util.h"

@interface DemoCBPeripheral : CBPeripheral

@property (nonatomic) PeripheralType *demoPeripheralType;

- (NSString *)uniqueIdentifier;

@end
