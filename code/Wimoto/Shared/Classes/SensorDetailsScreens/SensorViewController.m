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
#import "WimotoDeckController.h"

@interface SensorViewController ()

@property (nonatomic, weak) IBOutlet UILabel *rssiLabel;
@property (nonatomic, weak) IBOutlet UIImageView *batteryLevelImage;

@property (nonatomic, weak) IBOutlet UIButton *enableSensorDataLoggerButton;
@property (nonatomic, weak) IBOutlet UIButton *readSensorDataLoggerButton;

@property (nonatomic, weak) IBOutlet UIButton *dataReadbackButton;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *dataReadbackIndicatorView;

@property (nonatomic, weak) IBOutlet UIButton *dfuButton;

- (IBAction)firmwareUpdateAction:(id)sender;

- (IBAction)enableSensorDataLogger:(id)sender;
- (IBAction)readSensorDataLogger:(id)sender;

- (IBAction)readDataLogger:(id)sender;

- (IBAction)showLeftMenu:(id)sender;
- (IBAction)showRightMenu:(id)sender;

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
    [_sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_SENSOR_DL_STATE options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    
    _lastUpdateLabel.sensor = _sensor;
    
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
        [_sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_SENSOR_DL_STATE];
    }
    @catch (NSException *exception) {
        // No need to handle just prevent app crash
    }
    
    NSLog(@"SensorViewController dealloc");
    
    [_lastUpdateLabel reset];
}

- (IBAction)firmwareUpdateAction:(id)sender {
    FirmwareViewController *firmwareController = [[FirmwareViewController alloc] initWithSensor:_sensor];
    UINavigationController *firmwareNavController = [[UINavigationController alloc] initWithRootViewController:firmwareController];
    [self presentViewController:firmwareNavController animated:YES completion:nil];
}

- (IBAction)enableSensorDataLogger:(id)sender {
    [_sensor enableDataLogger:YES];
}

- (IBAction)readSensorDataLogger:(id)sender {
    [_sensor readDataLogger];
}

- (IBAction)readDataLogger:(id)sender {
    UIAlertView *readOptionsAlert = [[UIAlertView alloc] initWithTitle:nil message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"E-mail", @"Cloud Sync", nil];
    [readOptionsAlert show];
}

- (IBAction)showLeftMenu:(id)sender {
    if ([(WimotoDeckController*)self.viewDeckController isSideOpen:IIViewDeckLeftSide]) {
        [(WimotoDeckController*)self.viewDeckController toggleLeftView];
    } else {
        [(WimotoDeckController*)self.viewDeckController openLeftViewAnimated:YES];
    }
}

- (IBAction)showRightMenu:(id)sender {
    if ([(WimotoDeckController*)self.viewDeckController isSideOpen:IIViewDeckRightSide]) {
        [(WimotoDeckController*)self.viewDeckController toggleRightView];
    } else {
        [(WimotoDeckController*)self.viewDeckController openRightViewAnimated:YES];
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
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([keyPath isEqualToString:OBSERVER_KEY_PATH_SENSOR_PERIPHERAL]) {
            if ([[change objectForKey:NSKeyValueChangeNewKey] isKindOfClass:[NSNull class]]) {
                self.view.backgroundColor = [UIColor lightGrayColor];
                _rssiLabel.hidden           = YES;
                _batteryLevelImage.hidden   = YES;
                //            _enableSensorDataLoggerButton.hidden    = NO;
                //            _enableSensorDataLoggerButton.enabled   = NO;
                //            _readSensorDataLoggerButton.hidden      = YES;
                _dataReadbackButton.hidden  = YES;
                _dfuButton.hidden           = YES;
            } else {
                _rssiLabel.hidden           = NO;
                _batteryLevelImage.hidden   = NO;
                //            _enableSensorDataLoggerButton.hidden    = NO;
                //            _enableSensorDataLoggerButton.enabled   = NO;
                //            _readSensorDataLoggerButton.hidden      = YES;
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
            
            switch (dlState) {
                case kDataLoggerStateNone:
                    _enableSensorDataLoggerButton.hidden = YES;
                    _readSensorDataLoggerButton.hidden = YES;
                    break;
                case kDataLoggerStateUnknown:
                    _enableSensorDataLoggerButton.hidden = NO;
                    _enableSensorDataLoggerButton.enabled = NO;
                    _readSensorDataLoggerButton.hidden = YES;
                    break;
                case kDataLoggerStateDisabled:
                    _enableSensorDataLoggerButton.hidden = NO;
                    _enableSensorDataLoggerButton.enabled = YES;
                    _readSensorDataLoggerButton.hidden = YES;
                    break;
                case kDataLoggerStateEnabled:
                    _enableSensorDataLoggerButton.hidden = YES;
                    _enableSensorDataLoggerButton.enabled = NO;
                    _readSensorDataLoggerButton.hidden = NO;
                    _readSensorDataLoggerButton.enabled = YES;
                    break;
                case kDataLoggerStateRead:
                    _enableSensorDataLoggerButton.hidden = YES;
                    _enableSensorDataLoggerButton.enabled = NO;
                    _readSensorDataLoggerButton.hidden = NO;
                    _readSensorDataLoggerButton.enabled = NO;
                    break;
                default:
                    break;
            }
            //            _enableSensorDataLoggerButton.hidden = NO;
            //            _enableSensorDataLoggerButton.enabled = YES;
            //            //_enableSensorDataLoggerButton.selected = (dlState == kDataLoggerStateEnabled);
        }
    });
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    self.sensor.name = [textField text];
    //[self.sensor.entity saveNewName:[textField text]];
    return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        _dataReadbackButton.hidden = YES;
        [_dataReadbackIndicatorView startAnimating];
        
        [_sensor.entity jsonRepresentation:^(NSData *result) {
            [self didUpdateSensorReadingData:result error:nil];
        }];
    }

}

#pragma mark - SensorDataReadingDelegate

- (void)didReadSensorDataLogger:(NSArray *)data {
    NSLog(@"didReadSensorDataLogger");
    
    if([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
        mailController.mailComposeDelegate = self;
        
        [mailController setSubject:@"Wimoto"];
        [mailController setMessageBody:[NSString stringWithFormat:@"Content from Wimoto %@ Sensor %@", [self.sensor codename], [self.sensor uniqueIdentifier]] isHTML:NO];
        [mailController addAttachmentData:[NSJSONSerialization dataWithJSONObject:data options:0 error:nil] mimeType:@"application/json" fileName:@"AppData.json"];
        
        [self presentViewController:mailController animated:YES completion:nil];
    }
}

- (void)didUpdateSensorReadingData:(NSData *)data error:(NSError *)error {
    NSLog(@"didUpdateSensorReadingData ");
    _dataReadbackButton.hidden = NO;
    [_dataReadbackIndicatorView stopAnimating];
    
    if (!error) {
        if([MFMailComposeViewController canSendMail]) {
            MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
            mailController.mailComposeDelegate = self;
            
            [mailController setSubject:@"Wimoto"];
            [mailController setMessageBody:[NSString stringWithFormat:@"Content from Wimoto %@ Sensor %@", [self.sensor codename], [self.sensor uniqueIdentifier]] isHTML:NO];
            [mailController addAttachmentData:data mimeType:@"application/json" fileName:@"AppData.json"];
            
            //NSLog(@"Mail Content String = %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            
            [self presentViewController:mailController animated:YES completion:nil];
        }
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
