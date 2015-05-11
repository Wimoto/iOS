//
//  WPTemperaturePickerView.m
//  Wimoto
//
//  Created by MacBook on 11/05/2015.
//
//

#import "WPTemperaturePickerView.h"
#import "WPTemperatureValueLabel.h"

@implementation WPTemperaturePickerView

+ (id)showWithMinValue:(float)minValue maxValue:(float)maxValue save:(SaveBlock)saveBlock cancel:(CancelBlock)cancelBlock {
    WPTemperaturePickerView *pickerView = [[WPTemperaturePickerView alloc] init];
    [pickerView showWithMinValue:minValue maxValue:maxValue save:saveBlock cancel:cancelBlock];
    return pickerView;
}

#pragma mark - UIPickerViewDataSource

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    NSArray *rows = [self.columns objectAtIndex:component];
    NSString *title = nil;
    NSObject *rowObject = [rows objectAtIndex:row];
    if ([rowObject isKindOfClass:[NSString class]]) {
        title = (NSString *)rowObject;
    }
    else if ([rowObject isKindOfClass:[NSNumber class]]) {
        title = [NSString stringWithFormat:@"%@", rowObject];
    }
    else {
        title = @"";
    }
    UIView *labelContainer = (UIView *)view;
    if (!labelContainer) {
        labelContainer = [[UIView alloc] init];
        labelContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        WPTemperatureValueLabel *label = [[WPTemperatureValueLabel alloc] init];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        if (component == 0 || component == 2) {
            label.textAlignment = NSTextAlignmentRight;
            label.textColor = [UIColor blackColor];
            label.text = title;
        }
        else {
            label.frame = CGRectMake(10.0, 0.0, 0.0, 0.0);
            label.textAlignment = NSTextAlignmentLeft;
            label.textColor = [UIColor redColor];
            
            NSObject *rowObject = [rows objectAtIndex:row];
            if ([rowObject isKindOfClass:[NSNumber class]]) {
                NSNumber *number = (NSNumber *)rowObject;
                [label setTemperature:[number floatValue]];
            }
        }
        [labelContainer addSubview:label];
    }
    return labelContainer;
}

@end
