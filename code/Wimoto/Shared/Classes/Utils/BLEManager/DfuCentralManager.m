//
//  WimotoCentralManager.m
//  Wimoto
//
//  Created by MacBook on 25/06/2014.
//
//

#import "DfuCentralManager.h"

#import "CBPeripheral+Util.h"

@interface DfuCentralManager ()

@property (nonatomic, weak) id<DfuCentralManagerDelegate> dcmDelegate;

@property (nonatomic, strong) NSMutableSet *pendingPeripherals;

@end

@implementation DfuCentralManager

- (id)initWithDelegate:(id<DfuCentralManagerDelegate>)dcmDelegate {
    dispatch_queue_t centralQueue = dispatch_queue_create("com.wimoto.ios.dfu", DISPATCH_QUEUE_SERIAL);
    self = [super initWithDelegate:nil queue:centralQueue];
    if (self) {
        self.delegate       = self;
        
        _dcmDelegate            = dcmDelegate;
        _pendingPeripherals     = [NSMutableSet set];
        
    }
    return self;
}

- (void)startScan {
    NSLog(@"DfuCentralManager startScan");
    
    NSDictionary *scanOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
    
    [self scanForPeripheralsWithServices:[NSArray arrayWithObject:[CBUUID UUIDWithString:BLE_GENERIC_SERVICE_UUID_DFU]] options:scanOptions];
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    if (([central state]==CBCentralManagerStatePoweredOn)||([central state]==CBCentralManagerStatePoweredOff)) {
        return;
    }
    NSString * state = nil;
    switch ([central state]) {
        case CBCentralManagerStateUnsupported:
            state = @"The platform/hardware doesn't support Bluetooth Low Energy.";
            break;
        case CBCentralManagerStateUnauthorized:
            state = @"The app is not authorized to use Bluetooth Low Energy.";
            break;
        case CBCentralManagerStateUnknown:
            state = @"CBCentralManagerStateUnknown";
            break;
        case CBCentralManagerStateResetting:
            state = @"CBCentralManagerStateResetting";
            break;
        default:
            break;
    }
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:state delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    
    NSLog(@"DfuCentralManager didDiscoverDfuPeripheral %@", peripheral);
    [_pendingPeripherals addObject:peripheral];
    
    if (peripheral.state == CBPeripheralStateDisconnected) {
        [self connectPeripheral:peripheral options:nil];
    }
    
    NSLog(@"DfuCentralManager dfuPeripherals %d", [_pendingPeripherals count]);
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"didConnectDfuPeripheral %@", peripheral);
    
    [_dcmDelegate didConnectDfuPeripheral:peripheral];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"didDisconnectDfuPeripheral %@", peripheral);
    
    //[_dcmDelegate didDisconnectPeripheral:peripheral];
    [_pendingPeripherals removeObject:peripheral];
}

@end
