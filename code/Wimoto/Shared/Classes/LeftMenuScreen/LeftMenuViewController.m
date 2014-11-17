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
#import "AppDelegate_iPhone.h"

@interface LeftMenuViewController ()

@property (nonatomic, weak) IBOutlet UIButton *fbButton;

- (IBAction)settingsAction:(id)sender;
- (IBAction)helpAction:(id)sender;
- (IBAction)addNewSensorAction:(id)sender;
- (IBAction)facebookLoginAction:(id)sender;
- (void)handleFBSessionStateChangeWithNotification:(NSNotification *)notification;

@end

@implementation LeftMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleFBSessionStateChangeWithNotification:)
                                                 name:@"SessionStateChangeNotification"
                                               object:nil];
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
    AppDelegate_iPhone *appDelegate = (AppDelegate_iPhone *)[UIApplication sharedApplication].delegate;
    if ([FBSession activeSession].state != FBSessionStateOpen &&
        [FBSession activeSession].state != FBSessionStateOpenTokenExtended) {
        [appDelegate openActiveSessionWithPermissions:@[@"public_profile", @"email"] allowLoginUI:YES];
    }
    else {
        [[FBSession activeSession] closeAndClearTokenInformation];
    }
}

- (void)handleFBSessionStateChangeWithNotification:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    FBSessionState sessionState = [[userInfo objectForKey:@"state"] integerValue];
    NSError *error = [userInfo objectForKey:@"error"];
    if (!error) {
        NSLog(@"FACEBOOK ACCESS TOKEN %@", [[[FBSession activeSession] accessTokenData] accessToken]);
        if (sessionState == FBSessionStateOpen) {
            [FBRequestConnection startWithGraphPath:@"me"
                                         parameters:@{@"fields":@"email"}
                                         HTTPMethod:@"GET"
                                  completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                      if (!error) {
                                          NSLog(@"FACEBOOK EMAIL %@", result);
                                      }
                                      else {
                                          NSLog(@"%@", [error localizedDescription]);
                                      }
                                  }];
            [_fbButton setTitle:@"Facebook Logout" forState:UIControlStateNormal];
        }
        else if (sessionState == FBSessionStateClosed || sessionState == FBSessionStateClosedLoginFailed) {
            [_fbButton setTitle:@"Facebook Login" forState:UIControlStateNormal];
        }
    }
    else {
        NSLog(@"Error: %@", [error localizedDescription]);
        [_fbButton setTitle:@"Facebook Login" forState:UIControlStateNormal];
    }
}

@end
