//
//  SensorsManager.h
//  Wimoto
//
//  Created by MacBook on 24/06/2014.
//
//

#import "Sensor.h"
#import "WimotoCentralManager.h"

@protocol SensorsObserver <NSObject>

- (void)didUpdateSensors:(NSSet*)sensors;

@end

@interface SensorsManager : NSObject <WimotoCentralManagerDelegate>

+ (dispatch_queue_t)queue;
+ (CBLDatabase *)managerDatabase;

+ (void)registerSensor:(Sensor*)sensor;
+ (void)unregisterSensor:(Sensor*)sensor;

+ (void)addObserverForUnregisteredSensors:(id<SensorsObserver>)observer;
+ (void)removeObserverForUnregisteredSensors:(id<SensorsObserver>)observer;

+ (void)addObserverForRegisteredSensors:(id<SensorsObserver>)observer;
+ (void)removeObserverForRegisteredSensors:(id<SensorsObserver>)observer;

@end
