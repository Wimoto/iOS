//
//  ClimateSensorDetailsViewController.m
//  Wimoto
//
//  Created by MC700 on 12/3/13.
//
//

#import "ClimateSensorDetailsViewController.h"
#import "WPPickerView.h"

@interface ClimateSensorDetailsViewController ()

@end

@implementation ClimateSensorDetailsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = YES;
    
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
    
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_SENSOR_TEMP_MEASURE options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    @try {
        [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_SENSOR_TEMP_MEASURE];
        
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
    ClimateSensor *sensor = (ClimateSensor *)self.sensor;
    if (_tempSwitch.on) {
        TemperatureMeasure tempMeasure = sensor.tempMeasure;
        float minValue = -25.0;
        float maxValue = 125.0;
        if (tempMeasure == kTemperatureMeasureFahrenheit) {
            minValue = [sensor convertToFahrenheit:minValue];
            maxValue = [sensor convertToFahrenheit:maxValue];
        }
        WPPickerView *pickerView = [WPPickerView showWithMinValue:minValue maxValue:maxValue save:^(float lowerValue, float upperValue) {
            [sensor enableAlarm:YES forCharacteristicWithUUIDString:BLE_CLIMATE_CHAR_UUID_TEMPERATURE_ALARM_SET];
            
            sensor.temperatureAlarmLow = lowerValue;
            sensor.temperatureAlarmHigh = upperValue;
            
            [sensor writeAlarmValue:upperValue forCharacteristicWithUUIDString:BLE_CLIMATE_CHAR_UUID_TEMPERATURE_ALARM_HIGH_VALUE];
            [sensor writeAlarmValue:lowerValue forCharacteristicWithUUIDString:BLE_CLIMATE_CHAR_UUID_TEMPERATURE_ALARM_LOW_VALUE];
        } cancel:^{
            //[_tempSwitch setOn:NO animated:YES];
        }];
        [pickerView setLowerValue:sensor.temperatureAlarmLow];
        [pickerView setUpperValue:sensor.temperatureAlarmHigh];
    }
    else {
        [sensor enableAlarm:NO forCharacteristicWithUUIDString:BLE_CLIMATE_CHAR_UUID_TEMPERATURE_ALARM_SET];
    }
}

- (IBAction)humidityAlarmAction:(id)sender {
    ClimateSensor *sensor = (ClimateSensor *)self.sensor;
    if (_humiditySwitch.on) {
        float minValue = 0.0;
        float maxValue = 100.0;
        WPPickerView *pickerView = [WPPickerView showWithMinValue:minValue maxValue:maxValue save:^(float lowerValue, float upperValue) {
            [sensor enableAlarm:YES forCharacteristicWithUUIDString:BLE_CLIMATE_CHAR_UUID_HUMIDITY_ALARM_SET];
            
            sensor.humidityAlarmLow = lowerValue;
            sensor.humidityAlarmHigh = upperValue;
            
            [sensor writeAlarmValue:upperValue forCharacteristicWithUUIDString:BLE_CLIMATE_CHAR_UUID_HUMIDITY_ALARM_HIGH_VALUE];
            [sensor writeAlarmValue:lowerValue forCharacteristicWithUUIDString:BLE_CLIMATE_CHAR_UUID_HUMIDITY_ALARM_LOW_VALUE];
        } cancel:^{
            //[_humiditySwitch setOn:NO animated:YES];
        }];
        [pickerView setLowerValue:sensor.humidityAlarmLow];
        [pickerView setUpperValue:sensor.humidityAlarmHigh];
    }
    else {
        [sensor enableAlarm:NO forCharacteristicWithUUIDString:BLE_CLIMATE_CHAR_UUID_HUMIDITY_ALARM_SET];
    }
}

- (IBAction)lightAlarmAction:(id)sender {
    ClimateSensor *sensor = (ClimateSensor *)self.sensor;
    if (_lightSwitch.on) {
        float minValue = 10.0;
        float maxValue = 65535.0;
        WPPickerView *pickerView = [WPPickerView showWithMinValue:minValue maxValue:maxValue save:^(float lowerValue, float upperValue) {
            [sensor enableAlarm:YES forCharacteristicWithUUIDString:BLE_CLIMATE_CHAR_UUID_LIGHT_ALARM_SET];
            
            sensor.lightAlarmLow = lowerValue;
            sensor.lightAlarmHigh = upperValue;
            
            [sensor writeAlarmValue:upperValue forCharacteristicWithUUIDString:BLE_CLIMATE_CHAR_UUID_LIGHT_ALARM_HIGH_VALUE];
            [sensor writeAlarmValue:lowerValue forCharacteristicWithUUIDString:BLE_CLIMATE_CHAR_UUID_LIGHT_ALARM_LOW_VALUE];
        } cancel:^{
            //[_lightSwitch setOn:NO animated:YES];
        }];
        [pickerView setLowerValue:sensor.lightAlarmLow];
        [pickerView setUpperValue:sensor.lightAlarmHigh];
    }
    else {
        [sensor enableAlarm:NO forCharacteristicWithUUIDString:BLE_CLIMATE_CHAR_UUID_LIGHT_ALARM_SET];
    }
}

#pragma mark - Value Observer

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    ClimateSensor *sensor = (ClimateSensor*)self.sensor;
    if ([keyPath isEqualToString:OBSERVER_KEY_PATH_SENSOR_PERIPHERAL]) {
        if ([[change objectForKey:NSKeyValueChangeNewKey] isKindOfClass:[NSNull class]]) {
            _tempAlarmContainer.hidden = YES;
            _humidityAlarmContainer.hidden = YES;
            _lightAlarmContainer.hidden = YES;
            [WPPickerView dismiss];
            _tempLabel.text = SENSOR_VALUE_PLACEHOLDER;
            _humidityLabel.text = SENSOR_VALUE_PLACEHOLDER;
            _lightLabel.text = SENSOR_VALUE_PLACEHOLDER;
        } else {
            _tempAlarmContainer.hidden = NO;
            _humidityAlarmContainer.hidden = NO;
            _lightAlarmContainer.hidden = NO;
            ClimateSensor *sensor = (ClimateSensor*)self.sensor;
            _tempLabel.text = [NSString stringWithFormat:@"%.1f", [sensor temperature]];
            _humidityLabel.text = [NSString stringWithFormat:@"%.1f", [sensor humidity]];
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
            _tempLabel.text = [NSString stringWithFormat:@"%.1f", [[change objectForKey:NSKeyValueChangeNewKey] floatValue]];
        }
        [self.sensor.entity latestValuesWithType:kValueTypeTemperature completionHandler:^(NSArray *result) {
            _temperatureSparkLine.dataValues = result;
        }];
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_CLIMATE_SENSOR_HUMIDITY]) {
        if (self.sensor.peripheral) {
            _humidityLabel.text = [NSString stringWithFormat:@"%.1f", [[change objectForKey:NSKeyValueChangeNewKey] floatValue]];
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
        NSLog(@"observeValueForKeyPath #310 %d", [[change objectForKey:NSKeyValueChangeNewKey] intValue]);
        _tempSwitch.on = ([[change objectForKey:NSKeyValueChangeNewKey] intValue] == kAlarmStateEnabled)?YES:NO;
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_CLIMATE_SENSOR_HUMIDITY_ALARM_STATE]) {
        _humiditySwitch.on = ([[change objectForKey:NSKeyValueChangeNewKey] intValue] == kAlarmStateEnabled)?YES:NO;
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_CLIMATE_SENSOR_LIGHT_ALARM_STATE]) {
        _lightSwitch.on = ([[change objectForKey:NSKeyValueChangeNewKey] intValue] == kAlarmStateEnabled)?YES:NO;
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_CLIMATE_SENSOR_TEMPERATURE_ALARM_LOW]) {
        _tempLowValueLabel.text = [NSString stringWithFormat:@"%.f", sensor.temperatureAlarmLow];
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_CLIMATE_SENSOR_TEMPERATURE_ALARM_HIGH]) {
        _tempHighValueLabel.text = [NSString stringWithFormat:@"%.f", sensor.temperatureAlarmHigh];
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_CLIMATE_SENSOR_HUMIDITY_ALARM_LOW]) {
        _humidityLowValueLabel.text = [NSString stringWithFormat:@"%.f", sensor.humidityAlarmLow];
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_CLIMATE_SENSOR_HUMIDITY_ALARM_HIGH]) {
        _humidityHighValueLabel.text = [NSString stringWithFormat:@"%.f", sensor.humidityAlarmHigh];
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_CLIMATE_SENSOR_LIGHT_ALARM_LOW]) {
        _lightLowValueLabel.text = [NSString stringWithFormat:@"%.f", sensor.lightAlarmLow];
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_CLIMATE_SENSOR_LIGHT_ALARM_HIGH]) {
        _lightHighValueLabel.text = [NSString stringWithFormat:@"%.f", sensor.lightAlarmHigh];
    }
    else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_SENSOR_TEMP_MEASURE]) {
        TemperatureMeasure tempMeasure = [[change objectForKey:NSKeyValueChangeNewKey] intValue];
        
        _tempConversionLabel.text = [sensor temperatureSymbol];
        _tempLabel.text = [NSString stringWithFormat:@"%.1f", [sensor temperature]];
    
        _tempHighValueLabel.text = [NSString stringWithFormat:@"%.f", sensor.temperatureAlarmHigh];
        _tempLowValueLabel.text = [NSString stringWithFormat:@"%.f", sensor.temperatureAlarmLow];
    }
}

@end
