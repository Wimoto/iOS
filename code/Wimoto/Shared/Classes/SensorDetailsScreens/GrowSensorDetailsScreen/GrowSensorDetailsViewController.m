//
//  GrowSensorDetailsViewController.m
//  Wimoto
//
//  Created by MC700 on 12/3/13.
//
//

#import "GrowSensorDetailsViewController.h"
#import "ASBSparkLineView.h"
#import "GrowSensor.h"
#import "DatabaseManager.h"

@interface GrowSensorDetailsViewController ()

@property (nonatomic, weak) IBOutlet UILabel *soilTempLabel;
@property (nonatomic, weak) IBOutlet UILabel *soilMoistureLabel;
@property (nonatomic, weak) IBOutlet UILabel *lightLabel;

@property (nonatomic, weak) IBOutlet ASBSparkLineView *soilTempSparkLine;
@property (nonatomic, weak) IBOutlet ASBSparkLineView *soilMoistureSparkLine;
@property (nonatomic, weak) IBOutlet ASBSparkLineView *lightSparkLine;

@property (nonatomic, weak) IBOutlet UISwitch *soilTempSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *soilMoistureSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *lightSwitch;

@property (nonatomic, strong) NSString *currentAlarmUUIDString;

- (IBAction)switchAction:(id)sender;

@end

@implementation GrowSensorDetailsViewController

- (id)initWithSensor:(Sensor*)sensor {
    self = [super initWithSensor:sensor];
    if (self) {
        [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_GROW_SENSOR_LIGHT options:NSKeyValueObservingOptionNew context:NULL];
        [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_GROW_SENSOR_SOIL_MOISTURE options:NSKeyValueObservingOptionNew context:NULL];
        [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_GROW_SENSOR_SOIL_TEMPERATURE options:NSKeyValueObservingOptionNew context:NULL];
        self.sensor.delegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    _soilTempLabel.text = [NSString stringWithFormat:@"%.1f", [(GrowSensor*)self.sensor soilTemperature]];
    _soilMoistureLabel.text = [NSString stringWithFormat:@"%.1f", [(GrowSensor*)self.sensor soilMoisture]];
    _lightLabel.text = [NSString stringWithFormat:@"%.f", [(GrowSensor*)self.sensor light]];
    
    _soilTempSparkLine.labelText = @"";
    _soilTempSparkLine.showCurrentValue = NO;
    [DatabaseManager lastSensorValuesForSensor:self.sensor andType:kValueTypeSoilTemperature completionHandler:^(NSMutableArray *item) {
        _soilTempSparkLine.dataValues = item;
    }];
    
    _soilMoistureSparkLine.labelText = @"";
    _soilMoistureSparkLine.showCurrentValue = NO;
    [DatabaseManager lastSensorValuesForSensor:self.sensor andType:kValueTypeSoilHumidity completionHandler:^(NSMutableArray *item) {
        _soilMoistureSparkLine.dataValues = item;
    }];
    
    _lightSparkLine.labelText = @"";
    _lightSparkLine.showCurrentValue = NO;
    [DatabaseManager lastSensorValuesForSensor:self.sensor andType:kValueTypeLight completionHandler:^(NSMutableArray *item) {
        _lightSparkLine.dataValues = item;
    }];
    
    GrowSensor *growSensor = (GrowSensor *)[self sensor];
    _soilTempSwitch.on = (growSensor.soilTempAlarmState == kAlarmStateEnabled)?YES:NO;
    _soilMoistureSwitch.on = (growSensor.soilMoistureAlarmState == kAlarmStateEnabled)?YES:NO;
    _lightSwitch.on = (growSensor.lightAlarmState == kAlarmStateEnabled)?YES:NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_GROW_SENSOR_LIGHT];
    [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_GROW_SENSOR_SOIL_MOISTURE];
    [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_GROW_SENSOR_SOIL_TEMPERATURE];
}

- (IBAction)switchAction:(id)sender {
    UISwitch *switchControl = (UISwitch *)sender;
    GrowSensor *growSensor = (GrowSensor *)[self sensor];
    if ([switchControl isEqual:_soilTempSwitch]) {
        [growSensor enableAlarm:[switchControl isOn] forCharacteristicWithUUIDString:BLE_GROW_SERVICE_UUID_SOIL_TEMPERATURE_ALARM];
        self.currentAlarmUUIDString = BLE_GROW_SERVICE_UUID_SOIL_TEMPERATURE_ALARM;
    }
    else if ([switchControl isEqual:_soilMoistureSwitch]) {
        [growSensor enableAlarm:[switchControl isOn] forCharacteristicWithUUIDString:BLE_GROW_SERVICE_UUID_SOIL_MOISTURE_ALARM];
        self.currentAlarmUUIDString = BLE_GROW_SERVICE_UUID_SOIL_MOISTURE_ALARM;
    }
    else if ([switchControl isEqual:_lightSwitch]) {
        [growSensor enableAlarm:[switchControl isOn] forCharacteristicWithUUIDString:BLE_GROW_SERVICE_UUID_LIGHT_ALARM];
        self.currentAlarmUUIDString = BLE_GROW_SERVICE_UUID_LIGHT_ALARM;
    }
    if ([switchControl isOn]) {
        [self showSlider];
    }
    else {
        [self hideSlider];
    }
}

- (void)showSlider {
    GrowSensor *growSensor = (GrowSensor *)[self sensor];
    if ([_currentAlarmUUIDString isEqualToString:BLE_GROW_SERVICE_UUID_SOIL_TEMPERATURE_ALARM]) {
        [self.alarmSlider setSliderRange:0];
        [self.alarmSlider setMinimumValue:-60];
        [self.alarmSlider setMaximumValue:130];
        [self.alarmSlider setUpperValue:[growSensor maximumAlarmValueForCharacteristicWithUUIDString:BLE_GROW_SERVICE_UUID_SOIL_TEMPERATURE_ALARM]];
        [self.alarmSlider setLowerValue:[growSensor maximumAlarmValueForCharacteristicWithUUIDString:BLE_GROW_SERVICE_UUID_SOIL_TEMPERATURE_ALARM]];
    }
    else if ([_currentAlarmUUIDString isEqualToString:BLE_GROW_SERVICE_UUID_SOIL_MOISTURE_ALARM]) {
        [self.alarmSlider setSliderRange:0];
        [self.alarmSlider setMinimumValue:10];
        [self.alarmSlider setMaximumValue:50];
        [self.alarmSlider setUpperValue:[growSensor maximumAlarmValueForCharacteristicWithUUIDString:BLE_GROW_SERVICE_UUID_SOIL_MOISTURE_ALARM]];
        [self.alarmSlider setLowerValue:[growSensor maximumAlarmValueForCharacteristicWithUUIDString:BLE_GROW_SERVICE_UUID_SOIL_MOISTURE_ALARM]];
    }
    else if ([_currentAlarmUUIDString isEqualToString:BLE_GROW_SERVICE_UUID_LIGHT_ALARM]) {
        [self.alarmSlider setSliderRange:0];
        [self.alarmSlider setMinimumValue:10];
        [self.alarmSlider setMaximumValue:50];
        [self.alarmSlider setUpperValue:[growSensor maximumAlarmValueForCharacteristicWithUUIDString:BLE_GROW_SERVICE_UUID_LIGHT_ALARM]];
        [self.alarmSlider setLowerValue:[growSensor maximumAlarmValueForCharacteristicWithUUIDString:BLE_GROW_SERVICE_UUID_LIGHT_ALARM]];
    }
    [super showSlider];
}

#pragma mark - SensorDelegate

- (void)didUpdateAlarmStateWithUUIDString:(NSString *)UUIDString {
    GrowSensor *growSensor = (GrowSensor *)[self sensor];
    if ([UUIDString isEqualToString:BLE_GROW_SERVICE_UUID_SOIL_TEMPERATURE_ALARM]) {
        _soilTempSwitch.on = (growSensor.soilTempAlarmState == kAlarmStateEnabled)?YES:NO;
    }
    else if ([UUIDString isEqualToString:BLE_GROW_SERVICE_UUID_SOIL_MOISTURE_ALARM]) {
        _soilMoistureSwitch.on = (growSensor.soilMoistureAlarmState == kAlarmStateEnabled)?YES:NO;
    }
    else if ([UUIDString isEqualToString:BLE_GROW_SERVICE_UUID_LIGHT_ALARM]) {
        _lightSwitch.on = (growSensor.lightAlarmState == kAlarmStateEnabled)?YES:NO;
    }
}

#pragma mark - AlarmSliderDelegate

- (void)alarmSliderSaveAction:(id)sender {
    GrowSensor *growSensor = (GrowSensor *)[self sensor];
    [growSensor writeHighAlarmValue:self.alarmSlider.upperValue forCharacteristicWithUUIDString:_currentAlarmUUIDString];
    [growSensor writeLowAlarmValue:self.alarmSlider.lowerValue forCharacteristicWithUUIDString:_currentAlarmUUIDString];
}

#pragma mark - Value Observer

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    if ([keyPath isEqualToString:OBSERVER_KEY_PATH_GROW_SENSOR_SOIL_TEMPERATURE]) {
        _soilTempLabel.text = [NSString stringWithFormat:@"%.1f", [[change objectForKey:NSKeyValueChangeNewKey] floatValue]];
        [DatabaseManager lastSensorValuesForSensor:self.sensor andType:kValueTypeSoilTemperature completionHandler:^(NSMutableArray *item) {
            _soilTempSparkLine.dataValues = item;
        }];
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_GROW_SENSOR_SOIL_MOISTURE]) {
        _soilMoistureLabel.text = [NSString stringWithFormat:@"%.1f", [[change objectForKey:NSKeyValueChangeNewKey] floatValue]];
        [DatabaseManager lastSensorValuesForSensor:self.sensor andType:kValueTypeSoilHumidity completionHandler:^(NSMutableArray *item) {
            _soilMoistureSparkLine.dataValues = item;
        }];
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_GROW_SENSOR_LIGHT]) {
        _lightLabel.text = [NSString stringWithFormat:@"%.f", [[change objectForKey:NSKeyValueChangeNewKey] floatValue]];
        [DatabaseManager lastSensorValuesForSensor:self.sensor andType:kValueTypeLight completionHandler:^(NSMutableArray *item) {
            _lightSparkLine.dataValues = item;
        }];
    }
}

@end
