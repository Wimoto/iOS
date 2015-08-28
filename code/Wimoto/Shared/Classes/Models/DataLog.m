//
//  DataLog.m
//  Wimoto
//
//  Created by Ievgen on 8/20/15.
//
//

#import "DataLog.h"
#import "NSData+Conversion.h"

static NSString * const kDataLogJsonRaw            = @"Raw";
static NSString * const kDataLogJsonYear           = @"Year";
static NSString * const kDataLogJsonMonth          = @"Month";
static NSString * const kDataLogJsonDay            = @"Day";
static NSString * const kDataLogJsonHour           = @"Hour";
static NSString * const kDataLogJsonMinutes        = @"Minutes";
static NSString * const kDataLogJsonSeconds        = @"Seconds";
static NSString * const kDataLogJsonLogId          = @"LogId";

@implementation DataLog

- (id)initWithData:(NSData *)data {
    self = [super init];
    if (self) {
        _raw = [data hexadecimalString];
        
        int16_t year	= 0;
        [data getBytes:&year range:NSMakeRange(0, 2)];
        _year = CFSwapInt16BigToHost(year);
        
        int16_t month	= 0;
        [data getBytes:&month range:NSMakeRange(2, 1)];
        _month = month;
        
        int16_t day	= 0;
        [data getBytes:&day range:NSMakeRange(3, 1)];
        _day = day;
        
        int16_t hour	= 0;
        [data getBytes:&hour range:NSMakeRange(4, 1)];
        _hour = hour;
        
        int16_t minute	= 0;
        [data getBytes:&minute range:NSMakeRange(5, 1)];
        _minute = minute;
        
        int16_t seconds	= 0;
        [data getBytes:&seconds range:NSMakeRange(6, 1)];
        _seconds = seconds;
        
        int16_t logId	= 0;
        [data getBytes:&logId range:NSMakeRange(14, 2)];
        _logId = CFSwapInt16BigToHost(logId);
    }
    return self;
}

- (NSDictionary *)dictionaryDescription {
    NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionary];
    [mutableDictionary setObject:_raw forKey:kDataLogJsonRaw];
    [mutableDictionary setObject:[NSNumber numberWithInt:_year] forKey:kDataLogJsonYear];
    [mutableDictionary setObject:[NSNumber numberWithInt:_month] forKey:kDataLogJsonMonth];
    [mutableDictionary setObject:[NSNumber numberWithInt:_day] forKey:kDataLogJsonDay];
    [mutableDictionary setObject:[NSNumber numberWithInt:_hour] forKey:kDataLogJsonHour];
    [mutableDictionary setObject:[NSNumber numberWithInt:_minute] forKey:kDataLogJsonMinutes];
    [mutableDictionary setObject:[NSNumber numberWithInt:_seconds] forKey:kDataLogJsonSeconds];
    [mutableDictionary setObject:[NSNumber numberWithInt:_logId] forKey:kDataLogJsonLogId];

    return mutableDictionary;
}

@end
