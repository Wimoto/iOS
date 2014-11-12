//
//  FirmwareViewController.m
//  Wimoto
//
//  Created by Danny Kokarev on 10.06.14.
//
//

#import "FirmwareViewController.h"
#import "FirmwareCell.h"
#import "FirmwareUploadViewController.h"
#import "Firmware.h"
#import "SVProgressHUD.h"

@interface FirmwareViewController ()

@property (nonatomic, strong) IBOutlet FirmwareCell *tmpCell;
@property (nonatomic, assign) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *binaries;
@property (nonatomic, strong) Sensor *sensor;
@property (nonatomic, strong) NSMutableArray *firmwares;

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
    
    self.firmwares = [NSMutableArray array];
    [WPNetworkDispatcher performNetworkRequest:[WPRequest requestWithType:kWPRequestGetFirmwareList andData:nil] withResponseReceiver:self];    
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
    return [_firmwares count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"FirmwareCell";
    FirmwareCell *cell = (FirmwareCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        [[NSBundle mainBundle] loadNibNamed:@"FirmwareCell_iPhone" owner:self options:nil];
        cell = _tmpCell;
        self.tmpCell = nil;
    }
    [cell bindData:[_firmwares objectAtIndex:indexPath.row]];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Firmware *firmware = [_firmwares objectAtIndex:indexPath.row];
    
    FirmwareUploadViewController *firmwareUploadController = [[FirmwareUploadViewController alloc] initWithSensor:_sensor andFirmware:firmware];
    [self.navigationController pushViewController:firmwareUploadController animated:YES];
}

#pragma mark - WPResponseReceiver

- (void)processResponse:(WPResponse *)response {
    if (response.request.requestType == kWPRequestGetFirmwareList) {
        if ([response.responseData isKindOfClass:[NSDictionary class]]) {
            NSDictionary *responseDictionary = (NSDictionary *)[response responseData];
            [responseDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                if ([key isEqualToString:[_sensor codename]]) {
                    Firmware *firmware = [[Firmware alloc] initWithDictionary:obj];
                    firmware.name = key;
                    [_firmwares addObject:firmware];
                }
            }];
            [_tableView reloadData];
        }
    }
}

@end
