//
//  TimePickerView.m
//  Wimoto
//
//  Created by Mobitexoft on 03.07.15.
//
//

#import "TimePickerView.h"

@interface TimePickerView()

@property (nonatomic, weak) IBOutlet UIToolbar *pickerViewContainer;
@property (nonatomic, copy) TimeCancelBlock cancelBlock;
@property (nonatomic, copy) TimeSaveBlock saveBlock;

@property (nonatomic, weak) IBOutlet UIDatePicker *leftTimePicker;
@property (nonatomic, weak) IBOutlet UIDatePicker *rightTimePicker;

- (IBAction)cancelAction:(id)sender;
- (IBAction)saveAction:(id)sender;

@end

@implementation TimePickerView

+ (id)showWithMinDate:(NSDate *)minDate maxDate:(NSDate *)maxDate save:(TimeSaveBlock)saveBlock cancel:(TimeCancelBlock)cancelBlock {
    TimePickerView *timePickerView = [[TimePickerView alloc] init];
    [timePickerView showWithMinDate:minDate maxDate:maxDate save:saveBlock cancel:cancelBlock];
    
    return timePickerView;
}

- (IBAction)saveAction:(id)sender {
    [UIView animateWithDuration:0.2 animations:^{
        [self hide];
    } completion:^(BOOL finished) {
        if (_saveBlock) {
            _saveBlock([self lowerDate], [self upperDate]);
        }
        [self removeFromSuperview];
    }];
}

- (IBAction)cancelAction:(id)sender {
    [UIView animateWithDuration:0.2 animations:^{
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

- (void)showWithMinDate:(NSDate *)minDate maxDate:(NSDate *)maxDate save:(TimeSaveBlock)saveBlock cancel:(TimeCancelBlock)cancelBlock {
    self.saveBlock = saveBlock;
    self.cancelBlock = cancelBlock;

    CGRect screenFrame = [UIScreen mainScreen].bounds;
    self.frame = screenFrame;
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self];
    
    [[NSBundle mainBundle] loadNibNamed:@"TimePickerView" owner:self options:nil];
    _pickerViewContainer.frame = CGRectMake(0.0, self.frame.size.height, self.frame.size.width, _pickerViewContainer.frame.size.height);
    [self addSubview:_pickerViewContainer];
    
    [_leftTimePicker setDate:minDate];
    [_rightTimePicker setDate:maxDate];
    
    [self layoutIfNeeded];
    
    [UIView animateWithDuration:0.2 animations:^{
        self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
        _pickerViewContainer.frame = CGRectMake(_pickerViewContainer.frame.origin.x, self.frame.size.height - _pickerViewContainer.frame.size.height, _pickerViewContainer.frame.size.width, _pickerViewContainer.frame.size.height);
    } completion:nil];
}

- (NSDate *)lowerDate {
    NSDate *leftDate = [_leftTimePicker date];
    NSDate *rightDate = [_rightTimePicker date];

    return ([leftDate compare:rightDate] == NSOrderedAscending)?leftDate:rightDate;
}

- (NSDate *)upperDate {
    NSDate *leftDate = [_leftTimePicker date];
    NSDate *rightDate = [_rightTimePicker date];
    
    return ([leftDate compare:rightDate] == NSOrderedDescending)?leftDate:rightDate;
}

@end
