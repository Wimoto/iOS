//
//  SPRequest.m
//  Softmaker
//
//  Created by MC700 on 10/26/12.
//
//

#import "WPRequest.h"
#import "SBJSON.h"
#import <AdSupport/AdSupport.h>

@implementation WPRequest

+ (id)requestWithType:(WPRequestType)requestType andData:(NSObject*)requestData {
    WPRequest *request = [[WPRequest alloc] init];
    request.requestType = requestType;
    request.requestData = requestData;
    return request;
}

- (NSURLRequest*)formRequest {
    NSMutableURLRequest *mutableURLRequest = [[NSMutableURLRequest alloc] init];
    switch (_requestType) {
        case kWPRequestGetFirmwareList: {
            [mutableURLRequest setHTTPMethod:@"GET"]; //http://wimoto.io:8080/api/firmwares/Climate
            [mutableURLRequest setURL:[NSURL URLWithString:@"http://www.wimoto.com:8080/api/firmwares/"]];
            [mutableURLRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            break;
		}
    }
    return mutableURLRequest;
}

@end
