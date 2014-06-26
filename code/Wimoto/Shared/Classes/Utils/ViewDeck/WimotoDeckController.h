//
//  WimotoDeckController.h
//  Wimoto
//
//  Created by MC700 on 12/12/13.
//
//

#import "IIViewDeckController.h"
#import "Sensor.h"

#import "SensorsManager.h"

@interface WimotoDeckController : IIViewDeckController <SensorsObserver>

- (void)showSearchSensorScreen;
- (void)showSensorDetailsScreen:(Sensor*)sensor;

@end
