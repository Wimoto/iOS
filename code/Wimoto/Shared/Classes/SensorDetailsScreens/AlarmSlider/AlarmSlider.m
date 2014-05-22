//
//  AlarmSlider.m
//  Wimoto
//
//  Created by Danny Kokarev on 22.05.14.
//
//

#import "AlarmSlider.h"

@interface AlarmSlider ()

@property (nonatomic, strong) IBOutlet UIView *containerView;
@property (nonatomic, weak) IBOutlet UILabel *minValueLabel;
@property (nonatomic, weak) IBOutlet UILabel *maxValueLabel;

- (IBAction)doneAction:(id)sender;

@end

@implementation AlarmSlider

- (void)awakeFromNib
{
    
}

@end
