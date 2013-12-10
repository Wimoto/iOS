//
//  ClimateSensorDetailsViewController.h
//  Wimoto
//
//  Created by MC700 on 12/3/13.
//
//

#import "AppViewController.h"
#import "ASBSparkLineView.h"
#import "BLEManager.h"
#import "Sensor.h"

@class ASBSparkLineView;

@interface ClimateSensorDetailsViewController : AppViewController <BLEManagerDelegate>
@property (nonatomic, weak) IBOutlet ASBSparkLineView *sparklineTemperature;

- (id)initWithSensor:(Sensor *)sensor;

@end
