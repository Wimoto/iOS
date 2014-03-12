//
//  ThermoSensorDetailsViewController.m
//  Wimoto
//
//  Created by MC700 on 12/3/13.
//
//

#import "ThermoSensorDetailsViewController.h"
#import "ASBSparkLineView.h"
#import "DatabaseManager.h"
#import "ThermoSensor.h"
#import "AlarmValue.h"

@interface ThermoSensorDetailsViewController ()

@property (nonatomic, weak) IBOutlet UILabel *irTempLabel;
@property (nonatomic, weak) IBOutlet UILabel *probeTempLabel;
@property (nonatomic, weak) IBOutlet ASBSparkLineView *irTempSparkLine;
@property (nonatomic, weak) IBOutlet ASBSparkLineView *probeTempSparkLine;
@property (nonatomic, weak) IBOutlet UISwitch *irTempSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *probeTempSwitch;
@property (nonatomic, strong) NSArray *pickerData;

@property (nonatomic, strong) AlarmValue *irTempAlarm;
@property (nonatomic, strong) AlarmValue *probeTempAlarm;

- (IBAction)switchAction:(id)sender;

@end

@implementation ThermoSensorDetailsViewController

- (id)initWithSensor:(Sensor*)sensor
{
    self = [super initWithSensor:sensor];
    if (self) {
        [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_THERMO_SENSOR_IR_TEMP options:NSKeyValueObservingOptionNew context:NULL];
        [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_THERMO_SENSOR_PROBE_TEMP options:NSKeyValueObservingOptionNew context:NULL];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = YES;
    
    _irTempLabel.text = [NSString stringWithFormat:@"%.1f", [(ThermoSensor*)self.sensor irTemp]];
    _probeTempLabel.text = [NSString stringWithFormat:@"%.1f", [(ThermoSensor*)self.sensor probeTemp]];
    
    _irTempSparkLine.labelText = @"";
    _irTempSparkLine.showCurrentValue = NO;
    [DatabaseManager lastSensorValuesForSensor:self.sensor andType:kValueTypeIRTemperature completionHandler:^(NSMutableArray *item) {
        _irTempSparkLine.dataValues = item;
    }];
    
    _probeTempSparkLine.labelText = @"";
    _probeTempSparkLine.showCurrentValue = NO;
    [DatabaseManager lastSensorValuesForSensor:self.sensor andType:kValueTypeProbeTemperature completionHandler:^(NSMutableArray *item) {
        _probeTempSparkLine.dataValues = item;
    }];
    
    [DatabaseManager alarmInstanceWithSensor:self.sensor valueType:kValueTypeIRTemperature completionHandler:^(AlarmValue *item) {
        self.irTempAlarm = item;
        NSLog(@"-------------- irTempAlarm is active --- %i", [_irTempAlarm isActive]);
        _irTempSwitch.on = [_irTempAlarm isActive];
    }];
    [DatabaseManager alarmInstanceWithSensor:self.sensor valueType:kValueTypeProbeTemperature completionHandler:^(AlarmValue *item) {
        self.probeTempAlarm = item;
        _probeTempSwitch.on = [_probeTempAlarm isActive];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_THERMO_SENSOR_IR_TEMP];
    [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_THERMO_SENSOR_PROBE_TEMP];
}

- (IBAction)switchAction:(id)sender
{
    if ([(UISwitch *)sender isOn]) {
        NSString *pickerDataString = @"1-2-3-4-5-6-7-8-9-10-11-12-13-14-15-16-17-18-19-20-21-22-23-24-25-26-27-28-29-30";
        self.pickerData = [pickerDataString componentsSeparatedByString:@"-"];
        [self.pickerView reloadAllComponents];
        [self showPicker];
        self.currentSwitch = (UISwitch *)sender;
    }
    else {
        [self hidePicker:nil];
        if ([(UISwitch *)sender isEqual:_irTempSwitch]) {
            _irTempAlarm.isActive = NO;
            [DatabaseManager saveAlarm:_irTempAlarm];
        }
        else {
            _probeTempAlarm.isActive = NO;
            [DatabaseManager saveAlarm:_probeTempAlarm];
        }
        self.currentSwitch = nil;
    }
}

- (void)hidePicker:(id)sender
{
    [super hidePicker:sender];
    if (sender) {
        if ([self.currentSwitch isEqual:_irTempSwitch]) {
            _irTempAlarm.isActive = YES;
            [DatabaseManager saveAlarm:_irTempAlarm];
        }
        else {
            _probeTempAlarm.isActive = YES;
            [DatabaseManager saveAlarm:_probeTempAlarm];
        }
    }
}

#pragma mark - Value Observer

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    
    if ([keyPath isEqualToString:OBSERVER_KEY_PATH_THERMO_SENSOR_IR_TEMP]) {
        _irTempLabel.text = [NSString stringWithFormat:@"%.1f", [[change objectForKey:NSKeyValueChangeNewKey] floatValue]];
        [DatabaseManager lastSensorValuesForSensor:self.sensor andType:kValueTypeIRTemperature completionHandler:^(NSMutableArray *item) {
            _irTempSparkLine.dataValues = item;
        }];
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_THERMO_SENSOR_PROBE_TEMP]) {
        _probeTempLabel.text = [NSString stringWithFormat:@"%.1f", [[change objectForKey:NSKeyValueChangeNewKey] floatValue]];
        [DatabaseManager lastSensorValuesForSensor:self.sensor andType:kValueTypeProbeTemperature completionHandler:^(NSMutableArray *item) {
            _probeTempSparkLine.dataValues = item;
        }];
    }
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [_pickerData count];
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [_pickerData objectAtIndex:row];
}

@end
