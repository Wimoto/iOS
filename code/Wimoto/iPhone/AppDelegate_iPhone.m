//
//  AppDelegate_iPhone.m
//  Wimoto
//
//  Created by MC700 on 7/30/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate_iPhone.h"
#import "LeftMenuViewController.h"
#import "RightMenuViewController.h"
#import "WimotoDeckController.h"
#import "UIAlertView+Blocks.h"
#import "AppConstants.h"

@interface AppDelegate_iPhone ()

- (void)registerDefaultsFromSettingsBundle;

@end

@implementation AppDelegate_iPhone

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self registerDefaultsFromSettingsBundle];
    
    LeftMenuViewController *leftController = [[LeftMenuViewController alloc] init];
    RightMenuViewController *rightController = [[RightMenuViewController alloc] init];
    WimotoDeckController *deckController = [[WimotoDeckController alloc] initWithCenterViewController:nil leftViewController:leftController rightViewController:rightController];
    
    deckController.leftSize = 60.0;
    deckController.rightSize = 60.0;
    
// Local Notification categories -- added by Marc
    
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIMutableUserNotificationAction *notificationAction1 = [[UIMutableUserNotificationAction alloc] init];
        notificationAction1.identifier = NOTIFICATION_ACTION_DISMISS_ID;
        notificationAction1.title = @"Dismiss";
        notificationAction1.activationMode = UIUserNotificationActivationModeBackground;
        notificationAction1.destructive = NO;
        notificationAction1.authenticationRequired = NO;
        
        UIMutableUserNotificationAction *notificationAction2 = [[UIMutableUserNotificationAction alloc] init];
        notificationAction2.identifier = NOTIFICATION_ACTION_ALARM_OFF_ID;
        notificationAction2.title = @"Switch off alarm";
        notificationAction2.activationMode = UIUserNotificationActivationModeBackground;
        notificationAction2.destructive = YES;
        notificationAction2.authenticationRequired = YES;
        
        UIMutableUserNotificationCategory *notificationCategory = [[UIMutableUserNotificationCategory alloc] init];
        notificationCategory.identifier = NOTIFICATION_ALARM_CATEGORY_ID;
        [notificationCategory setActions:@[notificationAction1,notificationAction2] forContext:UIUserNotificationActionContextDefault];
        [notificationCategory setActions:@[notificationAction1,notificationAction2] forContext:UIUserNotificationActionContextMinimal];
        
        NSSet *categories = [NSSet setWithObjects:notificationCategory, nil];
        
        UIUserNotificationSettings *settings =
        [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge |
         UIUserNotificationTypeSound categories:categories];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        //[[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    
    /* // Test local notification
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        localNotification.category = @"Sensor"; //  Same as category identifier
    }
    localNotification.fireDate = [[NSDate date] dateByAddingTimeInterval:6.0];
    localNotification.alertBody = @"Alert text...";
    localNotification.alertAction = @"View";
    localNotification.soundName = @"alarm.aifc";
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
     */
// -- End of Local Notification stuff added by Marc
    
    self.window.rootViewController = deckController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)registerDefaultsFromSettingsBundle {
    NSString *mainBundlePath = [[NSBundle mainBundle] bundlePath];
    NSString *settingsPropertyListPath = [mainBundlePath
                                           stringByAppendingPathComponent:@"Settings.bundle/Root.plist"];
    NSDictionary *settingsPropertyList = [NSDictionary
                                          dictionaryWithContentsOfFile:settingsPropertyListPath];
    NSMutableArray *preferenceArray = [settingsPropertyList objectForKey:@"PreferenceSpecifiers"];
    NSMutableDictionary *registerableDictionary = [NSMutableDictionary dictionary];
    
    for (int i = 0; i < [preferenceArray count]; i++)  {
        NSString *key = [[preferenceArray objectAtIndex:i] objectForKey:@"Key"];
        if (key)  {
            id value = [[preferenceArray objectAtIndex:i] objectForKey:@"DefaultValue"];
            [registerableDictionary setObject:value forKey:key];
        }
    }
    [[NSUserDefaults standardUserDefaults] registerDefaults:registerableDictionary];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    if ([application applicationState] == UIApplicationStateActive) {
        [UIAlertView showWithTitle:nil message:[notification alertBody] cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"Switch off alarm"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {            
            [SensorsManager switchOffAlarm:[notification.userInfo objectForKey:@"uuid"] forSensor:[notification.userInfo objectForKey:@"sensor"]];
        }];
    }
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void (^)())completionHandler {
    if ([identifier isEqualToString:NOTIFICATION_ACTION_DISMISS_ID]) {
        NSLog(@"DISMISS");
    }
    else if ([identifier isEqualToString:NOTIFICATION_ACTION_ALARM_OFF_ID]) {
        NSLog(@"ALARM OFF");
    }
    completionHandler();
}

- (void)applicationWillResignActive:(UIApplication *)application {

    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [SensorsManager activate];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    NSLog(@"applicationWillTerminate");
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    return [SensorsManager handleOpenURL:url sourceApplication:sourceApplication];
}

#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}

@end
