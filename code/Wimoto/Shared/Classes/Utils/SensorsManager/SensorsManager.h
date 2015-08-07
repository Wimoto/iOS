//
//  SensorsManager.h
//  Wimoto
//
//  Created by MacBook on 24/06/2014.
//
//

#import "WimotoCentralManager.h"
#import "DemoWimotoCentralManager.h"

@class Sensor;

@protocol SensorsObserver <NSObject>

- (void)didUpdateSensors:(NSSet*)sensors;

@end

@protocol AuthentificationObserver <NSObject>

- (void)didAuthentificate:(BOOL)isAuthentificated;

@end

@interface SensorsManager : NSObject <WimotoCentralManagerDelegate, DemoWimotoCentralManagerDelegate>

+ (void)registerSensor:(Sensor*)sensor;
+ (void)unregisterSensor:(Sensor*)sensor;

+ (void)addObserverForUnregisteredSensors:(id<SensorsObserver>)observer;
+ (void)removeObserverForUnregisteredSensors:(id<SensorsObserver>)observer;

+ (void)addObserverForRegisteredSensors:(id<SensorsObserver>)observer;
+ (void)removeObserverForRegisteredSensors:(id<SensorsObserver>)observer;

+ (void)setAuthentificationObserver:(id<AuthentificationObserver>)observer;
+ (void)activate;
+ (BOOL)handleOpenURL:(NSURL *)URL sourceApplication:(NSString *)sourceApplication;
+ (void)authSwitch;

+ (void)switchOffAlarm:(NSString *)UUID forSensor:(NSString *)sensorId;

@end
