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

- (void)showWithMinValue:(float)minValue maxValue:(float)maxValue step:(float)step save:(SaveBlock)saveBlock cancel:(CancelBlock)cancelBlock;
- (NSArray *)configureDataSourceMinValue:(float)minValue maxValue:(float)maxValue step:(float)step;
- (void)hide;
- (IBAction)save:(id)sender;
- (IBAction)cancel:(id)sender;

@end

@implementation WPPickerView

+ (id)showWithMinValue:(float)minValue maxValue:(float)maxValue step:(float)step save:(SaveBlock)saveBlock cancel:(CancelBlock)cancelBlock {
    WPPickerView *pickerView = [[WPPickerView alloc] init];
    [pickerView showWithMinValue:minValue maxValue:maxValue step:step save:saveBlock cancel:cancelBlock];
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

- (void)showWithMinValue:(float)minValue maxValue:(float)maxValue step:(float)step save:(SaveBlock)saveBlock cancel:(CancelBlock)cancelBlock {
    self.saveBlock = saveBlock;
    self.cancelBlock = cancelBlock;
    
    self.userInteractionEnabled = YES;
    self.backgroundColor = [UIColor clearColor];
    self.columns = [self configureDataSourceMinValue:minValue maxValue:maxValue step:step];
    
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

- (NSArray *)configureDataSourceMinValue:(float)minValue maxValue:(float)maxValue step:(float)step {
    float properStep = (step > 0)?step:1.0;
    NSMutableArray *rangeArray = [NSMutableArray array];
    @autoreleasepool {
        for (float i = minValue; i <= maxValue; i += properStep) {
            [rangeArray addObject:[NSString stringWithFormat:@"%.1f", i]];
        }
    }
    return @[[rangeArray copy], [rangeArray copy]];
}

- (void)setLowerValue:(float)lowerValue {
    NSInteger index = [self indexForValue:lowerValue];
    if (index >= 0) {
        [_pickerView selectRow:index inComponent:0 animated:NO];
    }
}

- (void)setUpperValue:(float)upperValue {
    NSInteger index = [self indexForValue:upperValue];
    if (index >= 0) {
        [_pickerView selectRow:index inComponent:1 animated:NO];
    }
}

- (NSInteger)indexForValue:(float)value {
    NSArray *columnValues = [_columns objectAtIndex:0];
    float minValue = [[columnValues objectAtIndex:0] floatValue];
    float maxValue = [[columnValues lastObject] floatValue];
    if (minValue <= value <= maxValue) {
        NSPredicate *preicate = [NSPredicate predicateWithFormat:@"self == %@", [NSString stringWithFormat:@"%.1f", value]];
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
            NSArray *minColumn = [_columns objectAtIndex:0];
            NSArray *maxColumn = [_columns objectAtIndex:1];
            NSString *lowerValueString = [minColumn objectAtIndex:[_pickerView selectedRowInComponent:0]];
            NSString *upperValueString = [maxColumn objectAtIndex:[_pickerView selectedRowInComponent:1]];
            _saveBlock([lowerValueString floatValue], [upperValueString floatValue]);
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

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
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
    return title;
}

#pragma mark - UIPickerViewDelegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSArray *columnValues = [_columns objectAtIndex:0];
    NSInteger minIndex = [pickerView selectedRowInComponent:0];
    NSInteger maxIndex = [pickerView selectedRowInComponent:1];
    NSString *lowerValueString = [columnValues objectAtIndex:minIndex];
    NSString *upperValueString = [columnValues objectAtIndex:maxIndex];
    if ([lowerValueString floatValue] > [upperValueString floatValue]) {
        [pickerView selectRow:maxIndex inComponent:0 animated:YES];
    }
}

@end
