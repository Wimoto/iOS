//
//  RightMenuCell.m
//  Wimoto
//
//  Created by Danny Kokarev on 03.12.13.
//
//

#import "RightMenuCell.h"

@interface RightMenuCell ()

@property (nonatomic, weak) IBOutlet UILabel *sensorNameLabel;

@end

@implementation RightMenuCell

- (void)setSensor:(Sensor *)sensor {
    _sensor = sensor;
    
    NSString *title = @"";
    switch (sensor.type) {
        case kSensorTypeClimate:
            title = @"Climate Sensor";
            break;
        case kSensorTypeGrow:
            title = @"Grow Sensor";
            break;
        case kSensorTypeThermo:
            title = @"Thermo Sensor";
            break;
        case kSensorTypeSentry:
            title = @"Sentry Sensor";
            break;
        case kSensorTypeWater:
            title = @"Water Sensor";
            break;
        default:
            break;
    }
    
    _sensorNameLabel.text = title;
}

@end
