//
//  SPResponse.m
//  Softmaker
//
//  Created by MC700 on 10/26/12.
//
//

#import "WPResponse.h"
#import "NSString+SBJSON.h"

@implementation WPResponse

+ (id)responseWithData:(NSData*)data andRequest:(WPRequest*)request code:(int)code {
    WPResponse *response = [[WPResponse alloc] init];
    response.request = request;
    response.codeStatus = code;
    NSString *responseDataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"responseDataString - %@", responseDataString);
    NSString *responseString = responseDataString;
    if (!responseString) {
        response.responseResult = kOPResponseResultError;
        return response;
    }
    response.responseString = [NSString stringWithString:responseString];
    NSObject *unknownData = [responseString JSONValue];
    if (unknownData) {
        response.responseData = unknownData;
        response.responseResult = kOPResponseResultSuccess;
    }
    else {
        response.responseResult = kOPResponseResultError;
    }
    return response;
}

@end
