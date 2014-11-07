//
//  SentrySensorDetailsViewController.m
//  Wimoto
//
//  Created by MC700 on 12/3/13.
//
//

#import "SentrySensorDetailsViewController.h"
#import "ASBSparkLineView.h"
#import "SentrySensor.h"

@interface SentrySensorDetailsViewController ()

@property (nonatomic, weak) IBOutlet UILabel *accelerometerLabel;
@property (nonatomic, weak) IBOutlet UILabel *pasInfraredLabel;

@property (nonatomic, weak) IBOutlet ASBSparkLineView *accelerometerSparkLine;
@property (nonatomic, weak) IBOutlet ASBSparkLineView *pasInfraredSparkLine;

@property (nonatomic, weak) IBOutlet UISwitch *accelerometerSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *pasInfraredSwitch;

@property (nonatomic, weak) IBOutlet UIImageView *accelerometerAlarmImage;
@property (nonatomic, weak) IBOutlet UIImageView *pasInfraredAlarmImage;

@property (nonatomic, strong) NSString *currentAlarmUUIDString;

- (IBAction)accelerometerAlarmAction:(id)sender;
- (IBAction)pasInfraredAlarmAction:(id)sender;

@end

@implementation SentrySensorDetailsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = YES;
    
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_SENTRY_SENSOR_ACCELEROMETER options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_SENTRY_SENSOR_PASSIVE_INFRARED options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_SENTRY_SENSOR_ACCELEROMETER_ALARM_STATE options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_SENTRY_SENSOR_PAS_INFRARED_ALARM_STATE options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    
    _accelerometerSparkLine.labelText = @"";
    _accelerometerSparkLine.showCurrentValue = NO;
    [self.sensor.entity latestValuesWithType:kValueTypeAccelerometer completionHandler:^(NSArray *result) {
        _accelerometerSparkLine.dataValues = result;
    }];
    _pasInfraredSparkLine.labelText = @"";
    _pasInfraredSparkLine.showCurrentValue = NO;
    [self.sensor.entity latestValuesWithType:kValueTypePassiveInfrared completionHandler:^(NSArray *result) {
        _pasInfraredSparkLine.dataValues = result;
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    @try {
        [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_SENTRY_SENSOR_ACCELEROMETER];
        [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_SENTRY_SENSOR_PASSIVE_INFRARED];
        
        [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_SENTRY_SENSOR_ACCELEROMETER_ALARM_STATE];
        [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_SENTRY_SENSOR_PAS_INFRARED_ALARM_STATE];
    }
    @catch (NSException *exception) {
        // No need to handle just prevent app crash
    }
}

- (IBAction)accelerometerAlarmAction:(id)sender {
    [self.sensor enableAlarm:[sender isOn] forCharacteristicWithUUIDString:BLE_SENTRY_SERVICE_UUID_ACCELEROMETER_ALARM_SET];
}

- (IBAction)pasInfraredAlarmAction:(id)sender {
    [self.sensor enableAlarm:[sender isOn] forCharacteristicWithUUIDString:BLE_SENTRY_SERVICE_UUID_PASSIVE_INFRARED_ALARM_SET];
}

#pragma mark - Value Observer

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    
    if ([keyPath isEqualToString:OBSERVER_KEY_PATH_SENSOR_PERIPHERAL]) {
        if ([[change objectForKey:NSKeyValueChangeNewKey] isKindOfClass:[NSNull class]]) {
            _accelerometerAlarmImage.hidden = YES;
            _pasInfraredAlarmImage.hidden = YES;
            _accelerometerSwitch.hidden = YES;
            _pasInfraredSwitch.hidden = YES;
            _accelerometerLabel.text = SENSOR_VALUE_PLACEHOLDER;
            _pasInfraredLabel.text = SENSOR_VALUE_PLACEHOLDER;
        } else {
            _accelerometerAlarmImage.hidden = NO;
            _pasInfraredAlarmImage.hidden = NO;
            _accelerometerSwitch.hidden = NO;
            _pasInfraredSwitch.hidden = NO;
            SentrySensor *sensor = (SentrySensor*)self.sensor;
            _accelerometerLabel.text = [NSString stringWithFormat:@"%.1f", [sensor accelerometer]];
            _pasInfraredLabel.text = [NSString stringWithFormat:@"%.1f", [sensor pasInfrared]];
            self.view.backgroundColor = [UIColor colorWithRed:(140.f/255.f) green:(140.f/255.f) blue:(140.f/255.f) alpha:1.f];
        }
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_SENTRY_SENSOR_ACCELEROMETER]) {
        self.lastUpdateLabel.text = @"Just now";
        if ([self.lastUpdateTimer isValid]) {
            [self.lastUpdateTimer invalidate];
        }
        self.lastUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:15.0 target:self selector:@selector(refreshLastUpdateLabel) userInfo:nil repeats:YES];
        
        if (self.sensor.peripheral) {
            _accelerometerLabel.text = [NSString stringWithFormat:@"%.1f", [[change objectForKey:NSKeyValueChangeNewKey] floatValue]];
        }
        [self.sensor.entity latestValuesWithType:kValueTypeAccelerometer completionHandler:^(NSArray *result) {
            _accelerometerSparkLine.dataValues = result;
        }];
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_SENTRY_SENSOR_PASSIVE_INFRARED]) {
        if (self.sensor.peripheral) {
            _pasInfraredLabel.text = [NSString stringWithFormat:@"%.1f", [[change objectForKey:NSKeyValueChangeNewKey] floatValue]];
        }
        [self.sensor.entity latestValuesWithType:kValueTypePassiveInfrared completionHandler:^(NSArray *result) {
            _pasInfraredSparkLine.dataValues = result;
        }];
    }
    else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_SENTRY_SENSOR_ACCELEROMETER_ALARM_STATE]) {
        _accelerometerSwitch.on = ([[change objectForKey:NSKeyValueChangeNewKey] intValue] == kAlarmStateEnabled)?YES:NO;
    }
    else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_SENTRY_SENSOR_PAS_INFRARED_ALARM_STATE]) {
        _pasInfraredSwitch.on = ([[change objectForKey:NSKeyValueChangeNewKey] intValue] == kAlarmStateEnabled)?YES:NO;
    }
}

@end
