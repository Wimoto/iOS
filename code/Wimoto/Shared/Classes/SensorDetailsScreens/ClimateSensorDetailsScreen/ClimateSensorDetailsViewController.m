//
//  ClimateSensorDetailsViewController.m
//  Wimoto
//
//  Created by MC700 on 12/3/13.
//
//

#import "ClimateSensorDetailsViewController.h"

@interface ClimateSensorDetailsViewController ()

@end

@implementation ClimateSensorDetailsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = YES;
    
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_CLIMATE_SENSOR_TEMPERATURE options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_CLIMATE_SENSOR_HUMIDITY options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_CLIMATE_SENSOR_LIGHT options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_CLIMATE_SENSOR_TEMPERATURE_ALARM_STATE options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_CLIMATE_SENSOR_HUMIDITY_ALARM_STATE options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_CLIMATE_SENSOR_LIGHT_ALARM_STATE options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_CLIMATE_SENSOR_TEMPERATURE_ALARM_LOW options:NSKeyValueObservingOptionNew context:NULL];
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_CLIMATE_SENSOR_TEMPERATURE_ALARM_HIGH options:NSKeyValueObservingOptionNew context:NULL];
    
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_CLIMATE_SENSOR_HUMIDITY_ALARM_LOW options:NSKeyValueObservingOptionNew context:NULL];
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_CLIMATE_SENSOR_HUMIDITY_ALARM_HIGH options:NSKeyValueObservingOptionNew context:NULL];

    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_CLIMATE_SENSOR_LIGHT_ALARM_LOW options:NSKeyValueObservingOptionNew context:NULL];
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_CLIMATE_SENSOR_LIGHT_ALARM_HIGH options:NSKeyValueObservingOptionNew context:NULL];
    
    _temperatureSparkLine.labelText = @"";
    _temperatureSparkLine.showCurrentValue = NO;
    _temperatureSparkLine.currentValueColor = [UIColor redColor];
    [self.sensor.entity latestValuesWithType:kValueTypeTemperature completionHandler:^(NSArray *result) {
        _temperatureSparkLine.dataValues = result;
    }];
    
    _humiditySparkLine.labelText = @"";
    _humiditySparkLine.showCurrentValue = NO;
    [self.sensor.entity latestValuesWithType:kValueTypeHumidity completionHandler:^(NSArray *result) {
        _humiditySparkLine.dataValues = result;
    }];
    
    _lightSparkLine.labelText = @"";
    _lightSparkLine.showCurrentValue = NO;
    [self.sensor.entity latestValuesWithType:kValueTypeLight completionHandler:^(NSArray *result) {
        _lightSparkLine.dataValues = result;
    }];
    
    _temperatureSlider = [[AlarmSlider alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height, self.view.frame.size.width, 100.0)];
    [self.view addSubview:_temperatureSlider];
    _temperatureSlider.delegate = self;
    [_temperatureSlider setSliderRange:0];
    [_temperatureSlider setStepValue:0.1 animated:NO];
    [_temperatureSlider setMinimumValue:-60];
    [_temperatureSlider setMaximumValue:130];
    
    _humiditySlider = [[AlarmSlider alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height, self.view.frame.size.width, 100.0)];
    [self.view addSubview:_humiditySlider];
    _humiditySlider.delegate = self;
    [_humiditySlider setSliderRange:0];
    [_humiditySlider setMinimumValue:10];
    [_humiditySlider setMaximumValue:50];
    
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
        [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_CLIMATE_SENSOR_TEMPERATURE];
        [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_CLIMATE_SENSOR_HUMIDITY];
        [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_CLIMATE_SENSOR_LIGHT];

        [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_CLIMATE_SENSOR_TEMPERATURE_ALARM_STATE];
        [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_CLIMATE_SENSOR_HUMIDITY_ALARM_STATE];
        [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_CLIMATE_SENSOR_LIGHT_ALARM_STATE];
        
        [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_CLIMATE_SENSOR_TEMPERATURE_ALARM_LOW];
        [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_CLIMATE_SENSOR_TEMPERATURE_ALARM_HIGH];

        [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_CLIMATE_SENSOR_HUMIDITY_ALARM_LOW];
        [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_CLIMATE_SENSOR_HUMIDITY_ALARM_HIGH];

        [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_CLIMATE_SENSOR_LIGHT_ALARM_LOW];
        [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_CLIMATE_SENSOR_LIGHT_ALARM_HIGH];
    }
    @catch (NSException *exception) {
        // No need to handle just prevent app crash
    }
}

- (IBAction)temperatureAlarmAction:(id)sender {
    [self.sensor enableAlarm:[sender isOn] forCharacteristicWithUUIDString:BLE_CLIMATE_SERVICE_UUID_TEMPERATURE_ALARM_SET];
    
    ([sender isOn])?[_temperatureSlider showAction]:[_temperatureSlider hideAction:nil];
}

- (IBAction)humidityAlarmAction:(id)sender {
    [self.sensor enableAlarm:[sender isOn] forCharacteristicWithUUIDString:BLE_CLIMATE_SERVICE_UUID_HUMIDITY_ALARM_SET];
    
    ([sender isOn])?[_humiditySlider showAction]:[_humiditySlider hideAction:nil];
}

- (IBAction)lightAlarmAction:(id)sender {
    [self.sensor enableAlarm:[sender isOn] forCharacteristicWithUUIDString:BLE_CLIMATE_SERVICE_UUID_LIGHT_ALARM_SET];
    
    ([sender isOn])?[_lightSlider showAction]:[_lightSlider hideAction:nil];
}

#pragma mark - AlarmSliderDelegate

- (void)alarmSliderSaveAction:(id)sender {
    if ([sender isEqual:_temperatureSlider]) {
        [self.sensor writeAlarmValue:_temperatureSlider.upperValue forCharacteristicWithUUIDString:BLE_CLIMATE_SERVICE_UUID_TEMPERATURE_ALARM_HIGH_VALUE];
        [self.sensor writeAlarmValue:_temperatureSlider.lowerValue forCharacteristicWithUUIDString:BLE_CLIMATE_SERVICE_UUID_TEMPERATURE_ALARM_LOW_VALUE];
        
        _tempHighValueLabel.text = [NSString stringWithFormat:@"%.f", _temperatureSlider.upperValue];
        _tempLowValueLabel.text = [NSString stringWithFormat:@"%.f", _temperatureSlider.lowerValue];
    } else if ([sender isEqual:_humiditySlider]) {
        [self.sensor writeAlarmValue:_humiditySlider.upperValue forCharacteristicWithUUIDString:BLE_CLIMATE_SERVICE_UUID_HUMIDITY_ALARM_HIGH_VALUE];
        [self.sensor writeAlarmValue:_temperatureSlider.lowerValue forCharacteristicWithUUIDString:BLE_CLIMATE_SERVICE_UUID_HUMIDITY_ALARM_LOW_VALUE];
        
        _humidityHighValueLabel.text = [NSString stringWithFormat:@"%.f", _humiditySlider.upperValue];
        _humidityLowValueLabel.text = [NSString stringWithFormat:@"%.f", _humiditySlider.lowerValue];
    } else if ([sender isEqual:_lightSlider]) {
        [self.sensor writeAlarmValue:_lightSlider.upperValue forCharacteristicWithUUIDString:BLE_CLIMATE_SERVICE_UUID_LIGHT_ALARM_HIGH_VALUE];
        [self.sensor writeAlarmValue:_lightSlider.lowerValue forCharacteristicWithUUIDString:BLE_CLIMATE_SERVICE_UUID_LIGHT_ALARM_LOW_VALUE];
        
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
            _tempHighValueLabel.hidden = YES;
            _humidityHighValueLabel.hidden = YES;
            _lightHighValueLabel.hidden = YES;
            _tempLowValueLabel.hidden = YES;
            _humidityLowValueLabel.hidden = YES;
            _lightLowValueLabel.hidden = YES;
            _tempSwitch.hidden = YES;
            _humiditySwitch.hidden = YES;
            _lightSwitch.hidden = YES;
            _tempAlarmImage.hidden = YES;
            _humidityAlarmImage.hidden = YES;
            _lightAlarmImage.hidden = YES;
            [_temperatureSlider hideAction:nil];
            [_humiditySlider hideAction:nil];
            [_lightSlider hideAction:nil];
            _tempLabel.text = SENSOR_VALUE_PLACEHOLDER;
            _humidityLabel.text = SENSOR_VALUE_PLACEHOLDER;
            _lightLabel.text = SENSOR_VALUE_PLACEHOLDER;
        } else {
            _tempHighValueLabel.hidden = NO;
            _humidityHighValueLabel.hidden = NO;
            _lightHighValueLabel.hidden = NO;
            _tempLowValueLabel.hidden = NO;
            _humidityLowValueLabel.hidden = NO;
            _lightLowValueLabel.hidden = NO;
            _tempSwitch.hidden = NO;
            _humiditySwitch.hidden = NO;
            _lightSwitch.hidden = NO;
            _tempAlarmImage.hidden = NO;
            _humidityAlarmImage.hidden = NO;
            _lightAlarmImage.hidden = NO;
            ClimateSensor *sensor = (ClimateSensor*)self.sensor;
            _tempLabel.text = [NSString stringWithFormat:@"%.1f", roundToOne([sensor temperature])];
            _humidityLabel.text = [NSString stringWithFormat:@"%.1f", roundToOne([sensor humidity])];
            _lightLabel.text = [NSString stringWithFormat:@"%.f", [sensor light]];
            
            self.view.backgroundColor = [UIColor colorWithRed:(102.f/255.f) green:(204.f/255.f) blue:(255.f/255.f) alpha:1.f];
        }
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_CLIMATE_SENSOR_TEMPERATURE]) {
        self.lastUpdateLabel.text = @"Just now";
        if ([self.lastUpdateTimer isValid]) {
            [self.lastUpdateTimer invalidate];
        }
        self.lastUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:15.0 target:self selector:@selector(refreshLastUpdateLabel) userInfo:nil repeats:YES];
        
        if (self.sensor.peripheral) {
            _tempLabel.text = [NSString stringWithFormat:@"%.1f", roundToOne([[change objectForKey:NSKeyValueChangeNewKey] floatValue])];
        }
        [self.sensor.entity latestValuesWithType:kValueTypeTemperature completionHandler:^(NSArray *result) {
            _temperatureSparkLine.dataValues = result;
        }];
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_CLIMATE_SENSOR_HUMIDITY]) {
        if (self.sensor.peripheral) {
            _humidityLabel.text = [NSString stringWithFormat:@"%.1f", roundToOne([[change objectForKey:NSKeyValueChangeNewKey] floatValue])];
        }
        [self.sensor.entity latestValuesWithType:kValueTypeHumidity completionHandler:^(NSArray *result) {
            _humiditySparkLine.dataValues = result;
        }];
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_CLIMATE_SENSOR_LIGHT]) {
        if (self.sensor.peripheral) {
            _lightLabel.text = [NSString stringWithFormat:@"%.f", [[change objectForKey:NSKeyValueChangeNewKey] floatValue]];
        }
        [self.sensor.entity latestValuesWithType:kValueTypeLight completionHandler:^(NSArray *result) {
            _lightSparkLine.dataValues = result;
        }];
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_CLIMATE_SENSOR_TEMPERATURE_ALARM_STATE]) {
        _tempSwitch.on = ([[change objectForKey:NSKeyValueChangeNewKey] intValue] == kAlarmStateEnabled)?YES:NO;
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_CLIMATE_SENSOR_HUMIDITY_ALARM_STATE]) {
        _humiditySwitch.on = ([[change objectForKey:NSKeyValueChangeNewKey] intValue] == kAlarmStateEnabled)?YES:NO;
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_CLIMATE_SENSOR_LIGHT_ALARM_STATE]) {
        _lightSwitch.on = ([[change objectForKey:NSKeyValueChangeNewKey] intValue] == kAlarmStateEnabled)?YES:NO;
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_CLIMATE_SENSOR_TEMPERATURE_ALARM_LOW]) {
        float value = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
        _tempLowValueLabel.text = [NSString stringWithFormat:@"%.f", value];
        [_temperatureSlider setLowerValue:value];
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_CLIMATE_SENSOR_TEMPERATURE_ALARM_HIGH]) {
        float value = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
        _tempHighValueLabel.text = [NSString stringWithFormat:@"%.f", value];
        [_temperatureSlider setUpperValue:value];
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_CLIMATE_SENSOR_HUMIDITY_ALARM_LOW]) {
        float value = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
        _humidityLowValueLabel.text = [NSString stringWithFormat:@"%.f", value];
        [_humiditySlider setLowerValue:value];
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_CLIMATE_SENSOR_HUMIDITY_ALARM_HIGH]) {
        float value = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
        _humidityHighValueLabel.text = [NSString stringWithFormat:@"%.f", value];
        [_humiditySlider setUpperValue:value];
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_CLIMATE_SENSOR_LIGHT_ALARM_LOW]) {
        float value = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
        _lightLowValueLabel.text = [NSString stringWithFormat:@"%.f", value];
        [_lightSlider setLowerValue:value];
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_CLIMATE_SENSOR_LIGHT_ALARM_HIGH]) {
        float value = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
        _lightHighValueLabel.text = [NSString stringWithFormat:@"%.f", value];
        [_lightSlider setUpperValue:value];
    }
}

@end
