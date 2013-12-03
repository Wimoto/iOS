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

- (void)bindData:(NSString *)string
{
    _sensorNameLabel.text = string;
}

@end
