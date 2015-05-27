//
//  WPTemperaturePickerView.m
//  Wimoto
//
//  Created by MacBook on 11/05/2015.
//
//

#import "WPTemperaturePickerView.h"
#import "AppConstants.h"
#import "SensorHelper.h"

@interface WPTemperaturePickerView ()

@property (nonatomic) TemperatureMeasure tempMeasure;

@end

@implementation WPTemperaturePickerView

+ (id)showWithMinValue:(float)minValue maxValue:(float)maxValue save:(SaveBlock)saveBlock cancel:(CancelBlock)cancelBlock {
    WPTemperaturePickerView *pickerView = [[WPTemperaturePickerView alloc] init];
    [pickerView showWithMinValue:minValue maxValue:maxValue save:saveBlock cancel:cancelBlock];
    return pickerView;
}

- (id)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(settingsNotification:)
                                                     name:NSUserDefaultsDidChangeNotification
                                                   object:nil];
        [self updateWithDefaults:[NSUserDefaults standardUserDefaults]];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)settingsNotification:(NSNotification *)notification {
    [self updateWithDefaults:[notification object]];
}

- (void)updateWithDefaults:(NSUserDefaults *)userDefaults {
    NSString *cOrFString = [userDefaults objectForKey:@"cOrF"];
    self.tempMeasure = ([cOrFString isEqualToString:@"C"])?kTemperatureMeasureCelsius:kTemperatureMeasureFahrenheit;
}

- (void)showWithMinValue:(float)minValue maxValue:(float)maxValue save:(SaveBlock)saveBlock cancel:(CancelBlock)cancelBlock {
    if (_tempMeasure == kTemperatureMeasureFahrenheit) {
        minValue = [SensorHelper fahrenheitFromCelcius:minValue];
        maxValue = [SensorHelper fahrenheitFromCelcius:maxValue];
    }
    [super showWithMinValue:minValue maxValue:maxValue save:saveBlock cancel:cancelBlock];
}

- (void)setLowerValue:(float)lowerValue {
    [super setLowerValue:(_tempMeasure == kTemperatureMeasureFahrenheit)?[SensorHelper fahrenheitFromCelcius:lowerValue]:lowerValue];
}

- (void)setUpperValue:(float)upperValue {
    [super setUpperValue:(_tempMeasure == kTemperatureMeasureFahrenheit)?[SensorHelper fahrenheitFromCelcius:upperValue]:upperValue];
}

- (float)upperValue {
    return (_tempMeasure == kTemperatureMeasureFahrenheit)?[SensorHelper celsiusFromFahrenheit:[super upperValue]]:[super upperValue];
}

- (float)lowerValue {
    return (_tempMeasure == kTemperatureMeasureFahrenheit)?[SensorHelper celsiusFromFahrenheit:[super lowerValue]]:[super lowerValue];
}

@end
