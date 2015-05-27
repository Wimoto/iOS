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
    self.tempView.text = SENSOR_VALUE_PLACEHOLDER;
    self.humidityLabel.text = SENSOR_VALUE_PLACEHOLDER;
    self.lightLabel.text = SENSOR_VALUE_PLACEHOLDER;
    self.view.backgroundColor = [UIColor colorWithRed:(102.f/255.f) green:(204.f/255.f) blue:(255.f/255.f) alpha:1.f];
    // Do any additional setup after loading the view.
    
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_CLIMATE_SENSOR_TEMPERATURE_ALARM_LOW options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial context:NULL];
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_CLIMATE_SENSOR_TEMPERATURE_ALARM_HIGH options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial context:NULL];
    
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_CLIMATE_SENSOR_HUMIDITY_ALARM_LOW options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial context:NULL];
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_CLIMATE_SENSOR_HUMIDITY_ALARM_HIGH options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial context:NULL];
    
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_CLIMATE_SENSOR_LIGHT_ALARM_LOW options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial context:NULL];
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_CLIMATE_SENSOR_LIGHT_ALARM_HIGH options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial context:NULL];
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
    DemoClimateSensor *sensor = (DemoClimateSensor*)self.sensor;
    
    if ([keyPath isEqualToString:OBSERVER_KEY_PATH_CLIMATE_SENSOR_TEMPERATURE]) {
        self.lastUpdateLabel.text = @"Just now";
        if ([self.lastUpdateTimer isValid]) {
            [self.lastUpdateTimer invalidate];
        }
        self.lastUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:15.0 target:self selector:@selector(refreshLastUpdateLabel) userInfo:nil repeats:YES];
        
        [self.tempView setTemperature:[sensor temperature]];
        
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
        [self.tempLowValueLabel setTemperature:sensor.temperatureAlarmLow];
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_CLIMATE_SENSOR_TEMPERATURE_ALARM_HIGH]) {
        [self.tempHighValueLabel setTemperature:sensor.temperatureAlarmHigh];
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_CLIMATE_SENSOR_HUMIDITY_ALARM_LOW]) {
        self.humidityLowValueLabel.text = [NSString stringWithFormat:@"%.f", sensor.humidityAlarmLow];
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_CLIMATE_SENSOR_HUMIDITY_ALARM_HIGH]) {
        self.humidityHighValueLabel.text = [NSString stringWithFormat:@"%.f", sensor.humidityAlarmHigh];
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_CLIMATE_SENSOR_LIGHT_ALARM_LOW]) {
        self.lightLowValueLabel.text = [NSString stringWithFormat:@"%.f", sensor.lightAlarmLow];
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_CLIMATE_SENSOR_LIGHT_ALARM_HIGH]) {
        self.lightHighValueLabel.text = [NSString stringWithFormat:@"%.f", sensor.lightAlarmHigh];
    }
}

@end
