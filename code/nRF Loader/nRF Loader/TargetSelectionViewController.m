//
//  ViewController.m
//  nRF Loader
//
//  Created by Ole Morten on 10/8/13.
//  Copyright (c) 2013 Nordic Semiconductor. All rights reserved.
//

#import "TargetSelectionViewController.h"
#import "ProgressViewController.h"

#import "AppInfoCell.h"
#import "DeviceInformationCell.h"

@interface TargetSelectionViewController ()
@property CBCentralManager *cm;
@property (weak, nonatomic) IBOutlet UILabel *appNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *appSizeLabel;
@property NSMutableArray *discoveredTargets;
@property NSMutableDictionary *discoveredTargetsRSSI;

@property BOOL isScanning;
@end

@implementation TargetSelectionViewController
@synthesize cm = _cm;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.discoveredTargets = [@[] mutableCopy];
    self.discoveredTargetsRSSI = [@{} mutableCopy];
    
    self.targetTableView.delegate = self;
    self.targetTableView.dataSource = self;
    
    self.cm = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
}

- (void) viewWillAppear:(BOOL)animated
{
    [self.targetTableView deselectRowAtIndexPath:self.targetTableView.indexPathForSelectedRow animated:NO];
    
    self.appNameLabel.text = self.dfuController.appName;
    self.appSizeLabel.text = [NSString stringWithFormat:@"%d bytes", self.dfuController.appSize];
    
    [self.discoveredTargets removeAllObjects];
    [self.targetTableView reloadData];
    
    if (self.cm.state == CBCentralManagerStatePoweredOn && !self.isScanning)
    {
        [self startScan];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) stopScan
{
    [self.discoveredTargets removeAllObjects];
    [self.targetTableView reloadData];
    
    [self.cm stopScan];
    self.isScanning = NO;
    [self.scanActivityIndicator stopAnimating];
    self.navigationItem.rightBarButtonItem.title = @"Scan";
    NSLog(@"Stopped scan.");
    
}

- (void) startScan
{
    [self.cm scanForPeripheralsWithServices:@[[DFUController serviceUUID]] options:@{CBCentralManagerScanOptionAllowDuplicatesKey: @YES}];
    self.isScanning = YES;
    [self.scanActivityIndicator startAnimating];
    self.navigationItem.rightBarButtonItem.title = @"Stop scan";
    NSLog(@"Started scan.");
}

- (IBAction)scanButtonPressed:(id)sender
{
    if (self.isScanning)
    {
        [self stopScan];
    }
    else
    {
        [self startScan];
    }
}

- (UIImage *) imageForSignalStrength:(NSNumber *) RSSI
{
    NSString *imageName;
    if (RSSI.floatValue > -40.0)
        imageName = @"3-BARS.png";
    else if (RSSI.floatValue > -60.0)
        imageName = @"2-BARS.png";
    else if (RSSI.floatValue > -100.0)
        imageName = @"1-BAR.png";
    else
        imageName = @"0-BARS.png";
    
    return [UIImage imageNamed:imageName];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showProgress"])
    {
        CBPeripheral *p = [self.discoveredTargets objectAtIndex:self.targetTableView.indexPathForSelectedRow.row];

        self.dfuController.peripheral = p;
        [self.cm connectPeripheral:p options:nil];

        [self stopScan];
        
        ProgressViewController *vc = (ProgressViewController *) segue.destinationViewController;
        [vc setDfuController:self.dfuController];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.discoveredTargets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DeviceInformationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DeviceInformationCell"];
    CBPeripheral *p = [self.discoveredTargets objectAtIndex:indexPath.row];
    cell.nameLabel.text = p.name;
    
    NSNumber *rssi = [self.discoveredTargetsRSSI objectForKey:[NSString stringWithFormat:@"%@", p.identifier]];
    cell.rssiImage.image = [self imageForSignalStrength:rssi];
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90.0;
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state == CBCentralManagerStatePoweredOn)
    {
        [self scanButtonPressed:nil];
    }
    NSLog(@"Central manager did update state: %d", (int) central.state);
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    // Avoid bogus value sometimes given by iOS.
    if (RSSI.intValue != 127)
    {
        NSString *key = [NSString stringWithFormat:@"%@", peripheral.identifier];
        NSNumber *oldRSSI = [self.discoveredTargetsRSSI objectForKey:key];
        NSNumber *newRSSI = [NSNumber numberWithFloat:(RSSI.floatValue*0.3 + oldRSSI.floatValue*0.7)];
        [self.discoveredTargetsRSSI setValue:newRSSI forKey:key];
    }
    
    if (![self.discoveredTargets containsObject:peripheral])
    {
        [self.discoveredTargets addObject:peripheral];
    }
    
    NSLog(@"didDiscoverPeripheral %@, %f", peripheral.name, RSSI.floatValue);
    [self.targetTableView reloadData];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"didConnectPeripheral %@", peripheral.name);
    
    [self.dfuController didConnect];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    if (error)
    {
        NSLog(@"didDisconnectPeripheral %@: %@", peripheral.name, error);
    }

    [self.dfuController didDisconnect:error];
}
@end
