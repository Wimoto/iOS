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
#import "LastUpdateLabel.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface SensorViewController : AppViewController <AlarmSliderDelegate, UITextFieldDelegate, SensorDataReadingDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) Sensor *sensor;
@property (nonatomic, strong) UISwitch *currentSwitch;
@property (nonatomic, weak) IBOutlet UITextField *sensorNameField;
@property (nonatomic, weak) IBOutlet LastUpdateLabel *lastUpdateLabel;

- (id)initWithSensor:(Sensor *)sensor;

@end
