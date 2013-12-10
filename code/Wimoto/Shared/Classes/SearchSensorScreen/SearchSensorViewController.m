//
//  SearchSensorViewController.m
//  Wimoto
//
//  Created by MC700 on 12/9/13.
//
//

#import "SearchSensorViewController.h"
#import "SensorCell.h"
#import "SensorManager.h"

@interface SearchSensorViewController ()

@property (nonatomic, weak) IBOutlet UITableView *sensorTableView;
@property (nonatomic, strong) NSMutableArray *sensorArray;
@property (nonatomic, weak) IBOutlet SensorCell *tmpCell;

@end

@implementation SearchSensorViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _sensorTableView.tableFooterView = [[UIView alloc] init];
    _sensorArray = [NSMutableArray array];
    
    [BLEManager sharedManager].delegate = self;
    [[BLEManager sharedManager] startScanForHRBelts];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [BLEManager sharedManager].delegate = nil;
    [[BLEManager sharedManager] stopScanForHRBelts];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_sensorArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"SensorCell";
    SensorCell *cell = (SensorCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)?@"SensorCell_iPad":@"SensorCell_iPhone" owner:self options:nil];
        cell = _tmpCell;
        _tmpCell = nil;
    }
    cell.sensor = [_sensorArray objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [SensorManager addSensor:[_sensorArray objectAtIndex:indexPath.row]];
    
//    SensorDetailsViewController *sensorDetailsViewController = [[SensorDetailsViewController alloc] initWithSensor:[_sensorArray objectAtIndex:indexPath.row]];
//    [self.navigationController pushViewController:sensorDetailsViewController animated:YES];
}

#pragma mark - BLEManagerDelegate

- (void)didConnectPeripheral:(CBPeripheral*)peripheral {
    Sensor *sensor = [[Sensor alloc] initWithPeripheral:peripheral];
    [_sensorArray addObject:sensor];
    [_sensorTableView reloadData];
}

- (void)didDisconnectPeripheral:(CBPeripheral*)peripheral {
    
}

@end
