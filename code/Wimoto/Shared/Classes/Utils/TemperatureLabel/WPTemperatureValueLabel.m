//
//  WPTemperatureValueLabel.m
//  Wimoto
//
//  Created by MacBook on 11/05/2015.
//
//

#import "WPTemperatureValueLabel.h"
#import "SensorHelper.h"

@interface WPTemperatureValueLabel ()

@property (nonatomic) float temperature;

@end

@implementation WPTemperatureValueLabel


- (void)setTempMeasure:(TemperatureMeasure)tempMeasure {
    [super setTempMeasure:tempMeasure];
    
    [self setTemperature:_temperature];
}

- (void)setTemperature:(float)temperature {
    _temperature = temperature;
    
    float resultValue = (self.tempMeasure == kTemperatureMeasureFahrenheit)?[SensorHelper fahrenheitFromCelcius:_temperature]:_temperature;
    [self setText:[NSString stringWithFormat:@"%.1f", resultValue]];
}

@end
