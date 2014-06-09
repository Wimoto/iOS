//
//  WaterSensorDetailsViewController.m
//  Wimoto
//
//  Created by MC700 on 12/3/13.
//
//

#import "WaterSensorDetailsViewController.h"
#import "ASBSparkLineView.h"
#import "WaterSensor.h"
#import "DatabaseManager.h"

@interface WaterSensorDetailsViewController ()

@property (nonatomic, weak) IBOutlet UILabel *levelLabel;
@property (nonatomic, weak) IBOutlet UILabel *contactLabel;
@property (nonatomic, weak) IBOutlet ASBSparkLineView *levelSparkLine;

@property (nonatomic, weak) IBOutlet UISwitch *contactSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *levelSwitch;

@property (nonatomic, strong) NSString *currentAlarmUUIDString;

- (IBAction)switchAction:(id)sender;

@end

@implementation WaterSensorDetailsViewController

- (id)initWithSensor:(Sensor*)sensor
{
    self = [super initWithSensor:sensor];
    if (self) {
        [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_WATER_SENSOR_LEVEL options:NSKeyValueObservingOptionNew context:NULL];
        [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_WATER_SENSOR_PRESENCE options:NSKeyValueObservingOptionNew context:NULL];
        self.sensor.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = YES;
    
    _levelLabel.text = [NSString stringWithFormat:@"%.1f", [(WaterSensor*)self.sensor level]];
    _contactLabel.text = ([(WaterSensor*)self.sensor presense])?@"YES":@"NO";
    
    _levelSparkLine.labelText = @"";
    _levelSparkLine.showCurrentValue = NO;
    [DatabaseManager lastSensorValuesForSensor:self.sensor andType:kValueTypeLevel completionHandler:^(NSMutableArray *item) {
        _levelSparkLine.dataValues = item;
    }];
    
    WaterSensor *waterSensor = (WaterSensor *)[self sensor];
    _contactSwitch.on = (waterSensor.presenseAlarmState == kAlarmStateEnabled)?YES:NO;
    _levelSwitch.on = (waterSensor.levelAlarmState == kAlarmStateEnabled)?YES:NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_WATER_SENSOR_LEVEL];
    [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_WATER_SENSOR_PRESENCE];
}

- (IBAction)switchAction:(id)sender {
    UISwitch *switchControl = (UISwitch *)sender;
    WaterSensor *waterSensor = (WaterSensor *)[self sensor];
    if ([switchControl isEqual:_contactSwitch]) {
        [waterSensor enableAlarm:[switchControl isOn] forCharacteristicWithUUIDString:BLE_WATER_SERVICE_UUID_PRESENCE_ALARM];
        self.currentAlarmUUIDString = BLE_WATER_SERVICE_UUID_PRESENCE_ALARM;
    }
    else if ([switchControl isEqual:_levelSwitch]) {
        [waterSensor enableAlarm:[switchControl isOn] forCharacteristicWithUUIDString:BLE_WATER_SERVICE_UUID_LEVEL_ALARM];
        self.currentAlarmUUIDString = BLE_WATER_SERVICE_UUID_LEVEL_ALARM;
        if ([switchControl isOn]) {
            [self showSlider];
        }
        else {
            [self hideSlider];
        }
    }
}

- (void)showSlider {
    WaterSensor *waterSensor = (WaterSensor *)[self sensor];
    if ([_currentAlarmUUIDString isEqualToString:BLE_WATER_SERVICE_UUID_LEVEL_ALARM]) {
        [self.alarmSlider setSliderRange:0];
        [self.alarmSlider setMinimumValue:10];
        [self.alarmSlider setMaximumValue:50];
        [self.alarmSlider setUpperValue:[waterSensor maximumAlarmValueForCharacteristicWithUUID:[CBUUID UUIDWithString:BLE_WATER_SERVICE_UUID_LEVEL_ALARM]]];
        [self.alarmSlider setLowerValue:[waterSensor maximumAlarmValueForCharacteristicWithUUID:[CBUUID UUIDWithString:BLE_WATER_SERVICE_UUID_LEVEL_ALARM]]];
    }
}

#pragma mark - SensorDelegate

- (void)didUpdateAlarmStateWithUUIDString:(NSString *)UUIDString {
    WaterSensor *waterSensor = (WaterSensor *)[self sensor];
    if ([UUIDString isEqualToString:BLE_WATER_SERVICE_UUID_PRESENCE_ALARM]) {
        _contactSwitch.on = (waterSensor.presenseAlarmState == kAlarmStateEnabled)?YES:NO;
    }
    else if ([UUIDString isEqualToString:BLE_WATER_SERVICE_UUID_LEVEL_ALARM]) {
        _levelSwitch.on = (waterSensor.levelAlarmState == kAlarmStateEnabled)?YES:NO;
    }
}

#pragma mark - AlarmSliderDelegate

- (void)alarmSliderSaveAction:(id)sender {
    WaterSensor *waterSensor = (WaterSensor *)[self sensor];
    [waterSensor writeHighAlarmValue:self.alarmSlider.upperValue forCharacteristicWithUUIDString:_currentAlarmUUIDString];
    [waterSensor writeLowAlarmValue:self.alarmSlider.lowerValue forCharacteristicWithUUIDString:_currentAlarmUUIDString];
}

#pragma mark - Value Observer

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    if ([keyPath isEqualToString:OBSERVER_KEY_PATH_WATER_SENSOR_LEVEL]) {
        self.lastUpdateLabel.text = @"Just now";
        NSNumber *level = [change objectForKey:NSKeyValueChangeNewKey];
        _levelLabel.text = [NSString stringWithFormat:@"%.1f", [level floatValue]];
        [DatabaseManager lastSensorValuesForSensor:self.sensor andType:kValueTypeLevel completionHandler:^(NSMutableArray *item) {
            _levelSparkLine.dataValues = item;
        }];
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_WATER_SENSOR_PRESENCE]) {
        _contactLabel.text = ([[change objectForKey:NSKeyValueChangeNewKey] boolValue])?@"YES":@"NO";
    }
}

@end
