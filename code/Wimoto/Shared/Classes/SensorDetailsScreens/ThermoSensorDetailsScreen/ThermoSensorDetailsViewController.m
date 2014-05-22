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
#import "AppConstants.h"

@interface ThermoSensorDetailsViewController ()

@property (nonatomic, weak) IBOutlet UILabel *irTempLabel;
@property (nonatomic, weak) IBOutlet UILabel *probeTempLabel;
@property (nonatomic, weak) IBOutlet ASBSparkLineView *irTempSparkLine;
@property (nonatomic, weak) IBOutlet ASBSparkLineView *probeTempSparkLine;
@property (nonatomic, weak) IBOutlet UISwitch *irTempSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *probeTempSwitch;
@property (nonatomic, strong) NSArray *pickerData;

- (void)didConnectPeripheral:(NSNotification*)notification;

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didConnectPeripheral:) name:NC_BLE_MANAGER_PERIPHERAL_CONNECTED object:nil];
        
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

- (void)didConnectPeripheral:(NSNotification*)notification
{
    CBPeripheral *peripheral = [notification object];
    self.sensor.peripheral = peripheral;
}


- (IBAction)switchAction:(id)sender
{
    if ([(UISwitch *)sender isOn]) {
        [self showSlider];
    }
    else {
        [self hideSlider:nil];
    }
    /*
    if ([(UISwitch *)sender isOn]) {
        
        NSMutableArray *valuesArray = [NSMutableArray array];
        @autoreleasepool {
            for (int i = 1; i < 300; i++) {
                NSString *stringValue = [NSString stringWithFormat:@"%i", i];
                [valuesArray addObject:stringValue];
            }
        }
        self.pickerData = [NSArray arrayWithArray:valuesArray];
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
     */
}

- (void)hidePicker:(id)sender
{
    [super hideSlider:sender];
    /*
    if (sender) {
        NSString *valueString = [_pickerData objectAtIndex:[self.pickerView selectedRowInComponent:0]];
        if ([self.currentSwitch isEqual:_irTempSwitch]) {
            _irTempAlarm.isActive = YES;
            _irTempAlarm.value = [valueString integerValue];
            [DatabaseManager saveAlarm:_irTempAlarm];
        }
        else {
            _probeTempAlarm.isActive = YES;
            _probeTempAlarm.value = [valueString integerValue];
            [DatabaseManager saveAlarm:_probeTempAlarm];
        }
    }
     */
}

#pragma mark - Value Observer

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    
    float value = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
    if ([keyPath isEqualToString:OBSERVER_KEY_PATH_THERMO_SENSOR_IR_TEMP]) {
        _irTempLabel.text = [NSString stringWithFormat:@"%.1f", value];
        [DatabaseManager lastSensorValuesForSensor:self.sensor andType:kValueTypeIRTemperature completionHandler:^(NSMutableArray *item) {
            _irTempSparkLine.dataValues = item;
        }];
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_THERMO_SENSOR_PROBE_TEMP]) {
        _probeTempLabel.text = [NSString stringWithFormat:@"%.1f", value];
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
