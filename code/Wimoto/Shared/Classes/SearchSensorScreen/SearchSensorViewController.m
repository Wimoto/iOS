//
//  SearchSensorViewController.m
//  Wimoto
//
//  Created by MC700 on 12/9/13.
//
//

#import "SearchSensorViewController.h"

#import "AppConstants.h"

#import "ClimateSensorDetailsViewController.h"
#import "SensorCell.h"
#import "SensorManager.h"

@interface SearchSensorViewController ()

@property (nonatomic, strong) NSMutableArray *sensorsArray;

@property (nonatomic, weak) IBOutlet UITableView *sensorTableView;
@property (nonatomic, weak) IBOutlet SensorCell *tmpCell;

- (void)didConnectPeripheral:(NSNotification*)notification;
- (void)didDisconnectPeripheral:(NSNotification*)notification;

@end

@implementation SearchSensorViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _sensorTableView.tableFooterView = [[UIView alloc] init];
    
    NSArray *array = [BLEManager identifiedPeripherals];
    _sensorsArray = [NSMutableArray arrayWithCapacity:[array count]];
    
    for (CBPeripheral *peripheral in array) {
        [_sensorsArray addObject:[Sensor sensorWithPeripheral:peripheral]];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didConnectPeripheral:) name:NC_BLE_MANAGER_PERIPHERAL_CONNECTED object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDisconnectPeripheral:) name:NC_BLE_MANAGER_PERIPHERAL_DISCONNECTED object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didConnectPeripheral:(NSNotification*)notification {
    CBPeripheral *peripheral = [notification object];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"peripheral=%@", peripheral];
    NSArray *filteredArray = [_sensorsArray filteredArrayUsingPredicate:predicate];
    
    if ([filteredArray count]==0) {
        [_sensorsArray addObject:[Sensor sensorWithPeripheral:peripheral]];
        
        [_sensorTableView reloadData];
    }
}

- (void)didDisconnectPeripheral:(NSNotification*)notification {
    CBPeripheral *peripheral = [notification object];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"peripheral=%@", peripheral];
    NSArray *filteredArray = [_sensorsArray filteredArrayUsingPredicate:predicate];

    if ([filteredArray count]>0) {
        [_sensorsArray removeObject:[filteredArray objectAtIndex:0]];
        
        [_sensorTableView reloadData];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_sensorsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"SensorCell";
    SensorCell *cell = (SensorCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)?@"SensorCell_iPad":@"SensorCell_iPhone" owner:self options:nil];
        cell = _tmpCell;
        _tmpCell = nil;
    }
    cell.sensor = [_sensorsArray objectAtIndex:indexPath.row];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //[SensorManager addSensor:[_sensorArray objectAtIndex:indexPath.row]];
    
    ClimateSensorDetailsViewController *climateSensorController = [[ClimateSensorDetailsViewController alloc] initWithSensor:[_sensorsArray objectAtIndex:indexPath.row]];
    self.viewDeckController.centerController = climateSensorController;
    
    //SensorDetailsViewController *sensorDetailsViewController = [[SensorDetailsViewController alloc] initWithSensor:[_sensorArray objectAtIndex:indexPath.row]];
    //[self.navigationController pushViewController:sensorDetailsViewController animated:YES];
}

@end
