//
//  ThermoSensorDetailsViewController.m
//  Wimoto
//
//  Created by MC700 on 12/3/13.
//
//

#import "ThermoSensorDetailsViewController.h"

@interface ThermoSensorDetailsViewController ()

@end

@implementation ThermoSensorDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = YES;
    
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_THERMO_SENSOR_IR_TEMP options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_THERMO_SENSOR_PROBE_TEMP options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_THERMO_SENSOR_IR_TEMP_ALARM_STATE options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_THERMO_SENSOR_PROBE_TEMP_ALARM_STATE options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_THERMO_SENSOR_IR_TEMP_ALARM_LOW options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_THERMO_SENSOR_IR_TEMP_ALARM_HIGH options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_THERMO_SENSOR_PROBE_TEMP_ALARM_LOW options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_THERMO_SENSOR_PROBE_TEMP_ALARM_HIGH options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    
    _irTempSparkLine.labelText = @"";
    _irTempSparkLine.showCurrentValue = NO;
    [self.sensor.entity latestValuesWithType:kValueTypeIRTemperature completionHandler:^(NSArray *result) {
        _irTempSparkLine.dataValues = result;
    }];
    _probeTempSparkLine.labelText = @"";
    _probeTempSparkLine.showCurrentValue = NO;
    [self.sensor.entity latestValuesWithType:kValueTypeProbeTemperature completionHandler:^(NSArray *result) {
        _probeTempSparkLine.dataValues = result;
    }];
    
    _irTempSlider = [[AlarmSlider alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height, self.view.frame.size.width, 100.0)];
    [self.view addSubview:_irTempSlider];
    _irTempSlider.delegate = self;
    [_irTempSlider setSliderRange:0];
    [_irTempSlider setMinimumValue:-60];
    [_irTempSlider setMaximumValue:130];
    [_irTempSlider setStepValue:0.1 animated:NO];
    
    _probeTempSlider = [[AlarmSlider alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height, self.view.frame.size.width, 100.0)];
    [self.view addSubview:_probeTempSlider];
    _probeTempSlider.delegate = self;
    [_probeTempSlider setSliderRange:0];
    [_probeTempSlider setMinimumValue:10];
    [_probeTempSlider setMaximumValue:50];
    [_probeTempSlider setStepValue:0.1 animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    @try {
        [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_THERMO_SENSOR_IR_TEMP];
        [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_THERMO_SENSOR_PROBE_TEMP];
        
        [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_THERMO_SENSOR_IR_TEMP_ALARM_STATE];
        [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_THERMO_SENSOR_PROBE_TEMP_ALARM_STATE];
        
        [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_THERMO_SENSOR_IR_TEMP_ALARM_LOW];
        [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_THERMO_SENSOR_IR_TEMP_ALARM_HIGH];
        
        [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_THERMO_SENSOR_PROBE_TEMP_ALARM_LOW];
        [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_THERMO_SENSOR_PROBE_TEMP_ALARM_HIGH];
    }
    @catch (NSException *exception) {
        // No need to handle just prevent app crash
    }
}

- (IBAction)irTempAlarmAction:(id)sender {
    [self.sensor enableAlarm:[sender isOn] forCharacteristicWithUUIDString:BLE_THERMO_SERVICE_UUID_IR_TEMPERATURE_ALARM_SET];
    ([sender isOn])?[_irTempSlider showAction]:[_irTempSlider hideAction:nil];
}

- (IBAction)probeTempAlarmAction:(id)sender {
    [self.sensor enableAlarm:[sender isOn] forCharacteristicWithUUIDString:BLE_THERMO_SERVICE_UUID_PROBE_TEMPERATURE_ALARM_SET];
    ([sender isOn])?[_probeTempSlider showAction]:[_probeTempSlider hideAction:nil];
}

#pragma mark - AlarmSliderDelegate

- (void)alarmSliderSaveAction:(id)sender {
    if ([sender isEqual:_irTempSlider]) {
        [self.sensor writeAlarmValue:_irTempSlider.upperValue forCharacteristicWithUUIDString:BLE_THERMO_SERVICE_UUID_IR_TEMPERATURE_ALARM_HIGH_VALUE];
        [self.sensor writeAlarmValue:_irTempSlider.lowerValue forCharacteristicWithUUIDString:BLE_THERMO_SERVICE_UUID_IR_TEMPERATURE_ALARM_LOW_VALUE];
        _irTempHighValueLabel.text = [NSString stringWithFormat:@"%.f", _irTempSlider.upperValue];
        _irTempLowValueLabel.text = [NSString stringWithFormat:@"%.f", _irTempSlider.lowerValue];
    } else if ([sender isEqual:_probeTempSlider]) {
        [self.sensor writeAlarmValue:_probeTempSlider.upperValue forCharacteristicWithUUIDString:BLE_THERMO_SERVICE_UUID_PROBE_TEMPERATURE_ALARM_HIGH_VALUE];
        [self.sensor writeAlarmValue:_probeTempSlider.lowerValue forCharacteristicWithUUIDString:BLE_THERMO_SERVICE_UUID_PROBE_TEMPERATURE_ALARM_LOW_VALUE];
        _probeTempHighValueLabel.text = [NSString stringWithFormat:@"%.f", _probeTempSlider.upperValue];
        _probeTempLowValueLabel.text = [NSString stringWithFormat:@"%.f", _probeTempSlider.lowerValue];
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
            _irTempLabel.text = SENSOR_VALUE_PLACEHOLDER;
            _probeTempLabel.text = SENSOR_VALUE_PLACEHOLDER;
        } else {
            ThermoSensor *sensor = (ThermoSensor*)self.sensor;
            _irTempLabel.text = [NSString stringWithFormat:@"%.1f", [sensor irTemp]];
            _probeTempLabel.text = [NSString stringWithFormat:@"%.1f", [sensor probeTemp]];
            self.view.backgroundColor = [UIColor colorWithRed:(255.f/255.f) green:(159.f/255.f) blue:(17.f/255.f) alpha:1.f];
        }
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_THERMO_SENSOR_IR_TEMP]) {
        float value = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
        
        self.lastUpdateLabel.text = @"Just now";
        if ([self.lastUpdateTimer isValid]) {
            [self.lastUpdateTimer invalidate];
        }
        self.lastUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:15.0 target:self selector:@selector(refreshLastUpdateLabel) userInfo:nil repeats:YES];
        
        if (self.sensor.peripheral) {
            _irTempLabel.text = [NSString stringWithFormat:@"%.1f", value];
        }
        [self.sensor.entity latestValuesWithType:kValueTypeIRTemperature completionHandler:^(NSArray *result) {
            _irTempSparkLine.dataValues = result;
        }];
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_THERMO_SENSOR_PROBE_TEMP]) {
        float value = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
        
        if (self.sensor.peripheral) {
            _probeTempLabel.text = [NSString stringWithFormat:@"%.1f", value];
        }
        [self.sensor.entity latestValuesWithType:kValueTypeProbeTemperature completionHandler:^(NSArray *result) {
            _probeTempSparkLine.dataValues = result;
        }];
    }
    else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_THERMO_SENSOR_IR_TEMP_ALARM_STATE]) {
        _irTempSwitch.on = ([[change objectForKey:NSKeyValueChangeNewKey] intValue] == kAlarmStateEnabled)?YES:NO;
    }
    else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_THERMO_SENSOR_PROBE_TEMP_ALARM_STATE]) {
        _probeTempSwitch.on = ([[change objectForKey:NSKeyValueChangeNewKey] intValue] == kAlarmStateEnabled)?YES:NO;
    }
    else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_THERMO_SENSOR_IR_TEMP_ALARM_LOW]) {
        float value = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
        _irTempLowValueLabel.text = [NSString stringWithFormat:@"%.f", value];
        [_irTempSlider setLowerValue:value];
    }
    else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_THERMO_SENSOR_IR_TEMP_ALARM_HIGH]) {
        float value = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
        _irTempHighValueLabel.text = [NSString stringWithFormat:@"%.f", value];
        [_irTempSlider setUpperValue:value];
    }
    else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_THERMO_SENSOR_PROBE_TEMP_ALARM_LOW]) {
        float value = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
        _probeTempLowValueLabel.text = [NSString stringWithFormat:@"%.f", value];
        [_probeTempSlider setLowerValue:value];
    }
    else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_THERMO_SENSOR_PROBE_TEMP_ALARM_HIGH]) {
        float value = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
        _probeTempHighValueLabel.text = [NSString stringWithFormat:@"%.f", value];
        [_probeTempSlider setUpperValue:value];
    }
}

@end
