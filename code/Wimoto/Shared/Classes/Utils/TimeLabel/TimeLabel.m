//
//  TimeLabel.m
//  Wimoto
//
//  Created by Mobitexoft on 08.07.15.
//
//

#import "TimeLabel.h"

@implementation TimeLabel

- (void)setDate:(NSDate *)date {
    if (date == nil) {
        return;
    }
    
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc]init];
    timeFormatter.dateFormat = @"HH:mm a";
    [self setText:[timeFormatter stringFromDate:date]];
}

@end
