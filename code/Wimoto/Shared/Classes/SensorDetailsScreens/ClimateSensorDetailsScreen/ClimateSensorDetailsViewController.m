//
//  ClimateSensorDetailsViewController.m
//  Wimoto
//
//  Created by MC700 on 12/3/13.
//
//

#import "ClimateSensorDetailsViewController.h"
#import "WPPickerView.h"
#import "WPTemperaturePickerView.h"

@interface ClimateSensorDetailsViewController ()

@end

@implementation ClimateSensorDetailsViewController

- (id)initWithSensor:(Sensor*)sensor {
    self = [super initWithNibName:[self nibNameForInterfaceOrientation:[UIApplication sharedApplication].statusBarOrientation] bundle:nil];
    if (self) {
        self.sensor = sensor;
    }
    return self;
}

- (id)init {
    self = [super initWithNibName:[self nibNameForInterfaceOrientation:[UIApplication sharedApplication].statusBarOrientation] bundle:nil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = YES;
    
    [self refresh];
    
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

- (void)refresh {
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
    
    [self.lastUpdateLabel refresh];
}

- (NSString *)nibNameForInterfaceOrientation:(UIInterfaceOrientation)orientation {
    BOOL isIpad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    NSString *nibName = [NSString stringWithFormat:@"ClimateSensorDetailsViewController_%@", (isIpad)?@"iPad":@"iPhone"];
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        nibName = [nibName stringByAppendingString:@"-landscape"];
    }
    return nibName;
}

- (void)refreshToInterfaceOrientation:(UIInterfaceOrientation)orientation {
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        _chartView.animationEnabled = NO;
        self.temperatureChartLine = [[APChartLine alloc] initWithChartView:self.chartView title:@"Temperature" lineWidth:2.0 lineColor:[UIColor greenColor]];
        self.humidityChartLine = [[APChartLine alloc] initWithChartView:self.chartView title:@"Humidity" lineWidth:2.0 lineColor:[UIColor yellowColor]];
        self.lightChartLine = [[APChartLine alloc] initWithChartView:self.chartView title:@"Light" lineWidth:2.0 lineColor:[UIColor redColor]];
        [_chartView addLine:self.temperatureChartLine];
        [_chartView addLine:self.humidityChartLine];
        [_chartView addLine:self.lightChartLine];
    } else {
        [self refresh];
        
        self.sensorNameField.text = self.sensor.name;
        
        _tempView.text = SENSOR_VALUE_PLACEHOLDER;
        _humidityLabel.text = SENSOR_VALUE_PLACEHOLDER;
        _lightLabel.text = SENSOR_VALUE_PLACEHOLDER;
        self.temperatureChartLine = nil;
        self.humidityChartLine = nil;
        self.lightChartLine = nil;
    }
    self.view.backgroundColor = [UIColor colorWithRed:(102.f/255.f) green:(204.f/255.f) blue:(255.f/255.f) alpha:1.f];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [[NSBundle mainBundle] loadNibNamed:[self nibNameForInterfaceOrientation:toInterfaceOrientation] owner:self options:nil];
    [self refreshToInterfaceOrientation:toInterfaceOrientation];
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
    ClimateSensor *sensor = (ClimateSensor *)self.sensor;
    
    sensor.temperatureAlarmState = (_tempSwitch.on)?kAlarmStateEnabled:kAlarmStateDisabled;
    if (_tempSwitch.on) {
        float minValue = -50.0;
        float maxValue = 120.0;
        WPTemperaturePickerView *pickerView = [WPTemperaturePickerView showWithMinValue:minValue maxValue:maxValue save:^(float lowerValue, float upperValue) {
            sensor.temperatureAlarmLow = lowerValue;
            sensor.temperatureAlarmHigh = upperValue;
        } cancel:^{
            // empty implementation
        }];
        [pickerView setLowerValue:sensor.temperatureAlarmLow];
        [pickerView setUpperValue:sensor.temperatureAlarmHigh];
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
    dispatch_async(dispatch_get_main_queue(), ^{
        ClimateSensor *sensor = (ClimateSensor*)self.sensor;
        if ([keyPath isEqualToString:OBSERVER_KEY_PATH_SENSOR_PERIPHERAL]) {
            if ([[change objectForKey:NSKeyValueChangeNewKey] isKindOfClass:[NSNull class]]) {
                _tempAlarmContainer.hidden = YES;
                _humidityAlarmContainer.hidden = YES;
                _lightAlarmContainer.hidden = YES;
                [WPPickerView dismiss];
                _tempView.text = SENSOR_VALUE_PLACEHOLDER;
                _humidityLabel.text = SENSOR_VALUE_PLACEHOLDER;
                _lightLabel.text = SENSOR_VALUE_PLACEHOLDER;
            } else {
                _tempAlarmContainer.hidden = NO;
                _humidityAlarmContainer.hidden = NO;
                _lightAlarmContainer.hidden = NO;
                
                [_tempView setTemperature:[sensor temperature]];
                _humidityLabel.text = [NSString stringWithFormat:@"%.1f", [sensor humidity]];
                _lightLabel.text = [NSString stringWithFormat:@"%.1f", [sensor light]];
                
                self.view.backgroundColor = [UIColor colorWithRed:(102.f/255.f) green:(204.f/255.f) blue:(255.f/255.f) alpha:1.f];
            }
        } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_CLIMATE_SENSOR_TEMPERATURE]) {
            [self.lastUpdateLabel refresh];
            
            if (self.sensor.peripheral) {
                [_tempView setTemperature:[[change objectForKey:NSKeyValueChangeNewKey] floatValue]];
            }
            
            [self.sensor.entity latestValuesWithType:kValueTypeTemperature completionHandler:^(NSArray *result) {
                _temperatureSparkLine.dataValues = result;
                
                [_temperatureChartLine clear];
                CGFloat x = 1;
                for (NSNumber *value in result) {
                    [_temperatureChartLine addPoint:CGPointMake(x, value.floatValue)];
                    x++;
                }
                [_chartView setNeedsDisplay];
            }];            
        } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_CLIMATE_SENSOR_HUMIDITY]) {
            if (self.sensor.peripheral) {
                _humidityLabel.text = [NSString stringWithFormat:@"%.1f", [[change objectForKey:NSKeyValueChangeNewKey] floatValue]];
            }
            [self.sensor.entity latestValuesWithType:kValueTypeHumidity completionHandler:^(NSArray *result) {
                _humiditySparkLine.dataValues = result;
                
                [_humidityChartLine clear];
                CGFloat x = 1;
                for (NSNumber *value in result) {
                    [_humidityChartLine addPoint:CGPointMake(x, value.floatValue)];
                    x++;
                }
                [_chartView setNeedsDisplay];
            }];
        } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_CLIMATE_SENSOR_LIGHT]) {
            if (self.sensor.peripheral) {
                _lightLabel.text = [NSString stringWithFormat:@"%.1f", [[change objectForKey:NSKeyValueChangeNewKey] floatValue]];
            }
            [self.sensor.entity latestValuesWithType:kValueTypeLight completionHandler:^(NSArray *result) {
                _lightSparkLine.dataValues = result;
                
                [_lightChartLine clear];
                CGFloat x = 1;
                for (NSNumber *value in result) {
                    [_lightChartLine addPoint:CGPointMake(x, value.floatValue)];
                    x++;
                }
                [_chartView setNeedsDisplay];
            }];
        } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_CLIMATE_SENSOR_TEMPERATURE_ALARM_STATE]) {
            _tempSwitch.on = ([[change objectForKey:NSKeyValueChangeNewKey] intValue] == kAlarmStateEnabled)?YES:NO;
        } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_CLIMATE_SENSOR_HUMIDITY_ALARM_STATE]) {
            _humiditySwitch.on = ([[change objectForKey:NSKeyValueChangeNewKey] intValue] == kAlarmStateEnabled)?YES:NO;
        } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_CLIMATE_SENSOR_LIGHT_ALARM_STATE]) {
            _lightSwitch.on = ([[change objectForKey:NSKeyValueChangeNewKey] intValue] == kAlarmStateEnabled)?YES:NO;
        } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_CLIMATE_SENSOR_TEMPERATURE_ALARM_LOW]) {
            [_tempLowValueLabel setTemperature:sensor.temperatureAlarmLow];
        } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_CLIMATE_SENSOR_TEMPERATURE_ALARM_HIGH]) {
            [_tempHighValueLabel setTemperature:sensor.temperatureAlarmHigh];
        } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_CLIMATE_SENSOR_HUMIDITY_ALARM_LOW]) {
            _humidityLowValueLabel.text = [NSString stringWithFormat:@"%.1f", sensor.humidityAlarmLow];
        } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_CLIMATE_SENSOR_HUMIDITY_ALARM_HIGH]) {
            _humidityHighValueLabel.text = [NSString stringWithFormat:@"%.1f", sensor.humidityAlarmHigh];
        } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_CLIMATE_SENSOR_LIGHT_ALARM_LOW]) {
            _lightLowValueLabel.text = [NSString stringWithFormat:@"%.1f", sensor.lightAlarmLow];
        } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_CLIMATE_SENSOR_LIGHT_ALARM_HIGH]) {
            _lightHighValueLabel.text = [NSString stringWithFormat:@"%.1f", sensor.lightAlarmHigh];
        }
    });
}

@end
