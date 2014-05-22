//
//  SensorViewController.h
//  Wimoto
//
//  Created by MC700 on 12/13/13.
//
//

#import "AppViewController.h"
#import "Sensor.h"
#import "NMRangeSlider.h"

@interface SensorViewController : AppViewController

@property (nonatomic, strong) Sensor *sensor;
@property (nonatomic, strong) UISwitch *currentSwitch;
@property (nonatomic, strong) NMRangeSlider *rangeSlider;
@property (nonatomic, strong) UIView *rangeContainer;
@property (nonatomic, strong) UILabel *alarmMinValueLabel;
@property (nonatomic, strong) UILabel *alarmMaxValueLabel;

- (id)initWithSensor:(Sensor *)sensor;
- (void)showSlider;
- (void)hideSlider:(id)sender;

@end
