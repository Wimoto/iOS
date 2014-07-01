//
//  WimotoCentralManager.m
//  Wimoto
//
//  Created by MacBook on 25/06/2014.
//
//

#import "WimotoCentralManager.h"

#import "CBPeripheral+Util.h"

@interface WimotoCentralManager ()

@property (nonatomic, weak) id<WimotoCentralManagerDelegate> wcmDelegate;

@property (nonatomic, strong) NSMutableSet *pendingPeripherals;

@end

@implementation WimotoCentralManager

- (id)initWithDelegate:(id<WimotoCentralManagerDelegate>)wcmDelegate {
    dispatch_queue_t centralQueue = dispatch_queue_create("com.wimoto.ios", DISPATCH_QUEUE_SERIAL);
    self = [super initWithDelegate:nil queue:centralQueue];
    if (self) {
        self.delegate       = self;
        
        _wcmDelegate            = wcmDelegate;
        _pendingPeripherals     = [NSMutableSet set];
        
    }
    return self;
}

- (void)startScan {
    NSDictionary *scanOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
    
    NSArray *targetServices = [NSArray arrayWithObjects:
                               [CBUUID UUIDWithString:BLE_CLIMATE_AD_SERVICE_UUID_TEMPERATURE],
                               [CBUUID UUIDWithString:BLE_CLIMATE_AD_SERVICE_UUID_LIGHT],
                               [CBUUID UUIDWithString:BLE_CLIMATE_AD_SERVICE_UUID_HUMIDITY],
                               [CBUUID UUIDWithString:BLE_WATER_AD_SERVICE_UUID_PRESENCE],
                               [CBUUID UUIDWithString:BLE_WATER_AD_SERVICE_UUID_LEVEL],
                               [CBUUID UUIDWithString:BLE_GROW_AD_SERVICE_UUID_LIGHT],
                               [CBUUID UUIDWithString:BLE_GROW_AD_SERVICE_UUID_SOIL_MOISTURE],
                               [CBUUID UUIDWithString:BLE_GROW_AD_SERVICE_UUID_SOIL_TEMPERATURE],
                               [CBUUID UUIDWithString:BLE_SENTRY_AD_SERVICE_UUID_ACCELEROMETER],
                               [CBUUID UUIDWithString:BLE_SENTRY_AD_SERVICE_UUID_PASSIVE_INFRARED],
                               [CBUUID UUIDWithString:BLE_THERMO_AD_SERVICE_UUID_IR_TEMPERATURE],
                               [CBUUID UUIDWithString:BLE_THERMO_AD_SERVICE_UUID_PROBE_TEMPERATURE],
                               [CBUUID UUIDWithString:@"180D"], nil];
    
    [self scanForPeripheralsWithServices:targetServices options:scanOptions];
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
    
    NSLog(@"WimotoCentralManager didDiscoverPeripheral %@", peripheral);
    [_pendingPeripherals addObject:peripheral];
    
    if (peripheral.state == CBPeripheralStateDisconnected) {
        [self connectPeripheral:peripheral options:nil];
    }
    
    NSLog(@"WimotoCentralManager peripherals %d", [_pendingPeripherals count]);
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"didConnectPeripheral %@", peripheral);
    
    peripheral.delegate = self;
    
    NSArray *services = [NSArray arrayWithObject:[CBUUID UUIDWithString:BLE_GENERIC_SERVICE_UUID_DEVICE]];
    [peripheral discoverServices:services];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"didDisconnectPeripheral %@", peripheral);
    
    [_wcmDelegate didDisconnectPeripheral:peripheral];
    [_pendingPeripherals removeObject:peripheral];
}

#pragma mark - CBPeripheralDelegate

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
        
        [_wcmDelegate didConnectPeripheral:aPeripheral];
        [_pendingPeripherals removeObject:aPeripheral];
    }
}

@end
