//
//  SearchSensorViewController.m
//  Wimoto
//
//  Created by MC700 on 12/9/13.
//
//

#import "SearchSensorViewController.h"
#import "AppConstants.h"
#import "SensorCell.h"
#import "WimotoDeckController.h"
#import "SensorsManager.h"

@interface SearchSensorViewController ()

@property (nonatomic, strong) NSArray *sensorsArray;
@property (nonatomic, weak) IBOutlet UITableView *sensorTableView;
@property (nonatomic, weak) IBOutlet SensorCell *tmpCell;

@end

@implementation SearchSensorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _sensorTableView.tableFooterView = [[UIView alloc] init];
    
    [SensorsManager addObserverForUnregisteredSensors:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [SensorsManager addObserverForUnregisteredSensors:self];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Sensor *sensor = [_sensorsArray objectAtIndex:indexPath.row];
    
    [SensorsManager registerSensor:sensor];
    [(WimotoDeckController*)self.viewDeckController showSensorDetailsScreen:sensor];
}

#pragma mark - SensorsObserver

- (void)didUpdateSensors:(NSSet*)sensors {
    _sensorsArray = [sensors allObjects];
    [_sensorTableView reloadData];
}

@end
