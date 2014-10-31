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

@interface ThermoSensorDetailsViewController : SensorViewController

@property (nonatomic, weak) IBOutlet UILabel *irTempLabel;
@property (nonatomic, weak) IBOutlet UILabel *probeTempLabel;

@property (nonatomic, weak) IBOutlet ASBSparkLineView *irTempSparkLine;
@property (nonatomic, weak) IBOutlet ASBSparkLineView *probeTempSparkLine;

@property (nonatomic, weak) IBOutlet UISwitch *irTempSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *probeTempSwitch;

@property (nonatomic, weak) IBOutlet UILabel *irTempHighValueLabel;
@property (nonatomic, weak) IBOutlet UILabel *irTempLowValueLabel;
@property (nonatomic, weak) IBOutlet UILabel *probeTempHighValueLabel;
@property (nonatomic, weak) IBOutlet UILabel *probeTempLowValueLabel;

@property (nonatomic, strong) AlarmSlider *irTempSlider;
@property (nonatomic, strong) AlarmSlider *probeTempSlider;

@property (nonatomic, strong) NSString *currentAlarmUUIDString;

- (IBAction)irTempAlarmAction:(id)sender;
- (IBAction)probeTempAlarmAction:(id)sender;

@end
