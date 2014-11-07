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
#import "Firmware.h"
#import "SVProgressHUD.h"

@interface FirmwareViewController ()

@property (nonatomic, strong) IBOutlet FirmwareCell *tmpCell;
@property (nonatomic, assign) IBOutlet UITableView *tableView;
@property (nonatomic, strong) DFUController *dfuController;
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
    
    /*
    self.dfuController = [[DFUController alloc] init];
    //[_dfuController setPeripheral:[_sensor peripheral]];
    
    NSError *error;
    NSData *jsonData = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"binary_list" withExtension:@"json"]];
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    self.binaries = [dictionary objectForKey:@"binaries"];
    */
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
    [WPNetworkDispatcher performNetworkRequest:[WPRequest requestWithType:kWPRequestDownload andData:[firmware fileURL]] withResponseReceiver:self];
    /*
    NSDictionary *binary = [_binaries objectAtIndex:indexPath.row];
    NSURL *firmwareURL = [[NSBundle mainBundle] URLForResource:[binary objectForKey:@"filename"] withExtension:[binary objectForKey:@"extension"]];
    [self.dfuController setFirmwareURL:firmwareURL];
    FirmwareUploadViewController *firmwareUploadController = [[FirmwareUploadViewController alloc] initWithDFUController:_dfuController];
    [self.navigationController pushViewController:firmwareUploadController animated:YES];
     */
}

#pragma mark - WPResponseReceiver

- (void)downloadProgress:(float)progress request:(WPRequest *)request {
    if (request.requestType == kWPRequestDownload) {
        [SVProgressHUD showProgress:progress status:nil maskType:SVProgressHUDMaskTypeBlack];
    }
}

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
    else if (response.request.requestType == kWPRequestDownload) {
        if (response.codeStatus != 200) {
            [SVProgressHUD showErrorWithStatus:@"Can't download"];
        }
        else {
            [SVProgressHUD dismiss];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
