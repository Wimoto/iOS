//
//  GrowSensorDetailsViewController.m
//  Wimoto
//
//  Created by MC700 on 12/3/13.
//
//

#import "GrowSensorDetailsViewController.h"
#import "ASBSparkLineView.h"
#import "WPPickerView.h"
#import "GrowSensor.h"

#import "WPTemperatureValueLabel.h"
#import "WPTemperatureView.h"
#import "WPTemperaturePickerView.h"

@interface GrowSensorDetailsViewController ()

@property (nonatomic, weak) IBOutlet WPTemperatureView *soilTempView;

@property (nonatomic, weak) IBOutlet UILabel *soilMoistureLabel;
@property (nonatomic, weak) IBOutlet UILabel *lightLabel;

@property (nonatomic, weak) IBOutlet ASBSparkLineView *soilTempSparkLine;
@property (nonatomic, weak) IBOutlet ASBSparkLineView *soilMoistureSparkLine;
@property (nonatomic, weak) IBOutlet ASBSparkLineView *lightSparkLine;

@property (nonatomic, weak) IBOutlet UISwitch *soilTempSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *soilMoistureSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *lightSwitch;

@property (nonatomic, weak) IBOutlet WPTemperatureValueLabel *soilTempHighValueLabel;
@property (nonatomic, weak) IBOutlet WPTemperatureValueLabel *soilTempLowValueLabel;
@property (nonatomic, weak) IBOutlet UILabel *soilMoistureHighValueLabel;
@property (nonatomic, weak) IBOutlet UILabel *soilMoistureLowValueLabel;
@property (nonatomic, weak) IBOutlet UILabel *lightHighValueLabel;
@property (nonatomic, weak) IBOutlet UILabel *lightLowValueLabel;

@property (nonatomic, weak) IBOutlet UILabel *soilTempConversionLabel;

@property (nonatomic, weak) IBOutlet UIView *soilTempAlarmContainer;
@property (nonatomic, weak) IBOutlet UIView *soilMoistureAlarmContainer;
@property (nonatomic, weak) IBOutlet UIView *lightAlarmContainer;

@property (nonatomic, strong) NSString *currentAlarmUUIDString;

- (IBAction)soilTempAlarmAction:(id)sender;
- (IBAction)soilMoistureAlarmAction:(id)sender;
- (IBAction)lightAlarmAction:(id)sender;

@end

@implementation GrowSensorDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    
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
    GrowSensor *sensor = (GrowSensor *)self.sensor;
    sensor.soilTempAlarmState = (_soilTempSwitch.on)?kAlarmStateEnabled:kAlarmStateDisabled;
    if (_soilTempSwitch.on) {
        float minValue = -60.0;
        float maxValue = 130.0;
        WPTemperaturePickerView *pickerView = [WPTemperaturePickerView showWithMinValue:minValue maxValue:maxValue save:^(float lowerValue, float upperValue) {
            sensor.soilTemperatureAlarmLow = lowerValue;
            sensor.soilTemperatureAlarmHigh = upperValue;
        } cancel:^{
            //[_soilTempSwitch setOn:NO animated:YES];
        }];
        [pickerView setLowerValue:sensor.soilTemperatureAlarmLow];
        [pickerView setUpperValue:sensor.soilTemperatureAlarmHigh];
    }
}

- (IBAction)soilMoistureAlarmAction:(id)sender {
    GrowSensor *sensor = (GrowSensor *)self.sensor;
    sensor.soilMoistureAlarmState = (_soilMoistureSwitch.on)?kAlarmStateEnabled:kAlarmStateDisabled;
    if (_soilMoistureSwitch.on) {
        float minValue = 10.0;
        float maxValue = 50.0;
        WPPickerView *pickerView = [WPPickerView showWithMinValue:minValue maxValue:maxValue save:^(float lowerValue, float upperValue) {
            sensor.soilMoistureAlarmLow = lowerValue;
            sensor.soilMoistureAlarmHigh = upperValue;
        } cancel:^{
            //[_soilMoistureSwitch setOn:NO animated:YES];
        }];
        [pickerView setLowerValue:sensor.soilMoistureAlarmLow];
        [pickerView setUpperValue:sensor.soilMoistureAlarmHigh];
    }
}

- (IBAction)lightAlarmAction:(id)sender {
    GrowSensor *sensor = (GrowSensor *)self.sensor;
    sensor.lightAlarmState = (_lightSwitch.on)?kAlarmStateEnabled:kAlarmStateDisabled;
    if (_lightSwitch.on) {
        float minValue = 10.0;
        float maxValue = 50.0;
        WPPickerView *pickerView = [WPPickerView showWithMinValue:minValue maxValue:maxValue save:^(float lowerValue, float upperValue) {
            sensor.lightAlarmLow = lowerValue;
            sensor.lightAlarmHigh = upperValue;
        } cancel:^{
            //[_lightSwitch setOn:NO animated:YES];
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
    GrowSensor *sensor = (GrowSensor*)self.sensor;
    if ([keyPath isEqualToString:OBSERVER_KEY_PATH_SENSOR_PERIPHERAL]) {
        if ([[change objectForKey:NSKeyValueChangeNewKey] isKindOfClass:[NSNull class]]) {
            _soilMoistureAlarmContainer.hidden = YES;
            _soilTempAlarmContainer.hidden = YES;
            _lightAlarmContainer.hidden = YES;
            [WPPickerView dismiss];
            
            _soilTempView.text = SENSOR_VALUE_PLACEHOLDER;
            _soilMoistureLabel.text = SENSOR_VALUE_PLACEHOLDER;
            _lightLabel.text = SENSOR_VALUE_PLACEHOLDER;
        } else {
            _soilMoistureAlarmContainer.hidden = NO;
            _soilTempAlarmContainer.hidden = NO;
            _lightAlarmContainer.hidden = NO;
            
            [_soilTempView setTemperature:[sensor soilTemperature]];
            _soilMoistureLabel.text = [NSString stringWithFormat:@"%.1f", [sensor soilMoisture]];
            _lightLabel.text = [NSString stringWithFormat:@"%.1f", [sensor light]];
            self.view.backgroundColor = [UIColor colorWithRed:(153.f/255.f) green:(233.f/255.f) blue:(124.f/255.f) alpha:1.f];
        }
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_GROW_SENSOR_SOIL_TEMPERATURE]) {
        self.lastUpdateLabel.text = @"Just now";
        if ([self.lastUpdateTimer isValid]) {
            [self.lastUpdateTimer invalidate];
        }
        self.lastUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:15.0 target:self selector:@selector(refreshLastUpdateLabel) userInfo:nil repeats:YES];
        
        if (self.sensor.peripheral) {
            [_soilTempView setTemperature:[[change objectForKey:NSKeyValueChangeNewKey] floatValue]];
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
            _lightLabel.text = [NSString stringWithFormat:@"%.1f", [[change objectForKey:NSKeyValueChangeNewKey] floatValue]];
        }
        [self.sensor.entity latestValuesWithType:kValueTypeLight completionHandler:^(NSArray *result) {
            _lightSparkLine.dataValues = result;
        }];
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_GROW_SENSOR_LIGHT_ALARM_STATE]) {
        _lightSwitch.on = ([[change objectForKey:NSKeyValueChangeNewKey] intValue] == kAlarmStateEnabled)?YES:NO;
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_GROW_SENSOR_SOIL_MOISTURE_ALARM_STATE]) {
        _soilMoistureSwitch.on = ([[change objectForKey:NSKeyValueChangeNewKey] intValue] == kAlarmStateEnabled)?YES:NO;
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_GROW_SENSOR_SOIL_TEMPERATURE_ALARM_STATE]) {
        _soilTempSwitch.on = ([[change objectForKey:NSKeyValueChangeNewKey] intValue] == kAlarmStateEnabled)?YES:NO;
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_GROW_SENSOR_LIGHT_ALARM_LOW]) {
        _lightLowValueLabel.text = [NSString stringWithFormat:@"%.1f", sensor.lightAlarmLow];
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_GROW_SENSOR_LIGHT_ALARM_HIGH]) {
        _lightHighValueLabel.text = [NSString stringWithFormat:@"%.1f", sensor.lightAlarmHigh];
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_GROW_SENSOR_SOIL_MOISTURE_ALARM_LOW]) {
        _soilMoistureLowValueLabel.text = [NSString stringWithFormat:@"%.1f", sensor.soilMoistureAlarmLow];
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_GROW_SENSOR_SOIL_MOISTURE_ALARM_HIGH]) {
        _soilMoistureHighValueLabel.text = [NSString stringWithFormat:@"%.1f", sensor.soilMoistureAlarmHigh];
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_GROW_SENSOR_SOIL_TEMPERATURE_ALARM_LOW]) {
        [_soilTempLowValueLabel setTemperature:sensor.soilTemperatureAlarmLow];
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_GROW_SENSOR_SOIL_TEMPERATURE_ALARM_HIGH]) {
        [_soilTempHighValueLabel setTemperature:sensor.soilTemperatureAlarmHigh];
    }
}

@end
