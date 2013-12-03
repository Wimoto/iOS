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
    ZBarReaderViewController *reader = [[ZBarReaderViewController alloc] init];
    //reader.readerDelegate = self;
    reader.showsZBarControls = NO;
    reader.navigationItem.title = @"Scan";
    ZBarImageScanner *scanner = reader.scanner;
    [scanner setSymbology: 0
                   config: ZBAR_CFG_ENABLE
                       to: 0];
    [scanner setSymbology: ZBAR_QRCODE
                   config: ZBAR_CFG_ENABLE
                       to: 1];
    self.viewDeckController.centerController = reader;
    [self.viewDeckController closeLeftViewAnimated:YES duration:0.2 completion:^(IIViewDeckController *controller, BOOL success) {}];
}

@end
