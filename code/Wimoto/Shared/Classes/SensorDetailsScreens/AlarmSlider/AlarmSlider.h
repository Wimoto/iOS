//
//  AlarmSlider.h
//  Wimoto
//
//  Created by Danny Kokarev on 22.05.14.
//
//

#import <UIKit/UIKit.h>
#import "NMRangeSlider.h"

@protocol AlarmSliderDelegate <NSObject>

- (void)alarmSliderSaveAction:(id)sender;

@end

@interface AlarmSlider : UIView

@property (nonatomic, weak) id<AlarmSliderDelegate>delegate;

- (void)showAction;
- (IBAction)hideAction:(id)sender;

- (void)setMinimumValue:(CGFloat)value;
- (void)setMaximumValue:(CGFloat)value;
- (void)setLowerValue:(CGFloat)value;
- (void)setUpperValue:(CGFloat)value;
- (void)setSliderRange:(CGFloat)value;
- (void)setStepValue:(CGFloat)value animated:(BOOL)animated;

- (CGFloat)lowerValue;
- (CGFloat)upperValue;

@end
