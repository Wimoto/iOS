//
//  SPResponse.h
//  Softmaker
//
//  Created by MC700 on 10/26/12.
//
//

#import "WPRequest.h"

#define SP_KEY_CONNECTION_RESULT @"result"
#define SP_KEY_CONNECTION_DATA   @"data"

typedef enum {
	kOPResponseResultError = 0,
    kOPResponseResultSuccess
} SPResponseResult;

@interface WPResponse : NSObject 

@property (nonatomic, assign) SPResponseResult responseResult;
@property (nonatomic, strong) NSObject *responseData;
@property (nonatomic, strong) WPRequest *request;
@property (nonatomic, assign) int codeStatus;
@property (nonatomic, strong) NSString *responseString;

+ (id)responseWithData:(NSData*)data andRequest:(WPRequest*)request code:(int)code;

@end
