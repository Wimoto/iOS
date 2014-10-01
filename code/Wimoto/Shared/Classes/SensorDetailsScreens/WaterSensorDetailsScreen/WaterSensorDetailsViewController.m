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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = YES;
    
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_WATER_SENSOR_LEVEL options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_WATER_SENSOR_PRESENCE options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    
    _levelSparkLine.labelText = @"";
    _levelSparkLine.showCurrentValue = NO;
    [self.sensor.entity latestValuesWithType:kValueTypeLevel completionHandler:^(NSArray *result) {
        _levelSparkLine.dataValues = result;
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
    @try {
        [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_WATER_SENSOR_LEVEL];
        [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_WATER_SENSOR_PRESENCE];
    }
    @catch (NSException *exception) {
        // No need to handle just prevent app crash
    }
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
//    WaterSensor *waterSensor = (WaterSensor *)[self sensor];
//    if ([_currentAlarmUUIDString isEqualToString:BLE_WATER_SERVICE_UUID_LEVEL_ALARM]) {
//        [self.alarmSlider setSliderRange:0];
//        [self.alarmSlider setMinimumValue:10];
//        [self.alarmSlider setMaximumValue:50];
//        [self.alarmSlider setUpperValue:[waterSensor maximumAlarmValueForCharacteristicWithUUID:[CBUUID UUIDWithString:BLE_WATER_SERVICE_UUID_LEVEL_ALARM]]];
//        [self.alarmSlider setLowerValue:[waterSensor maximumAlarmValueForCharacteristicWithUUID:[CBUUID UUIDWithString:BLE_WATER_SERVICE_UUID_LEVEL_ALARM]]];
//    }
}

#pragma mark - AlarmSliderDelegate

- (void)alarmSliderSaveAction:(id)sender {
//    WaterSensor *waterSensor = (WaterSensor *)[self sensor];
//    [waterSensor writeHighAlarmValue:self.alarmSlider.upperValue forCharacteristicWithUUIDString:_currentAlarmUUIDString];
//    [waterSensor writeLowAlarmValue:self.alarmSlider.lowerValue forCharacteristicWithUUIDString:_currentAlarmUUIDString];
}

#pragma mark - Value Observer

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    
    if ([keyPath isEqualToString:OBSERVER_KEY_PATH_SENSOR_PERIPHERAL]) {
        if ([[change objectForKey:NSKeyValueChangeNewKey] isKindOfClass:[NSNull class]]) {
            _levelLabel.text = SENSOR_VALUE_PLACEHOLDER;
            _contactLabel.text = SENSOR_VALUE_PLACEHOLDER;
        } else {
            WaterSensor *sensor = (WaterSensor*)self.sensor;
            _levelLabel.text = [NSString stringWithFormat:@"%.1f", [sensor level]];
            _contactLabel.text = ([sensor presense])?@"YES":@"NO";
            self.view.backgroundColor = [UIColor colorWithRed:(102.f/255.f) green:(204.f/255.f) blue:(255.f/255.f) alpha:1.f];
        }
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_WATER_SENSOR_LEVEL]) {
        self.lastUpdateLabel.text = @"Just now";
        if ([self.lastUpdateTimer isValid]) {
            [self.lastUpdateTimer invalidate];
        }
        self.lastUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:15.0 target:self selector:@selector(refreshLastUpdateLabel) userInfo:nil repeats:YES];
        NSNumber *level = [change objectForKey:NSKeyValueChangeNewKey];
        
        if (self.sensor.peripheral) {
            _levelLabel.text = [NSString stringWithFormat:@"%.1f", [level floatValue]];
        }
        [self.sensor.entity latestValuesWithType:kValueTypeLevel completionHandler:^(NSArray *result) {
            _levelSparkLine.dataValues = result;
        }];
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_WATER_SENSOR_PRESENCE]) {
        if (self.sensor.peripheral) {
            _contactLabel.text = ([[change objectForKey:NSKeyValueChangeNewKey] boolValue])?@"YES":@"NO";
        }
    }
}

@end
