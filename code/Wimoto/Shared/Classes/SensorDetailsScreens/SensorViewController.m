//
//  SensorViewController.m
//  Wimoto
//
//  Created by MC700 on 12/13/13.
//
//

#import "SensorViewController.h"
#import "NSString+Util.h"
#import "RelativeDateDescriptor.h"

@interface SensorViewController ()

@property (nonatomic, weak) IBOutlet UILabel *rssiLabel;
@property (nonatomic, weak) IBOutlet UIImageView *batteryLevelImage;

@end

@implementation SensorViewController

- (id)initWithSensor:(Sensor*)sensor {
    self = [super init];
    if (self) {
        _sensor = sensor;
        [_sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_SENSOR_RSSI options:NSKeyValueObservingOptionNew context:NULL];
        [_sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_SENSOR_BATTERY_LEVEL options:NSKeyValueObservingOptionNew context:NULL];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *sensorName = [self.sensor name];
    if ([sensorName isNotEmpty]) {
        self.sensorNameField.text = sensorName;
    }
    if (_sensor.rssi) {
        _rssiLabel.text = [NSString stringWithFormat:@"%@dB", _sensor.rssi];
    }
    [self refreshLastUpdateLabel];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!_alarmSlider) {
        self.alarmSlider = [[AlarmSlider alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height, self.view.frame.size.width, 100.0)];
        [self.view addSubview:_alarmSlider];
        _alarmSlider.delegate = self;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_SENSOR_RSSI];
    [_sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_SENSOR_BATTERY_LEVEL];
    if ([self.lastUpdateTimer isValid]) {
        [self.lastUpdateTimer invalidate];
    }
    self.lastUpdateTimer = nil;
}

- (void)refreshLastUpdateLabel {
    NSDate *lastUpdateDate = [self.sensor lastUpdateDate];
    if (lastUpdateDate) {
        RelativeDateDescriptor *descriptor = [[RelativeDateDescriptor alloc] initWithPriorDateDescriptionFormat:@"%@ ago" postDateDescriptionFormat:@"in %@"];
        _lastUpdateLabel.text = [descriptor describeDate:lastUpdateDate relativeTo:[NSDate date]];
    }
}

- (void)showSlider {
    [_alarmSlider showAction];
}

- (void)hideSlider {
    [_alarmSlider hideAction:nil];
}

#pragma mark - SensorDelegate

- (void)didUpdateAlarmStateWithUUIDString:(NSString *)UUIDString {
    //Implement in child
}

- (void)didReadMinAlarmValueFromCharacteristicUUID:(CBUUID *)uuid {
    //Implement in child
}

- (void)didReadMaxAlarmValueFromCharacteristicUUID:(CBUUID *)uuid {
    //Implement in child
}

#pragma mark - AlarmSliderDelegate

- (void)alarmSliderSaveAction:(id)sender {
    //Implement in child
}

#pragma mark - Value Observer

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:OBSERVER_KEY_PATH_SENSOR_RSSI]) {
        _rssiLabel.text = [NSString stringWithFormat:@"%@dB", [change objectForKey:NSKeyValueChangeNewKey]];
    }
    else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_SENSOR_BATTERY_LEVEL]) {
        NSNumber *batteryValue = (NSNumber *)[change objectForKey:NSKeyValueChangeNewKey];
        int value = [batteryValue intValue];
        NSLog(@"BATTERY LEVEL INTEGER VALUE = %i", value);
        NSString *batteryImagePath = nil;
        if (value < 25) {
            batteryImagePath = @"battery-low";
        }
        else if (value < 50) {
            batteryImagePath = @"battery-medium";
        }
        else if (value < 75) {
            batteryImagePath = @"battery-high";
        }
        else {
            batteryImagePath = @"battery-full";
        }
        _batteryLevelImage.image = [UIImage imageNamed:batteryImagePath];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if ([textField.text isNotEmpty]) {
        self.sensor.name = [textField text];
        [self.sensor save:nil];
    }
    return YES;
}

@end
