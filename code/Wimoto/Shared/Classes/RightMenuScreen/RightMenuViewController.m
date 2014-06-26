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

@property (nonatomic, strong) NSArray *sensorsArray;
@property (nonatomic, strong) IBOutlet RightMenuCell *tmpCell;

@end

@implementation RightMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    [SensorsManager addObserverForRegisteredSensors:self];    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [SensorsManager removeObserverForRegisteredSensors:self];
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
        _tmpCell = nil;
    }
    cell.sensorEntity = [_sensorsArray objectAtIndex:indexPath.row];
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
    [SensorsManager unregisterSensor:[_sensorsArray objectAtIndex:indexPath.row]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    Sensor *sensor = [_sensorsArray objectAtIndex:indexPath.row];
    
    [(WimotoDeckController*)self.viewDeckController showSensorDetailsScreen:sensor];
    [self.viewDeckController closeRightViewAnimated:YES duration:0.2 completion:nil];
}

#pragma mark - SensorsObserver

- (void)didUpdateSensors:(NSSet*)sensors {
    _sensorsArray = [sensors allObjects];
    [self.tableView reloadData];
}

@end
