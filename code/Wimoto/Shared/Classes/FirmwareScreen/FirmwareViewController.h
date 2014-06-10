//
//  FirmwareViewController.h
//  Wimoto
//
//  Created by Danny Kokarev on 10.06.14.
//
//

#import "AppViewController.h"
#import "WPNetworkDispatcher.h"
#import "Sensor.h"

@interface FirmwareViewController : AppViewController <UITableViewDataSource, UITableViewDelegate, WPResponseReceiver>

- (id)initWithSensor:(Sensor *)sensor;

@end
