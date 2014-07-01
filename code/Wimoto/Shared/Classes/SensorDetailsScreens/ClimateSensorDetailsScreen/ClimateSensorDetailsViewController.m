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

@property (nonatomic, strong) NSString *currentAlarmUUIDString;

- (IBAction)switchAction:(id)sender;

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
    
    _temperatureSparkLine.labelText = @"";
    _temperatureSparkLine.showCurrentValue = NO;
    [self.sensor lastSensorValuesWithType:kValueTypeTemperature completionHandler:^(NSMutableArray *item) {
        _temperatureSparkLine.dataValues = item;
    }];
    _humiditySparkLine.labelText = @"";
    _humiditySparkLine.showCurrentValue = NO;
    [self.sensor lastSensorValuesWithType:kValueTypeHumidity completionHandler:^(NSMutableArray *item) {
        _humiditySparkLine.dataValues = item;
    }];
    _lightSparkLine.labelText = @"";
    _lightSparkLine.showCurrentValue = NO;
    [self.sensor lastSensorValuesWithType:kValueTypeLight completionHandler:^(NSMutableArray *item) {
        _lightSparkLine.dataValues = item;
    }];
    ClimateSensor *climateSensor = (ClimateSensor *)[self sensor];
    _tempSwitch.on = (climateSensor.temperatureAlarmState == kAlarmStateEnabled)?YES:NO;
    _lightSwitch.on = (climateSensor.lightAlarmState == kAlarmStateEnabled)?YES:NO;
    _humiditySwitch.on = (climateSensor.humidityAlarmState == kAlarmStateEnabled)?YES:NO;
    NSLog(@"TEMPERATURE SWITCH IS ON - %i", [_tempSwitch isOn]);
    NSLog(@"LIGHT SWITCH IS ON - %i", [_tempSwitch isOn]);
    NSLog(@"HUMIDITY SWITCH IS ON - %i", [_tempSwitch isOn]);
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
    }
    @catch (NSException *exception) {
        // No need to handle just prevent app crash
    }
}

- (IBAction)switchAction:(id)sender
{
    UISwitch *switchControl = (UISwitch *)sender;
    ClimateSensor *climateSensor = (ClimateSensor *)[self sensor];
    if ([switchControl isEqual:_tempSwitch]) {
        [climateSensor enableAlarm:[switchControl isOn] forCharacteristicWithUUIDString:BLE_CLIMATE_SERVICE_UUID_TEMPERATURE_ALARM];
        self.currentAlarmUUIDString = BLE_CLIMATE_SERVICE_UUID_TEMPERATURE_ALARM;
    }
    else if ([switchControl isEqual:_lightSwitch]) {
        [climateSensor enableAlarm:[switchControl isOn] forCharacteristicWithUUIDString:BLE_CLIMATE_SERVICE_UUID_LIGHT_ALARM];
        self.currentAlarmUUIDString = BLE_CLIMATE_SERVICE_UUID_LIGHT_ALARM;
    }
    else if ([switchControl isEqual:_humiditySwitch]) {
        [climateSensor enableAlarm:[switchControl isOn] forCharacteristicWithUUIDString:BLE_CLIMATE_SERVICE_UUID_HUMIDITY_ALARM];
        self.currentAlarmUUIDString = BLE_CLIMATE_SERVICE_UUID_HUMIDITY_ALARM;
    }
    if ([switchControl isOn]) {
        [self showSlider];
    }
    else {
        [self hideSlider];
    }
}

- (void)showSlider {
    if ([_currentAlarmUUIDString isEqualToString:BLE_CLIMATE_SERVICE_UUID_TEMPERATURE_ALARM]) {
        [self.alarmSlider setSliderRange:0];
        [self.alarmSlider setMinimumValue:-60];
        [self.alarmSlider setMaximumValue:130];
        [self.alarmSlider setUpperValue:[_tempHighValueLabel.text floatValue]];
        [self.alarmSlider setLowerValue:[_tempLowValueLabel.text floatValue]];
    }
    else if ([_currentAlarmUUIDString isEqualToString:BLE_CLIMATE_SERVICE_UUID_LIGHT_ALARM]) {
        [self.alarmSlider setSliderRange:0];
        [self.alarmSlider setMinimumValue:10];
        [self.alarmSlider setMaximumValue:50];
        [self.alarmSlider setUpperValue:[_lightHighValueLabel.text floatValue]];
        [self.alarmSlider setLowerValue:[_lightLowValueLabel.text floatValue]];
    }
    else if ([_currentAlarmUUIDString isEqualToString:BLE_CLIMATE_SERVICE_UUID_HUMIDITY_ALARM]) {
        [self.alarmSlider setSliderRange:0];
        [self.alarmSlider setMinimumValue:10];
        [self.alarmSlider setMaximumValue:50];
        [self.alarmSlider setUpperValue:[_humidityHighValueLabel.text floatValue]];
        [self.alarmSlider setLowerValue:[_humidityLowValueLabel.text floatValue]];
    }
    NSLog(@"ALARM SLIDER LOW VALUE - %f", [self.alarmSlider lowerValue]);
    NSLog(@"ALARM SLIDER HIGH VALUE - %f", [self.alarmSlider upperValue]);
    [super showSlider];
}

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
    ClimateSensor *climateSensor = (ClimateSensor *)[self sensor];
    [climateSensor writeHighAlarmValue:self.alarmSlider.upperValue forCharacteristicWithUUIDString:_currentAlarmUUIDString];
    [climateSensor writeLowAlarmValue:self.alarmSlider.lowerValue forCharacteristicWithUUIDString:_currentAlarmUUIDString];
    
    NSString *highValueString = [NSString stringWithFormat:@"%.f", self.alarmSlider.upperValue];
    NSString *lowValueString = [NSString stringWithFormat:@"%.f", self.alarmSlider.lowerValue];
    if ([_currentAlarmUUIDString isEqualToString:BLE_CLIMATE_SERVICE_UUID_TEMPERATURE_ALARM]) {
        self.tempHighValueLabel.text = highValueString;
        self.tempLowValueLabel.text = lowValueString;
    }
    else if ([_currentAlarmUUIDString isEqualToString:BLE_CLIMATE_SERVICE_UUID_LIGHT_ALARM]) {
        self.lightHighValueLabel.text = highValueString;
        self.lightLowValueLabel.text = lowValueString;
    }
    else if ([_currentAlarmUUIDString isEqualToString:BLE_CLIMATE_SERVICE_UUID_HUMIDITY_ALARM]) {
        self.humidityHighValueLabel.text = highValueString;
        self.humidityLowValueLabel.text = lowValueString;
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
        [self.sensor lastSensorValuesWithType:kValueTypeTemperature completionHandler:^(NSMutableArray *item) {
            _temperatureSparkLine.dataValues = item;
        }];
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_CLIMATE_SENSOR_HUMIDITY]) {
        if (self.sensor.peripheral) {
            _humidityLabel.text = [NSString stringWithFormat:@"%.1f", [[change objectForKey:NSKeyValueChangeNewKey] floatValue]];
        }
        [self.sensor lastSensorValuesWithType:kValueTypeHumidity completionHandler:^(NSMutableArray *item) {
            _humiditySparkLine.dataValues = item;
        }];
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_CLIMATE_SENSOR_LIGHT]) {
        if (self.sensor.peripheral) {
            _lightLabel.text = [NSString stringWithFormat:@"%.f", [[change objectForKey:NSKeyValueChangeNewKey] floatValue]];
        }
        [self.sensor lastSensorValuesWithType:kValueTypeLight completionHandler:^(NSMutableArray *item) {
            _lightSparkLine.dataValues = item;
        }];
    }
}

@end
