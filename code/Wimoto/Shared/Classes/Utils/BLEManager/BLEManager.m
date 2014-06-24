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
        
//        NSArray *serviceUUIDStrings = [NSArray arrayWithObjects:BLE_CLIMATE_SERVICE_UUID_TEMPERATURE, BLE_WATER_SERVICE_UUID_PRESENCE, BLE_GROW_SERVICE_UUID_LIGHT, BLE_THERMO_SERVICE_UUID_IR_TEMPERATURE, nil];
//        NSMutableArray *serviceUUIDs = [NSMutableArray array];
//        for (NSString *uuid in serviceUUIDStrings) {
//            [serviceUUIDs addObject:[CBUUID UUIDWithString:uuid]];
//        }
        [_centralBluetoothManager scanForPeripheralsWithServices:nil options:scanOptions];
    }
    return self;
}

+ (NSArray*)identifiedPeripherals {
    NSArray *managedPeripherals = [[BLEManager sharedManager] managedPeripherals];
    
    NSMutableArray *filteredArray = [NSMutableArray arrayWithCapacity:[managedPeripherals count]];
    for (CBPeripheral *peripheral in managedPeripherals) {
        if ([peripheral isIdentified]) {
            [filteredArray addObject:peripheral];
        }
    }
    return filteredArray;
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
    if ((![_managedPeripherals containsObject:peripheral])&&(peripheral.state != CBPeripheralStateConnected)) {
        [_managedPeripherals addObject:peripheral];
        [_centralBluetoothManager connectPeripheral:peripheral options:nil];
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    [[NSNotificationCenter defaultCenter] postNotificationName:NC_BLE_MANAGER_PERIPHERAL_DISCONNECTED object:peripheral];
    if ([_managedPeripherals containsObject:peripheral]) {
        peripheral.delegate = nil;
        [_managedPeripherals removeObject:peripheral];
    }
}

#pragma mark - CBPeriferalDelegate

- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error {
    for (CBService *aService in aPeripheral.services) {
        if ([aService.UUID isEqual:[CBUUID UUIDWithString:BLE_GENERIC_SERVICE_UUID_DEVICE]]) {
            [aPeripheral discoverCharacteristics:[NSArray arrayWithObjects:[CBUUID UUIDWithString:BLE_GENERIC_CHAR_UUID_SYSTEM_ID], [CBUUID UUIDWithString:BLE_GENERIC_CHAR_UUID_MODEL_NUMBER], nil] forService:aService];
            break;
        }
    }
}

- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if ([service.UUID isEqual:[CBUUID UUIDWithString:BLE_GENERIC_SERVICE_UUID_DEVICE]]) {
        for (CBCharacteristic *aChar in service.characteristics) {
            if (([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_GENERIC_CHAR_UUID_SYSTEM_ID]]) ||
                ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_GENERIC_CHAR_UUID_MODEL_NUMBER]])) {
                [aPeripheral readValueForCharacteristic:aChar];
            }
        }
    }
}

- (void)peripheral:(CBPeripheral *)aPeripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"didUpdateValueForCharacteristic start");
    if ([aPeripheral isIdentified]) {
        NSLog(@"didUpdateValueForCharacteristic peripheralType %d  systemId %@", [aPeripheral peripheralType], [aPeripheral systemId]);
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:NC_BLE_MANAGER_PERIPHERAL_CONNECTED object:aPeripheral];
        });
    }
}

@end
