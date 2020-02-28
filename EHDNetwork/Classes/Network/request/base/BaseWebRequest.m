//
//  BaseWebRequest.m
//  network
//
//  Created by luohs on 15/11/16.
//
//

#import "BaseWebRequest.h"
#import "NetworkProxy.h"

@implementation BaseWebRequest
- (NSURLRequest *)URLRequest
{
    NSMutableURLRequest *request = (NSMutableURLRequest *)[super URLRequest];
    __block NSString *cookieHeader = nil;
    NSDictionary *fields = [[NetworkProxy proxy] userOAuthFields];
    [fields enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSNumber class]]) {
            [request setValue:[obj stringValue] forHTTPHeaderField:key];
        }
        else if ([obj isKindOfClass:[NSString class]]) {
            [request setValue:obj forHTTPHeaderField:key];
        }
    }];
    [fields enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (!cookieHeader) {
            cookieHeader = [NSString stringWithFormat: @"%@=%@", key, obj];
        } else {
            cookieHeader = [NSString stringWithFormat: @"%@; %@=%@",cookieHeader, key, obj];
        }
    }];
    [request setValue:cookieHeader forHTTPHeaderField:@"Cookie"];
    return request;
}
@end
