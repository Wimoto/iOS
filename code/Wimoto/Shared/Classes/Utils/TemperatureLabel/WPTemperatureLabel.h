//
//  WPTemperatureLabel.h
//  Wimoto
//
//  Created by MacBook on 11/05/2015.
//
//

#import <UIKit/UIKit.h>

typedef enum {
    kTemperatureMeasureFahrenheit = 0,
    kTemperatureMeasureCelsius
} TemperatureMeasure;

@interface WPTemperatureLabel : UILabel

@property (nonatomic) TemperatureMeasure tempMeasure;

@end
