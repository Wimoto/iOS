//
//  Firmware.m
//  Wimoto
//
//  Created by Danny Kokarev on 10.06.14.
//
//

#import "Firmware.h"

@implementation Firmware

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        NSObject *fileURLObject = [dictionary objectForKey:DICT_KEY_FIRMWARE_FILE_URL];
        if ([fileURLObject isKindOfClass:[NSString class]]) {
            self.fileURL = (NSString *)fileURLObject;
        }
        NSObject *versionObject = [dictionary objectForKey:DICT_KEY_FIRMWARE_VERSION];
        if ([versionObject isKindOfClass:[NSNumber class]]) {
            self.version = [NSString stringWithFormat:@"%@", versionObject];
        }
    }
    return self;
}

@end
