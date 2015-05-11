//
//  ClimateSensorDetailsViewController.h
//  Wimoto
//
//  Created by MC700 on 12/3/13.
//
//

#import "SensorViewController.h"
#import "ASBSparkLineView.h"
#import "ClimateSensor.h"
#import "SensorHelper.h"

#import "WPTemperatureValueLabel.h"

@interface ClimateSensorDetailsViewController : SensorViewController

@property (nonatomic, weak) IBOutlet WPTemperatureValueLabel *tempLabel;
@property (nonatomic, weak) IBOutlet UILabel *humidityLabel;
@property (nonatomic, weak) IBOutlet UILabel *lightLabel;

@property (nonatomic, weak) IBOutlet ASBSparkLineView *temperatureSparkLine;
@property (nonatomic, weak) IBOutlet ASBSparkLineView *humiditySparkLine;
@property (nonatomic, weak) IBOutlet ASBSparkLineView *lightSparkLine;

@property (nonatomic, weak) IBOutlet UISwitch *tempSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *lightSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *humiditySwitch;

@property (nonatomic, weak) IBOutlet WPTemperatureValueLabel *tempHighValueLabel;
@property (nonatomic, weak) IBOutlet WPTemperatureValueLabel *tempLowValueLabel;
@property (nonatomic, weak) IBOutlet UILabel *humidityHighValueLabel;
@property (nonatomic, weak) IBOutlet UILabel *humidityLowValueLabel;
@property (nonatomic, weak) IBOutlet UILabel *lightHighValueLabel;
@property (nonatomic, weak) IBOutlet UILabel *lightLowValueLabel;

@property (nonatomic, weak) IBOutlet UILabel *tempConversionLabel;

@property (nonatomic, weak) IBOutlet UIView *tempAlarmContainer;
@property (nonatomic, weak) IBOutlet UIView *humidityAlarmContainer;
@property (nonatomic, weak) IBOutlet UIView *lightAlarmContainer;

- (IBAction)temperatureAlarmAction:(id)sender;
- (IBAction)humidityAlarmAction:(id)sender;
- (IBAction)lightAlarmAction:(id)sender;

@end