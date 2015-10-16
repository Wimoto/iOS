//
//  DemoClimateSensorDetailsViewController.m
//  Wimoto
//
//  Created by MC700 on 30.10.14.
//
//

#import "DemoClimateSensorDetailsViewController.h"
#import "Wimoto-Swift.h"

@interface DemoClimateSensorDetailsViewController ()

@end

@implementation DemoClimateSensorDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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
    __weak typeof(self) weakSelf = self;
    if ([keyPath isEqualToString:OBSERVER_KEY_PATH_CLIMATE_SENSOR_TEMPERATURE]) {
        [self.lastUpdateLabel refresh];
        
        [self.tempView setTemperature:[sensor temperature]];
        [self.sensor.entity latestValuesWithType:kValueTypeTemperature completionHandler:^(NSArray *result) {
            weakSelf.temperatureSparkLine.dataValues = result;
            
            [weakSelf.temperatureChartLine clear];
            CGFloat x = 1;
            for (NSNumber *value in result) {
                [weakSelf.temperatureChartLine addPoint:CGPointMake(x, value.floatValue)];
                x++;
            }
            [weakSelf.chartView setNeedsDisplay];
        }];
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_CLIMATE_SENSOR_HUMIDITY]) {
        self.humidityLabel.text = [NSString stringWithFormat:@"%.1f", [[change objectForKey:NSKeyValueChangeNewKey] floatValue]];
        [self.sensor.entity latestValuesWithType:kValueTypeHumidity completionHandler:^(NSArray *result) {
            weakSelf.humiditySparkLine.dataValues = result;
            
            [weakSelf.humidityChartLine clear];
            CGFloat x = 1;
            for (NSNumber *value in result) {
                [weakSelf.humidityChartLine addPoint:CGPointMake(x, value.floatValue)];
                x++;
            }
            [weakSelf.chartView setNeedsDisplay];
        }];
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_CLIMATE_SENSOR_LIGHT]) {
        self.lightLabel.text = [NSString stringWithFormat:@"%.f", [[change objectForKey:NSKeyValueChangeNewKey] floatValue]];
        [self.sensor.entity latestValuesWithType:kValueTypeLight completionHandler:^(NSArray *result) {
            weakSelf.lightSparkLine.dataValues = result;
            
            [weakSelf.lightChartLine clear];
            CGFloat x = 1;
            for (NSNumber *value in result) {
                [weakSelf.lightChartLine addPoint:CGPointMake(x, value.floatValue)];
                x++;
            }
            [weakSelf.chartView setNeedsDisplay];
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
