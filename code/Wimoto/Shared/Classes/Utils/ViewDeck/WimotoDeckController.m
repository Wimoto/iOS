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
#import "TestSensor.h"
#import "ClimateSensor.h"
#import "WaterSensor.h"
#import "GrowSensor.h"
#import "SentrySensor.h"
#import "ThermoSensor.h"

@interface WimotoDeckController ()

@end

@implementation WimotoDeckController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    } else if ([sensor isKindOfClass:[TestSensor class]]) {
        self.centerController = [[ThermoSensorDetailsViewController alloc] initWithSensor:sensor];
    } else {
        self.centerController = [[NoSensorViewController alloc] init];
    }
}

@end
