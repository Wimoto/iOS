//
//  DatePickerView.h
//  Wimoto
//
//  Created by admin on 25.05.15.
//  Copyright (c) 2015 Mobitexoft. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^DatePickerBlock)(NSDate *date);

@interface DatePickerView : UIView

+ (void)showWithSelectedDate:(NSDate *)date completionHandler:(DatePickerBlock)handler;
+ (void)dismiss;

@end
