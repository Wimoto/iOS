//
//  GrowSensorDetailsViewController.m
//  Wimoto
//
//  Created by MC700 on 12/3/13.
//
//

#import "GrowSensorDetailsViewController.h"
#import "ASBSparkLineView.h"
#import "GrowSensor.h"

@interface GrowSensorDetailsViewController ()

@property (nonatomic, weak) IBOutlet UILabel *soilTempLabel;
@property (nonatomic, weak) IBOutlet UILabel *soilMoistureLabel;
@property (nonatomic, weak) IBOutlet UILabel *lightLabel;

@property (nonatomic, weak) IBOutlet ASBSparkLineView *soilTempSparkLine;
@property (nonatomic, weak) IBOutlet ASBSparkLineView *soilMoistureSparkLine;
@property (nonatomic, weak) IBOutlet ASBSparkLineView *lightSparkLine;

@property (nonatomic, weak) IBOutlet UISwitch *soilTempSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *soilMoistureSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *lightSwitch;

@property (nonatomic, weak) IBOutlet UILabel *soilTempHighValueLabel;
@property (nonatomic, weak) IBOutlet UILabel *soilTempLowValueLabel;
@property (nonatomic, weak) IBOutlet UILabel *soilMoistureHighValueLabel;
@property (nonatomic, weak) IBOutlet UILabel *soilMoistureLowValueLabel;
@property (nonatomic, weak) IBOutlet UILabel *lightHighValueLabel;
@property (nonatomic, weak) IBOutlet UILabel *lightLowValueLabel;

@property (nonatomic, weak) IBOutlet UIView *soilTempAlarmContainer;
@property (nonatomic, weak) IBOutlet UIView *soilMoistureAlarmContainer;
@property (nonatomic, weak) IBOutlet UIView *lightAlarmContainer;

@property (nonatomic, strong) AlarmSlider *soilTempSlider;
@property (nonatomic, strong) AlarmSlider *soilMoistureSlider;
@property (nonatomic, strong) AlarmSlider *lightSlider;

@property (nonatomic, strong) NSString *currentAlarmUUIDString;

- (IBAction)soilTempAlarmAction:(id)sender;
- (IBAction)soilMoistureAlarmAction:(id)sender;
- (IBAction)lightAlarmAction:(id)sender;

@end

@implementation GrowSensorDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = YES;
    
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_GROW_SENSOR_LIGHT options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_GROW_SENSOR_SOIL_MOISTURE options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_GROW_SENSOR_SOIL_TEMPERATURE options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_GROW_SENSOR_LIGHT_ALARM_STATE options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_GROW_SENSOR_SOIL_MOISTURE_ALARM_STATE options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_GROW_SENSOR_SOIL_TEMPERATURE_ALARM_STATE options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_GROW_SENSOR_LIGHT_ALARM_LOW options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_GROW_SENSOR_LIGHT_ALARM_HIGH options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_GROW_SENSOR_SOIL_MOISTURE_ALARM_LOW options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_GROW_SENSOR_SOIL_MOISTURE_ALARM_HIGH options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_GROW_SENSOR_SOIL_TEMPERATURE_ALARM_LOW options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_GROW_SENSOR_SOIL_TEMPERATURE_ALARM_HIGH options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    
    _soilTempSparkLine.labelText = @"";
    _soilTempSparkLine.showCurrentValue = NO;
    [self.sensor.entity latestValuesWithType:kValueTypeSoilTemperature completionHandler:^(NSArray *result) {
        _soilTempSparkLine.dataValues = result;
    }];
    
    _soilMoistureSparkLine.labelText = @"";
    _soilMoistureSparkLine.showCurrentValue = NO;
    [self.sensor.entity latestValuesWithType:kValueTypeSoilHumidity completionHandler:^(NSArray *result) {
        _soilMoistureSparkLine.dataValues = result;
    }];
    
    _lightSparkLine.labelText = @"";
    _lightSparkLine.showCurrentValue = NO;
    [self.sensor.entity latestValuesWithType:kValueTypeLight completionHandler:^(NSArray *result) {
        _lightSparkLine.dataValues = result;
    }];
    
    _soilTempSlider = [[AlarmSlider alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height, self.view.frame.size.width, 100.0)];
    [self.view addSubview:_soilTempSlider];
    _soilTempSlider.delegate = self;
    [_soilTempSlider setSliderRange:0];
    [_soilTempSlider setMinimumValue:-60];
    [_soilTempSlider setMaximumValue:130];
    
    _soilMoistureSlider = [[AlarmSlider alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height, self.view.frame.size.width, 100.0)];
    [self.view addSubview:_soilMoistureSlider];
    _soilMoistureSlider.delegate = self;
    [_soilMoistureSlider setSliderRange:0];
    [_soilMoistureSlider setMinimumValue:10];
    [_soilMoistureSlider setMaximumValue:50];
    
    _lightSlider = [[AlarmSlider alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height, self.view.frame.size.width, 100.0)];
    [self.view addSubview:_lightSlider];
    _lightSlider.delegate = self;
    [_lightSlider setSliderRange:0];
    [_lightSlider setMinimumValue:10];
    [_lightSlider setMaximumValue:50];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    @try {
        [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_GROW_SENSOR_LIGHT];
        [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_GROW_SENSOR_SOIL_MOISTURE];
        [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_GROW_SENSOR_SOIL_TEMPERATURE];
        
        [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_GROW_SENSOR_LIGHT_ALARM_STATE];
        [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_GROW_SENSOR_SOIL_MOISTURE_ALARM_STATE];
        [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_GROW_SENSOR_SOIL_TEMPERATURE_ALARM_STATE];
        
        [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_GROW_SENSOR_LIGHT_ALARM_LOW];
        [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_GROW_SENSOR_LIGHT_ALARM_HIGH];
        
        [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_GROW_SENSOR_SOIL_MOISTURE_ALARM_LOW];
        [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_GROW_SENSOR_SOIL_MOISTURE_ALARM_HIGH];
        
        [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_GROW_SENSOR_SOIL_TEMPERATURE_ALARM_LOW];
        [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_GROW_SENSOR_SOIL_TEMPERATURE_ALARM_HIGH];
    }
    @catch (NSException *exception) {
        // No need to handle just prevent app crash
    }
}

- (IBAction)soilTempAlarmAction:(id)sender {
    [self.sensor enableAlarm:[sender isOn] forCharacteristicWithUUIDString:BLE_GROW_SERVICE_UUID_SOIL_TEMPERATURE_ALARM_SET];
    ([sender isOn])?[_soilTempSlider showAction]:[_soilTempSlider hideAction:nil];
}

- (IBAction)soilMoistureAlarmAction:(id)sender {
    [self.sensor enableAlarm:[sender isOn] forCharacteristicWithUUIDString:BLE_GROW_SERVICE_UUID_SOIL_MOISTURE_ALARM_SET];
    ([sender isOn])?[_soilMoistureSlider showAction]:[_soilMoistureSlider hideAction:nil];
}

- (IBAction)lightAlarmAction:(id)sender {
    [self.sensor enableAlarm:[sender isOn] forCharacteristicWithUUIDString:BLE_GROW_SERVICE_UUID_LIGHT_ALARM_SET];
    ([sender isOn])?[_lightSlider showAction]:[_lightSlider hideAction:nil];
}

#pragma mark - AlarmSliderDelegate

- (void)alarmSliderSaveAction:(id)sender {
    if ([sender isEqual:_soilTempSlider]) {
        [self.sensor writeAlarmValue:_soilTempSlider.upperValue forCharacteristicWithUUIDString:BLE_GROW_SERVICE_UUID_SOIL_TEMPERATURE_ALARM_HIGH_VALUE];
        [self.sensor writeAlarmValue:_soilTempSlider.lowerValue forCharacteristicWithUUIDString:BLE_GROW_SERVICE_UUID_SOIL_TEMPERATURE_ALARM_LOW_VALUE];
        _soilTempHighValueLabel.text = [NSString stringWithFormat:@"%.f", _soilTempSlider.upperValue];
        _soilTempLowValueLabel.text = [NSString stringWithFormat:@"%.f", _soilTempSlider.lowerValue];
    } else if ([sender isEqual:_soilMoistureSlider]) {
        [self.sensor writeAlarmValue:_soilMoistureSlider.upperValue forCharacteristicWithUUIDString:BLE_GROW_SERVICE_UUID_SOIL_MOISTURE_ALARM_HIGH_VALUE];
        [self.sensor writeAlarmValue:_soilMoistureSlider.lowerValue forCharacteristicWithUUIDString:BLE_GROW_SERVICE_UUID_SOIL_MOISTURE_ALARM_LOW_VALUE];
        _soilMoistureHighValueLabel.text = [NSString stringWithFormat:@"%.f", _soilMoistureSlider.upperValue];
        _soilMoistureLowValueLabel.text = [NSString stringWithFormat:@"%.f", _soilMoistureSlider.lowerValue];
    } else if ([sender isEqual:_lightSlider]) {
        [self.sensor writeAlarmValue:_lightSlider.upperValue forCharacteristicWithUUIDString:BLE_GROW_SERVICE_UUID_LIGHT_ALARM_HIGH_VALUE];
        [self.sensor writeAlarmValue:_lightSlider.lowerValue forCharacteristicWithUUIDString:BLE_GROW_SERVICE_UUID_LIGHT_ALARM_LOW_VALUE];
        _lightHighValueLabel.text = [NSString stringWithFormat:@"%.f", _lightSlider.upperValue];
        _lightLowValueLabel.text = [NSString stringWithFormat:@"%.f", _lightSlider.lowerValue];
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
            _soilMoistureAlarmContainer.hidden = YES;
            _soilTempAlarmContainer.hidden = YES;
            _lightAlarmContainer.hidden = YES;
            [_soilMoistureSlider hideAction:nil];
            [_soilTempSlider hideAction:nil];
            [_lightSlider hideAction:nil];
            
            _soilTempLabel.text = SENSOR_VALUE_PLACEHOLDER;
            _soilMoistureLabel.text = SENSOR_VALUE_PLACEHOLDER;
            _lightLabel.text = SENSOR_VALUE_PLACEHOLDER;
        } else {
            _soilMoistureAlarmContainer.hidden = NO;
            _soilTempAlarmContainer.hidden = NO;
            _lightAlarmContainer.hidden = NO;
            GrowSensor *sensor = (GrowSensor*)self.sensor;
            _soilTempLabel.text = [NSString stringWithFormat:@"%.1f", [sensor soilTemperature]];
            _soilMoistureLabel.text = [NSString stringWithFormat:@"%.1f", [sensor soilMoisture]];
            _lightLabel.text = [NSString stringWithFormat:@"%.f", [sensor light]];
            self.view.backgroundColor = [UIColor colorWithRed:(153.f/255.f) green:(233.f/255.f) blue:(124.f/255.f) alpha:1.f];
        }
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_GROW_SENSOR_SOIL_TEMPERATURE]) {
        self.lastUpdateLabel.text = @"Just now";
        if ([self.lastUpdateTimer isValid]) {
            [self.lastUpdateTimer invalidate];
        }
        self.lastUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:15.0 target:self selector:@selector(refreshLastUpdateLabel) userInfo:nil repeats:YES];
        
        if (self.sensor.peripheral) {
            _soilTempLabel.text = [NSString stringWithFormat:@"%.1f", [[change objectForKey:NSKeyValueChangeNewKey] floatValue]];
        }
        [self.sensor.entity latestValuesWithType:kValueTypeSoilTemperature completionHandler:^(NSArray *result) {
            _soilTempSparkLine.dataValues = result;
        }];
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_GROW_SENSOR_SOIL_MOISTURE]) {
        if (self.sensor.peripheral) {
            _soilMoistureLabel.text = [NSString stringWithFormat:@"%.1f", [[change objectForKey:NSKeyValueChangeNewKey] floatValue]];
        }
        [self.sensor.entity latestValuesWithType:kValueTypeSoilHumidity completionHandler:^(NSArray *result) {
            _soilMoistureSparkLine.dataValues = result;
        }];
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_GROW_SENSOR_LIGHT]) {
        if (self.sensor.peripheral) {
            _lightLabel.text = [NSString stringWithFormat:@"%.f", [[change objectForKey:NSKeyValueChangeNewKey] floatValue]];
        }
        [self.sensor.entity latestValuesWithType:kValueTypeLight completionHandler:^(NSArray *result) {
            _lightSparkLine.dataValues = result;
        }];
    }
    else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_GROW_SENSOR_LIGHT_ALARM_STATE]) {
        _lightSwitch.on = ([[change objectForKey:NSKeyValueChangeNewKey] intValue] == kAlarmStateEnabled)?YES:NO;
    }
    else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_GROW_SENSOR_SOIL_MOISTURE_ALARM_STATE]) {
        _soilMoistureSwitch.on = ([[change objectForKey:NSKeyValueChangeNewKey] intValue] == kAlarmStateEnabled)?YES:NO;
    }
    else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_GROW_SENSOR_SOIL_TEMPERATURE_ALARM_STATE]) {
        _soilTempSwitch.on = ([[change objectForKey:NSKeyValueChangeNewKey] intValue] == kAlarmStateEnabled)?YES:NO;
    }
    else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_GROW_SENSOR_LIGHT_ALARM_LOW]) {
        float value = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
        _lightLowValueLabel.text = [NSString stringWithFormat:@"%.f", value];
        [_lightSlider setLowerValue:value];
    }
    else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_GROW_SENSOR_LIGHT_ALARM_HIGH]) {
        float value = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
        _lightHighValueLabel.text = [NSString stringWithFormat:@"%.f", value];
        [_lightSlider setUpperValue:value];
    }
    else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_GROW_SENSOR_SOIL_MOISTURE_ALARM_LOW]) {
        float value = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
        _soilMoistureLowValueLabel.text = [NSString stringWithFormat:@"%.f", value];
        [_soilMoistureSlider setLowerValue:value];
    }
    else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_GROW_SENSOR_SOIL_MOISTURE_ALARM_HIGH]) {
        float value = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
        _soilMoistureHighValueLabel.text = [NSString stringWithFormat:@"%.f", value];
        [_soilMoistureSlider setUpperValue:value];
    }
    else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_GROW_SENSOR_SOIL_TEMPERATURE_ALARM_LOW]) {
        float value = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
        _soilTempLowValueLabel.text = [NSString stringWithFormat:@"%.f", value];
        [_soilTempSlider setLowerValue:value];
    }
    else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_GROW_SENSOR_SOIL_TEMPERATURE_ALARM_HIGH]) {
        float value = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
        _soilTempHighValueLabel.text = [NSString stringWithFormat:@"%.f", value];
        [_soilTempSlider setUpperValue:value];
    }
}

@end
