//
//  ClimateSensorDetailsViewController.m
//  Wimoto
//
//  Created by MC700 on 12/3/13.
//
//

#import "ClimateSensorDetailsViewController.h"
#import "ASBSparkLineView.h"
#import "ClimateSensor.h"
#import "SensorHelper.h"

@interface ClimateSensorDetailsViewController ()

@property (nonatomic, weak) IBOutlet UILabel *tempLabel;
@property (nonatomic, weak) IBOutlet UILabel *humidityLabel;
@property (nonatomic, weak) IBOutlet UILabel *lightLabel;

@property (nonatomic, weak) IBOutlet ASBSparkLineView *temperatureSparkLine;
@property (nonatomic, weak) IBOutlet ASBSparkLineView *humiditySparkLine;
@property (nonatomic, weak) IBOutlet ASBSparkLineView *lightSparkLine;

@property (nonatomic, weak) IBOutlet UISwitch *tempSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *lightSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *humiditySwitch;

@property (nonatomic, weak) IBOutlet UILabel *tempHighValueLabel;
@property (nonatomic, weak) IBOutlet UILabel *tempLowValueLabel;
@property (nonatomic, weak) IBOutlet UILabel *humidityHighValueLabel;
@property (nonatomic, weak) IBOutlet UILabel *humidityLowValueLabel;
@property (nonatomic, weak) IBOutlet UILabel *lightHighValueLabel;
@property (nonatomic, weak) IBOutlet UILabel *lightLowValueLabel;

@property (nonatomic, strong) AlarmSlider *temperatureSlider;
@property (nonatomic, strong) AlarmSlider *humiditySlider;
@property (nonatomic, strong) AlarmSlider *lightSlider;

- (IBAction)temperatureAlarmAction:(id)sender;
- (IBAction)humidityAlarmAction:(id)sender;
- (IBAction)lightAlarmAction:(id)sender;

@end

@implementation ClimateSensorDetailsViewController

- (id)initWithSensor:(Sensor*)sensor
{
    self = [super initWithSensor:sensor];
    if (self) {
        self.sensor.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = YES;
    
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_CLIMATE_SENSOR_TEMPERATURE options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_CLIMATE_SENSOR_HUMIDITY options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_CLIMATE_SENSOR_LIGHT options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_CLIMATE_SENSOR_TEMPERATURE_ALARM_LOW options:NSKeyValueObservingOptionNew context:NULL];
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_CLIMATE_SENSOR_TEMPERATURE_ALARM_HIGH options:NSKeyValueObservingOptionNew context:NULL];
    
    _temperatureSparkLine.labelText = @"";
    _temperatureSparkLine.showCurrentValue = NO;
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
    
    ClimateSensor *climateSensor = (ClimateSensor *)[self sensor];
    _tempSwitch.on = (climateSensor.temperatureAlarmState == kAlarmStateEnabled)?YES:NO;
    _lightSwitch.on = (climateSensor.lightAlarmState == kAlarmStateEnabled)?YES:NO;
    _humiditySwitch.on = (climateSensor.humidityAlarmState == kAlarmStateEnabled)?YES:NO;
    NSLog(@"TEMPERATURE SWITCH IS ON - %i", [_tempSwitch isOn]);
    NSLog(@"LIGHT SWITCH IS ON - %i", [_tempSwitch isOn]);
    NSLog(@"HUMIDITY SWITCH IS ON - %i", [_tempSwitch isOn]);
    
    _temperatureSlider = [[AlarmSlider alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height, self.view.frame.size.width, 100.0)];
    [self.view addSubview:_temperatureSlider];
    _temperatureSlider.delegate = self;
    [_temperatureSlider setSliderRange:0];
    [_temperatureSlider setMinimumValue:-60];
    [_temperatureSlider setMaximumValue:130];
    
    _humiditySlider = [[AlarmSlider alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height, self.view.frame.size.width, 100.0)];
    [self.view addSubview:_humiditySlider];
    _humiditySlider.delegate = self;
    [_humiditySlider setSliderRange:0];
    [_humiditySlider setMinimumValue:-60];
    [_humiditySlider setMaximumValue:130];
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
        
        [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_CLIMATE_SENSOR_TEMPERATURE_ALARM_LOW];
        [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_CLIMATE_SENSOR_TEMPERATURE_ALARM_HIGH];
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
    
}

- (IBAction)lightAlarmAction:(id)sender {
    
}

//- (void)showSlider {
//    if ([_currentAlarmUUIDString isEqualToString:BLE_CLIMATE_SERVICE_UUID_TEMPERATURE_ALARM_SET]) {
//        [self.alarmSlider setSliderRange:0];
//        [self.alarmSlider setMinimumValue:-60];
//        [self.alarmSlider setMaximumValue:130];
//        [self.alarmSlider setUpperValue:[_tempHighValueLabel.text floatValue]];
//        [self.alarmSlider setLowerValue:[_tempLowValueLabel.text floatValue]];
//    }
//    else if ([_currentAlarmUUIDString isEqualToString:BLE_CLIMATE_SERVICE_UUID_LIGHT_ALARM]) {
//        [self.alarmSlider setSliderRange:0];
//        [self.alarmSlider setMinimumValue:10];
//        [self.alarmSlider setMaximumValue:50];
//        [self.alarmSlider setUpperValue:[_lightHighValueLabel.text floatValue]];
//        [self.alarmSlider setLowerValue:[_lightLowValueLabel.text floatValue]];
//    }
//    else if ([_currentAlarmUUIDString isEqualToString:BLE_CLIMATE_SERVICE_UUID_HUMIDITY_ALARM]) {
//        [self.alarmSlider setSliderRange:0];
//        [self.alarmSlider setMinimumValue:10];
//        [self.alarmSlider setMaximumValue:50];
//        [self.alarmSlider setUpperValue:[_humidityHighValueLabel.text floatValue]];
//        [self.alarmSlider setLowerValue:[_humidityLowValueLabel.text floatValue]];
//    }
//    NSLog(@"ALARM SLIDER LOW VALUE - %f", [self.alarmSlider lowerValue]);
//    NSLog(@"ALARM SLIDER HIGH VALUE - %f", [self.alarmSlider upperValue]);
//    [super showSlider];
//}

#pragma mark - SensorDelegate

- (void)didUpdateAlarmStateWithUUIDString:(NSString *)UUIDString {
    NSLog(@"DID UPDATE ALARM STATE WITH UUID - %@", UUIDString);
    ClimateSensor *climateSensor = (ClimateSensor *)[self sensor];
    if ([UUIDString isEqualToString:BLE_CLIMATE_SERVICE_UUID_TEMPERATURE_ALARM]) {
        _tempSwitch.on = (climateSensor.temperatureAlarmState == kAlarmStateEnabled)?YES:NO;
    }
    else if ([UUIDString isEqualToString:BLE_CLIMATE_SERVICE_UUID_LIGHT_ALARM]) {
        _lightSwitch.on = (climateSensor.lightAlarmState == kAlarmStateEnabled)?YES:NO;
    }
    else if ([UUIDString isEqualToString:BLE_CLIMATE_SERVICE_UUID_HUMIDITY_ALARM]) {
        _humiditySwitch.on = (climateSensor.humidityAlarmState == kAlarmStateEnabled)?YES:NO;
    }
    NSLog(@"TEMPERATURE SWITCH IS ON - %i", [_tempSwitch isOn]);
    NSLog(@"LIGHT SWITCH IS ON - %i", [_tempSwitch isOn]);
    NSLog(@"HUMIDITY SWITCH IS ON - %i", [_tempSwitch isOn]);
}

- (void)didReadMaxAlarmValueFromCharacteristicUUID:(CBUUID *)uuid {
    ClimateSensor *climateSensor = (ClimateSensor *)[self sensor];
    NSString *highValueString = [NSString stringWithFormat:@"%.f", [climateSensor maximumAlarmValueForCharacteristicWithUUID:uuid]];
    
    NSLog(@"CLIMATE didReadMaxAlarmValueFromCharacteristic - %@", highValueString);
    
    if ([uuid isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_SERVICE_UUID_TEMPERATURE_ALARM_HIGH_VALUE]]) {
        _tempHighValueLabel.text = highValueString;
    }
    else if ([uuid isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_SERVICE_UUID_LIGHT_ALARM_HIGH_VALUE]]) {
        _lightHighValueLabel.text = highValueString;
    }
    else if ([uuid isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_SERVICE_UUID_HUMIDITY_ALARM_HIGH_VALUE]]) {
        _humidityHighValueLabel.text = highValueString;
    }
}

- (void)didReadMinAlarmValueFromCharacteristicUUID:(CBUUID *)uuid {
    ClimateSensor *climateSensor = (ClimateSensor *)[self sensor];
    NSString *lowValueString = [NSString stringWithFormat:@"%.f", [climateSensor minimumAlarmValueForCharacteristicWithUUID:uuid]];
    
    NSLog(@"CLIMATE didReadMinAlarmValueFromCharacteristic - %@", lowValueString);
    
    if ([uuid isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_SERVICE_UUID_TEMPERATURE_ALARM_LOW_VALUE]]) {
        _tempLowValueLabel.text = lowValueString;
    }
    else if ([uuid isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_SERVICE_UUID_LIGHT_ALARM_LOW_VALUE]]) {
        _lightLowValueLabel.text = lowValueString;
    }
    else if ([uuid isEqual:[CBUUID UUIDWithString:BLE_CLIMATE_SERVICE_UUID_HUMIDITY_ALARM_LOW_VALUE]]) {
        _humidityLowValueLabel.text = lowValueString;
    }
}

#pragma mark - AlarmSliderDelegate

- (void)alarmSliderSaveAction:(id)sender {
    if ([sender isEqual:_temperatureSlider]) {
        [self.sensor writeHighAlarmValue:_temperatureSlider.upperValue forCharacteristicWithUUIDString:BLE_CLIMATE_SERVICE_UUID_TEMPERATURE_ALARM_HIGH_VALUE];
        [self.sensor writeLowAlarmValue:_temperatureSlider.lowerValue forCharacteristicWithUUIDString:BLE_CLIMATE_SERVICE_UUID_TEMPERATURE_ALARM_LOW_VALUE];
        
        _tempHighValueLabel.text = [NSString stringWithFormat:@"%.f", _temperatureSlider.upperValue];
        _tempLowValueLabel.text = [NSString stringWithFormat:@"%.f", _temperatureSlider.lowerValue];
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
            _tempLabel.text = SENSOR_VALUE_PLACEHOLDER;
            _humidityLabel.text = SENSOR_VALUE_PLACEHOLDER;
            _lightLabel.text = SENSOR_VALUE_PLACEHOLDER;
        } else {
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
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_CLIMATE_SENSOR_TEMPERATURE_ALARM_LOW]) {
        float value = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
        _tempLowValueLabel.text = [NSString stringWithFormat:@"%.f", value];
        [_temperatureSlider setLowerValue:value];
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_CLIMATE_SENSOR_TEMPERATURE_ALARM_HIGH]) {
        float value = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
        _tempHighValueLabel.text = [NSString stringWithFormat:@"%.f", value];
        [_temperatureSlider setUpperValue:value];
    }
}

@end
