//
//  WPTemperatureLabel.m
//  Wimoto
//
//  Created by MacBook on 11/05/2015.
//
//

#import "WPTemperatureLabel.h"

@interface  WPTemperatureLabel()

@end

@implementation WPTemperatureLabel

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(settingsNotification:)
                                                 name:NSUserDefaultsDidChangeNotification
                                               object:nil];
    [self updateWithDefaults:[NSUserDefaults standardUserDefaults]];
}

- (void)dealloc {
    @try {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    @catch (NSException *exception) {
        //
    }
}

- (void)settingsNotification:(NSNotification *)notification {
    [self updateWithDefaults:[notification object]];
}

- (void)updateWithDefaults:(NSUserDefaults *)userDefaults {
    NSString *cOrFString = [userDefaults objectForKey:@"cOrF"];
    self.tempMeasure = ([cOrFString isEqualToString:@"C"])?kTemperatureMeasureCelsius:kTemperatureMeasureFahrenheit;
}

@end
