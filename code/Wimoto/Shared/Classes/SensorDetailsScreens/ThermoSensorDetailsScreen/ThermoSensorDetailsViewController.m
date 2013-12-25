//
//  ThermoSensorDetailsViewController.m
//  Wimoto
//
//  Created by MC700 on 12/3/13.
//
//

#import "ThermoSensorDetailsViewController.h"
#import "ASBSparkLineView.h"
#import "DatabaseManager.h"
#import "ThermoSensor.h"

@interface ThermoSensorDetailsViewController ()

@property (nonatomic, weak) IBOutlet UILabel *irTempLabel;
@property (nonatomic, weak) IBOutlet UILabel *probeTempLabel;

@property (nonatomic, weak) IBOutlet ASBSparkLineView *irTempSparkLine;
@property (nonatomic, weak) IBOutlet ASBSparkLineView *probeTempSparkLine;

@end

@implementation ThermoSensorDetailsViewController

- (id)initWithSensor:(Sensor*)sensor
{
    self = [super initWithSensor:sensor];
    if (self) {
        [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_THERMO_SENSOR_IR_TEMP options:NSKeyValueObservingOptionNew context:NULL];
        [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_THERMO_SENSOR_PROBE_TEMP options:NSKeyValueObservingOptionNew context:NULL];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = YES;
    
    _irTempLabel.text = [NSString stringWithFormat:@"%.1f", [(ThermoSensor*)self.sensor irTemp]];
    _probeTempLabel.text = [NSString stringWithFormat:@"%.1f", [(ThermoSensor*)self.sensor probeTemp]];
    
    _irTempSparkLine.labelText = @"";
    _irTempSparkLine.showCurrentValue = NO;
    _irTempSparkLine.dataValues = [DatabaseManager lastSensorValuesForSensor:self.sensor andType:kValueTypeIRTemperature];
    
    _probeTempSparkLine.labelText = @"";
    _probeTempSparkLine.showCurrentValue = NO;
    _probeTempSparkLine.dataValues = [DatabaseManager lastSensorValuesForSensor:self.sensor andType:kValueTypeProbeTemperature];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_THERMO_SENSOR_IR_TEMP];
    [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_THERMO_SENSOR_PROBE_TEMP];
}

#pragma mark - Value Observer

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    
    if ([keyPath isEqualToString:OBSERVER_KEY_PATH_THERMO_SENSOR_IR_TEMP]) {
        _irTempLabel.text = [NSString stringWithFormat:@"%.1f", [[change objectForKey:NSKeyValueChangeNewKey] floatValue]];
        _irTempSparkLine.dataValues = [DatabaseManager lastSensorValuesForSensor:self.sensor andType:kValueTypeIRTemperature];
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_THERMO_SENSOR_PROBE_TEMP]) {
        _probeTempLabel.text = [NSString stringWithFormat:@"%.1f", [[change objectForKey:NSKeyValueChangeNewKey] floatValue]];
        _probeTempSparkLine.dataValues = [DatabaseManager lastSensorValuesForSensor:self.sensor andType:kValueTypeProbeTemperature];
    }
}

@end
