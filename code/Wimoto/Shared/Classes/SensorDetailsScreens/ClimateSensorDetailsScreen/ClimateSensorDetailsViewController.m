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

@interface ClimateSensorDetailsViewController ()

@property (nonatomic, strong) NSMutableArray *mutableArray;

@property (nonatomic, weak) IBOutlet UILabel *tempLabel;
@property (nonatomic, weak) IBOutlet UILabel *humidityLabel;
@property (nonatomic, weak) IBOutlet UILabel *lightLabel;

@property (nonatomic, weak) IBOutlet ASBSparkLineView *temperatureSparkLine;
@property (nonatomic, weak) IBOutlet ASBSparkLineView *humiditySparkLine;
@property (nonatomic, weak) IBOutlet ASBSparkLineView *lightSparkLine;

@end

@implementation ClimateSensorDetailsViewController

- (id)initWithSensor:(Sensor*)sensor
{
    self = [super initWithSensor:sensor];
    if (self) {
        [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_CLIMATE_SENSOR_TEMPERATURE options:NSKeyValueObservingOptionNew context:NULL];
        [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_CLIMATE_SENSOR_HUMIDITY options:NSKeyValueObservingOptionNew context:NULL];
        [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_CLIMATE_SENSOR_LIGHT options:NSKeyValueObservingOptionNew context:NULL];
        
        _mutableArray = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = YES;
    
    _tempLabel.text = [NSString stringWithFormat:@"%.1f", [(ClimateSensor*)self.sensor temperature]];
    _humidityLabel.text = [NSString stringWithFormat:@"%.1f", [(ClimateSensor*)self.sensor humidity]];
    _lightLabel.text = [NSString stringWithFormat:@"%.f", [(ClimateSensor*)self.sensor light]];
    
    _temperatureSparkLine.labelText = @"";
    _temperatureSparkLine.showCurrentValue = NO;
    _temperatureSparkLine.dataValues = [DatabaseManager lastSensorValuesForSensor:self.sensor andType:kValueTypeTemperature];
    
    _humiditySparkLine.labelText = @"";
    _humiditySparkLine.showCurrentValue = NO;
    _humiditySparkLine.dataValues = [DatabaseManager lastSensorValuesForSensor:self.sensor andType:kValueTypeHumidity];
    
    _lightSparkLine.labelText = @"";
    _lightSparkLine.showCurrentValue = NO;
    _lightSparkLine.dataValues = [DatabaseManager lastSensorValuesForSensor:self.sensor andType:kValueTypeLight];
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

#pragma mark - Value Observer

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    
    if ([keyPath isEqualToString:OBSERVER_KEY_PATH_CLIMATE_SENSOR_TEMPERATURE]) {
        NSNumber *temperature = [change objectForKey:NSKeyValueChangeNewKey];
        
        _tempLabel.text = [NSString stringWithFormat:@"%.1f", [temperature floatValue]];
        _temperatureSparkLine.dataValues = [DatabaseManager lastSensorValuesForSensor:self.sensor andType:kValueTypeTemperature];
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_CLIMATE_SENSOR_HUMIDITY]) {
        _humidityLabel.text = [NSString stringWithFormat:@"%.1f", [[change objectForKey:NSKeyValueChangeNewKey] floatValue]];
        
        _humiditySparkLine.dataValues = [DatabaseManager lastSensorValuesForSensor:self.sensor andType:kValueTypeHumidity];
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_CLIMATE_SENSOR_LIGHT]) {
        _lightLabel.text = [NSString stringWithFormat:@"%.f", [[change objectForKey:NSKeyValueChangeNewKey] floatValue]];
        
        _lightSparkLine.dataValues = [DatabaseManager lastSensorValuesForSensor:self.sensor andType:kValueTypeLight];
    }
}

@end
