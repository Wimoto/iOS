//
//  SearchSensorViewController.m
//  Wimoto
//
//  Created by MC700 on 12/9/13.
//
//

#import "SearchSensorViewController.h"
#import "SensorCell.h"

@interface SearchSensorViewController ()

@property (nonatomic, weak) IBOutlet UITableView *sensorTableView;
@property (nonatomic, strong) NSMutableArray *sensorArray;
@property (nonatomic, weak) IBOutlet SensorCell *tmpCell;

@end

@implementation SearchSensorViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _sensorArray = [NSMutableArray array];
    
    [BLEManager sharedManager].delegate = self;
    [[BLEManager sharedManager] startScanForHRBelts];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    if (cell == nil)
    {
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
    
//    SensorDetailsViewController *sensorDetailsViewController = [[SensorDetailsViewController alloc] initWithSensor:[_sensorArray objectAtIndex:indexPath.row]];
//    [self.navigationController pushViewController:sensorDetailsViewController animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
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
