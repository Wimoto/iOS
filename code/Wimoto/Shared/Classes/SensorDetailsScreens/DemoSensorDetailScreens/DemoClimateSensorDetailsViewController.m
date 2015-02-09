//
//  DemoClimateSensorDetailsViewController.m
//  Wimoto
//
//  Created by MC700 on 30.10.14.
//
//

#import "DemoClimateSensorDetailsViewController.h"

@interface DemoClimateSensorDetailsViewController ()

@end

@implementation DemoClimateSensorDetailsViewController

- (id)initWithSensor:(Sensor*)sensor {
    BOOL isIpad = (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad);
    self = [super initWithNibName:[NSString stringWithFormat:@"%@_%@", NSStringFromClass(self.superclass), (isIpad)?@"iPad":@"iPhone"] bundle:nil];
    if (self) {
        self.sensor = sensor;
    }
    return self;
}

- (id)init {
    BOOL isIpad = (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad);
    self = [super initWithNibName:[NSString stringWithFormat:@"%@_%@", NSStringFromClass(self.superclass), (isIpad)?@"iPad":@"iPhone"] bundle:nil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tempLabel.text = SENSOR_VALUE_PLACEHOLDER;
    self.humidityLabel.text = SENSOR_VALUE_PLACEHOLDER;
    self.lightLabel.text = SENSOR_VALUE_PLACEHOLDER;
    self.view.backgroundColor = [UIColor colorWithRed:(102.f/255.f) green:(204.f/255.f) blue:(255.f/255.f) alpha:1.f];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Value Observer

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:OBSERVER_KEY_PATH_CLIMATE_SENSOR_TEMPERATURE]) {
        self.lastUpdateLabel.text = @"Just now";
        if ([self.lastUpdateTimer isValid]) {
            [self.lastUpdateTimer invalidate];
        }
        self.lastUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:15.0 target:self selector:@selector(refreshLastUpdateLabel) userInfo:nil repeats:YES];
        self.tempLabel.text = [NSString stringWithFormat:@"%.1f", [[change objectForKey:NSKeyValueChangeNewKey] floatValue]];
        [self.sensor.entity latestValuesWithType:kValueTypeTemperature completionHandler:^(NSArray *result) {
            self.temperatureSparkLine.dataValues = result;
        }];
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_CLIMATE_SENSOR_HUMIDITY]) {
        self.humidityLabel.text = [NSString stringWithFormat:@"%.1f", [[change objectForKey:NSKeyValueChangeNewKey] floatValue]];
        [self.sensor.entity latestValuesWithType:kValueTypeHumidity completionHandler:^(NSArray *result) {
            self.humiditySparkLine.dataValues = result;
        }];
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_CLIMATE_SENSOR_LIGHT]) {
        self.lightLabel.text = [NSString stringWithFormat:@"%.f", [[change objectForKey:NSKeyValueChangeNewKey] floatValue]];
        [self.sensor.entity latestValuesWithType:kValueTypeLight completionHandler:^(NSArray *result) {
            self.lightSparkLine.dataValues = result;
        }];
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_CLIMATE_SENSOR_TEMPERATURE_ALARM_STATE]) {
        self.tempSwitch.on = ([[change objectForKey:NSKeyValueChangeNewKey] intValue] == kAlarmStateEnabled)?YES:NO;
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_CLIMATE_SENSOR_HUMIDITY_ALARM_STATE]) {
        self.humiditySwitch.on = ([[change objectForKey:NSKeyValueChangeNewKey] intValue] == kAlarmStateEnabled)?YES:NO;
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_CLIMATE_SENSOR_LIGHT_ALARM_STATE]) {
        self.lightSwitch.on = ([[change objectForKey:NSKeyValueChangeNewKey] intValue] == kAlarmStateEnabled)?YES:NO;
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_CLIMATE_SENSOR_TEMPERATURE_ALARM_LOW]) {
        float value = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
        self.tempLowValueLabel.text = [NSString stringWithFormat:@"%.f", value];
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_CLIMATE_SENSOR_TEMPERATURE_ALARM_HIGH]) {
        float value = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
        self.tempHighValueLabel.text = [NSString stringWithFormat:@"%.f", value];
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_CLIMATE_SENSOR_HUMIDITY_ALARM_LOW]) {
        float value = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
        self.humidityLowValueLabel.text = [NSString stringWithFormat:@"%.f", value];
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_CLIMATE_SENSOR_HUMIDITY_ALARM_HIGH]) {
        float value = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
        self.humidityHighValueLabel.text = [NSString stringWithFormat:@"%.f", value];
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_CLIMATE_SENSOR_LIGHT_ALARM_LOW]) {
        float value = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
        self.lightLowValueLabel.text = [NSString stringWithFormat:@"%.f", value];
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_CLIMATE_SENSOR_LIGHT_ALARM_HIGH]) {
        float value = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
        self.lightHighValueLabel.text = [NSString stringWithFormat:@"%.f", value];
    }
}

@end
