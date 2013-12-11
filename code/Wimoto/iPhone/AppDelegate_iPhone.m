//
//  AppDelegate_iPhone.m
//  Wimoto
//
//  Created by MC700 on 7/30/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate_iPhone.h"
#import "LeftMenuViewController.h"
#import "IIViewDeckController.h"
#import "RightMenuViewController.h"
#import "ClimateSensorDetailsViewController.h"
#import "GrowSensorDetailsViewController.h"
#import "ThermoSensorDetailsViewController.h"
#import "SentrySensorDetailsViewController.h"
#import "WaterSensorDetailsViewController.h"
#import "SensorManager.h"

@implementation AppDelegate_iPhone

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    NSMutableArray *sensorsArray = [SensorManager getSensors];
    if ([sensorsArray count] == 0) {
        Sensor *sensor = [[Sensor alloc] init];
        sensor.type = 0;
        [SensorManager addSensor:sensor];
    }
    
    LeftMenuViewController *leftController = [[LeftMenuViewController alloc] init];
    RightMenuViewController *rightController = [[RightMenuViewController alloc] init];
    IIViewDeckController *deckController = [[IIViewDeckController alloc] initWithCenterViewController:nil leftViewController:leftController rightViewController:rightController];
    deckController.leftSize = 60.0;
    deckController.rightSize = 60.0;
    
    Sensor *firstSensor = [[SensorManager getSensors] objectAtIndex:0];
    if (firstSensor.type==kSensorTypeClimate) {
        ClimateSensorDetailsViewController *climateController = [[ClimateSensorDetailsViewController alloc] init];
        deckController.centerController = [[UINavigationController alloc] initWithRootViewController:climateController];
    } else if (firstSensor.type==kSensorTypeGrow) {
        GrowSensorDetailsViewController *growController = [[GrowSensorDetailsViewController alloc] init];
        deckController.centerController = growController;
    } else if (firstSensor.type==kSensorTypeSentry) {
        SentrySensorDetailsViewController *sentryController = [[SentrySensorDetailsViewController alloc] init];
        deckController.centerController = sentryController;
    } else if (firstSensor.type==kSensorTypeThermo) {
        ThermoSensorDetailsViewController *thermoController = [[ThermoSensorDetailsViewController alloc] init];
        deckController.centerController = thermoController;
    } else if (firstSensor.type==kSensorTypeWater) {
        WaterSensorDetailsViewController *waterController = [[WaterSensorDetailsViewController alloc] init];
        deckController.centerController = waterController;
    }
    
    self.window.rootViewController = deckController;
    [self.window makeKeyAndVisible];
    return YES;
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
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}

@end
