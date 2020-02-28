//
//  NetResponseError.m
//  EHDNetwork
//
//  Created by luohs on 2020/2/28.
//

#import "NetResponseError.h"

@implementation NetResponseError
+ (instancetype)errorWithUserInfo:(id)userInfo context:(id)context
{
    if (![userInfo isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        dictionary[@"object"] = userInfo;
        userInfo = dictionary;
    }
    
    NetResponseError *error = ({
        [NetResponseError errorWithDomain:NSURLErrorDomain
                                       code:NSURLErrorCannotParseResponse
                                   userInfo:userInfo];
    });
    
    error->_context = context;
    
    return error;
}
@end
