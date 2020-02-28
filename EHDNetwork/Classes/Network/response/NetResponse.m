//
//  NetResponse.m
//  EHDNetwork
//
//  Created by luohs on 2020/2/28.
//

#import "NetResponse.h"
#import "NetworkProxy.h"
#import "NetResponseParser.h"
#import "NetResponseError.h"
@implementation NetResponse
- (void)dealloc
{
    
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _statusCode = 0;
        _data = nil;
        _msg = nil;
        _raw = nil;
        _rawDictionary = nil;
        _error = nil;
    }
    return self;
}

- (instancetype)initWithObject:(id)object dataClass:(Class)dataClass
{
    if ([object isKindOfClass:[self class]]) {
        return object;
    }
    
    self = [self init];
    if (self) {
        _statusCode = 200;
        _raw = object;
        NSError *error = nil;
        NSDictionary *dictionary = [NetResponseParser dictionaryWithObject:object error:&error];
        [self p_updateWithDictionary:dictionary dataClass:dataClass error:error];
    }
    
    return self;
}

- (instancetype)initWithError:(NSError *)error
{
    if ([error isKindOfClass:[NetResponseError class]]) {
        NetResponseError *temp = (NetResponseError *)error;
        id response = temp.context;
        if ([response isKindOfClass:[NetResponse class]]) {
            return response;
        }
    }
    
    self = [self init];
    if (self) {
        for (NSHTTPURLResponse *response in error.userInfo.allValues) {
            if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                _statusCode = response.statusCode;
            }
        }
        [self p_updateWithDictionary:error.userInfo dataClass:nil error:error];
        if (_msg.length == 0) {
            _msg = @"网络错误";
        }
    }
    return self;
}

- (void)p_updateWithDictionary:(NSDictionary *)dictionary
                     dataClass:(Class)dataClass
                         error:(NSError *)error
{
    dictionary = [dictionary isKindOfClass:[NSDictionary class]] ? dictionary : nil;
    NetworkProxy *proxy = [NetworkProxy proxy];
    
    // result
    const BOOL result = ({
        NSString *key = nil;
        if ([proxy respondsToSelector:@selector(responseObjectResultKey)]) {
            key = [proxy responseObjectResultKey];
        }
        if (key.length == 0) {
            key = @"result";
        }
        
        NSDictionary *resultMap = nil;
        if ([proxy respondsToSelector:@selector(responseObjectResultValueMap)]) {
            resultMap = [proxy responseObjectResultValueMap];
        }
        if (resultMap.count == 0) {
            resultMap = @{@"success" : @(YES)};
        }
        
        NSString *value = nil;
        NSString *result = [NetResponseParser stringWithObject:dictionary[@"result"]];
        if (result) {
            value = resultMap[result];
        }
        value.boolValue;
    });
    
    // error
    if (!result && !error) {
        error = [NetResponseError errorWithUserInfo:dictionary context:self];
    }
    _error = error;
    
    // 服务端返回的msg
    _serverMsg = [NetResponseParser stringWithObject:dictionary[@"msg"]];
    // 错误时才设置msg
    if (error) {
        _msg = self.serverMsg;
    } else {
        _msg = nil;
    }
    
    // 不管是否error 都尝试获取code
    {
        NSString *key = nil;
        if ([proxy respondsToSelector:@selector(responseObjectHandlingCodeKey)]) {
            key = [proxy responseObjectHandlingCodeKey];
        }
        if (key.length == 0) {
            key = @"code";
        }
        _code = [NetResponseParser stringWithObject:dictionary[key]];
        if (_code.length == 0) {
            if (_error) {
                _code = [NetResponseParser stringWithObject:dictionary[@"errorCode"]];
                if (_code.length == 0) {
                    _code = [NetResponseParser stringWithObject:dictionary[@"data"]];
                }
            }
        }
    }
    
    // count
    _count = [NetResponseParser stringWithObject:dictionary[@"count"]];
    
    // 方便查看变量 这里使用NSMutableDictionary
    _rawDictionary = [NSMutableDictionary dictionaryWithDictionary:dictionary];
    
    // 解析data
    _data = [NetResponseParser objectWithRawValue:dictionary[@"data"] dataClass:dataClass];
}
@end
