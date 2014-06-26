//
//  WimotoDeckController.m
//  Wimoto
//
//  Created by MC700 on 12/12/13.
//
//

#import "WimotoDeckController.h"

#import "SearchSensorViewController.h"

#import "NoSensorViewController.h"
#import "ClimateSensorDetailsViewController.h"
#import "WaterSensorDetailsViewController.h"
#import "GrowSensorDetailsViewController.h"
#import "SentrySensorDetailsViewController.h"
#import "ThermoSensorDetailsViewController.h"

#import "Sensor.h"
#import "ClimateSensor.h"
#import "WaterSensor.h"
#import "GrowSensor.h"
#import "SentrySensor.h"
#import "ThermoSensor.h"

#import "NMRangeSlider.h"

@interface WimotoDeckController ()

@end

@implementation WimotoDeckController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self disablePanOverViewsOfClass:[NMRangeSlider class]];
	
    self.centerController = [[NoSensorViewController alloc] init];
    
    [SensorsManager addObserverForRegisteredSensors:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [SensorsManager removeObserverForRegisteredSensors:self];
}

- (void)showSearchSensorScreen {
    self.centerController = [[SearchSensorViewController alloc] init];
}

- (void)showSensorDetailsScreen:(Sensor*)sensor {
    if ([sensor isKindOfClass:[ClimateSensor class]]) {
        self.centerController = [[ClimateSensorDetailsViewController alloc] initWithSensor:sensor];
    } else if ([sensor isKindOfClass:[WaterSensor class]]) {
        self.centerController = [[WaterSensorDetailsViewController alloc] initWithSensor:sensor];
    } else if ([sensor isKindOfClass:[GrowSensor class]]) {
        self.centerController = [[GrowSensorDetailsViewController alloc] initWithSensor:sensor];
    } else if ([sensor isKindOfClass:[SentrySensor class]]) {
        self.centerController = [[SentrySensorDetailsViewController alloc] initWithSensor:sensor];
    } else if ([sensor isKindOfClass:[ThermoSensor class]]) {
        self.centerController = [[ThermoSensorDetailsViewController alloc] initWithSensor:sensor];
    } else {
        self.centerController = [[NoSensorViewController alloc] init];
    }
}

#pragma mark - SensorsObserver

- (void)didUpdateSensors:(NSSet*)sensors {
    if ([sensors count] == 0) {
        if ([self.centerController isKindOfClass:[SensorViewController class]]) {
            [self showSensorDetailsScreen:nil];
        }
    } else {
        if ([self.centerController isKindOfClass:[NoSensorViewController class]]) {
            [self showSensorDetailsScreen:[sensors anyObject]];
        } else if ([self.centerController isKindOfClass:[SensorViewController class]]) {
            SensorViewController *sensorViewController = (SensorViewController*)self.centerController;
            if (![sensors containsObject:sensorViewController.sensor]) {
                [self showSensorDetailsScreen:[sensors anyObject]];
            }
        }
    }
}

@end
