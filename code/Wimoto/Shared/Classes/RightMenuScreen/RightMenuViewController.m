//
//  RightMenuViewController.m
//  Wimoto
//
//  Created by Danny Kokarev on 03.12.13.
//
//

#import "RightMenuViewController.h"
#import "RightMenuCell.h"

#import "ClimateSensorDetailsViewController.h"
#import "GrowSensorDetailsViewController.h"
#import "SentrySensorDetailsViewController.h"
#import "ThermoSensorDetailsViewController.h"
#import "WaterSensorDetailsViewController.h"

#import "SensorManager.h"

@interface RightMenuViewController ()

@property (nonatomic, strong) NSArray *sensorsArray;
@property (nonatomic, strong) IBOutlet RightMenuCell *tmpCell;

@end

@implementation RightMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _sensorsArray = [SensorManager getSensors];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Sensor *sensor = [_sensorsArray objectAtIndex:indexPath.row];
    if (sensor.type==kSensorTypeClimate) {
        ClimateSensorDetailsViewController *climateController = [[ClimateSensorDetailsViewController alloc] init];
        self.viewDeckController.centerController = climateController;
    } else if (sensor.type==kSensorTypeGrow) {
        GrowSensorDetailsViewController *growController = [[GrowSensorDetailsViewController alloc] init];
        self.viewDeckController.centerController = growController;
    } else if (sensor.type==kSensorTypeSentry) {
        SentrySensorDetailsViewController *sentryController = [[SentrySensorDetailsViewController alloc] init];
        self.viewDeckController.centerController = sentryController;
    } else if (sensor.type==kSensorTypeThermo) {
        ThermoSensorDetailsViewController *thermoController = [[ThermoSensorDetailsViewController alloc] init];
        self.viewDeckController.centerController = thermoController;
    } else if (sensor.type==kSensorTypeWater) {
        WaterSensorDetailsViewController *waterController = [[WaterSensorDetailsViewController alloc] init];
        self.viewDeckController.centerController = waterController;
    }
    [self.viewDeckController closeRightViewAnimated:YES duration:0.2 completion:nil];
}

@end
