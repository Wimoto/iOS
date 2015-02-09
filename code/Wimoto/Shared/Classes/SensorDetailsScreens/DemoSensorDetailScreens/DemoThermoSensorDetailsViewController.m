//
//  DemoThermoSensorDetailsViewController.m
//  Wimoto
//
//  Created by MC700 on 30.10.14.
//
//

#import "DemoThermoSensorDetailsViewController.h"
#import "DemoThermoSensor.h"

@interface DemoThermoSensorDetailsViewController ()

@end

@implementation DemoThermoSensorDetailsViewController

- (id)initWithSensor:(Sensor*)sensor {
    BOOL isIpad = (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad);
    self = [super initWithNibName:[NSString stringWithFormat:@"%@_%@", NSStringFromClass(self.superclass), (isIpad)?@"iPad":@"iPhone"] bundle:nil];
    if (self) {
        self.sensor = sensor;
    }
    return self;
}

- (id)init {
    BOOL isIpad = (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad);
    self = [super initWithNibName:[NSString stringWithFormat:@"%@_%@", NSStringFromClass(self.superclass), (isIpad)?@"iPad":@"iPhone"] bundle:nil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.irTempLabel.text = SENSOR_VALUE_PLACEHOLDER;
    self.probeTempLabel.text = SENSOR_VALUE_PLACEHOLDER;
    self.view.backgroundColor = [UIColor colorWithRed:(255.f/255.f) green:(159.f/255.f) blue:(17.f/255.f) alpha:1.f];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Value Observer

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    DemoThermoSensor *sensor = (DemoThermoSensor *)[self sensor];
    if ([keyPath isEqualToString:OBSERVER_KEY_PATH_SENSOR_PERIPHERAL]) {
        return;
    }
    if ([keyPath isEqualToString:OBSERVER_KEY_PATH_THERMO_SENSOR_IR_TEMP]) {
        self.lastUpdateLabel.text = @"Just now";
        if ([self.lastUpdateTimer isValid]) {
            [self.lastUpdateTimer invalidate];
        }
        self.lastUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:15.0 target:self selector:@selector(refreshLastUpdateLabel) userInfo:nil repeats:YES];
        self.irTempLabel.text = [NSString stringWithFormat:@"%.1f", [sensor irTemp]];
        [self.sensor.entity latestValuesWithType:kValueTypeIRTemperature completionHandler:^(NSArray *result) {
            self.irTempSparkLine.dataValues = result;
        }];
    } else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_THERMO_SENSOR_PROBE_TEMP]) {
        self.probeTempLabel.text = [NSString stringWithFormat:@"%.1f", [sensor probeTemp]];
        [self.sensor.entity latestValuesWithType:kValueTypeProbeTemperature completionHandler:^(NSArray *result) {
            self.probeTempSparkLine.dataValues = result;
        }];
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    /*
    else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_THERMO_SENSOR_IR_TEMP_ALARM_STATE]) {
        self.irTempSwitch.on = ([[change objectForKey:NSKeyValueChangeNewKey] intValue] == kAlarmStateEnabled)?YES:NO;
    }
    else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_THERMO_SENSOR_PROBE_TEMP_ALARM_STATE]) {
        self.probeTempSwitch.on = ([[change objectForKey:NSKeyValueChangeNewKey] intValue] == kAlarmStateEnabled)?YES:NO;
    }
    else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_THERMO_SENSOR_IR_TEMP_ALARM_LOW]) {
        float value = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
        self.irTempLowValueLabel.text = [NSString stringWithFormat:@"%.f", value];
        [self.irTempSlider setLowerValue:value];
    }
    else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_THERMO_SENSOR_IR_TEMP_ALARM_HIGH]) {
        float value = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
        self.irTempHighValueLabel.text = [NSString stringWithFormat:@"%.f", value];
        [self.irTempSlider setUpperValue:value];
    }
    else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_THERMO_SENSOR_PROBE_TEMP_ALARM_LOW]) {
        float value = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
        self.probeTempLowValueLabel.text = [NSString stringWithFormat:@"%.f", value];
        [self.probeTempSlider setLowerValue:value];
    }
    else if ([keyPath isEqualToString:OBSERVER_KEY_PATH_THERMO_SENSOR_PROBE_TEMP_ALARM_HIGH]) {
        float value = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
        self.probeTempHighValueLabel.text = [NSString stringWithFormat:@"%.f", value];
        [self.probeTempSlider setUpperValue:value];
    }
     */
}

@end
