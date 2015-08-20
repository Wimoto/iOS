//
//  DataLog.h
//  Wimoto
//
//  Created by Ievgen on 8/20/15.
//
//

#import <Foundation/Foundation.h>

@interface DataLog : NSObject

@property (nonatomic, strong) NSString *raw;

@property (nonatomic) int16_t year;
@property (nonatomic) int16_t month;
@property (nonatomic) int16_t day;
@property (nonatomic) int16_t hour;
@property (nonatomic) int16_t minute;
@property (nonatomic) int16_t seconds;
@property (nonatomic) int16_t logId;

- (id)initWithData:(NSData *)data;
- (NSDictionary *)dictionaryDescription;

@end
