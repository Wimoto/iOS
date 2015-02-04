//
//  WPPickerView.h
//  Wimoto
//
//  Created by Alena Kokareva on 30.01.15.
//
//

#import <UIKit/UIKit.h>

typedef void(^CancelBlock)();
typedef void(^SaveBlock)(float lowerValue, float upperValue);

@interface WPPickerView : UIView <UIPickerViewDataSource, UIPickerViewDelegate>

+ (id)showWithMinValue:(float)minValue maxValue:(float)maxValue save:(SaveBlock)saveBlock cancel:(CancelBlock)cancelBlock;
+ (void)dismiss;
- (void)setUpperValue:(float)upperValue;
- (void)setLowerValue:(float)lowerValue;

@end
