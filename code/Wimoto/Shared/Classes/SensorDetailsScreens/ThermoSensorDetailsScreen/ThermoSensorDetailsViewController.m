//
//  ThermoSensorDetailsViewController.m
//  Wimoto
//
//  Created by MC700 on 12/3/13.
//
//

#import "ThermoSensorDetailsViewController.h"
#import "WPPickerView.h"

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
    ThermoSensor *sensor = (ThermoSensor *)self.sensor;
    if (_irTempSwitch.on) {
        TemperatureMeasure tempMeasure = sensor.tempMeasure;
        float minValue = -60.0;
        float maxValue = 130.0;
        if (tempMeasure == kTemperatureMeasureFahrenheit) {
            minValue = [sensor convertToFahrenheit:minValue];
            maxValue = [sensor convertToFahrenheit:maxValue];
        }
        WPPickerView *pickerView = [WPPickerView showWithMinValue:minValue maxValue:maxValue save:^(float lowerValue, float upperValue) {
            [sensor enableAlarm:YES forCharacteristicWithUUIDString:BLE_THERMO_CHAR_UUID_IR_TEMPERATURE_ALARM_SET];
            
            sensor.irTempAlarmLow = lowerValue;
            sensor.irTempAlarmHigh = upperValue;
            
            [sensor writeAlarmValue:upperValue forCharacteristicWithUUIDString:BLE_THERMO_CHAR_UUID_IR_TEMPERATURE_ALARM_HIGH_VALUE];
            [sensor writeAlarmValue:lowerValue forCharacteristicWithUUIDString:BLE_THERMO_CHAR_UUID_IR_TEMPERATURE_ALARM_LOW_VALUE];
        } cancel:^{
            //[_irTempSwitch setOn:NO animated:YES];
        }];
        [pickerView setLowerValue:sensor.irTempAlarmLow];
        [pickerView setUpperValue:sensor.irTempAlarmHigh];
    }
    else {
        [sensor enableAlarm:NO forCharacteristicWithUUIDString:BLE_THERMO_CHAR_UUID_IR_TEMPERATURE_ALARM_SET];
    }
}

- (IBAction)probeTempAlarmAction:(id)sender {
    ThermoSensor *sensor = (ThermoSensor *)self.sensor;
    TemperatureMeasure tempMeasure = sensor.tempMeasure;
    float minValue = -20.0;
    float maxValue = 50.0;
    if (tempMeasure == kTemperatureMeasureFahrenheit) {
        minValue = [sensor convertToFahrenheit:minValue];
        maxValue = [sensor convertToFahrenheit:maxValue];
    }
    if (_probeTempSwitch.on) {
        WPPickerView *pickerView = [WPPickerView showWithMinValue:minValue maxValue:maxValue save:^(float lowerValue, float upperValue) {
            [sensor enableAlarm:YES forCharacteristicWithUUIDString:BLE_THERMO_CHAR_UUID_PROBE_TEMPERATURE_ALARM_SET];
            
            sensor.probeTempAlarmLow = lowerValue;
            sensor.probeTempAlarmHigh = upperValue;
            
            [sensor writeAlarmValue:upperValue forCharacteristicWithUUIDString:BLE_THERMO_CHAR_UUID_PROBE_TEMPERATURE_ALARM_HIGH_VALUE];
            [sensor writeAlarmValue:lowerValue forCharacteristicWithUUIDString:BLE_THERMO_CHAR_UUID_PROBE_TEMPERATURE_ALARM_LOW_VALUE];
        } cancel:^{
            //[_probeTempSwitch setOn:NO animated:YES];
        }];
        [pickerView setLowerValue:sensor.probeTempAlarmLow];
        [pickerView setUpperValue:sensor.probeTempAlarmHigh];
    }
    else {
        [sensor enableAlarm:NO forCharacteristicWithUUIDString:BLE_THERMO_CHAR_UUID_PROBE_TEMPERATURE_ALARM_SET];
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
            [WPPickerView dismiss];
            
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
        _irTempLowValueLabel.text = [NSString stringWithFormat:@"%.1f", [sensor irTempAlarmLow]];
    }
    else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_THERMO_SENSOR_IR_TEMP_ALARM_HIGH]) {
        _irTempHighValueLabel.text = [NSString stringWithFormat:@"%.1f", [sensor irTempAlarmHigh]];
    }
    else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_THERMO_SENSOR_PROBE_TEMP_ALARM_LOW]) {
        _probeTempLowValueLabel.text = [NSString stringWithFormat:@"%.1f", [sensor probeTempAlarmLow]];
    }
    else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_THERMO_SENSOR_PROBE_TEMP_ALARM_HIGH]) {
        _probeTempHighValueLabel.text = [NSString stringWithFormat:@"%.1f", [sensor probeTempAlarmHigh]];
    }
    else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_SENSOR_TEMP_MEASURE]) {
        _irTempConversionLabel.text = [sensor temperatureSymbol];
        _probeTempConversionLabel.text = [sensor temperatureSymbol];
        _irTempLabel.text = [NSString stringWithFormat:@"%.1f", [sensor irTemp]];
        _probeTempLabel.text = [NSString stringWithFormat:@"%.1f", [sensor probeTemp]];        
    }
}

@end
