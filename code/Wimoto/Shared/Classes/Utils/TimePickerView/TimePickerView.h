//
//  TimePickerView.h
//  Wimoto
//
//  Created by Mobitexoft on 03.07.15.
//
//

#import <UIKit/UIKit.h>

typedef void(^TimeCancelBlock)();
typedef void(^TimeSaveBlock)(NSDate *minDate, NSDate *maxDate);

@interface TimePickerView : UIView 

+ (id)showWithMinDate:(NSDate *)minDate maxDate:(NSDate *)maxDate save:(TimeSaveBlock)saveBlock cancel:(TimeCancelBlock)cancelBlock;
- (void)showWithMinDate:(NSDate *)minDate maxDate:(NSDate *)maxDate save:(TimeSaveBlock)saveBlock cancel:(TimeCancelBlock)cancelBlock;

- (NSDate *)upperDate;
- (NSDate *)lowerDate;

@end
