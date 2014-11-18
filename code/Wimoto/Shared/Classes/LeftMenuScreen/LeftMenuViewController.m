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
#import "SearchSensorViewController.h"
#import "WimotoDeckController.h"

@interface LeftMenuViewController ()

@property (nonatomic, weak) IBOutlet UIButton *fbButton;

- (IBAction)settingsAction:(id)sender;
- (IBAction)helpAction:(id)sender;
- (IBAction)addNewSensorAction:(id)sender;
- (IBAction)facebookLoginAction:(id)sender;

@end

@implementation LeftMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_fbButton setTitle:([SensorsManager isAuthentificated])?@"Facebook Logout":@"Facebook Login" forState:UIControlStateNormal];
    [SensorsManager sharedManager].authObserver = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)settingsAction:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
/*    SettingsViewController *settingsController = [[SettingsViewController alloc] init];
    UINavigationController *settingsNavController = [[UINavigationController alloc] initWithRootViewController:settingsController];
    self.viewDeckController.centerController = settingsNavController;
    [self.viewDeckController closeLeftViewAnimated:YES duration:0.2 completion:^(IIViewDeckController *controller, BOOL success) {}];
 */
}

- (IBAction)helpAction:(id)sender {
    HelpViewController *helpController = [[HelpViewController alloc] init];
    UINavigationController *helpNavController = [[UINavigationController alloc] initWithRootViewController:helpController];
    self.viewDeckController.centerController = helpNavController;
    [self.viewDeckController closeLeftViewAnimated:YES duration:0.2 completion:^(IIViewDeckController *controller, BOOL success) {}];
}

- (IBAction)addNewSensorAction:(id)sender {
    [(WimotoDeckController*)self.viewDeckController showSearchSensorScreen];
    [self.viewDeckController closeLeftViewAnimated:YES duration:0.2 completion:^(IIViewDeckController *controller, BOOL success) {}];
}

- (IBAction)facebookLoginAction:(id)sender {
    [SensorsManager authSwitch];
}

#pragma mark - AuthentificationObserver

- (void)didAuthentificate:(BOOL)isAuthentificated {
    [_fbButton setTitle:(isAuthentificated)?@"Facebook Logout":@"Facebook Login" forState:UIControlStateNormal];
}

@end
