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
    
    NSString *cOrFString = [[NSUserDefaults standardUserDefaults] objectForKey:@"cOrF"];
    BOOL isCelsius = [cOrFString isEqualToString:@"C"]?YES:NO;
    [self.sensor setTempMeasure:isCelsius?kTemperatureMeasureCelsius:kTemperatureMeasureFahrenheit];
    _tempConversionLabel.text = [self.sensor temperatureSymbol];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingsNotification:) name:NSUserDefaultsDidChangeNotification object:nil];
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
    NSLog(@"alarm temp");
    
    ClimateSensor *sensor = (ClimateSensor *)self.sensor;
    
    sensor.temperatureAlarmState = (_tempSwitch.on)?kAlarmStateEnabled:kAlarmStateDisabled;
    if (_tempSwitch.on) {
        TemperatureMeasure tempMeasure = sensor.tempMeasure;
        float minValue = -50.0;
        float maxValue = 120.0;
        if (tempMeasure == kTemperatureMeasureFahrenheit) {
            minValue = [sensor convertToFahrenheit:minValue];
            maxValue = [sensor convertToFahrenheit:maxValue];
        }
        WPPickerView *pickerView = [WPPickerView showWithMinValue:minValue maxValue:maxValue save:^(float lowerValue, float upperValue) {
            if (tempMeasure == kTemperatureMeasureFahrenheit) {
                sensor.temperatureAlarmLow  = [sensor convertToCelsius:lowerValue];
                sensor.temperatureAlarmHigh = [sensor convertToCelsius:upperValue];
            } else {
                sensor.temperatureAlarmLow = lowerValue;
                sensor.temperatureAlarmHigh = upperValue;
            }
        } cancel:^{
            // empty implementation
        }];
        [pickerView setLowerValue:[sensor temperatureAlarmLowFromMeasure]];
        [pickerView setUpperValue:[sensor temperatureAlarmHighFromMeasure]];
    }
}

- (IBAction)humidityAlarmAction:(id)sender {
    ClimateSensor *sensor = (ClimateSensor *)self.sensor;
    
    sensor.humidityAlarmState = (_humiditySwitch.on)?kAlarmStateEnabled:kAlarmStateDisabled;
    if (_humiditySwitch.on) {
        float minValue = 0.0;
        float maxValue = 100.0;
        WPPickerView *pickerView = [WPPickerView showWithMinValue:minValue maxValue:maxValue save:^(float lowerValue, float upperValue) {            
            sensor.humidityAlarmLow = lowerValue;
            sensor.humidityAlarmHigh = upperValue;            
        } cancel:^{
            // empty implementation
        }];
        [pickerView setLowerValue:sensor.humidityAlarmLow];
        [pickerView setUpperValue:sensor.humidityAlarmHigh];
    }
}

- (IBAction)lightAlarmAction:(id)sender {
    ClimateSensor *sensor = (ClimateSensor *)self.sensor;
    
    sensor.lightAlarmState = (_lightSwitch.on)?kAlarmStateEnabled:kAlarmStateDisabled;
    if (_lightSwitch.on) {
        float minValue = 10.0;
        float maxValue = 65535.0;
        WPPickerView *pickerView = [WPPickerView showWithMinValue:minValue maxValue:maxValue save:^(float lowerValue, float upperValue) {
            sensor.lightAlarmLow = lowerValue;
            sensor.lightAlarmHigh = upperValue;            
        } cancel:^{
            // empty implementation
        }];
        [pickerView setLowerValue:sensor.lightAlarmLow];
        [pickerView setUpperValue:sensor.lightAlarmHigh];
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
            _tempLabel.text = [NSString stringWithFormat:@"%.1f", [sensor temperatureFromMeasure]];
            _humidityLabel.text = [NSString stringWithFormat:@"%.1f", [sensor humidity]];
            _lightLabel.text = [NSString stringWithFormat:@"%.1f", [sensor light]];
            
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
            _lightLabel.text = [NSString stringWithFormat:@"%.1f", [[change objectForKey:NSKeyValueChangeNewKey] floatValue]];
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
        _tempLowValueLabel.text = [NSString stringWithFormat:@"%.1f", [sensor temperatureAlarmLowFromMeasure]];
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_CLIMATE_SENSOR_TEMPERATURE_ALARM_HIGH]) {
        _tempHighValueLabel.text = [NSString stringWithFormat:@"%.1f", [sensor temperatureAlarmHighFromMeasure]];
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_CLIMATE_SENSOR_HUMIDITY_ALARM_LOW]) {
        _humidityLowValueLabel.text = [NSString stringWithFormat:@"%.1f", sensor.humidityAlarmLow];
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_CLIMATE_SENSOR_HUMIDITY_ALARM_HIGH]) {
        _humidityHighValueLabel.text = [NSString stringWithFormat:@"%.1f", sensor.humidityAlarmHigh];
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_CLIMATE_SENSOR_LIGHT_ALARM_LOW]) {
        _lightLowValueLabel.text = [NSString stringWithFormat:@"%.1f", sensor.lightAlarmLow];
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_CLIMATE_SENSOR_LIGHT_ALARM_HIGH]) {
        _lightHighValueLabel.text = [NSString stringWithFormat:@"%.1f", sensor.lightAlarmHigh];
    }
    else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_SENSOR_TEMP_MEASURE]) {
        TemperatureMeasure tempMeasure = [[change objectForKey:NSKeyValueChangeNewKey] intValue];
        
        _tempConversionLabel.text = [sensor temperatureSymbol];
        _tempLabel.text = [NSString stringWithFormat:@"%.1f", [sensor temperature]];
    
        _tempHighValueLabel.text = [NSString stringWithFormat:@"%.1f", sensor.temperatureAlarmHigh];
        _tempLowValueLabel.text = [NSString stringWithFormat:@"%.1f", sensor.temperatureAlarmLow];
    }
}

- (void)settingsNotification:(NSNotification *)notification {
    NSLog(@"settingsNotification:");
    
    NSUserDefaults *userDefaults = [notification object];
    NSString *cOrFString = [userDefaults objectForKey:@"cOrF"];
    BOOL isCelsius = [cOrFString isEqualToString:@"C"]?YES:NO;
    
    [self.sensor setTempMeasure:isCelsius?kTemperatureMeasureCelsius:kTemperatureMeasureFahrenheit];
    _tempConversionLabel.text = [self.sensor temperatureSymbol];
    
}

@end
