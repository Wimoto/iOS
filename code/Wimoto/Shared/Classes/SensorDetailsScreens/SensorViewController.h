//
//  SensorViewController.h
//  Wimoto
//
//  Created by MC700 on 12/13/13.
//
//

#define SENSOR_VALUE_PLACEHOLDER        @"--"

#import "AppViewController.h"
#import "Sensor.h"
#import "NMRangeSlider.h"
#import "AlarmSlider.h"

@interface SensorViewController : AppViewController <AlarmSliderDelegate, SensorDelegate, UITextFieldDelegate>

@property (nonatomic, strong) Sensor *sensor;
@property (nonatomic, strong) UISwitch *currentSwitch;
@property (nonatomic, weak) IBOutlet UITextField *sensorNameField;
@property (nonatomic, weak) IBOutlet UILabel *lastUpdateLabel;
@property (nonatomic, strong) NSTimer *lastUpdateTimer;

- (id)initWithSensor:(Sensor *)sensor;
- (void)showSlider;
- (void)hideSlider;
- (void)refreshLastUpdateLabel;

@end
