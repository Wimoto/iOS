//
//  Firmware.h
//  Wimoto
//
//  Created by Danny Kokarev on 10.06.14.
//
//

#import <Foundation/Foundation.h>

#define DICT_KEY_FIRMWARE_FILE_URL              @"fileURL"
#define DICT_KEY_FIRMWARE_VERSION               @"latestVersion"

@interface Firmware : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *fileURL;
@property (nonatomic, strong) NSString *version;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
