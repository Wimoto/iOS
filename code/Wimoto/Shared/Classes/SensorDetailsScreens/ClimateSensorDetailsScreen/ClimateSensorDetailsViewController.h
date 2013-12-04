//
//  ClimateSensorDetailsViewController.h
//  Wimoto
//
//  Created by MC700 on 12/3/13.
//
//

#import "AppViewController.h"
#import "ASBSparkLineView.h"

@class ASBSparkLineView;


@interface ClimateSensorDetailsViewController : AppViewController
@property (nonatomic, weak) IBOutlet ASBSparkLineView *sparklineTemperature;

@end
