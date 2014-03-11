//
//  SentrySensorDetailsViewController.m
//  Wimoto
//
//  Created by MC700 on 12/3/13.
//
//

#import "SentrySensorDetailsViewController.h"
#import "ASBSparkLineView.h"
#import "DatabaseManager.h"
#import "SentrySensor.h"

@interface SentrySensorDetailsViewController ()

@property (nonatomic, weak) IBOutlet UILabel *accelerometerLabel;
@property (nonatomic, weak) IBOutlet UILabel *pasInfraredLabel;

@property (nonatomic, weak) IBOutlet ASBSparkLineView *accelerometerSparkLine;
@property (nonatomic, weak) IBOutlet ASBSparkLineView *pasInfraredSparkLine;

@end

@implementation SentrySensorDetailsViewController

- (id)initWithSensor:(Sensor*)sensor
{
    self = [super initWithSensor:sensor];
    if (self) {
        [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_SENTRY_SENSOR_ACCELEROMETER options:NSKeyValueObservingOptionNew context:NULL];
        [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_SENTRY_SENSOR_PASSIVE_INFRARED options:NSKeyValueObservingOptionNew context:NULL];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = YES;
    
    _accelerometerLabel.text = [NSString stringWithFormat:@"%.1f", [(SentrySensor*)self.sensor accelerometer]];
    _pasInfraredLabel.text = [NSString stringWithFormat:@"%.1f", [(SentrySensor*)self.sensor pasInfrared]];
    
    _accelerometerSparkLine.labelText = @"";
    _accelerometerSparkLine.showCurrentValue = NO;
    [DatabaseManager lastSensorValuesForSensor:self.sensor andType:kValueTypeAccelerometer completionHandler:^(NSMutableArray *item) {
        _accelerometerSparkLine.dataValues = item;
    }];
    
    _pasInfraredSparkLine.labelText = @"";
    _pasInfraredSparkLine.showCurrentValue = NO;
    [DatabaseManager lastSensorValuesForSensor:self.sensor andType:kValueTypePassiveInfrared completionHandler:^(NSMutableArray *item) {
        _pasInfraredSparkLine.dataValues = item;
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_SENTRY_SENSOR_ACCELEROMETER];
    [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_SENTRY_SENSOR_PASSIVE_INFRARED];
}

#pragma mark - Value Observer

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    
    if ([keyPath isEqualToString:OBSERVER_KEY_PATH_SENTRY_SENSOR_ACCELEROMETER]) {
        _accelerometerLabel.text = [NSString stringWithFormat:@"%.1f", [[change objectForKey:NSKeyValueChangeNewKey] floatValue]];
        [DatabaseManager lastSensorValuesForSensor:self.sensor andType:kValueTypeAccelerometer completionHandler:^(NSMutableArray *item) {
            _accelerometerSparkLine.dataValues = item;
        }];
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_SENTRY_SENSOR_PASSIVE_INFRARED]) {
        _pasInfraredLabel.text = [NSString stringWithFormat:@"%.1f", [[change objectForKey:NSKeyValueChangeNewKey] floatValue]];
        [DatabaseManager lastSensorValuesForSensor:self.sensor andType:kValueTypePassiveInfrared completionHandler:^(NSMutableArray *item) {
            _pasInfraredSparkLine.dataValues = item;
        }];
    }
}

@end
