//
//  WPPickerView.h
//  Wimoto
//
//  Created by MC700 on 30.01.15.
//
//

#import <UIKit/UIKit.h>

typedef void(^CancelBlock)();
typedef void(^SaveBlock)(float lowerValue, float upperValue);

@interface WPPickerView : UIView <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) NSArray *columns;

+ (id)showWithMinValue:(float)minValue maxValue:(float)maxValue save:(SaveBlock)saveBlock cancel:(CancelBlock)cancelBlock;

- (void)showWithMinValue:(float)minValue maxValue:(float)maxValue save:(SaveBlock)saveBlock cancel:(CancelBlock)cancelBlock;
+ (void)dismiss;
- (void)setUpperValue:(float)upperValue;
- (void)setLowerValue:(float)lowerValue;

- (float)upperValue;
- (float)lowerValue;

@end
