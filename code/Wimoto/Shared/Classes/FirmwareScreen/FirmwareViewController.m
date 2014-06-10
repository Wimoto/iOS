//
//  FirmwareViewController.m
//  Wimoto
//
//  Created by Danny Kokarev on 10.06.14.
//
//

#import "FirmwareViewController.h"
#import "FirmwareCell.h"

@interface FirmwareViewController ()

@property (nonatomic, strong) IBOutlet FirmwareCell *tmpCell;
@property (nonatomic, assign) IBOutlet UITableView *tableView;

- (void)doneAction;

@end

@implementation FirmwareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Firmware update";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneAction)];
    _tableView.tableFooterView = [[UIView alloc] init];
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
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"FirmwareCell";
    FirmwareCell *cell = (FirmwareCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        [[NSBundle mainBundle] loadNibNamed:@"FirmwareCell_iPhone" owner:self options:nil];
        cell = _tmpCell;
        self.tmpCell = nil;
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - WPResponseReceiver

- (void)processResponse:(WPResponse *)response {
    NSLog(@"---- %@", response.responseData);
}

@end
