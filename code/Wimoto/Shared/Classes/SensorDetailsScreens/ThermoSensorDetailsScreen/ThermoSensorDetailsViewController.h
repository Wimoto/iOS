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

#import "WPTemperatureView.h"
#import "WPTemperatureValueLabel.h"

#import "Wimoto-Swift.h"

@interface ThermoSensorDetailsViewController : SensorViewController

@property (nonatomic, weak) IBOutlet WPTemperatureView *irTempView;
@property (nonatomic, weak) IBOutlet WPTemperatureView *probeTempView;

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

@property (nonatomic, weak) IBOutlet APChartView *chartView;
@property (nonatomic, strong) APChartLine *irTempChartLine;
@property (nonatomic, strong) APChartLine *probeTempChartLine;

@property (nonatomic, strong) NSString *currentAlarmUUIDString;

- (IBAction)irTempAlarmAction:(id)sender;
- (IBAction)probeTempAlarmAction:(id)sender;

@end
