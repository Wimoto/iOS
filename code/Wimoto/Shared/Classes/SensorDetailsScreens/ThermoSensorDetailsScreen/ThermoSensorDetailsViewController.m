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

@property (nonatomic, strong) NSString *currentAlarmUUIDString;

- (void)didConnectPeripheral:(NSNotification*)notification;

- (IBAction)switchAction:(id)sender;

@end

@implementation ThermoSensorDetailsViewController

- (id)initWithSensor:(Sensor*)sensor {
    self = [super initWithSensor:sensor];
    if (self) {
        [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_THERMO_SENSOR_IR_TEMP options:NSKeyValueObservingOptionNew context:NULL];
        [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_THERMO_SENSOR_PROBE_TEMP options:NSKeyValueObservingOptionNew context:NULL];
        self.sensor.delegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didConnectPeripheral:) name:NC_BLE_MANAGER_PERIPHERAL_CONNECTED object:nil];
        
    _irTempLabel.text = [NSString stringWithFormat:@"%@", [(ThermoSensor*)self.sensor irTemp]];
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
    
    ThermoSensor *thermoSensor = (ThermoSensor *)[self sensor];
    _irTempSwitch.on = (thermoSensor.irTempAlarmState == kAlarmStateEnabled)?YES:NO;
    _probeTempSwitch.on = (thermoSensor.probeTempAlarmState == kAlarmStateEnabled)?YES:NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_THERMO_SENSOR_IR_TEMP];
    [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_THERMO_SENSOR_PROBE_TEMP];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didConnectPeripheral:(NSNotification*)notification {
    CBPeripheral *peripheral = [notification object];
    self.sensor.peripheral = peripheral;
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
    ThermoSensor *thermoSensor = (ThermoSensor *)[self sensor];
    if ([_currentAlarmUUIDString isEqualToString:BLE_THERMO_SERVICE_UUID_IR_TEMPERATURE_ALARM]) {
        [self.alarmSlider setSliderRange:0];
        [self.alarmSlider setMinimumValue:-60];
        [self.alarmSlider setMaximumValue:130];
        [self.alarmSlider setUpperValue:[thermoSensor maximumAlarmValueForCharacteristicWithUUIDString:BLE_THERMO_SERVICE_UUID_IR_TEMPERATURE_ALARM]];
        [self.alarmSlider setLowerValue:[thermoSensor maximumAlarmValueForCharacteristicWithUUIDString:BLE_THERMO_SERVICE_UUID_IR_TEMPERATURE_ALARM]];
    }
    else if ([_currentAlarmUUIDString isEqualToString:BLE_THERMO_SERVICE_UUID_PROBE_TEMPERATURE_ALARM]) {
        [self.alarmSlider setSliderRange:0];
        [self.alarmSlider setMinimumValue:10];
        [self.alarmSlider setMaximumValue:50];
        [self.alarmSlider setUpperValue:[thermoSensor maximumAlarmValueForCharacteristicWithUUIDString:BLE_THERMO_SERVICE_UUID_PROBE_TEMPERATURE_ALARM]];
        [self.alarmSlider setLowerValue:[thermoSensor maximumAlarmValueForCharacteristicWithUUIDString:BLE_THERMO_SERVICE_UUID_PROBE_TEMPERATURE_ALARM]];
    }
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
}

#pragma mark - AlarmSliderDelegate

- (void)alarmSliderSaveAction:(id)sender {
    ThermoSensor *thermoSensor = (ThermoSensor *)[self sensor];
    [thermoSensor writeHighAlarmValue:self.alarmSlider.upperValue forCharacteristicWithUUIDString:_currentAlarmUUIDString];
    [thermoSensor writeLowAlarmValue:self.alarmSlider.lowerValue forCharacteristicWithUUIDString:_currentAlarmUUIDString];
    
    NSString *highValueString = [NSString stringWithFormat:@"%.f", self.alarmSlider.upperValue];
    NSString *lowValueString = [NSString stringWithFormat:@"%.f", self.alarmSlider.lowerValue];
    if ([_currentAlarmUUIDString isEqualToString:BLE_THERMO_SERVICE_UUID_IR_TEMPERATURE_ALARM]) {
        self.highLabel1.text = highValueString;
        self.lowLabel1.text = lowValueString;
    }
    else if ([_currentAlarmUUIDString isEqualToString:BLE_THERMO_SERVICE_UUID_PROBE_TEMPERATURE_ALARM]) {
        self.highLabel2.text = highValueString;
        self.lowLabel2.text = lowValueString;
    }
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

@end
