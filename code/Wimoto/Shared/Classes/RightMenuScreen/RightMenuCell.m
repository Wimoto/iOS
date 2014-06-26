//
//  RightMenuCell.m
//  Wimoto
//
//  Created by Danny Kokarev on 03.12.13.
//
//

#import "RightMenuCell.h"

@interface RightMenuCell ()

@property (nonatomic, weak) IBOutlet UILabel *sensorNameLabel;

@end

@implementation RightMenuCell

- (void)setSensorEntity:(SensorEntity *)sensorEntity {
    _sensorEntity = sensorEntity;
    
    _sensorNameLabel.text = [_sensorEntity name];
}

@end
