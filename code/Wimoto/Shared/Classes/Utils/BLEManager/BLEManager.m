//
//  BLEManager.m
//  Wimoto
//
//  Created by MC700 on 5/2/13.
//
//

#import "BLEManager.h"
#import "AppConstants.h"

#import "CBPeripheral+Util.h"

@interface BLEManager ()

@property (nonatomic, strong) CBCentralManager *centralBluetoothManager;

@end

@implementation BLEManager

static BLEManager *bleManager = nil;

+ (void)initialize {
    [BLEManager sharedManager];
}

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
        _managedPeripherals = [NSMutableArray array];
        
        NSDictionary *scanOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
        
        [_centralBluetoothManager scanForPeripheralsWithServices:nil options:scanOptions];
    }
    return self;
}

+ (NSArray*)identifiedPeripherals {
    NSArray *managedPeripherals = [[BLEManager sharedManager] managedPeripherals];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"systemId != %@", @""];
    return [managedPeripherals filteredArrayUsingPredicate:predicate];
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
    
    if ((![_managedPeripherals containsObject:peripheral])&&(![peripheral isConnected])) {
        [_managedPeripherals addObject:peripheral];
        [_centralBluetoothManager connectPeripheral:peripheral options:nil];
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    [peripheral identifyWithDelegate:self];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    [[NSNotificationCenter defaultCenter] postNotificationName:NC_BLE_MANAGER_PERIPHERAL_DISCONNECTED object:peripheral];
    
    [_managedPeripherals removeObject:peripheral];
}

#pragma mark - CBPeriferalDelegate

- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error
{
    for (CBService *aService in aPeripheral.services) {
        if ([aService.UUID isEqual:[CBUUID UUIDWithString:@"180A"]]) {
            [aPeripheral discoverCharacteristics:[NSArray arrayWithObject:[CBUUID UUIDWithString:@"2A23"]] forService:aService];
        }
    }
}

- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if ([service.UUID isEqual:[CBUUID UUIDWithString:@"180A"]]) {
        for (CBCharacteristic *aChar in service.characteristics) {
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"2A23"]]) {
                [aPeripheral readValueForCharacteristic:aChar];
            }
        }
    }
}

- (void)peripheral:(CBPeripheral *)aPeripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A23"]]) {
        if (characteristic.value) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:NC_BLE_MANAGER_PERIPHERAL_CONNECTED object:aPeripheral];
            });
        }
    }
}

@end
