//
//  NSString+Util.m
//  Wimoto
//
//  Created by Danny Kokarev on 12.12.12.
//
//

#import "NSString+Util.h"

@implementation NSString (NSString_Util)

- (BOOL)isEmpty {
    return ![self isNotEmpty];
}

- (BOOL)isNotEmpty {
	if ([[self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]==0) {
		return NO;
	}
	return YES; 
}	

@end
