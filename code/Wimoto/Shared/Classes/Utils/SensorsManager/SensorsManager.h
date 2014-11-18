//
//  SensorsManager.h
//  Wimoto
//
//  Created by MacBook on 24/06/2014.
//
//

#import "WimotoCentralManager.h"
#import <FacebookSDK/FacebookSDK.h>

@class Sensor;

@protocol SensorsObserver <NSObject>

- (void)didUpdateSensors:(NSSet*)sensors;

@end

@protocol AuthentificationObserver <NSObject>

- (void)didAuthentificate:(BOOL)isAuthentificated;

@end

@interface SensorsManager : NSObject <WimotoCentralManagerDelegate>

@property (nonatomic, weak) id<AuthentificationObserver>authObserver;

+ (SensorsManager*)sharedManager;

+ (void)activate;
+ (BOOL)handleOpenURL:(NSURL *)URL sourceApplication:(NSString *)sourceApplication;
+ (BOOL)isAuthentificated;
+ (void)authSwitch;

+ (void)registerSensor:(Sensor*)sensor;
+ (void)unregisterSensor:(Sensor*)sensor;

+ (void)addObserverForUnregisteredSensors:(id<SensorsObserver>)observer;
+ (void)removeObserverForUnregisteredSensors:(id<SensorsObserver>)observer;

+ (void)addObserverForRegisteredSensors:(id<SensorsObserver>)observer;
+ (void)removeObserverForRegisteredSensors:(id<SensorsObserver>)observer;

@end
