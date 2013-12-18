//
//  SensorViewController.m
//  Wimoto
//
//  Created by MC700 on 12/13/13.
//
//

#import "SensorViewController.h"

@interface SensorViewController ()

@property (nonatomic, weak) IBOutlet UILabel *rssiLabel;

@end

@implementation SensorViewController

- (id)initWithSensor:(Sensor*)sensor {
    self = [super init];
    if (self) {
        _sensor = sensor;
        
        [_sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_SENSOR_RSSI options:NSKeyValueObservingOptionNew context:NULL];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _rssiLabel.text = [NSString stringWithFormat:@"%@dB", _sensor.rssi];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_SENSOR_RSSI];
}

#pragma mark - Value Observer

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:OBSERVER_KEY_PATH_SENSOR_RSSI]) {
        _rssiLabel.text = [NSString stringWithFormat:@"%@dB", [change objectForKey:NSKeyValueChangeNewKey]];
    }
}

@end
