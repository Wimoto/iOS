//
//  WPDatePickerView.m
//  Wimoto
//
//  Created by admin on 25.05.15.
//  Copyright (c) 2015 Mobitexoft. All rights reserved.
//

#import "DatePickerView.h"
#import "SRMonthPicker.h"

@interface DatePickerView () <SRMonthPickerDelegate>

@property (nonatomic, strong) IBOutlet UIView *contentView;
@property (nonatomic, weak) IBOutlet SRMonthPicker *datePicker;
@property (nonatomic, weak) IBOutlet UIToolbar *toolBar;
@property (nonatomic, copy) DatePickerBlock handler;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *datePickerBottom;

- (void)commonInit;
- (IBAction)cancelAction:(id)sender;
- (IBAction)saveAction:(id)sender;

@end

@implementation DatePickerView

- (id)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    if (!_contentView) {
        [[NSBundle mainBundle] loadNibNamed:@"DatePickerView" owner:self options:nil];
        [self addSubview:_contentView];
        _contentView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_contentView]|"
                                                                     options:NSLayoutFormatDirectionLeadingToTrailing
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(_contentView)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_contentView]|"
                                                                     options:NSLayoutFormatDirectionLeadingToTrailing
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(_contentView)]];
        _datePicker.monthPickerDelegate = self;
    }
}

+ (void)showWithSelectedDate:(NSDate *)date completionHandler:(DatePickerBlock)handler {
    DatePickerView *datePickerView = [[DatePickerView alloc] init];
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:datePickerView];
    datePickerView.translatesAutoresizingMaskIntoConstraints = NO;
    [keyWindow addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[datePickerView]|"
                                                                 options:NSLayoutFormatDirectionLeadingToTrailing
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(datePickerView)]];
    [keyWindow addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[datePickerView]|"
                                                                 options:NSLayoutFormatDirectionLeadingToTrailing
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(datePickerView)]];
    [datePickerView showWithSelectedDate:date completionHandler:handler];
}

+ (void)dismiss {
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    for (int i = [keyWindow.subviews count]-1; i >= 0; i--) {
        UIView *subView = [keyWindow.subviews objectAtIndex:i];
        if ([subView isKindOfClass:[DatePickerView class]]) {
            [(DatePickerView *)subView dismiss];
            break;
        }
    }
}

- (IBAction)cancelAction:(id)sender {
    [self dismiss];
}

- (IBAction)saveAction:(id)sender {
    if (_handler) {
        _handler(_datePicker.date);
    }
    [self dismiss];
}

- (void)showWithSelectedDate:(NSDate *)date completionHandler:(DatePickerBlock)handler {
    self.handler = handler;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy";
    NSString *currentYear = [dateFormatter stringFromDate:[NSDate date]];
    _datePicker.yearFirst = NO;
    _datePicker.minimumYear = [currentYear integerValue];
    _datePicker.maximumYear = 2100;
    _datePicker.date = (date != nil)?date:[NSDate date];
    [self layoutIfNeeded];
    _datePickerBottom.constant = -(_datePicker.frame.size.height + _toolBar.frame.size.height);
    [self layoutIfNeeded];
    _datePickerBottom.constant = 0.0;
    [UIView animateWithDuration:0.2 animations:^{
        self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        [self layoutIfNeeded];
    }];
}

- (void)dismiss {
    _datePickerBottom.constant = -(_datePicker.frame.size.height + _toolBar.frame.size.height);
    [UIView animateWithDuration:0.2 animations:^{
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - SRMonthPickerDelegate

- (void)monthPickerWillChangeDate:(SRMonthPicker *)monthPicker {
    
}

- (void)monthPickerDidChangeDate:(SRMonthPicker *)monthPicker {
    
}

@end
