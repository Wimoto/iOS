//
//  SensorViewController.h
//  Wimoto
//
//  Created by MC700 on 12/13/13.
//
//

#import "AppViewController.h"
#import "Sensor.h"

@interface SensorViewController : AppViewController

@property (nonatomic, strong) Sensor *sensor;

- (id)initWithSensor:(Sensor*)sensor;

@end
