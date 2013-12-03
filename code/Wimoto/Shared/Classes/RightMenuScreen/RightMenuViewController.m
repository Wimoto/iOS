//
//  RightMenuViewController.m
//  Wimoto
//
//  Created by Danny Kokarev on 03.12.13.
//
//

#import "RightMenuViewController.h"
#import "RightMenuCell.h"
#import "SensorDataViewController.h"

@interface RightMenuViewController ()

@property (nonatomic, strong) NSMutableArray *sensorsArray;
@property (nonatomic, strong) IBOutlet RightMenuCell *tmpCell;

@end

@implementation RightMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.sensorsArray = [NSMutableArray arrayWithObjects:@"Sensor 1", @"Sensor 2", @"Sensor 3", nil];
    self.tableView.tableFooterView = [[UIView alloc] init];
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
    [cell bindData:[_sensorsArray objectAtIndex:indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SensorDataViewController *sensorDataController = [[SensorDataViewController alloc] init];
    UINavigationController *sensorDataNavController = [[UINavigationController alloc] initWithRootViewController:sensorDataController];
    self.viewDeckController.centerController = sensorDataNavController;
    [self.viewDeckController closeRightViewAnimated:YES duration:0.2 completion:^(IIViewDeckController *controller, BOOL success) {}];
}

@end
