//
//  WaterSensorDetailsViewController.m
//  Wimoto
//
//  Created by MC700 on 12/3/13.
//
//

#import "WaterSensorDetailsViewController.h"
#import "ASBSparkLineView.h"
#import "WaterSensor.h"

@interface WaterSensorDetailsViewController ()

@property (nonatomic, weak) IBOutlet UILabel *levelLabel;
@property (nonatomic, weak) IBOutlet UILabel *contactLabel;
@property (nonatomic, weak) IBOutlet ASBSparkLineView *levelSparkLine;

@property (nonatomic, weak) IBOutlet UISwitch *contactSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *levelSwitch;

@property (nonatomic, weak) IBOutlet UILabel *levelLowValueLabel;
@property (nonatomic, weak) IBOutlet UILabel *levelHighValueLabel;

@property (nonatomic, weak) IBOutlet UIView *levelAlarmContainer;
@property (nonatomic, weak) IBOutlet UIView *contactAlarmContainer;

@property (nonatomic, strong) AlarmSlider *levelSlider;

@property (nonatomic, strong) NSString *currentAlarmUUIDString;

- (IBAction)levelAlarmAction:(id)sender;

@end

@implementation WaterSensorDetailsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = YES;
    
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_WATER_SENSOR_LEVEL options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_WATER_SENSOR_PRESENCE options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_WATER_SENSOR_LEVEL_ALARM_STATE options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_WATER_SENSOR_PRESENSE_ALARM_STATE options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_WATER_SENSOR_LEVEL_ALARM_LOW options:NSKeyValueObservingOptionNew context:NULL];
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_WATER_SENSOR_LEVEL_ALARM_HIGH options:NSKeyValueObservingOptionNew context:NULL];
    
    _levelSparkLine.labelText = @"";
    _levelSparkLine.showCurrentValue = NO;
    [self.sensor.entity latestValuesWithType:kValueTypeLevel completionHandler:^(NSArray *result) {
        _levelSparkLine.dataValues = result;
    }];
    
    _levelSlider = [[AlarmSlider alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height, self.view.frame.size.width, 100.0)];
    [self.view addSubview:_levelSlider];
    _levelSlider.delegate = self;
    [_levelSlider setSliderRange:0];
    [_levelSlider setMinimumValue:-60];
    [_levelSlider setMaximumValue:130];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    @try {
        [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_WATER_SENSOR_LEVEL];
        [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_WATER_SENSOR_PRESENCE];
        [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_WATER_SENSOR_LEVEL_ALARM_STATE];
        [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_WATER_SENSOR_PRESENSE_ALARM_STATE];
        [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_WATER_SENSOR_LEVEL_ALARM_LOW];
        [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_WATER_SENSOR_LEVEL_ALARM_HIGH];
    }
    @catch (NSException *exception) {
        // No need to handle just prevent app crash
    }
}

- (IBAction)levelAlarmAction:(id)sender {
    [self.sensor enableAlarm:[sender isOn] forCharacteristicWithUUIDString:BLE_WATER_SERVICE_UUID_LEVEL_ALARM_SET];
    ([sender isOn])?[_levelSlider showAction]:[_levelSlider hideAction:nil];
}

#pragma mark - AlarmSliderDelegate

- (void)alarmSliderSaveAction:(id)sender {
    if ([sender isEqual:_levelSlider]) {
        [self.sensor writeAlarmValue:_levelSlider.upperValue forCharacteristicWithUUIDString:BLE_WATER_SERVICE_UUID_LEVEL_ALARM_HIGH_VALUE];
        [self.sensor writeAlarmValue:_levelSlider.lowerValue forCharacteristicWithUUIDString:BLE_WATER_SERVICE_UUID_LEVEL_ALARM_LOW_VALUE];
        
        _levelLowValueLabel.text = [NSString stringWithFormat:@"%.f", _levelSlider.upperValue];
        _levelHighValueLabel.text = [NSString stringWithFormat:@"%.f", _levelSlider.lowerValue];
    }
}

#pragma mark - Value Observer

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    
    if ([keyPath isEqualToString:OBSERVER_KEY_PATH_SENSOR_PERIPHERAL]) {
        if ([[change objectForKey:NSKeyValueChangeNewKey] isKindOfClass:[NSNull class]]) {
            _levelAlarmContainer.hidden = YES;
            _contactAlarmContainer.hidden = YES;
            [_levelSlider hideAction:nil];
            _levelLabel.text = SENSOR_VALUE_PLACEHOLDER;
            _contactLabel.text = SENSOR_VALUE_PLACEHOLDER;
        } else {
            _levelAlarmContainer.hidden = NO;
            _contactAlarmContainer.hidden = NO;
            WaterSensor *sensor = (WaterSensor*)self.sensor;
            _levelLabel.text = [NSString stringWithFormat:@"%.1f", [sensor level]];
            _contactLabel.text = ([sensor presense])?@"Wet":@"Dry";
            self.view.backgroundColor = [UIColor colorWithRed:(102.f/255.f) green:(204.f/255.f) blue:(255.f/255.f) alpha:1.f];
        }
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_WATER_SENSOR_LEVEL]) {
        self.lastUpdateLabel.text = @"Just now";
        if ([self.lastUpdateTimer isValid]) {
            [self.lastUpdateTimer invalidate];
        }
        self.lastUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:15.0 target:self selector:@selector(refreshLastUpdateLabel) userInfo:nil repeats:YES];
        NSNumber *level = [change objectForKey:NSKeyValueChangeNewKey];
        
        if (self.sensor.peripheral) {
            _levelLabel.text = [NSString stringWithFormat:@"%.1f", [level floatValue]];
        }
        [self.sensor.entity latestValuesWithType:kValueTypeLevel completionHandler:^(NSArray *result) {
            _levelSparkLine.dataValues = result;
        }];
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_WATER_SENSOR_PRESENCE]) {
        if (self.sensor.peripheral) {
            _contactLabel.text = ([[change objectForKey:NSKeyValueChangeNewKey] boolValue])?@"Wet":@"Dry";
        }
    }
    else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_WATER_SENSOR_LEVEL_ALARM_STATE]) {
        _levelSwitch.on = ([[change objectForKey:NSKeyValueChangeNewKey] intValue] == kAlarmStateEnabled)?YES:NO;
    }
    else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_WATER_SENSOR_PRESENSE_ALARM_STATE]) {
        _contactSwitch.on = ([[change objectForKey:NSKeyValueChangeNewKey] intValue] == kAlarmStateEnabled)?YES:NO;
    }
    else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_WATER_SENSOR_LEVEL_ALARM_LOW]) {
        float value = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
        _levelLowValueLabel.text = [NSString stringWithFormat:@"%.f", value];
        [_levelSlider setLowerValue:value];
    }
    else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_WATER_SENSOR_LEVEL_ALARM_HIGH]) {
        float value = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
        _levelHighValueLabel.text = [NSString stringWithFormat:@"%.f", value];
        [_levelSlider setUpperValue:value];
    }
}

@end
