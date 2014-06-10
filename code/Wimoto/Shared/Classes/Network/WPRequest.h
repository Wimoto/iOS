//
//  SPRequest.h
//  Softmaker
//
//  Created by MC700 on 10/26/12.
//
//


typedef enum {
    kWPGetFirmware = 1,
}WPRequestType;

@interface WPRequest : NSObject

@property (nonatomic, assign) WPRequestType requestType;
@property (nonatomic, strong) NSObject *requestData;
@property (nonatomic, assign) BOOL needsLockWindow;
@property (nonatomic, assign) int page;

+ (id)requestWithType:(WPRequestType)requestType andData:(NSObject*)requestData;
- (NSURLRequest*)formRequest;

@end
