//
//  WimotoDeckController.h
//  Wimoto
//
//  Created by MC700 on 12/12/13.
//
//

#import "IIViewDeckController.h"
#import "Sensor.h"

@interface WimotoDeckController : IIViewDeckController

- (void)showSearchSensorScreen;
- (void)showSensorDetailsScreen:(Sensor*)sensor;

@end
