//
//  WPPickerView.m
//  Wimoto
//
//  Created by Alena Kokareva on 30.01.15.
//
//

#import "WPPickerView.h"

@interface WPPickerView ()

@property (nonatomic, strong) NSArray *columns;
@property (nonatomic, copy) SaveBlock saveBlock;
@property (nonatomic, copy) CancelBlock cancelBlock;
@property (nonatomic, weak) IBOutlet UIPickerView *pickerView;
@property (nonatomic, weak) IBOutlet UIToolbar *pickerViewContainer;

- (void)showWithMinValue:(float)minValue maxValue:(float)maxValue save:(SaveBlock)saveBlock cancel:(CancelBlock)cancelBlock;
- (NSArray *)configureDataSourceMinValue:(float)minValue maxValue:(float)maxValue;
- (NSInteger)indexForValue:(float)value;
- (void)hide;
- (IBAction)save:(id)sender;
- (IBAction)cancel:(id)sender;

@end

@implementation WPPickerView

+ (id)showWithMinValue:(float)minValue maxValue:(float)maxValue save:(SaveBlock)saveBlock cancel:(CancelBlock)cancelBlock {
    WPPickerView *pickerView = [[WPPickerView alloc] init];
    [pickerView showWithMinValue:minValue maxValue:maxValue save:saveBlock cancel:cancelBlock];
    return pickerView;
}

+ (void)dismiss {
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    for (UIView *subView in keyWindow.subviews) {
        if ([subView isKindOfClass:[WPPickerView class]]) {
            [(WPPickerView *)subView cancel:nil];
            break;
        }
    }
}

- (void)showWithMinValue:(float)minValue maxValue:(float)maxValue save:(SaveBlock)saveBlock cancel:(CancelBlock)cancelBlock {
    self.saveBlock = saveBlock;
    self.cancelBlock = cancelBlock;
    
    self.userInteractionEnabled = YES;
    self.backgroundColor = [UIColor clearColor];
    self.columns = [self configureDataSourceMinValue:minValue maxValue:maxValue];
    
    CGRect screenFrame = [UIScreen mainScreen].bounds;
    self.frame = screenFrame;
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self];
    
    [[NSBundle mainBundle] loadNibNamed:@"WPPickerView" owner:self options:nil];
    _pickerViewContainer.frame = CGRectMake(0.0, self.frame.size.height, self.frame.size.width, _pickerViewContainer.frame.size.height);
    [self addSubview:_pickerViewContainer];
    
    [UIView animateWithDuration:0.25 delay:0.0 options:(7 << 16) animations:^{
        self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
        _pickerViewContainer.frame = CGRectMake(_pickerViewContainer.frame.origin.x, self.frame.size.height - _pickerViewContainer.frame.size.height, _pickerViewContainer.frame.size.width, _pickerViewContainer.frame.size.height);
    } completion:nil];
}

- (NSArray *)configureDataSourceMinValue:(float)minValue maxValue:(float)maxValue {
    NSMutableArray *rangeArray = [NSMutableArray array];
    NSMutableArray *decimalArray = [NSMutableArray array];
    @autoreleasepool {
        for (int i = minValue; i <= maxValue; i++) {
            if (i == 0 && [rangeArray count] > 0) {
                [rangeArray addObject:[NSString stringWithFormat:@"-0"]];
            }
            [rangeArray addObject:[NSString stringWithFormat:@"%i", i]];
        }
        for (int i = 0; i < 10; i++) {
            [decimalArray addObject:[NSString stringWithFormat:@".%i", i]];
        }
    }
    return @[[rangeArray copy], [decimalArray copy], [rangeArray copy], [decimalArray copy]];
}

- (void)setLowerValue:(float)lowerValue {
    float integerValue;
    int decimalPart = abs(roundf((modff(lowerValue, &integerValue) * 10.0)));
    [_pickerView selectRow:decimalPart inComponent:1 animated:NO];
    NSInteger index = [self indexForValue:integerValue];
    if (index >= 0) {
        [_pickerView selectRow:index inComponent:0 animated:NO];
    }
}

- (void)setUpperValue:(float)upperValue {
    float integerValue;
    int decimalPart = abs(roundf((modff(upperValue, &integerValue) * 10.0)));
    [_pickerView selectRow:decimalPart inComponent:3 animated:NO];
    
    NSInteger index = [self indexForValue:integerValue];
    if (index >= 0) {
        [_pickerView selectRow:index inComponent:2 animated:NO];
    }
}

- (NSInteger)indexForValue:(float)value {
    NSArray *columnValues = [_columns objectAtIndex:0];
    float minValue = [[columnValues objectAtIndex:0] floatValue];
    float maxValue = [[columnValues lastObject] floatValue];
    if (minValue <= value <= maxValue) {
        NSPredicate *preicate = [NSPredicate predicateWithFormat:@"self == %@", [NSString stringWithFormat:@"%.f", value]];
        NSArray *filteredArray = [columnValues filteredArrayUsingPredicate:preicate];
        if ([filteredArray count] > 0) {
            NSString *matchValue = [filteredArray lastObject];
            return [columnValues indexOfObject:matchValue];
        }
    }
    return -1;
}

- (IBAction)save:(id)sender {
    [UIView animateWithDuration:0.25 delay:0.0 options:(7 << 16) animations:^{
        [self hide];
    } completion:^(BOOL finished) {
        if (_saveBlock) {
            NSArray *columnValues = [_columns objectAtIndex:0];
            NSArray *columnDecimalValues = [_columns objectAtIndex:1];
            
            NSInteger minIndex = [_pickerView selectedRowInComponent:0];
            NSInteger decimalMinIndex = [_pickerView selectedRowInComponent:1];
            NSInteger maxIndex = [_pickerView selectedRowInComponent:2];
            NSInteger decimalMaxIndex = [_pickerView selectedRowInComponent:3];
            
            NSString *lowerValueString = [columnValues objectAtIndex:minIndex];
            NSString *upperValueString = [columnValues objectAtIndex:maxIndex];
            NSString *decimalLowerValueString = [columnDecimalValues objectAtIndex:decimalMinIndex];
            NSString *decimalUpperValueString = [columnDecimalValues objectAtIndex:decimalMaxIndex];
            
            float decimalLowerValue = [[decimalLowerValueString substringFromIndex:1] floatValue]/10.0;
            float decimalUpperValue = [[decimalUpperValueString substringFromIndex:1] floatValue]/10.0;
            float integerLowerValue = [lowerValueString floatValue];
            float integerUpperValue = [upperValueString floatValue];
            
            float lowerValue = 0.0;
            float upperValue = 0.0;
            
            if ([lowerValueString isEqualToString:@"-0"]) {
                if (decimalLowerValue != 0.0) {
                    lowerValue = integerLowerValue - decimalLowerValue;
                }
            }
            else {
                lowerValue = integerLowerValue + ((integerLowerValue < 0)?(-decimalLowerValue):decimalLowerValue);
            }
            if ([upperValueString isEqualToString:@"-0"]) {
                if (decimalUpperValue != 0.0) {
                    upperValue = integerUpperValue - decimalUpperValue;
                }
            }
            else {
                upperValue = integerUpperValue + ((integerUpperValue < 0)?(-decimalUpperValue):decimalUpperValue);
            }
    
            if (lowerValue > upperValue) {
                _saveBlock(upperValue, lowerValue);
            }
            else {
                _saveBlock(lowerValue, upperValue);
            }
        }
        [self removeFromSuperview];
    }];
}

- (IBAction)cancel:(id)sender {
    [UIView animateWithDuration:0.25 delay:0.0 options:(7 << 16) animations:^{
        [self hide];
    } completion:^(BOOL finished) {
        if (_cancelBlock) {
            _cancelBlock();
        }
        [self removeFromSuperview];
    }];
}

- (void)hide {
    self.backgroundColor = [UIColor clearColor];
    _pickerViewContainer.frame = CGRectMake(_pickerViewContainer.frame.origin.x, self.frame.size.height, _pickerViewContainer.frame.size.width, _pickerViewContainer.frame.size.height);
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return [_columns count];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [[_columns objectAtIndex:component] count];
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    NSArray *rows = [_columns objectAtIndex:component];
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
        UILabel *label = [[UILabel alloc] init];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        if (component == 0 || component == 2) {
            label.textAlignment = NSTextAlignmentRight;
            label.textColor = [UIColor blackColor];
        }
        else {
            label.frame = CGRectMake(10.0, 0.0, 0.0, 0.0);
            label.textAlignment = NSTextAlignmentLeft;
            label.textColor = [UIColor redColor];
        }
        [labelContainer addSubview:label];
    }
    UILabel *label = [labelContainer.subviews lastObject];
    label.text = title;
    return labelContainer;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return 80.0;
}

@end
