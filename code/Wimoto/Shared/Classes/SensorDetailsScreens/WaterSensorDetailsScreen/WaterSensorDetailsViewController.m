//
//  WaterSensorDetailsViewController.m
//  Wimoto
//
//  Created by MC700 on 12/3/13.
//
//

#import "WaterSensorDetailsViewController.h"
#import "ASBSparkLineView.h"

#import "WaterSensor.h"

#import "DatabaseManager.h"

@interface WaterSensorDetailsViewController ()

@property (nonatomic, weak) IBOutlet UILabel *waterLevelLabel;
@property (nonatomic, weak) IBOutlet UILabel *contactSensorLabel;

@property (nonatomic, weak) IBOutlet ASBSparkLineView *levelSparkLine;

@end

@implementation WaterSensorDetailsViewController

- (id)initWithSensor:(Sensor*)sensor
{
    self = [super initWithSensor:sensor];
    if (self) {
        [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_WATER_SENSOR_LEVEL options:NSKeyValueObservingOptionNew context:NULL];
        [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_WATER_SENSOR_PRESENCE options:NSKeyValueObservingOptionNew context:NULL];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = YES;
    
    _waterLevelLabel.text = [NSString stringWithFormat:@"%.1f", [(WaterSensor*)self.sensor level]];
    _contactSensorLabel.text = ([(WaterSensor*)self.sensor presense])?@"YES":@"NO";
    
    _levelSparkLine.labelText = @"";
    _levelSparkLine.showCurrentValue = NO;
    _levelSparkLine.dataValues = [DatabaseManager lastSensorValuesForSensor:self.sensor andType:kValueTypeLevel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_WATER_SENSOR_LEVEL];
    [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_WATER_SENSOR_PRESENCE];
}

#pragma mark - Value Observer

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    
    if ([keyPath isEqualToString:OBSERVER_KEY_PATH_WATER_SENSOR_LEVEL]) {
        NSNumber *level = [change objectForKey:NSKeyValueChangeNewKey];
        
        _waterLevelLabel.text = [NSString stringWithFormat:@"%.1f", [level floatValue]];
        _levelSparkLine.dataValues = [DatabaseManager lastSensorValuesForSensor:self.sensor andType:kValueTypeLevel];
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_WATER_SENSOR_PRESENCE]) {
        _contactSensorLabel.text = ([[change objectForKey:NSKeyValueChangeNewKey] boolValue])?@"YES":@"NO";
    }
}

@end
