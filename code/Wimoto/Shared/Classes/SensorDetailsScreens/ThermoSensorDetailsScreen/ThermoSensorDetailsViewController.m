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
    [_irTempSlider setStepValue:0.1 animated:NO];
    
    _probeTempSlider = [[AlarmSlider alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height, self.view.frame.size.width, 100.0)];
    [self.view addSubview:_probeTempSlider];
    _probeTempSlider.delegate = self;
    [_probeTempSlider setSliderRange:0];
    [_probeTempSlider setStepValue:0.1 animated:NO];
    
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_THERMO_SENSOR_IR_TEMP options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_THERMO_SENSOR_PROBE_TEMP options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_SENSOR_TEMP_MEASURE options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_THERMO_SENSOR_IR_TEMP_ALARM_STATE options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_THERMO_SENSOR_PROBE_TEMP_ALARM_STATE options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_THERMO_SENSOR_IR_TEMP_ALARM_LOW options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_THERMO_SENSOR_IR_TEMP_ALARM_HIGH options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_THERMO_SENSOR_PROBE_TEMP_ALARM_LOW options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_THERMO_SENSOR_PROBE_TEMP_ALARM_HIGH options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    @try {
        [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_THERMO_SENSOR_IR_TEMP];
        [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_THERMO_SENSOR_PROBE_TEMP];
        
        [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_SENSOR_TEMP_MEASURE];
        
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
    [self.sensor enableAlarm:[sender isOn] forCharacteristicWithUUIDString:BLE_THERMO_CHAR_UUID_IR_TEMPERATURE_ALARM_SET];
    ([sender isOn])?[_irTempSlider showAction]:[_irTempSlider hideAction:nil];
}

- (IBAction)probeTempAlarmAction:(id)sender {
    [self.sensor enableAlarm:[sender isOn] forCharacteristicWithUUIDString:BLE_THERMO_CHAR_UUID_PROBE_TEMPERATURE_ALARM_SET];
    ([sender isOn])?[_probeTempSlider showAction]:[_probeTempSlider hideAction:nil];
}

#pragma mark - AlarmSliderDelegate

- (void)alarmSliderSaveAction:(id)sender {
    if ([sender isEqual:_irTempSlider]) {
        [self.sensor writeAlarmValue:_irTempSlider.upperValue forCharacteristicWithUUIDString:BLE_THERMO_CHAR_UUID_IR_TEMPERATURE_ALARM_HIGH_VALUE];
        [self.sensor writeAlarmValue:_irTempSlider.lowerValue forCharacteristicWithUUIDString:BLE_THERMO_CHAR_UUID_IR_TEMPERATURE_ALARM_LOW_VALUE];
        _irTempHighValueLabel.text = [NSString stringWithFormat:@"%.f", _irTempSlider.upperValue];
        _irTempLowValueLabel.text = [NSString stringWithFormat:@"%.f", _irTempSlider.lowerValue];
    } else if ([sender isEqual:_probeTempSlider]) {
        [self.sensor writeAlarmValue:_probeTempSlider.upperValue forCharacteristicWithUUIDString:BLE_THERMO_CHAR_UUID_PROBE_TEMPERATURE_ALARM_HIGH_VALUE];
        [self.sensor writeAlarmValue:_probeTempSlider.lowerValue forCharacteristicWithUUIDString:BLE_THERMO_CHAR_UUID_PROBE_TEMPERATURE_ALARM_LOW_VALUE];
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
    ThermoSensor *sensor = (ThermoSensor *)[self sensor];
    if ([keyPath isEqualToString:OBSERVER_KEY_PATH_SENSOR_PERIPHERAL]) {
        if ([[change objectForKey:NSKeyValueChangeNewKey] isKindOfClass:[NSNull class]]) {
            _irTempAlarmContainer.hidden = YES;
            _probeTempAlarmContainer.hidden = YES;
            [_irTempSlider hideAction:nil];
            [_probeTempSlider hideAction:nil];
            _irTempLabel.text = SENSOR_VALUE_PLACEHOLDER;
            _probeTempLabel.text = SENSOR_VALUE_PLACEHOLDER;
        } else {
            _irTempAlarmContainer.hidden = NO;
            _probeTempAlarmContainer.hidden = NO;
            _irTempLabel.text = [NSString stringWithFormat:@"%.1f", [sensor irTemp]];
            _probeTempLabel.text = [NSString stringWithFormat:@"%.1f", [sensor probeTemp]];
            self.view.backgroundColor = [UIColor colorWithRed:(255.f/255.f) green:(159.f/255.f) blue:(17.f/255.f) alpha:1.f];
        }
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_THERMO_SENSOR_IR_TEMP]) {
        self.lastUpdateLabel.text = @"Just now";
        if ([self.lastUpdateTimer isValid]) {
            [self.lastUpdateTimer invalidate];
        }
        self.lastUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:15.0 target:self selector:@selector(refreshLastUpdateLabel) userInfo:nil repeats:YES];
        
        if (self.sensor.peripheral) {
            _irTempLabel.text = [NSString stringWithFormat:@"%.1f", [sensor irTemp]];
        }
        [self.sensor.entity latestValuesWithType:kValueTypeIRTemperature completionHandler:^(NSArray *result) {
            _irTempSparkLine.dataValues = result;
        }];
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_THERMO_SENSOR_PROBE_TEMP]) {
        if (self.sensor.peripheral) {
            _probeTempLabel.text = [NSString stringWithFormat:@"%.1f", [sensor probeTemp]];
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
        _irTempLowValueLabel.text = [NSString stringWithFormat:@"%.f", [sensor irTempAlarmLow]];
        [_irTempSlider setLowerValue:[sensor irTempAlarmLow]];
    }
    else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_THERMO_SENSOR_IR_TEMP_ALARM_HIGH]) {
        _irTempHighValueLabel.text = [NSString stringWithFormat:@"%.f", [sensor irTempAlarmHigh]];
        [_irTempSlider setUpperValue:[sensor irTempAlarmHigh]];
    }
    else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_THERMO_SENSOR_PROBE_TEMP_ALARM_LOW]) {
        _probeTempLowValueLabel.text = [NSString stringWithFormat:@"%.f", [sensor probeTempAlarmLow]];
        [_probeTempSlider setLowerValue:[sensor probeTempAlarmLow]];
    }
    else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_THERMO_SENSOR_PROBE_TEMP_ALARM_HIGH]) {
        _probeTempHighValueLabel.text = [NSString stringWithFormat:@"%.f", [sensor probeTempAlarmHigh]];
        [_probeTempSlider setUpperValue:[sensor probeTempAlarmHigh]];
    }
    else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_SENSOR_TEMP_MEASURE]) {
        TemperatureMeasure tempMeasure = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
                
        _irTempConversionLabel.text = [sensor temperatureSymbol];
        _probeTempConversionLabel.text = [sensor temperatureSymbol];
        _irTempLabel.text = [NSString stringWithFormat:@"%.1f", [sensor irTemp]];
        _probeTempLabel.text = [NSString stringWithFormat:@"%.1f", [sensor probeTemp]];
        
        [_irTempSlider setMinimumValue:(tempMeasure == kTemperatureMeasureCelsius)?-60:[sensor convertToFahrenheit:-60]];
        [_irTempSlider setMaximumValue:(tempMeasure == kTemperatureMeasureCelsius)?130:[sensor convertToFahrenheit:130]];
        [_probeTempSlider setMinimumValue:(tempMeasure == kTemperatureMeasureCelsius)?-20:[sensor convertToFahrenheit:-20]];
        [_probeTempSlider setMaximumValue:(tempMeasure == kTemperatureMeasureCelsius)?50:[sensor convertToFahrenheit:50]];
        
        [_irTempSlider setUpperValue:sensor.irTempAlarmHigh];
        [_irTempSlider setLowerValue:sensor.irTempAlarmLow];
        [_probeTempSlider setUpperValue:sensor.probeTempAlarmHigh];
        [_probeTempSlider setLowerValue:sensor.probeTempAlarmLow];
        
        _irTempHighValueLabel.text = [NSString stringWithFormat:@"%.f", _irTempSlider.upperValue];
        _irTempLowValueLabel.text = [NSString stringWithFormat:@"%.f", _irTempSlider.lowerValue];
        _probeTempHighValueLabel.text = [NSString stringWithFormat:@"%.f", _probeTempSlider.upperValue];
        _probeTempLowValueLabel.text = [NSString stringWithFormat:@"%.f", _probeTempSlider.lowerValue];
    }
}

@end
