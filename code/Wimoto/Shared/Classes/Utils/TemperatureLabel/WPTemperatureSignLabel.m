//
//  WPTemperatureSignLabel.m
//  Wimoto
//
//  Created by MacBook on 11/05/2015.
//
//

#import "WPTemperatureSignLabel.h"

@implementation WPTemperatureSignLabel

- (void)setTempMeasure:(TemperatureMeasure)tempMeasure {
    [super setTempMeasure:tempMeasure];
    
    [self setText:(self.tempMeasure == kTemperatureMeasureFahrenheit)?@"˚F":@"˚C"];
}

@end
