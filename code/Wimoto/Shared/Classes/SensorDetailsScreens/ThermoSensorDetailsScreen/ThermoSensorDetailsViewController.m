//
//  ThermoSensorDetailsViewController.m
//  Wimoto
//
//  Created by MC700 on 12/3/13.
//
//

#import "ThermoSensorDetailsViewController.h"
#import "WPPickerView.h"
#import "WPTemperaturePickerView.h"

#import "TimePickerView.h"

@interface ThermoSensorDetailsViewController ()

@end

@implementation ThermoSensorDetailsViewController

- (id)initWithSensor:(Sensor*)sensor {
    self = [super initWithNibName:[self nibNameForInterfaceOrientation:[UIApplication sharedApplication].statusBarOrientation] bundle:nil];
    if (self) {
        self.sensor = sensor;
    }
    return self;
}

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
    
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_THERMO_SENSOR_IR_TEMP options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_THERMO_SENSOR_PROBE_TEMP options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
        
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_THERMO_SENSOR_IR_TEMP_ALARM_STATE options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_THERMO_SENSOR_PROBE_TEMP_ALARM_STATE options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_THERMO_SENSOR_IR_TEMP_ALARM_LOW options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_THERMO_SENSOR_IR_TEMP_ALARM_HIGH options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_THERMO_SENSOR_PROBE_TEMP_ALARM_LOW options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_THERMO_SENSOR_PROBE_TEMP_ALARM_HIGH options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSString *)nibNameForInterfaceOrientation:(UIInterfaceOrientation)orientation {
    BOOL isIpad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    NSString *nibName = [NSString stringWithFormat:@"ThermoSensorDetailsViewController_%@", (isIpad)?@"iPad":@"iPhone"];
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        nibName = [nibName stringByAppendingString:@"-landscape"];
    }
    return nibName;
}

- (void)refreshToInterfaceOrientation:(UIInterfaceOrientation)orientation {
    [self viewDidLoad];
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        _chartView.animationEnabled = NO;
        self.irTempChartLine = [[APChartLine alloc] initWithChartView:self.chartView title:@"Infrared" lineWidth:2.0 lineColor:[UIColor greenColor]];
        self.probeTempChartLine = [[APChartLine alloc] initWithChartView:self.chartView title:@"Probe" lineWidth:2.0 lineColor:[UIColor yellowColor]];
        [_chartView addLine:_irTempChartLine];
        [_chartView addLine:_probeTempChartLine];
    } else {
        _irTempView.text = SENSOR_VALUE_PLACEHOLDER;
        _probeTempView.text = SENSOR_VALUE_PLACEHOLDER;
        self.irTempChartLine = nil;
        self.probeTempChartLine = nil;
    }
    self.view.backgroundColor = [UIColor colorWithRed:(255.f/255.f) green:(159.f/255.f) blue:(17.f/255.f) alpha:1.f];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [[NSBundle mainBundle] loadNibNamed:[self nibNameForInterfaceOrientation:toInterfaceOrientation] owner:self options:nil];
    [self refreshToInterfaceOrientation:toInterfaceOrientation];
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
    ThermoSensor *sensor = (ThermoSensor *)self.sensor;
    
    sensor.irTempAlarmState = (_irTempSwitch.on)?kAlarmStateEnabled:kAlarmStateDisabled;
    if (_irTempSwitch.on) {
        float minValue = -60.0;
        float maxValue = 130.0;
        WPTemperaturePickerView *pickerView = [WPTemperaturePickerView showWithMinValue:minValue maxValue:maxValue save:^(float lowerValue, float upperValue) {
            sensor.irTempAlarmLow = lowerValue;
            sensor.irTempAlarmHigh = upperValue;
        } cancel:^{
            //[_irTempSwitch setOn:NO animated:YES];
        }];
        [pickerView setLowerValue:sensor.irTempAlarmLow];
        [pickerView setUpperValue:sensor.irTempAlarmHigh];
    }
}

- (IBAction)probeTempAlarmAction:(id)sender {
    ThermoSensor *sensor = (ThermoSensor *)self.sensor;
    
    sensor.probeTempAlarmState = (_probeTempSwitch.on)?kAlarmStateEnabled:kAlarmStateDisabled;
    if (_probeTempSwitch.on) {
        float minValue = -20.0;
        float maxValue = 50.0;
        WPTemperaturePickerView *pickerView = [WPPickerView showWithMinValue:minValue maxValue:maxValue save:^(float lowerValue, float upperValue) {
            sensor.probeTempAlarmLow = lowerValue;
            sensor.probeTempAlarmHigh = upperValue;
        } cancel:^{
            //[_probeTempSwitch setOn:NO animated:YES];
        }];
        [pickerView setLowerValue:sensor.probeTempAlarmLow];
        [pickerView setUpperValue:sensor.probeTempAlarmHigh];
    }
}

#pragma mark - Value Observer

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        ThermoSensor *sensor = (ThermoSensor *)[self sensor];
        if ([keyPath isEqualToString:OBSERVER_KEY_PATH_SENSOR_PERIPHERAL]) {
            if ([[change objectForKey:NSKeyValueChangeNewKey] isKindOfClass:[NSNull class]]) {
                _irTempAlarmContainer.hidden = YES;
                _probeTempAlarmContainer.hidden = YES;
                [WPPickerView dismiss];
                
                _irTempView.text = SENSOR_VALUE_PLACEHOLDER;
                _probeTempView.text = SENSOR_VALUE_PLACEHOLDER;
            } else {
                _irTempAlarmContainer.hidden = NO;
                _probeTempAlarmContainer.hidden = NO;
                [_irTempView setTemperature:[sensor irTemp]];
                [_probeTempView setTemperature:[sensor probeTemp]];
                self.view.backgroundColor = [UIColor colorWithRed:(255.f/255.f) green:(159.f/255.f) blue:(17.f/255.f) alpha:1.f];
            }
        } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_THERMO_SENSOR_IR_TEMP]) {
            [self.lastUpdateLabel refresh];
            
            if (self.sensor.peripheral) {
                [_irTempView setTemperature:[sensor irTemp]];
            }
            [self.sensor.entity latestValuesWithType:kValueTypeIRTemperature completionHandler:^(NSArray *result) {
                _irTempSparkLine.dataValues = result;
                
                [_irTempChartLine clear];
                CGFloat x = 1;
                for (NSNumber *value in result) {
                    [_irTempChartLine addPoint:CGPointMake(x, value.floatValue)];
                    x++;
                }
                [_chartView setNeedsDisplay];
            }];
        } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_THERMO_SENSOR_PROBE_TEMP]) {
            [self.lastUpdateLabel refresh];
            
            if (self.sensor.peripheral) {
                [_probeTempView setTemperature:[sensor probeTemp]];
            }
            [self.sensor.entity latestValuesWithType:kValueTypeProbeTemperature completionHandler:^(NSArray *result) {
                _probeTempSparkLine.dataValues = result;
                
                [_probeTempChartLine clear];
                CGFloat x = 1;
                for (NSNumber *value in result) {
                    [_probeTempChartLine addPoint:CGPointMake(x, value.floatValue)];
                    x++;
                }
                [_chartView setNeedsDisplay];
            }];
        }
        else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_THERMO_SENSOR_IR_TEMP_ALARM_STATE]) {
            _irTempSwitch.on = ([[change objectForKey:NSKeyValueChangeNewKey] intValue] == kAlarmStateEnabled)?YES:NO;
        }
        else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_THERMO_SENSOR_PROBE_TEMP_ALARM_STATE]) {
            _probeTempSwitch.on = ([[change objectForKey:NSKeyValueChangeNewKey] intValue] == kAlarmStateEnabled)?YES:NO;
        }
        else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_THERMO_SENSOR_IR_TEMP_ALARM_LOW]) {
            [_irTempLowValueLabel setTemperature:sensor.irTempAlarmLow];
        }
        else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_THERMO_SENSOR_IR_TEMP_ALARM_HIGH]) {
            [_irTempHighValueLabel setTemperature:sensor.irTempAlarmHigh];
        }
        else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_THERMO_SENSOR_PROBE_TEMP_ALARM_LOW]) {
            [_probeTempLowValueLabel setTemperature:sensor.probeTempAlarmLow];
        }
        else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_THERMO_SENSOR_PROBE_TEMP_ALARM_HIGH]) {
            [_probeTempHighValueLabel setTemperature:sensor.probeTempAlarmHigh];
        }
    });
}

@end
