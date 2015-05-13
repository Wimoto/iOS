//
//  ThermoSensorDetailsViewController.h
//  Wimoto
//
//  Created by MC700 on 12/3/13.
//
//

#import "SensorViewController.h"
#import "ASBSparkLineView.h"
#import "ThermoSensor.h"
#import "AppConstants.h"

#import "WPTemperatureValueLabel.h"

@interface ThermoSensorDetailsViewController : SensorViewController

@property (nonatomic, weak) IBOutlet WPTemperatureValueLabel *irTempLabel;
@property (nonatomic, weak) IBOutlet WPTemperatureValueLabel *probeTempLabel;

@property (nonatomic, weak) IBOutlet ASBSparkLineView *irTempSparkLine;
@property (nonatomic, weak) IBOutlet ASBSparkLineView *probeTempSparkLine;

@property (nonatomic, weak) IBOutlet UISwitch *irTempSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *probeTempSwitch;

@property (nonatomic, weak) IBOutlet WPTemperatureValueLabel *irTempHighValueLabel;
@property (nonatomic, weak) IBOutlet WPTemperatureValueLabel *irTempLowValueLabel;
@property (nonatomic, weak) IBOutlet WPTemperatureValueLabel *probeTempHighValueLabel;
@property (nonatomic, weak) IBOutlet WPTemperatureValueLabel *probeTempLowValueLabel;

@property (nonatomic, weak) IBOutlet UIView *irTempAlarmContainer;
@property (nonatomic, weak) IBOutlet UIView *probeTempAlarmContainer;

@property (nonatomic, strong) NSString *currentAlarmUUIDString;

- (IBAction)irTempAlarmAction:(id)sender;
- (IBAction)probeTempAlarmAction:(id)sender;

@end
