//
//  GrowSensorDetailsViewController.m
//  Wimoto
//
//  Created by MC700 on 12/3/13.
//
//

#import "GrowSensorDetailsViewController.h"
#import "GrowSensor.h"

@interface GrowSensorDetailsViewController ()

@property (nonatomic, weak) IBOutlet UILabel *soilTempLabel;
@property (nonatomic, weak) IBOutlet UILabel *soilMoistureLabel;
@property (nonatomic, weak) IBOutlet UILabel *lightLabel;

@end

@implementation GrowSensorDetailsViewController

- (id)initWithSensor:(Sensor*)sensor
{
    self = [super initWithSensor:sensor];
    if (self) {
        [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_GROW_SENSOR_LIGHT options:NSKeyValueObservingOptionNew context:NULL];
        [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_GROW_SENSOR_SOIL_MOISTURE options:NSKeyValueObservingOptionNew context:NULL];
        [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_GROW_SENSOR_SOIL_TEMPERATURE options:NSKeyValueObservingOptionNew context:NULL];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    _soilTempLabel.text = [NSString stringWithFormat:@"%.1f", [(GrowSensor*)self.sensor soilTemperature]];
    _soilMoistureLabel.text = [NSString stringWithFormat:@"%.1f", [(GrowSensor*)self.sensor soilMoisture]];
    _lightLabel.text = [NSString stringWithFormat:@"%.f", [(GrowSensor*)self.sensor light]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_GROW_SENSOR_LIGHT];
    [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_GROW_SENSOR_SOIL_MOISTURE];
    [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_GROW_SENSOR_SOIL_TEMPERATURE];
}

#pragma mark - Value Observer

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    
    if ([keyPath isEqualToString:OBSERVER_KEY_PATH_GROW_SENSOR_SOIL_TEMPERATURE]) {
        _soilTempLabel.text = [NSString stringWithFormat:@"%.1f", [[change objectForKey:NSKeyValueChangeNewKey] floatValue]];
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_GROW_SENSOR_SOIL_MOISTURE]) {
        _soilMoistureLabel.text = [NSString stringWithFormat:@"%.1f", [[change objectForKey:NSKeyValueChangeNewKey] floatValue]];
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_GROW_SENSOR_LIGHT]) {
        _lightLabel.text = [NSString stringWithFormat:@"%.f", [[change objectForKey:NSKeyValueChangeNewKey] floatValue]];
    }
}

@end
