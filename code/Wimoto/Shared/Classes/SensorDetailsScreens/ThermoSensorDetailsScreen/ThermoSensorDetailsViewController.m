//
//  ThermoSensorDetailsViewController.m
//  Wimoto
//
//  Created by MC700 on 12/3/13.
//
//

#import "ThermoSensorDetailsViewController.h"
#import "ASBSparkLineView.h"
#import "ThermoSensor.h"
#import "AppConstants.h"

@interface ThermoSensorDetailsViewController ()

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

@property (nonatomic, strong) NSString *currentAlarmUUIDString;

- (IBAction)switchAction:(id)sender;

@end

@implementation ThermoSensorDetailsViewController

- (id)initWithSensor:(Sensor*)sensor {
    self = [super initWithSensor:sensor];
    if (self) {
        self.sensor.delegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = YES;
    
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_THERMO_SENSOR_IR_TEMP options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_THERMO_SENSOR_PROBE_TEMP options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    
//    _irTempSparkLine.labelText = @"";
//    _irTempSparkLine.showCurrentValue = NO;
//    [DatabaseManager lastSensorValuesForSensor:self.sensor andType:kValueTypeIRTemperature completionHandler:^(NSMutableArray *item) {
//        _irTempSparkLine.dataValues = item;
//    }];
//    _probeTempSparkLine.labelText = @"";
//    _probeTempSparkLine.showCurrentValue = NO;
//    [DatabaseManager lastSensorValuesForSensor:self.sensor andType:kValueTypeProbeTemperature completionHandler:^(NSMutableArray *item) {
//        _probeTempSparkLine.dataValues = item;
//    }];
    
    //ThermoSensor *thermoSensor = (ThermoSensor *)[self sensor];
    //_irTempSwitch.on = (thermoSensor.irTempAlarmState == kAlarmStateEnabled)?YES:NO;
    //_probeTempSwitch.on = (thermoSensor.probeTempAlarmState == kAlarmStateEnabled)?YES:NO;
    NSLog(@"IR TEMPERATURE SWITCH IS ON - %i", [_irTempSwitch isOn]);
    NSLog(@"PROBE TEMPERATURE SWITCH IS ON - %i", [_probeTempSwitch isOn]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    @try {
        [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_THERMO_SENSOR_IR_TEMP];
        [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_THERMO_SENSOR_PROBE_TEMP];
    }
    @catch (NSException *exception) {
        // No need to handle just prevent app crash
    }
}

- (IBAction)switchAction:(id)sender {
    UISwitch *switchControl = (UISwitch *)sender;
    ThermoSensor *thermoSensor = (ThermoSensor *)[self sensor];
    if ([switchControl isEqual:_irTempSwitch]) {
        [thermoSensor enableAlarm:[switchControl isOn] forCharacteristicWithUUIDString:BLE_THERMO_SERVICE_UUID_IR_TEMPERATURE_ALARM];
        self.currentAlarmUUIDString = BLE_THERMO_SERVICE_UUID_IR_TEMPERATURE_ALARM;
    }
    else if ([switchControl isEqual:_probeTempSwitch]) {
        [thermoSensor enableAlarm:[switchControl isOn] forCharacteristicWithUUIDString:BLE_THERMO_SERVICE_UUID_PROBE_TEMPERATURE_ALARM];
        self.currentAlarmUUIDString = BLE_THERMO_SERVICE_UUID_PROBE_TEMPERATURE_ALARM;
    }
    if ([switchControl isOn]) {
        [self showSlider];
    }
    else {
        [self hideSlider];
    }
}

- (void)showSlider {
    if ([_currentAlarmUUIDString isEqualToString:BLE_THERMO_SERVICE_UUID_IR_TEMPERATURE_ALARM]) {
        [self.alarmSlider setSliderRange:0];
        [self.alarmSlider setMinimumValue:-60];
        [self.alarmSlider setMaximumValue:130];
        [self.alarmSlider setUpperValue:[_irTempHighValueLabel.text floatValue]];
        [self.alarmSlider setLowerValue:[_irTempLowValueLabel.text floatValue]];
    }
    else if ([_currentAlarmUUIDString isEqualToString:BLE_THERMO_SERVICE_UUID_PROBE_TEMPERATURE_ALARM]) {
        [self.alarmSlider setSliderRange:0];
        [self.alarmSlider setMinimumValue:10];
        [self.alarmSlider setMaximumValue:50];
        [self.alarmSlider setUpperValue:[_probeTempHighValueLabel.text floatValue]];
        [self.alarmSlider setLowerValue:[_probeTempLowValueLabel.text floatValue]];
    }
    NSLog(@"ALARM SLIDER LOW VALUE - %f", [self.alarmSlider lowerValue]);
    NSLog(@"ALARM SLIDER HIGH VALUE - %f", [self.alarmSlider upperValue]);
    [super showSlider];
}

#pragma mark - SensorDelegate

- (void)didUpdateAlarmStateWithUUIDString:(NSString *)UUIDString {
    ThermoSensor *thermoSensor = (ThermoSensor *)[self sensor];
    if ([UUIDString isEqualToString:BLE_THERMO_SERVICE_UUID_IR_TEMPERATURE_ALARM]) {
        _irTempSwitch.on = (thermoSensor.irTempAlarmState == kAlarmStateEnabled)?YES:NO;
    }
    else if ([UUIDString isEqualToString:BLE_THERMO_SERVICE_UUID_PROBE_TEMPERATURE_ALARM]) {
        _probeTempSwitch.on = (thermoSensor.probeTempAlarmState == kAlarmStateEnabled)?YES:NO;
    }
    NSLog(@"IR TEMPERATURE SWITCH IS ON - %i", [_irTempSwitch isOn]);
    NSLog(@"PROBE TEMPERATURE SWITCH IS ON - %i", [_probeTempSwitch isOn]);
}

- (void)didReadMaxAlarmValueFromCharacteristicUUID:(CBUUID *)uuid {
    ThermoSensor *thermoSensor = (ThermoSensor *)[self sensor];
    NSString *highValueString = [NSString stringWithFormat:@"%.f", [thermoSensor maximumAlarmValueForCharacteristicWithUUID:uuid]];
    
    NSLog(@"THERMO didReadMaxAlarmValueFromCharacteristic - %@", highValueString);
    
    if ([uuid isEqual:[CBUUID UUIDWithString:BLE_THERMO_SERVICE_UUID_IR_TEMPERATURE_ALARM_HIGH_VALUE]]) {
        _irTempHighValueLabel.text = highValueString;
    }
    else if ([uuid isEqual:[CBUUID UUIDWithString:BLE_THERMO_SERVICE_UUID_PROBE_TEMPERATURE_ALARM_HIGH_VALUE]]) {
        _probeTempHighValueLabel.text = highValueString;
    }
}

- (void)didReadMinAlarmValueFromCharacteristicUUID:(CBUUID *)uuid {
    ThermoSensor *thermoSensor = (ThermoSensor *)[self sensor];
    NSString *lowValueString = [NSString stringWithFormat:@"%.f", [thermoSensor minimumAlarmValueForCharacteristicWithUUID:uuid]];
    
    NSLog(@"THERMO didReadMinAlarmValueFromCharacteristic - %@", lowValueString);
    
    if ([uuid isEqual:[CBUUID UUIDWithString:BLE_THERMO_SERVICE_UUID_IR_TEMPERATURE_ALARM_LOW_VALUE]]) {
        _irTempLowValueLabel.text = lowValueString;
    }
    else if ([uuid isEqual:[CBUUID UUIDWithString:BLE_THERMO_SERVICE_UUID_PROBE_TEMPERATURE_ALARM_LOW_VALUE]]) {
        _probeTempLowValueLabel.text = lowValueString;
    }
}

#pragma mark - AlarmSliderDelegate

- (void)alarmSliderSaveAction:(id)sender {
    ThermoSensor *thermoSensor = (ThermoSensor *)[self sensor];
    [thermoSensor writeHighAlarmValue:self.alarmSlider.upperValue forCharacteristicWithUUIDString:_currentAlarmUUIDString];
    [thermoSensor writeLowAlarmValue:self.alarmSlider.lowerValue forCharacteristicWithUUIDString:_currentAlarmUUIDString];
    
    NSString *highValueString = [NSString stringWithFormat:@"%.f", self.alarmSlider.upperValue];
    NSString *lowValueString = [NSString stringWithFormat:@"%.f", self.alarmSlider.lowerValue];
    if ([_currentAlarmUUIDString isEqualToString:BLE_THERMO_SERVICE_UUID_IR_TEMPERATURE_ALARM]) {
        self.irTempHighValueLabel.text = highValueString;
        self.irTempLowValueLabel.text = lowValueString;
    }
    else if ([_currentAlarmUUIDString isEqualToString:BLE_THERMO_SERVICE_UUID_PROBE_TEMPERATURE_ALARM]) {
        self.probeTempHighValueLabel.text = highValueString;
        self.probeTempLowValueLabel.text = lowValueString;
    }
}

#pragma mark - Value Observer

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    
    
    if ([keyPath isEqualToString:OBSERVER_KEY_PATH_SENSOR_PERIPHERAL]) {
        if ([[change objectForKey:NSKeyValueChangeNewKey] isKindOfClass:[NSNull class]]) {
            _irTempLabel.text = SENSOR_VALUE_PLACEHOLDER;
            _probeTempLabel.text = SENSOR_VALUE_PLACEHOLDER;
        } else {
            ThermoSensor *sensor = (ThermoSensor*)self.sensor;
            _irTempLabel.text = [NSString stringWithFormat:@"%.1f", [sensor irTemp]];
            _probeTempLabel.text = [NSString stringWithFormat:@"%.1f", [sensor probeTemp]];
            self.view.backgroundColor = [UIColor colorWithRed:(255.f/255.f) green:(159.f/255.f) blue:(17.f/255.f) alpha:1.f];
        }
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_THERMO_SENSOR_IR_TEMP]) {
        float value = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
        
        self.lastUpdateLabel.text = @"Just now";
        if ([self.lastUpdateTimer isValid]) {
            [self.lastUpdateTimer invalidate];
        }
        self.lastUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:15.0 target:self selector:@selector(refreshLastUpdateLabel) userInfo:nil repeats:YES];
        
        if (self.sensor.peripheral) {
            _irTempLabel.text = [NSString stringWithFormat:@"%.1f", value];
        }
//        [DatabaseManager lastSensorValuesForSensor:self.sensor andType:kValueTypeIRTemperature completionHandler:^(NSMutableArray *item) {
//            _irTempSparkLine.dataValues = item;
//        }];
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_THERMO_SENSOR_PROBE_TEMP]) {
        float value = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
        
        if (self.sensor.peripheral) {
            _probeTempLabel.text = [NSString stringWithFormat:@"%.1f", value];
        }
//        [DatabaseManager lastSensorValuesForSensor:self.sensor andType:kValueTypeProbeTemperature completionHandler:^(NSMutableArray *item) {
//            _probeTempSparkLine.dataValues = item;
//        }];
    }
}

@end
