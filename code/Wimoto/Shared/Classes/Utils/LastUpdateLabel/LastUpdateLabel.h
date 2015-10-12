//
//  LastUpdateLabel.h
//  Wimoto
//
//  Created by Mobitexoft on 12.10.15.
//
//

#import <UIKit/UIKit.h>
#import "Sensor.h"

@interface LastUpdateLabel : UILabel

@property (nonatomic, strong) Sensor *sensor;
@property (nonatomic, strong) NSTimer *lastUpdateTimer;

-(void)reset;
-(void)refresh;

@end
