//
//  FirmwareViewController.m
//  Wimoto
//
//  Created by Danny Kokarev on 10.06.14.
//
//

#import "FirmwareViewController.h"
#import "FirmwareCell.h"
#import "DFUController.h"
#import "FirmwareUploadViewController.h"

@interface FirmwareViewController ()

@property (nonatomic, strong) IBOutlet FirmwareCell *tmpCell;
@property (nonatomic, assign) IBOutlet UITableView *tableView;
@property (nonatomic, strong) DFUController *dfuController;
@property (nonatomic, strong) NSArray *binaries;
@property (nonatomic, strong) Sensor *sensor;

- (void)doneAction;

@end

@implementation FirmwareViewController

- (id)initWithSensor:(Sensor *)sensor {
    self = [super init];
    if (self) {
        self.sensor = sensor;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Firmware update";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneAction)];
    _tableView.tableFooterView = [[UIView alloc] init];
    self.dfuController = [[DFUController alloc] init];
    [_dfuController setPeripheral:[_sensor peripheral]];
    
    NSError *error;
    NSData *jsonData = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"binary_list" withExtension:@"json"]];
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    self.binaries = [dictionary objectForKey:@"binaries"];
    
    [WPNetworkDispatcher performNetworkRequest:[WPRequest requestWithType:kWPGetFirmware andData:nil] withResponseReceiver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)doneAction {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_binaries count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"FirmwareCell";
    FirmwareCell *cell = (FirmwareCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        [[NSBundle mainBundle] loadNibNamed:@"FirmwareCell_iPhone" owner:self options:nil];
        cell = _tmpCell;
        self.tmpCell = nil;
    }
    [cell bindData:[_binaries objectAtIndex:indexPath.row]];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *binary = [_binaries objectAtIndex:indexPath.row];
    NSURL *firmwareURL = [[NSBundle mainBundle] URLForResource:[binary objectForKey:@"filename"] withExtension:[binary objectForKey:@"extension"]];
    [self.dfuController setFirmwareURL:firmwareURL];
    FirmwareUploadViewController *firmwareUploadController = [[FirmwareUploadViewController alloc] initWithDFUController:_dfuController];
    [self.navigationController pushViewController:firmwareUploadController animated:YES];
}

#pragma mark - WPResponseReceiver

- (void)processResponse:(WPResponse *)response {
    NSLog(@"---- %@", response.responseData);
}

@end
