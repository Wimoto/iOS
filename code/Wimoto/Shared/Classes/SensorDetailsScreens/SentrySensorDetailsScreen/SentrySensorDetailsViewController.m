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
#import "TimePickerView.h"
#import "TimeLabel.h"

@interface SentrySensorDetailsViewController ()

@property (nonatomic, weak) IBOutlet UILabel *xAccelerometerLabel;
@property (nonatomic, weak) IBOutlet UILabel *yAccelerometerLabel;
@property (nonatomic, weak) IBOutlet UILabel *zAccelerometerLabel;

@property (nonatomic, weak) IBOutlet UILabel *pasInfraredLabel;

@property (nonatomic, weak) IBOutlet ASBSparkLineView *accelerometerSparkLine;
@property (nonatomic, weak) IBOutlet ASBSparkLineView *pasInfraredSparkLine;

@property (nonatomic, weak) IBOutlet UISwitch *accelerometerSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *pasInfraredSwitch;

@property (nonatomic, weak) IBOutlet TimeLabel *accelerometerAlarmEnabledLabel;
@property (nonatomic, weak) IBOutlet TimeLabel *accelerometerAlarmDisabledLabel;

@property (nonatomic, weak) IBOutlet TimeLabel *pasInfraredAlarmEnabledLabel;
@property (nonatomic, weak) IBOutlet TimeLabel *pasInfraredAlarmDisabledLabel;

@property (nonatomic, weak) IBOutlet UIView *accelerometerAlarmContainer;
@property (nonatomic, weak) IBOutlet UIView *pasInfraredAlarmContainer;

@property (nonatomic, strong) NSString *currentAlarmUUIDString;

- (IBAction)accelerometerAlarmAction:(id)sender;
- (IBAction)pasInfraredAlarmAction:(id)sender;

@end

@implementation SentrySensorDetailsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = YES;
    
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_SENTRY_SENSOR_X options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_SENTRY_SENSOR_Y options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_SENTRY_SENSOR_Z options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];

    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_SENTRY_SENSOR_PASSIVE_INFRARED options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_SENTRY_SENSOR_ACCELEROMETER_ALARM_STATE options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_SENTRY_SENSOR_PAS_INFRARED_ALARM_STATE options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_SENTRY_SENSOR_ACCELEROMETER_ALARM_ENABLED options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_SENTRY_SENSOR_ACCELEROMETER_ALARM_DISABLED options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_SENTRY_SENSOR_INFRARED_ALARM_ENABLED options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_SENTRY_SENSOR_INFRARED_ALARM_DISABLED options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    
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
        [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_SENTRY_SENSOR_X];
        [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_SENTRY_SENSOR_Y];
        [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_SENTRY_SENSOR_Z];

        [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_SENTRY_SENSOR_PASSIVE_INFRARED];
        
        [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_SENTRY_SENSOR_ACCELEROMETER_ALARM_STATE];
        [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_SENTRY_SENSOR_PAS_INFRARED_ALARM_STATE];
        
        [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_SENTRY_SENSOR_ACCELEROMETER_ALARM_ENABLED];
        [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_SENTRY_SENSOR_ACCELEROMETER_ALARM_DISABLED];
        
        [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_SENTRY_SENSOR_INFRARED_ALARM_ENABLED];
        [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_SENTRY_SENSOR_INFRARED_ALARM_DISABLED];
    }
    @catch (NSException *exception) {
        // No need to handle just prevent app crash
    }
}

- (IBAction)accelerometerAlarmAction:(id)sender {
    [self.sensor enableAlarm:[sender isOn] forCharacteristicWithUUIDString:BLE_SENTRY_CHAR_UUID_ACCELEROMETER_ALARM_SET];
    
    if (_accelerometerSwitch.on) {
        SentrySensor *sentrySensor = (SentrySensor *)self.sensor;
        [TimePickerView showWithMinDate:sentrySensor.accelerometerAlarmEnabledTime
                                maxDate:sentrySensor.accelerometerAlarmDisabledTime
                                   save:^(NSDate *minDate, NSDate *maxDate) {
                                       NSLog(@"Save");
                                       [sentrySensor setAccelerometerAlarmEnabledTime:minDate];
                                       [sentrySensor setAccelerometerAlarmDisabledTime:maxDate];
                                       [sentrySensor save];
                                   } cancel:^{
                                       NSLog(@"Cancel");
                                   }];
    }
}

- (IBAction)pasInfraredAlarmAction:(id)sender {
    [self.sensor enableAlarm:[sender isOn] forCharacteristicWithUUIDString:BLE_SENTRY_CHAR_UUID_PASSIVE_INFRARED_ALARM_SET];
    
    if (_pasInfraredSwitch.on) {
        SentrySensor *sentrySensor = (SentrySensor *)self.sensor;
        [TimePickerView showWithMinDate:sentrySensor.infraredAlarmEnabledTime
                                maxDate:sentrySensor.infraredAlarmDisabledTime
                                   save:^(NSDate *minDate, NSDate *maxDate) {
                                       NSLog(@"Save");
                                       [sentrySensor setInfraredAlarmEnabledTime:minDate];
                                       [sentrySensor setInfraredAlarmDisabledTime:maxDate];
                                       
                                       [sentrySensor save];
                                   } cancel:^{
                                       NSLog(@"Cancel");
                                   }];
    }
}

#pragma mark - Value Observer

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([keyPath isEqualToString:OBSERVER_KEY_PATH_SENSOR_PERIPHERAL]) {
            if ([[change objectForKey:NSKeyValueChangeNewKey] isKindOfClass:[NSNull class]]) {
                _accelerometerAlarmContainer.hidden = YES;
                _pasInfraredAlarmContainer.hidden = YES;
                _xAccelerometerLabel.text = SENSOR_VALUE_PLACEHOLDER;
                _yAccelerometerLabel.text = SENSOR_VALUE_PLACEHOLDER;
                _zAccelerometerLabel.text = SENSOR_VALUE_PLACEHOLDER;
                _pasInfraredLabel.text = SENSOR_VALUE_PLACEHOLDER;
            } else {
                _accelerometerAlarmContainer.hidden = NO;
                _pasInfraredAlarmContainer.hidden = NO;
                SentrySensor *sensor = (SentrySensor*)self.sensor;
                _xAccelerometerLabel.text = [NSString stringWithFormat:@"%.1f", [sensor x]];
                _yAccelerometerLabel.text = [NSString stringWithFormat:@"%.1f", [sensor y]];
                _zAccelerometerLabel.text = [NSString stringWithFormat:@"%.1f", [sensor z]];
                _pasInfraredLabel.text = [NSString stringWithFormat:@"%.1f", [sensor pasInfrared]];
                self.view.backgroundColor = [UIColor colorWithRed:(52.f/255.f) green:(80.f/255.f) blue:(159.f/255.f) alpha:1.f];
            }
        } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_SENTRY_SENSOR_X]) {
            self.lastUpdateLabel.text = @"Just now";
            if ([self.lastUpdateTimer isValid]) {
                [self.lastUpdateTimer invalidate];
            }
            self.lastUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:15.0 target:self selector:@selector(refreshLastUpdateLabel) userInfo:nil repeats:YES];
            
            if (self.sensor.peripheral) {
                _xAccelerometerLabel.text = [NSString stringWithFormat:@"%.1f", [[change objectForKey:NSKeyValueChangeNewKey] floatValue]];
            }
        } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_SENTRY_SENSOR_Y]) {
            self.lastUpdateLabel.text = @"Just now";
            if ([self.lastUpdateTimer isValid]) {
                [self.lastUpdateTimer invalidate];
            }
            self.lastUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:15.0 target:self selector:@selector(refreshLastUpdateLabel) userInfo:nil repeats:YES];
            
            if (self.sensor.peripheral) {
                _yAccelerometerLabel.text = [NSString stringWithFormat:@"%.1f", [[change objectForKey:NSKeyValueChangeNewKey] floatValue]];
            }
        } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_SENTRY_SENSOR_Z]) {
            self.lastUpdateLabel.text = @"Just now";
            if ([self.lastUpdateTimer isValid]) {
                [self.lastUpdateTimer invalidate];
            }
            self.lastUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:15.0 target:self selector:@selector(refreshLastUpdateLabel) userInfo:nil repeats:YES];
            
            if (self.sensor.peripheral) {
                _zAccelerometerLabel.text = [NSString stringWithFormat:@"%.1f", [[change objectForKey:NSKeyValueChangeNewKey] floatValue]];
            }
            //        [self.sensor.entity latestValuesWithType:kValueTypeAccelerometer completionHandler:^(NSArray *result) {
            //            _accelerometerSparkLine.dataValues = result;
            //        }];
        } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_SENTRY_SENSOR_PASSIVE_INFRARED]) {
            if (self.sensor.peripheral) {                
                int pir = 0;
                
                NSObject *pirObject = [change objectForKey:NSKeyValueChangeNewKey];
                if ([pirObject isKindOfClass:[NSNumber class]]) {
                    pir = [(NSNumber*)pirObject intValue];
                }
                
                if (pir == 0) {
                    _pasInfraredLabel.text = @"No movement";
                } else {
                    _pasInfraredLabel.text = @"Movement";
                }
                
                
                
                
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
        else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_SENTRY_SENSOR_ACCELEROMETER_ALARM_ENABLED]) {
            [_accelerometerAlarmEnabledLabel setDate:[(SentrySensor *)self.sensor accelerometerAlarmEnabledTime]];
        }
        else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_SENTRY_SENSOR_ACCELEROMETER_ALARM_DISABLED]) {
            [_accelerometerAlarmDisabledLabel setDate:[(SentrySensor *)self.sensor accelerometerAlarmDisabledTime]];
        }
        else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_SENTRY_SENSOR_INFRARED_ALARM_ENABLED]) {
            [_pasInfraredAlarmEnabledLabel setDate:[(SentrySensor *)self.sensor infraredAlarmEnabledTime]];
        }
        else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_SENTRY_SENSOR_INFRARED_ALARM_DISABLED]) {
            [_pasInfraredAlarmDisabledLabel setDate:[(SentrySensor *)self.sensor infraredAlarmDisabledTime]];
        }
    });
}

@end
