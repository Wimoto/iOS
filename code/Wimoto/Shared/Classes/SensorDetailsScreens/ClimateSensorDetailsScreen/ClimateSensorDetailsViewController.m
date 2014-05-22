//
//  ClimateSensorDetailsViewController.m
//  Wimoto
//
//  Created by MC700 on 12/3/13.
//
//

#import "ClimateSensorDetailsViewController.h"
#import "ASBSparkLineView.h"
#import "DatabaseManager.h"
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

@property (nonatomic, weak) AlarmService *currentAlarmService;

- (IBAction)switchAction:(id)sender;

@end

@implementation ClimateSensorDetailsViewController

- (id)initWithSensor:(Sensor*)sensor
{
    self = [super initWithSensor:sensor];
    if (self) {
        [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_CLIMATE_SENSOR_TEMPERATURE options:NSKeyValueObservingOptionNew context:NULL];
        [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_CLIMATE_SENSOR_HUMIDITY options:NSKeyValueObservingOptionNew context:NULL];
        [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_CLIMATE_SENSOR_LIGHT options:NSKeyValueObservingOptionNew context:NULL];        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = YES;
    
    _tempLabel.text = [NSString stringWithFormat:@"%.1f", [SensorHelper getTemperatureValue:[(ClimateSensor*)self.sensor temperature]]];
    _humidityLabel.text = [NSString stringWithFormat:@"%.1f", [SensorHelper getHumidityValue:[(ClimateSensor*)self.sensor humidity]]];
    _lightLabel.text = [NSString stringWithFormat:@"%.f", [(ClimateSensor*)self.sensor light]];
    
    _temperatureSparkLine.labelText = @"";
    _temperatureSparkLine.showCurrentValue = NO;
    [DatabaseManager lastSensorValuesForSensor:self.sensor andType:kValueTypeTemperature completionHandler:^(NSMutableArray *item) {
        _temperatureSparkLine.dataValues = item;
    }];
    
    _humiditySparkLine.labelText = @"";
    _humiditySparkLine.showCurrentValue = NO;
    [DatabaseManager lastSensorValuesForSensor:self.sensor andType:kValueTypeHumidity completionHandler:^(NSMutableArray *item) {
        _humiditySparkLine.dataValues = item;
    }];
    
    _lightSparkLine.labelText = @"";
    _lightSparkLine.showCurrentValue = NO;
    [DatabaseManager lastSensorValuesForSensor:self.sensor andType:kValueTypeLight completionHandler:^(NSMutableArray *item) {
        _lightSparkLine.dataValues = item;
    }];
    
    ClimateSensor *climateSensor = (ClimateSensor *)[self sensor];
    
    _tempSwitch.on = [climateSensor isTempAlarmActive];
    _lightSwitch.on = [climateSensor isLightAlarmActive];
    _humiditySwitch.on = [climateSensor isHumidityAlarmActive];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_CLIMATE_SENSOR_TEMPERATURE];
    [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_CLIMATE_SENSOR_HUMIDITY];
    [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_CLIMATE_SENSOR_LIGHT];
}

- (IBAction)switchAction:(id)sender
{
    UISwitch *switchControl = (UISwitch *)sender;
    ClimateSensor *climateSensor = (ClimateSensor *)[self sensor];
    if ([switchControl isEqual:_tempSwitch]) {
        climateSensor.isTempAlarmActive = [switchControl isOn];
        self.currentAlarmService = [climateSensor tempAlarm];
    }
    else if ([switchControl isEqual:_lightSwitch]) {
        climateSensor.isLightAlarmActive = [switchControl isOn];
        self.currentAlarmService = [climateSensor lightAlarm];
    }
    else if ([switchControl isEqual:_humiditySwitch]) {
        climateSensor.isHumidityAlarmActive = [switchControl isOn];
        self.currentAlarmService = [climateSensor humidityAlarm];
    }
    [climateSensor save:nil];
    if ([switchControl isOn]) {
        [self showSlider];
    }
    else {
        [self hideSlider:nil];
    }
}

- (void)showSlider {
    ClimateSensor *climateSensor = (ClimateSensor *)[self sensor];
    if ([self.currentAlarmService isEqual:[climateSensor tempAlarm]]) {
        self.rangeSlider.minimumRange = 2;
        self.rangeSlider.minimumValue = 20;
        self.rangeSlider.maximumValue = 50;
        self.rangeSlider.lowerValue = [climateSensor.tempAlarm minimumAlarmValue];
        self.rangeSlider.upperValue = [climateSensor.tempAlarm maximumAlarmValue];
    }
    else if ([self.currentAlarmService isEqual:[climateSensor lightAlarm]]) {
        self.rangeSlider.minimumRange = 2;
        self.rangeSlider.minimumValue = 20;
        self.rangeSlider.maximumValue = 50;
        self.rangeSlider.lowerValue = [climateSensor.lightAlarm minimumAlarmValue];
        self.rangeSlider.upperValue = [climateSensor.lightAlarm maximumAlarmValue];
    }
    else if ([self.currentAlarmService isEqual:[climateSensor humidityAlarm]]) {
        self.rangeSlider.minimumRange = 2;
        self.rangeSlider.minimumValue = 20;
        self.rangeSlider.maximumValue = 50;
        self.rangeSlider.lowerValue = [climateSensor.humidityAlarm minimumAlarmValue];
        self.rangeSlider.upperValue = [climateSensor.humidityAlarm maximumAlarmValue];
    }
    [super showSlider];
}

- (void)hideSlider:(id)sender {
    [super hideSlider:sender];
    if (sender) {
        [_currentAlarmService writeHighAlarmValue:self.rangeSlider.minimumValue];
        [_currentAlarmService writeHighAlarmValue:self.rangeSlider.maximumValue];
    }
}

#pragma mark - Value Observer

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    
    if ([keyPath isEqualToString:OBSERVER_KEY_PATH_CLIMATE_SENSOR_TEMPERATURE]) {
        _tempLabel.text = [NSString stringWithFormat:@"%.1f", [SensorHelper getTemperatureValue:[change objectForKey:NSKeyValueChangeNewKey]]];
        [DatabaseManager lastSensorValuesForSensor:self.sensor andType:kValueTypeTemperature completionHandler:^(NSMutableArray *item) {
            _temperatureSparkLine.dataValues = item;
        }];
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_CLIMATE_SENSOR_HUMIDITY]) {
        _humidityLabel.text = [NSString stringWithFormat:@"%.1f", [SensorHelper getHumidityValue:[change objectForKey:NSKeyValueChangeNewKey]]];
        [DatabaseManager lastSensorValuesForSensor:self.sensor andType:kValueTypeHumidity completionHandler:^(NSMutableArray *item) {
            _humiditySparkLine.dataValues = item;
        }];
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_CLIMATE_SENSOR_LIGHT]) {
        _lightLabel.text = [NSString stringWithFormat:@"%.f", [[change objectForKey:NSKeyValueChangeNewKey] floatValue]];
        [DatabaseManager lastSensorValuesForSensor:self.sensor andType:kValueTypeLight completionHandler:^(NSMutableArray *item) {
            _lightSparkLine.dataValues = item;
        }];
    }
}

@end
