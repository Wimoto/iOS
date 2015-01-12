//
//  SensorViewController.m
//  Wimoto
//
//  Created by MC700 on 12/13/13.
//
//

#import "SensorViewController.h"
#import "NSString+Util.h"
#import "RelativeDateDescriptor.h"
#import "FirmwareViewController.h"
#import "QueueManager.h"

@interface SensorViewController ()

@property (nonatomic, weak) IBOutlet UILabel *rssiLabel;
@property (nonatomic, weak) IBOutlet UIImageView *batteryLevelImage;

@property (nonatomic, weak) IBOutlet UIButton *dataLoggerButton;

@property (nonatomic, weak) IBOutlet UIButton *dataReadbackButton;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *dataReadbackIndicatorView;

@property (nonatomic, weak) IBOutlet UIButton *dfuButton;

- (IBAction)firmwareUpdateAction:(id)sender;

- (IBAction)enableDataLogger:(id)sender;
- (IBAction)readDataLogger:(id)sender;

@end

@implementation SensorViewController

- (id)initWithSensor:(Sensor*)sensor {
    self = [super init];
    if (self) {
        _sensor = sensor;
        [_sensor setDataReadingDelegate:self];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [_sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_SENSOR_PERIPHERAL options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    [_sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_SENSOR_RSSI options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    [_sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_SENSOR_BATTERY_LEVEL options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    [_sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_SENSOR_DL_STATE options:NSKeyValueObservingOptionNew context:NULL];
    
    
    NSString *sensorName = [_sensor name];
    if ([sensorName isNotEmpty]) {
        self.sensorNameField.text = sensorName;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_sensor setDataReadingDelegate:nil];
    @try {
        [_sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_SENSOR_PERIPHERAL];
        [_sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_SENSOR_RSSI];
        [_sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_SENSOR_BATTERY_LEVEL];
    }
    @catch (NSException *exception) {
        // No need to handle just prevent app crash
    }
    
    if ([self.lastUpdateTimer isValid]) {
        [self.lastUpdateTimer invalidate];
    }
    self.lastUpdateTimer = nil;
}

- (IBAction)firmwareUpdateAction:(id)sender {
    FirmwareViewController *firmwareController = [[FirmwareViewController alloc] initWithSensor:_sensor];
    UINavigationController *firmwareNavController = [[UINavigationController alloc] initWithRootViewController:firmwareController];
    [self presentViewController:firmwareNavController animated:YES completion:nil];
}

- (IBAction)enableDataLogger:(id)sender {
    [sender setEnabled:NO];
    
    [_sensor enableDataLogger:![sender isSelected]];
}

- (IBAction)readDataLogger:(id)sender {
    _dataReadbackButton.hidden = YES;
    [_dataReadbackIndicatorView startAnimating];
    
    [_sensor readDataLogger];
}

- (void)refreshLastUpdateLabel {
    NSDate *lastUpdateDate = [self.sensor.entity lastActivityAt];
    if (lastUpdateDate) {
        RelativeDateDescriptor *descriptor = [[RelativeDateDescriptor alloc] initWithPriorDateDescriptionFormat:@"%@ ago" postDateDescriptionFormat:@"in %@"];
        _lastUpdateLabel.text = [descriptor describeDate:lastUpdateDate relativeTo:[NSDate date]];
    }
}

#pragma mark - SensorDelegate

- (void)didUpdateAlarmStateWithUUIDString:(NSString *)UUIDString {
    //Implement in child
}

- (void)didReadMinAlarmValueFromCharacteristicUUID:(CBUUID *)uuid {
    //Implement in child
}

- (void)didReadMaxAlarmValueFromCharacteristicUUID:(CBUUID *)uuid {
    //Implement in child
}

#pragma mark - AlarmSliderDelegate

- (void)alarmSliderSaveAction:(id)sender {
    //Implement in child
}

#pragma mark - Value Observer

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:OBSERVER_KEY_PATH_SENSOR_PERIPHERAL]) {
        if ([[change objectForKey:NSKeyValueChangeNewKey] isKindOfClass:[NSNull class]]) {
            self.view.backgroundColor = [UIColor lightGrayColor];
            _rssiLabel.hidden           = YES;
            _batteryLevelImage.hidden   = YES;
            _dataLoggerButton.hidden    = YES;
            _dataReadbackButton.hidden  = YES;
            _dfuButton.hidden           = YES;
        } else {
            _rssiLabel.hidden           = NO;
            _batteryLevelImage.hidden   = NO;
            _dataReadbackButton.hidden  = NO;
            _dfuButton.hidden           = NO;
        }
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_SENSOR_RSSI]) {
        int rssi = 0;
        
        NSObject *rssiObject = [change objectForKey:NSKeyValueChangeNewKey];
        if ([rssiObject isKindOfClass:[NSNumber class]]) {
            rssi = [(NSNumber*)rssiObject intValue];
        }
        
        if (rssi == 0) {
            _rssiLabel.hidden = YES;
        } else {
            _rssiLabel.text = [NSString stringWithFormat:@"%idB", rssi];
            _rssiLabel.hidden = NO;
        }
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_SENSOR_BATTERY_LEVEL]) {
        int level = -1;
        
        NSObject *levelObject = [change objectForKey:NSKeyValueChangeNewKey];
        if ([levelObject isKindOfClass:[NSNumber class]]) {
            level = [(NSNumber *)levelObject intValue];
        }
        
        if (level == -1) {
            _batteryLevelImage.hidden = YES;
        } else {
            NSString *batteryImagePath = nil;
            if (level > 75) {
                batteryImagePath = @"battery-full";
            } else if (level > 50) {
                batteryImagePath = @"battery-high";
            } else if (level > 25) {
                batteryImagePath = @"battery-medium";
            } else {
                batteryImagePath = @"battery-low";
            }
                
            _batteryLevelImage.image = [UIImage imageNamed:batteryImagePath];
            _batteryLevelImage.hidden = NO;
        }
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_SENSOR_DL_STATE]) {
        DataLoggerState dlState = [[change objectForKey:NSKeyValueChangeNewKey] intValue];
        
        _dataLoggerButton.hidden = NO;
        _dataLoggerButton.enabled = YES;
        _dataLoggerButton.selected = (dlState == kDataLoggerStateEnabled);
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    self.sensor.name = [textField text];
    //[self.sensor.entity saveNewName:[textField text]];
    return YES;
}

#pragma mark - SensorDataReadingDelegate

- (void)didUpdateSensorReadingData:(NSData *)data error:(NSError *)error {
    NSLog(@"didUpdateSensorReadingData ");
    _dataReadbackButton.hidden = NO;
    [_dataReadbackIndicatorView stopAnimating];
    
    if (!error) {
        if([MFMailComposeViewController canSendMail]) {
            MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
            mailController.mailComposeDelegate = self;
            
            [mailController setSubject:@"Wimoto"];
            [mailController setMessageBody:@"Content from Wimoto Sensor" isHTML:NO];
            [mailController addAttachmentData:data mimeType:@"text/csv" fileName:@"AppData.csv"];
            
            [self presentViewController:mailController animated:YES completion:nil];
        }
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
