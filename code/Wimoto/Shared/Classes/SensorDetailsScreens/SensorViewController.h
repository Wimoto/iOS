//
//  SensorViewController.h
//  Wimoto
//
//  Created by MC700 on 12/13/13.
//
//

#import "AppViewController.h"
#import "Sensor.h"

@interface SensorViewController : AppViewController <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) Sensor *sensor;
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) UIView *pickerContainer;
@property (nonatomic, strong) UISwitch *currentSwitch;

- (id)initWithSensor:(Sensor *)sensor;
- (void)showPicker;
- (void)hidePicker:(id)sender;

@end
