//
//  SensorCell.m
//  Wimoto
//
//  Created by MC700 on 12/9/13.
//
//

#import "SensorCell.h"

@interface SensorCell ()

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *systemIdLabel;
@property (nonatomic, weak) IBOutlet UILabel *rssiLabel;

@end

@implementation SensorCell

- (void)setSensor:(Sensor *)sensor {
    [_sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_SENSOR_RSSI];
    
    _sensor = sensor;
    
    _titleLabel.text = _sensor.name;
    _systemIdLabel.text = _sensor.uniqueIdentifier;
    
    [_sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_SENSOR_RSSI options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)dealloc {
    [_sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_SENSOR_RSSI];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:OBSERVER_KEY_PATH_SENSOR_RSSI]) {
        NSLog(@"------- %@", [change objectForKey:NSKeyValueChangeNewKey]);
        _rssiLabel.text = [NSString stringWithFormat:@"%@dB", [change objectForKey:NSKeyValueChangeNewKey]];
    }
}

@end
