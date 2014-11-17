//
//  AlarmSlider.m
//  Wimoto
//
//  Created by Danny Kokarev on 22.05.14.
//
//

#import "AlarmSlider.h"

@interface AlarmSlider ()

@property (nonatomic, weak) IBOutlet NMRangeSlider *rangeSlider;
@property (nonatomic, strong) IBOutlet UIView *containerView;
@property (nonatomic, weak) IBOutlet UILabel *minValueLabel;
@property (nonatomic, weak) IBOutlet UILabel *maxValueLabel;

- (IBAction)labelSliderChanged:(NMRangeSlider*)sender;

@end

@implementation AlarmSlider

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    [[NSBundle mainBundle] loadNibNamed:@"AlarmSlider" owner:self options:nil];
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, _containerView.frame.size.height);
    [self addSubview:_containerView];
}

- (void)setMinimumValue:(CGFloat)value {
    _rangeSlider.minimumValue = value;
}

- (void)setMaximumValue:(CGFloat)value {
    _rangeSlider.maximumValue = value;
    NSLog(@"----======== %f", _rangeSlider.maximumValue);
}

- (void)setLowerValue:(CGFloat)value {
    [_rangeSlider setLowerValue:value];
}

- (void)setUpperValue:(CGFloat)value {
    [_rangeSlider setUpperValue:value];
}

- (void)setSliderRange:(CGFloat)value {
    _rangeSlider.minimumRange = value;
}

- (void)setStepValue:(CGFloat)value animated:(BOOL)animated {
    _rangeSlider.stepValue = value;
    _rangeSlider.stepValueAnimated = animated;
}

- (IBAction)labelSliderChanged:(NMRangeSlider*)sender {
    [self updateSliderLabels];
}

- (CGFloat)lowerValue {
    return [_rangeSlider lowerValue];
}

- (CGFloat)upperValue {
    return [_rangeSlider upperValue];
}

- (void)showAction {
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = CGRectMake(self.frame.origin.x, self.superview.frame.size.height - self.frame.size.height, self.frame.size.width, self.frame.size.height);
    }];
}

- (IBAction)hideAction:(id)sender {
    if (sender) {
        [_delegate alarmSliderSaveAction:self];
    }
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = CGRectMake(self.frame.origin.x, self.superview.frame.size.height, self.frame.size.width, self.frame.size.height);
    }];
}

- (void)updateSliderLabels  {
    //CGPoint lowerCenter;
    //lowerCenter.x = (_rangeSlider.lowerCenter.x + _rangeSlider.frame.origin.x);
    //lowerCenter.y = (_rangeSlider.center.y - 30.0f);
    //_minValueLabel.center = lowerCenter;
    _minValueLabel.text = [NSString stringWithFormat:@"Min %d", (int)_rangeSlider.lowerValue];
    
    //CGPoint upperCenter;
    //upperCenter.x = (_rangeSlider.upperCenter.x + _rangeSlider.frame.origin.x);
    //upperCenter.y = (_rangeSlider.center.y - 30.0f);
    //_maxValueLabel.center = upperCenter;
    _maxValueLabel.text = [NSString stringWithFormat:@"Max %d", (int)_rangeSlider.upperValue];
}

@end
