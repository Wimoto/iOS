//
//  GrowSensorDetailsViewController.m
//  Wimoto
//
//  Created by MC700 on 12/3/13.
//
//

#import "GrowSensorDetailsViewController.h"
#import "ASBSparkLineView.h"
#import "GrowSensor.h"
#import "DatabaseManager.h"

@interface GrowSensorDetailsViewController ()

@property (nonatomic, weak) IBOutlet UILabel *soilTempLabel;
@property (nonatomic, weak) IBOutlet UILabel *soilMoistureLabel;
@property (nonatomic, weak) IBOutlet UILabel *lightLabel;

@property (nonatomic, weak) IBOutlet ASBSparkLineView *soilTempSparkLine;
@property (nonatomic, weak) IBOutlet ASBSparkLineView *soilMoistureSparkLine;
@property (nonatomic, weak) IBOutlet ASBSparkLineView *lightSparkLine;

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
    
    _soilTempSparkLine.labelText = @"";
    _soilTempSparkLine.showCurrentValue = NO;
    [DatabaseManager lastSensorValuesForSensor:self.sensor andType:kValueTypeSoilTemperature completionHandler:^(NSMutableArray *item) {
        _soilTempSparkLine.dataValues = item;
    }];
    
    _soilMoistureSparkLine.labelText = @"";
    _soilMoistureSparkLine.showCurrentValue = NO;
    [DatabaseManager lastSensorValuesForSensor:self.sensor andType:kValueTypeSoilHumidity completionHandler:^(NSMutableArray *item) {
        _soilMoistureSparkLine.dataValues = item;
    }];
    
    _lightSparkLine.labelText = @"";
    _lightSparkLine.showCurrentValue = NO;
    [DatabaseManager lastSensorValuesForSensor:self.sensor andType:kValueTypeLight completionHandler:^(NSMutableArray *item) {
        _lightSparkLine.dataValues = item;
    }];
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
        [DatabaseManager lastSensorValuesForSensor:self.sensor andType:kValueTypeSoilTemperature completionHandler:^(NSMutableArray *item) {
            _soilTempSparkLine.dataValues = item;
        }];
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_GROW_SENSOR_SOIL_MOISTURE]) {
        _soilMoistureLabel.text = [NSString stringWithFormat:@"%.1f", [[change objectForKey:NSKeyValueChangeNewKey] floatValue]];
        [DatabaseManager lastSensorValuesForSensor:self.sensor andType:kValueTypeSoilHumidity completionHandler:^(NSMutableArray *item) {
            _soilMoistureSparkLine.dataValues = item;
        }];
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_GROW_SENSOR_LIGHT]) {
        _lightLabel.text = [NSString stringWithFormat:@"%.f", [[change objectForKey:NSKeyValueChangeNewKey] floatValue]];
        [DatabaseManager lastSensorValuesForSensor:self.sensor andType:kValueTypeLight completionHandler:^(NSMutableArray *item) {
            _lightSparkLine.dataValues = item;
        }];
    }
}

@end
