//
//  LeftMenuViewController.m
//  Wimoto
//
//  Created by Danny Kokarev on 03.12.13.
//
//

#import "LeftMenuViewController.h"
#import "HelpViewController.h"
#import "SettingsViewController.h"

#import "Sensor.h"
#import "SensorManager.h"

@interface LeftMenuViewController ()

- (IBAction)settingsAction:(id)sender;
- (IBAction)helpAction:(id)sender;
- (IBAction)addNewSensorAction:(id)sender;

@end

@implementation LeftMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)settingsAction:(id)sender
{
    SettingsViewController *settingsController = [[SettingsViewController alloc] init];
    UINavigationController *settingsNavController = [[UINavigationController alloc] initWithRootViewController:settingsController];
    self.viewDeckController.centerController = settingsNavController;
    [self.viewDeckController closeLeftViewAnimated:YES duration:0.2 completion:^(IIViewDeckController *controller, BOOL success) {}];
}

- (IBAction)helpAction:(id)sender
{
    HelpViewController *helpController = [[HelpViewController alloc] init];
    UINavigationController *helpNavController = [[UINavigationController alloc] initWithRootViewController:helpController];
    self.viewDeckController.centerController = helpNavController;
    [self.viewDeckController closeLeftViewAnimated:YES duration:0.2 completion:^(IIViewDeckController *controller, BOOL success) {}];
}

- (IBAction)addNewSensorAction:(id)sender
{
    NSInteger typeIndex = (arc4random() % 5);
    
    Sensor *sensor = [[Sensor alloc] init];
    sensor.type = typeIndex;
    
    [SensorManager addSensor:sensor];

    NSString *message = @"";
    switch (sensor.type) {
        case kSensorTypeClimate:
            message = @"Climate Sensor was added to sensors list";
            break;
        case kSensorTypeGrow:
            message = @"Grow Sensor was added to sensors list";
            break;
        case kSensorTypeThermo:
            message = @"Thermo Sensor was added to sensors list";
            break;
        case kSensorTypeSentry:
            message = @"Sentry Sensor was added to sensors list";
            break;
        case kSensorTypeWater:
            message = @"Water Sensor was added to sensors list";
            break;
        default:
            break;
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    
//    ZBarReaderViewController *reader = [[ZBarReaderViewController alloc] init];
//    //reader.readerDelegate = self;
//    reader.showsZBarControls = NO;
//    reader.navigationItem.title = @"Scan";
//    ZBarImageScanner *scanner = reader.scanner;
//    [scanner setSymbology: 0
//                   config: ZBAR_CFG_ENABLE
//                       to: 0];
//    [scanner setSymbology: ZBAR_QRCODE
//                   config: ZBAR_CFG_ENABLE
//                       to: 1];
//    self.viewDeckController.centerController = reader;
    [self.viewDeckController closeLeftViewAnimated:YES duration:0.2 completion:^(IIViewDeckController *controller, BOOL success) {}];
}

@end
