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
    NSLog(@"DfuCentralManager didConnectDfuPeripheral %@", peripheral);
    
    //peripheral.delegate = self;
    
    //NSArray *services = [NSArray arrayWithObject:[CBUUID UUIDWithString:BLE_GENERIC_SERVICE_UUID_DFU]];
    //[peripheral discoverServices:services];
    
    [_dcmDelegate didConnectDfuPeripheral:peripheral];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"DfuCentralManager didDisconnectDfuPeripheral %@", peripheral);
    
    //[_dcmDelegate didDisconnectPeripheral:peripheral];
    [_pendingPeripherals removeObject:peripheral];
}

//#pragma mark - CBPeripheralDelegate
//
//- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error {
//    for (CBService *aService in aPeripheral.services) {
//        if ([aService.UUID isEqual:[CBUUID UUIDWithString:BLE_GENERIC_SERVICE_UUID_DFU]]) {
//            NSLog(@"DfuCentralManager didDiscoverServices BLE_GENERIC_SERVICE_UUID_DFU");
//
//            [aPeripheral discoverCharacteristics:[NSArray arrayWithObjects:[CBUUID UUIDWithString:BLE_GENERIC_CHAR_UUID_DFU_CONTROL_POINT], [CBUUID UUIDWithString:BLE_GENERIC_CHAR_UUID_DFU_PACKET], nil] forService:aService];
//            return;
//        }
//    }
//}
//
//- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
//    if ([service.UUID isEqual:[CBUUID UUIDWithString:BLE_GENERIC_SERVICE_UUID_DFU]]) {
//        for (CBCharacteristic *aChar in service.characteristics) {
//            if (([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_GENERIC_CHAR_UUID_DFU_CONTROL_POINT]]) ||
//                ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_GENERIC_CHAR_UUID_DFU_PACKET]])) {
//                
//                NSLog(@"DfuCentralManager didDiscoverCharacteristicsForService BLE_GENERIC_SERVICE_UUID_DFU");
//                //[aPeripheral readValueForCharacteristic:aChar];
//            }
//        }
//    }
//}

@end
