//
//  SentrySensorDetailsViewController.m
//  Wimoto
//
//  Created by MC700 on 12/3/13.
//
//

#import "SentrySensorDetailsViewController.h"
#import "ASBSparkLineView.h"
#import "DatabaseManager.h"
#import "SentrySensor.h"

@interface SentrySensorDetailsViewController ()

@property (nonatomic, weak) IBOutlet UILabel *accelerometerLabel;
@property (nonatomic, weak) IBOutlet UILabel *pasInfraredLabel;

@property (nonatomic, weak) IBOutlet ASBSparkLineView *accelerometerSparkLine;
@property (nonatomic, weak) IBOutlet ASBSparkLineView *pasInfraredSparkLine;

@property (nonatomic, weak) IBOutlet UISwitch *accelerometerSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *pasInfraredSwitch;

@property (nonatomic, strong) NSString *currentAlarmUUIDString;

- (IBAction)switchAction:(id)sender;

@end

@implementation SentrySensorDetailsViewController

- (id)initWithSensor:(Sensor*)sensor
{
    self = [super initWithSensor:sensor];
    if (self) {
        [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_SENTRY_SENSOR_ACCELEROMETER options:NSKeyValueObservingOptionNew context:NULL];
        [self.sensor addObserver:self forKeyPath:OBSERVER_KEY_PATH_SENTRY_SENSOR_PASSIVE_INFRARED options:NSKeyValueObservingOptionNew context:NULL];
        self.sensor.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    _accelerometerLabel.text = [NSString stringWithFormat:@"%.1f", [(SentrySensor*)self.sensor accelerometer]];
    _pasInfraredLabel.text = [NSString stringWithFormat:@"%.1f", [(SentrySensor*)self.sensor pasInfrared]];
    
    _accelerometerSparkLine.labelText = @"";
    _accelerometerSparkLine.showCurrentValue = NO;
    [DatabaseManager lastSensorValuesForSensor:self.sensor andType:kValueTypeAccelerometer completionHandler:^(NSMutableArray *item) {
        _accelerometerSparkLine.dataValues = item;
    }];
    
    _pasInfraredSparkLine.labelText = @"";
    _pasInfraredSparkLine.showCurrentValue = NO;
    [DatabaseManager lastSensorValuesForSensor:self.sensor andType:kValueTypePassiveInfrared completionHandler:^(NSMutableArray *item) {
        _pasInfraredSparkLine.dataValues = item;
    }];
    
    SentrySensor *sentrySensor = (SentrySensor *)[self sensor];
    _accelerometerSwitch.on = (sentrySensor.accelerometerAlarmState == kAlarmStateEnabled)?YES:NO;
    _pasInfraredSwitch.on = (sentrySensor.pasInfraredAlarmState == kAlarmStateEnabled)?YES:NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_SENTRY_SENSOR_ACCELEROMETER];
    [self.sensor removeObserver:self forKeyPath:OBSERVER_KEY_PATH_SENTRY_SENSOR_PASSIVE_INFRARED];
}

- (IBAction)switchAction:(id)sender {
    UISwitch *switchControl = (UISwitch *)sender;
    SentrySensor *sentrySensor = (SentrySensor *)[self sensor];
    if ([switchControl isEqual:_accelerometerSwitch]) {
        [sentrySensor enableAlarm:[switchControl isOn] forCharacteristicWithUUIDString:BLE_SENTRY_SERVICE_UUID_ACCELEROMETER_ALARM];
        self.currentAlarmUUIDString = BLE_SENTRY_SERVICE_UUID_ACCELEROMETER_ALARM;
    }
    else if ([switchControl isEqual:_pasInfraredSwitch]) {
        [sentrySensor enableAlarm:[switchControl isOn] forCharacteristicWithUUIDString:BLE_SENTRY_SERVICE_UUID_PASSIVE_INFRARED_ALARM];
        self.currentAlarmUUIDString = BLE_SENTRY_SERVICE_UUID_PASSIVE_INFRARED_ALARM;
    }
}

#pragma mark - SensorDelegate

- (void)didUpdateAlarmStateWithUUIDString:(NSString *)UUIDString {
    SentrySensor *sentrySensor = (SentrySensor *)[self sensor];
    if ([UUIDString isEqualToString:BLE_SENTRY_SERVICE_UUID_ACCELEROMETER_ALARM]) {
        _accelerometerSwitch.on = (sentrySensor.accelerometerAlarmState == kAlarmStateEnabled)?YES:NO;
    }
    else if ([UUIDString isEqualToString:BLE_SENTRY_SERVICE_UUID_PASSIVE_INFRARED_ALARM]) {
        _pasInfraredSwitch.on = (sentrySensor.pasInfraredAlarmState == kAlarmStateEnabled)?YES:NO;
    }
}

#pragma mark - Value Observer

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    
    if ([keyPath isEqualToString:OBSERVER_KEY_PATH_SENTRY_SENSOR_ACCELEROMETER]) {
        self.lastUpdateLabel.text = @"Just now";
        if ([self.lastUpdateTimer isValid]) {
            [self.lastUpdateTimer invalidate];
        }
        self.lastUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:15.0 target:self selector:@selector(refreshLastUpdateLabel) userInfo:nil repeats:YES];
        _accelerometerLabel.text = [NSString stringWithFormat:@"%.1f", [[change objectForKey:NSKeyValueChangeNewKey] floatValue]];
        [DatabaseManager lastSensorValuesForSensor:self.sensor andType:kValueTypeAccelerometer completionHandler:^(NSMutableArray *item) {
            _accelerometerSparkLine.dataValues = item;
        }];
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_SENTRY_SENSOR_PASSIVE_INFRARED]) {
        _pasInfraredLabel.text = [NSString stringWithFormat:@"%.1f", [[change objectForKey:NSKeyValueChangeNewKey] floatValue]];
        [DatabaseManager lastSensorValuesForSensor:self.sensor andType:kValueTypePassiveInfrared completionHandler:^(NSMutableArray *item) {
            _pasInfraredSparkLine.dataValues = item;
        }];
    }
}

@end
