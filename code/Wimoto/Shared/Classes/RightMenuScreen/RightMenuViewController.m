//
//  RightMenuViewController.m
//  Wimoto
//
//  Created by Danny Kokarev on 03.12.13.
//
//

#import "RightMenuViewController.h"
#import "RightMenuCell.h"

#import "WimotoDeckController.h"

#import "DatabaseManager.h"

#import "AppConstants.h"
#import "CBPeripheral+Util.h"

@interface RightMenuViewController ()

@property (nonatomic, strong) NSMutableArray *sensorsArray;
@property (nonatomic, strong) IBOutlet RightMenuCell *tmpCell;

- (void)refreshSensors;

@end

@implementation RightMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didConnectPeripheral:) name:NC_BLE_MANAGER_PERIPHERAL_CONNECTED object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDisconnectPeripheral:) name:NC_BLE_MANAGER_PERIPHERAL_DISCONNECTED object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshSensors) name:NC_BLE_DID_ADD_NEW_SENSOR object:nil];
    
    [self refreshSensors];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)refreshSensors
{
    _sensorsArray = [[DatabaseManager storedSensors] mutableCopy];
    [self.tableView reloadData];
}

- (void)didConnectPeripheral:(NSNotification*)notification {
    CBPeripheral *peripheral = [notification object];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"systemId LIKE %@", [peripheral systemId]];
    NSArray *filteredArray = [_sensorsArray filteredArrayUsingPredicate:predicate];
    
    if ([filteredArray count]>0) {
        Sensor *sensor = [filteredArray objectAtIndex:0];
        sensor.peripheral = peripheral;
    }
}

- (void)didDisconnectPeripheral:(NSNotification*)notification {
    CBPeripheral *peripheral = [notification object];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"systemId LIKE %@", [peripheral systemId]];
    NSArray *filteredArray = [_sensorsArray filteredArrayUsingPredicate:predicate];
    
    if ([filteredArray count]>0) {
        Sensor *sensor = [filteredArray objectAtIndex:0];
        sensor.peripheral = nil;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_sensorsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"RightMenuCell";
    RightMenuCell *cell = (RightMenuCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)?@"RightMenuCell_iPad":@"RightMenuCell_iPhone" owner:self options:nil];
        cell = _tmpCell;
        self.tmpCell = nil;
    }
    cell.sensor = [_sensorsArray objectAtIndex:indexPath.row];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    Sensor *sensor = [_sensorsArray objectAtIndex:indexPath.row];
    [sensor deleteDocument:nil];
    
    [_sensorsArray removeObject:sensor];
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Sensor *sensor = [_sensorsArray objectAtIndex:indexPath.row];

    [(WimotoDeckController*)self.viewDeckController showSensorDetailsScreen:sensor];

    [self.viewDeckController closeRightViewAnimated:YES duration:0.2 completion:nil];
}

@end
