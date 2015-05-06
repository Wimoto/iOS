//
//  SettingsViewController.m
//  Wimoto
//
//  Created by Danny Kokarev on 03.12.13.
//
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@property (nonatomic, weak) IBOutlet UISegmentedControl *temperatureUnitSegmentedControl;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Settings";
    
    NSString *cOrFString = [[NSUserDefaults standardUserDefaults] objectForKey:@"cOrF"];
    BOOL isCelsius = [cOrFString isEqualToString:@"C"]?YES:NO;
    [_temperatureUnitSegmentedControl setSelectedSegmentIndex:isCelsius?0:1];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingsNotification:) name:NSUserDefaultsDidChangeNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)settingsNotification:(NSNotification *)notification {
    NSLog(@"settingsNotification:");
    
    NSUserDefaults *userDefaults = [notification object];
    NSString *cOrFString = [userDefaults objectForKey:@"cOrF"];
    BOOL isCelsius = [cOrFString isEqualToString:@"C"]?YES:NO;
    [_temperatureUnitSegmentedControl setSelectedSegmentIndex:isCelsius?0:1];
}

- (IBAction)temperatureUnitChanged:(id)sender {
    NSString *isCelsius = [_temperatureUnitSegmentedControl selectedSegmentIndex]==0?@"C":@"F";
    [[NSUserDefaults standardUserDefaults] setObject:isCelsius forKey:@"cOrF"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
