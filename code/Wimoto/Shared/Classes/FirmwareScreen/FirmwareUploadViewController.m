//
//  FirmwareUploadViewController.m
//  Wimoto
//
//  Created by Danny Kokarev on 10.06.14.
//
//

#import "FirmwareUploadViewController.h"

@interface FirmwareUploadViewController ()

@property (nonatomic, strong) Sensor *sensor;
@property (nonatomic, strong) Firmware *firmware;

@property (nonatomic, strong) DFUController *dfuController;
@property (nonatomic, weak) IBOutlet UILabel *fileNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *sizeLabel;
@property (nonatomic, weak) IBOutlet UILabel *targetNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *targetStatusLabel;
@property (nonatomic, weak) IBOutlet UILabel *progressLabel;
@property (nonatomic, weak) IBOutlet UIButton *uploadButton;
@property (nonatomic, weak) IBOutlet UIProgressView *progressView;
@property (nonatomic, assign) BOOL isTransferring;

@end

@implementation FirmwareUploadViewController

- (id)initWithSensor:(Sensor *)sensor andFirmware:(Firmware *)firmware {
    self = [super init];
    if (self) {
        _sensor = sensor;
        [_sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_SENSOR_DFU_MODE options:NSKeyValueObservingOptionNew context:nil];
        
        _firmware = firmware;
        
        self.dfuController = [[DFUController alloc] init];
        _dfuController.delegate = self;
        
        [_dfuController setFirmwareURL:[NSURL URLWithString:_firmware.fileURL]];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_sensor switchToDfuMode];
    
    self.navigationItem.title = @"Firmware upload";
    _fileNameLabel.text = [_dfuController appName];
    _sizeLabel.text = [NSString stringWithFormat:@"%d bytes", _dfuController.appSize];
    _targetNameLabel.text = [_dfuController targetName];
    _targetStatusLabel.text = @"-";
    _uploadButton.enabled = (_dfuController.state == IDLE)?YES:NO;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [_dfuController cancelTransfer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [_sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_SENSOR_DFU_MODE];
}

- (IBAction)uploadButtonPressed:(id)sender {
    if (!_isTransferring) {
        self.isTransferring = YES;
        [_dfuController startTransfer];
        [_uploadButton setTitle:@"Cancel" forState:UIControlStateNormal];
    }
    else {
        self.isTransferring = NO;
        [_dfuController cancelTransfer];
        [_uploadButton setTitle:@"Upload" forState:UIControlStateNormal];
    }
}

#pragma mark - DFUControllerDelegate

- (void)didUpdateProgress:(float)progress {
    _progressLabel.text = [NSString stringWithFormat:@"%.0f %%", progress*100];
    [_progressView setProgress:progress animated:YES];
}

- (void)didFinishTransfer {
    NSString *message = [NSString stringWithFormat:@"The upload completed successfully, %@ has been reset and now runs %@.", self.dfuController.targetName, self.dfuController.appName];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Finished upload!" message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)didCancelTransfer {
    NSString *message = [NSString stringWithFormat:@"The upload was cancelled. %@ has been reset, and runs its original application.", self.dfuController.targetName];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Canceled upload" message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didDisconnect:(NSError *)error {
    NSString *message = [NSString stringWithFormat:@"The connection was lost, with error description: %@", error.description];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection lost" message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didChangeState:(DFUControllerState)state {
    if (state == IDLE) {
        _uploadButton.enabled = YES;
    }
    self.targetStatusLabel.text = [self.dfuController stringFromState:state];
}

#pragma mark - Value Observer

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    NSLog(@"FirmwareUploadViewController switch to DFU mode");
    [_dfuController setPeripheral:_sensor.peripheral];
    [_dfuController didConnect];
    
    _targetNameLabel.text = [_dfuController targetName];
}

@end
