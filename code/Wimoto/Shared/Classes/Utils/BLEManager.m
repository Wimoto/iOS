//
//  BLEManager.m
//  Wimoto
//
//  Created by MC700 on 5/2/13.
//
//

#import "BLEManager.h"

@interface BLEManager ()

@property (nonatomic, strong) CBCentralManager *centralBluetoothManager;
@property (nonatomic, strong) NSMutableArray *pendingConnections;

@end

@implementation BLEManager

@synthesize delegate = _delegate;
@synthesize centralBluetoothManager = _centralBluetoothManager;
@synthesize pendingConnections = _pendingConnections;

static BLEManager *bleManager = nil;

+ (BLEManager*)sharedManager {
	if (!bleManager) {
		bleManager = [[BLEManager alloc] init];
	}
	return bleManager;
}

- (id)init {
    self = [super init];
    if (self) {
        dispatch_queue_t centralQueue = dispatch_queue_create("com.wimoto.ios", DISPATCH_QUEUE_SERIAL);
        
        _centralBluetoothManager = [[CBCentralManager alloc] initWithDelegate:self queue:centralQueue];
        _pendingConnections = [NSMutableArray array];
    }
    return self;
}

- (void)dealloc {
    [self stopScanForHRBelts];
}

- (void)startScanForHRBelts {
    NSDictionary *scanOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
    
    [_centralBluetoothManager scanForPeripheralsWithServices:nil options:scanOptions];
}

- (void)stopScanForHRBelts {
    [_centralBluetoothManager stopScan];
}

- (void)connectPeripheral:(CBPeripheral*)peripheral {
    if (peripheral) {
        [_centralBluetoothManager connectPeripheral:peripheral options:nil];
    }
}

- (void)disconnectPeripheral:(CBPeripheral*)peripheral {
    if (peripheral) {
        [_centralBluetoothManager cancelPeripheralConnection:peripheral];
    }
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    if (([central state]==CBCentralManagerStatePoweredOn)||([central state]==CBCentralManagerStatePoweredOff)) {
        return;
    }

    NSString * state = nil;
    
    switch ([central state])
    {
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
    
    if ((![_pendingConnections containsObject:peripheral])&&(![peripheral isConnected])) {
        [_pendingConnections addObject:peripheral];
        [_centralBluetoothManager connectPeripheral:peripheral options:nil];
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    if ([_delegate respondsToSelector:@selector(didConnectPeripheral:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_delegate didConnectPeripheral:peripheral];
        });
    }
    
    [_pendingConnections removeObject:peripheral];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    if ([_delegate respondsToSelector:@selector(didDisconnectPeripheral:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_delegate didDisconnectPeripheral:peripheral];
        });
    }
    
    [_pendingConnections removeObject:peripheral];
    
}

@end
