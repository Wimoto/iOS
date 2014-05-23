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
#import "AlarmSlider.h"

@interface SensorViewController : AppViewController <AlarmSliderDelegate, SensorDelegate>

@property (nonatomic, strong) Sensor *sensor;
@property (nonatomic, strong) UISwitch *currentSwitch;
@property (nonatomic, strong) AlarmSlider *alarmSlider;

- (id)initWithSensor:(Sensor *)sensor;
- (void)showSlider;
- (void)hideSlider;

@end
