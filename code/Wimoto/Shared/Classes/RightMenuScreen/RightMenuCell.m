//
//  RightMenuCell.m
//  Wimoto
//
//  Created by Danny Kokarev on 03.12.13.
//
//

#import "RightMenuCell.h"
#import "Sensor.h"

@interface RightMenuCell ()

@property (nonatomic, weak) IBOutlet UILabel *sensorNameLabel;

@end

@implementation RightMenuCell

- (void)setSensorEntity:(SensorEntity *)sensorEntity {
    [_sensorEntity removeObserver:self forKeyPath:SENSOR_ENTITY_NAME];
    _sensorEntity = sensorEntity;
    [_sensorEntity addObserver:self forKeyPath:SENSOR_ENTITY_NAME options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial context:NULL];
}

- (void)dealloc {
    [_sensorEntity removeObserver:self forKeyPath:SENSOR_ENTITY_NAME];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:SENSOR_ENTITY_NAME]) {
        NSString *nameString = [change objectForKey:NSKeyValueChangeNewKey];
        if ([nameString isKindOfClass:[NSString class]]) {
            _sensorNameLabel.text = nameString;
        }
    }
}

@end
