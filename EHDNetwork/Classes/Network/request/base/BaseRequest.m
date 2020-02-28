//
//  BaseRequest.m
//  network
//
//  Created by luohs on 15/7/2.
//  Copyright (c) 2015年 罗华胜. All rights reserved.
//

#import "BaseRequest.h"
#import "NetworkRequest.h"
#import <objc/runtime.h>
#import "NetworkProxy.h"
#import "BaseUploadRequest.h"
#import "NetResponse.h"
#if NET_HTTPDNS_ENABLE
#import <EHDHttpDNS/HttpDNS.h>
#endif

NSString * const NetProtocolHttp   = @"http://";
NSString * const NetProtocolHttps  = @"https://";

NSString * const NetPOSTHttpMethod   = @"POST";
NSString * const NetPUTHttpMethod    = @"PUT";
NSString * const NetGETHttpMethod    = @"GET";
NSString * const NetDELETEHttpMethod = @"DELETE";
static NSString * const NetworkDesKey = @"emFxMUBXU1g=";

static NSString * const NetworkOperationFailingURLResponseDataErrorKey = @"com.luohs.baserequest.response.error.data";

@interface BaseRequestManager: NSObject
{

}
@property (readwrite, nonatomic, strong) NSMutableDictionary <NSString*, BaseRequest*> *baseRequestsKeyedByIdentifier;
@property (readwrite, nonatomic, strong) NSLock *lock;
@end

@implementation BaseRequestManager
- (id)init
{
    self = [super init];
    if (self) {
        self.baseRequestsKeyedByIdentifier = [[NSMutableDictionary alloc] init];
        self.lock = [[NSLock alloc] init];
        self.lock.name = @"com.luohs.networking.request.manager.lock";
    }
    return self;
}

- (BaseRequest *)requestForIdentifier:(NSString *)identifier {
    BaseRequest *request = nil;
    [self.lock lock];
    request = self.baseRequestsKeyedByIdentifier[identifier];
    [self.lock unlock];

    return request;
}

- (void)setRequest:(BaseRequest *)request
     forIdentifier:(NSString *)identifier
{
    [self.lock lock];
    self.baseRequestsKeyedByIdentifier[identifier] = request;
    [self.lock unlock];
    
    #ifdef DEBUG
        NSMutableString *log = [NSMutableString string];
        [log appendFormat:@"\n\nRequest Queue Set Request Identifier:\n\t%@", identifier];
        [log appendFormat:@"\n\nRequest Queue Set Request Class:\n\t%@", NSStringFromClass(request.class)];
        [log appendFormat:@"\n\nRequest Queue Count:\n\t%@", @(self.baseRequestsKeyedByIdentifier.count)];
        NSLog(@"%@", log);
    #endif
}

- (void)removeRequestForIdentifier:(NSString *)identifier {

    if (self.baseRequestsKeyedByIdentifier.count <= 0){
        return;
    }
    
    BaseRequest *request = nil;
    [self.lock lock];
    request = self.baseRequestsKeyedByIdentifier[identifier];
    [self.baseRequestsKeyedByIdentifier removeObjectForKey:identifier];
    [self.lock unlock];
    
    #ifdef DEBUG
        NSParameterAssert(request);
        NSMutableString *log = [NSMutableString string];
        [log appendFormat:@"\n\nRequest Queue Remove Request Identifier:\n\t%@", identifier];
        [log appendFormat:@"\n\nRequest Queue Remove Request Class:\n\t%@", NSStringFromClass(request.class)];
        [log appendFormat:@"\n\nRequest Queue Count:\n\t%@", @(self.baseRequestsKeyedByIdentifier.count)];
        [self.baseRequestsKeyedByIdentifier enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, BaseRequest * _Nonnull obj, BOOL * _Nonnull stop) {
            [log appendFormat:@"\n\nRequest Queue Remain Request Class:\n\t%@", NSStringFromClass(obj.class)];
        }];
        NSLog(@"%@", log);
    #endif
}

- (void)removeAllRequest {
    [self.lock lock];
    [self.baseRequestsKeyedByIdentifier removeAllObjects];
    [self.lock unlock];

    #ifdef DEBUG
        NSMutableString *log = [NSMutableString string];
        [log appendFormat:@"\n\nRequest Queue Remove All\n\t"];
        [log appendFormat:@"\n\nRequest Queue Count:\n\t%@", @(self.baseRequestsKeyedByIdentifier.count)];
        NSLog(@"%@", log);
    #endif
}

- (NSArray <BaseRequest *> *)allRequests
{
    NSArray <BaseRequest *> *requests = nil;
    [self.lock lock];
    requests = [self.baseRequestsKeyedByIdentifier allValues];
    [self.lock unlock];
    return requests;
}
@end

#pragma mark - BaseRequest
typedef NS_OPTIONS(NSInteger, RequestStartOption){
    requestStartSynchronously       = 1 << 0,   //业务层处理
    requestStartAsynchronously      = 1 << 1,   //网络层处理
};

@interface BaseRequest ()
{
    NSInteger p_retryRemaining;
}
@property (nonatomic, copy) void(^cancelBlock)(void);
@property (nonatomic, retain) NetworkRequest *network;
//@property (nonatomic, copy) SuccessBlock baseSuccessBlock;
//@property (nonatomic, copy) FailureBlock baseFailureBlock;
//@property (nonatomic, copy) CompleteBlock baseCompleteBlock;
@property (nonatomic, copy) Callback callback;
@property (nonatomic, assign) RequestStartOption requestStartOption;
@property (nonatomic, copy) NSString *requestIdentifier;
@end

@implementation BaseRequest
+ (BaseRequestManager *)manager
{
    static dispatch_once_t onceToken;
    static BaseRequestManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [[BaseRequestManager alloc] init];
    });
    return manager;
}


- (id)init
{
    self = [super init];
    if (self){
        self.network = [[NetworkRequest alloc] init];
        self.maxRetry = 2;
        self.requestIdentifier = [[NSUUID UUID] UUIDString];
    }
    
    return self;
}

- (void)dealloc
{
#ifdef DEBUG
    NSMutableString *log = [NSMutableString string];
//    [log appendFormat:@"\n🚮🚮🚮🚮🚮🚮🚮🚮🚮🚮\t"];
    [log appendFormat:@"\n%@ dealloc 🚮🚮\n\n\t", NSStringFromClass([self class])];
    NSLog(@"\n%@\n\t", log);
#endif
    self.network = nil;
}

- (NSDictionary *)propertyKeyValues
{
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    Class cls = [self class];
    while (cls != [BaseRequest class] &&
           cls != [BaseUploadRequest class]) {
        u_int count;
        objc_property_t* properties = class_copyPropertyList(cls, &count);
        for (int i = 0; i < count; ++i) {
            objc_property_t prop = properties[i];
            const char *propertyName = property_getName(prop);
            NSString *key = [NSString stringWithUTF8String:propertyName];
            id value = [self valueForKey:key];
            result[key] = value;
        }
        free(properties);
        cls = class_getSuperclass(cls);
    }
    return result;
}

- (NSString *)absoluteResolvedPath
{
    NSString *prefix = [self useHttps]?NetProtocolHttps:NetProtocolHttp;
    NSString *path = [self apiPath];
    if (![path hasPrefix:NetProtocolHttp] &&
        ![path hasPrefix:NetProtocolHttps]) {
        path = [prefix stringByAppendingString:path];
    }
#if NET_HTTPDNS_ENABLE
    NSURL *url = [NSURL URLWithString:path];
    NSString *host = url.host;
    NSString *ip = [[HttpDNS sharedInstance] ipWithHost:host];
    if (ip.length) {
        path = [path stringByReplacingOccurrencesOfString:host withString:ip];
    }
#endif
    return path;
}

- (NSURLRequest *)URLRequest
{
    NSError *error = nil;
    return [NetworkRequest urlRequest:self error:&error];
}
#pragma mark - NetworkProtocol
/** @fn startSynchronously
 *  @brief 同步方式请求
 */
- (void)startSynchronously:(Callback)callback
{
    [[self.class manager] setRequest:self
                       forIdentifier:self.requestIdentifier];
    self.requestStartOption = requestStartSynchronously;
    self.callback = callback;
    [self.network cancleRequest];
    [self.network startSynchronously:self
                        networkBlock:[self networkBlock]];
}

/** @fn startAsynchronously:
 *  @brief 异步请求方式。
 */
- (void)startAsynchronously:(Callback)callback
{
    [[self.class manager] setRequest:self
                       forIdentifier:self.requestIdentifier];
    self.requestStartOption = requestStartAsynchronously;
    self.callback = callback;
    [self.network cancleRequest];
    [self.network startAsynchronously:self
                         networkBlock:[self networkBlock]];
}

- (BOOL)retry2start
{
    if (self.retryRemaining >= self.maxRetry) {
        return NO;
    }
    self->p_retryRemaining++;
    
    if (self.callback && (self.requestStartOption & requestStartSynchronously)) [self startSynchronously:self.callback];
    if (self.callback && (self.requestStartOption & requestStartAsynchronously)) [self startAsynchronously:self.callback];
    
    return YES;
}

/**	@fn cancleRequest:
 *	@brief 取消请求。
 */
- (void)cancleRequest
{
    [_network cancleRequest];
}

/**	@fn apiPath:
 *	@brief 子类必须需重写该方法。
 *	@return apiPath
 */
- (NSString *)apiPath
{
    return @"";
}

/**	@fn httpMethod:
 *	@brief 请求方式。
 *	@return 请求方式
 */
- (NSString *)httpMethod
{
    return NetPOSTHttpMethod;
}

/**	@fn useHttps:
 *	@brief 是否采用https。
 *	@return YES->https,NO->http
 */
- (BOOL)useHttps
{
#ifdef DEBUG
    return NO;
#else
    return YES;
#endif
}

- (BOOL)requestParametersInURI
{
    return YES;
}
#pragma mark - private method
- (NSInteger)retryRemaining
{
    return p_retryRemaining;
}

- (NetworkBlock)networkBlock
{
    __weak __typeof(self)weakSelf = self;
    return ^(BaseRequest* request, NSURLSessionDataTask *task, id responseObject, NSError* error){
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        NetResponse *tfresponse = nil;
        NetResponseHandleOption option =
        [strongSelf responseHandling:weakSelf task:task responseObject:responseObject error:error tfresponse:&tfresponse];
        
        if (strongSelf.callback && (option & NetResponseHandleUser)) strongSelf.callback(request, tfresponse);
        if (option & NetResponseHandleUser) [[self.class manager] removeRequestForIdentifier:request.requestIdentifier];
    };
}

- (NetResponseHandleOption)responseHandling:(BaseRequest *)request
                                       task:(NSURLSessionDataTask *)task
                             responseObject:(id)responseObject
                                      error:(NSError *)error
                                 tfresponse:(NetResponse *__autoreleasing *)response
{
    Class dataClass = request.tf_dataClass;
    NetResponse *tfresponse = nil;
    if (error) {
        tfresponse = [[NetResponse alloc] initWithError:error];
    }
    
    if (responseObject) {
        tfresponse = [[NetResponse alloc] initWithObject:responseObject
                                                 dataClass:dataClass];
    }
    
    if ([tfresponse respondsToSelector:@selector(response)]) {
        [tfresponse setValue:task.response forKey:NSStringFromSelector(@selector(response))];
    }
    
    if (response != nil) *response = tfresponse;
    
    if (tfresponse.error) {
        #ifdef DEBUG
            NSMutableString *log = [NSMutableString string];
//            [log appendFormat:@"\n❌❌❌❌❌❌❌❌❌❌\t"];
            [log appendFormat:@"\n%@ response error ❌❌\t", NSStringFromClass([request class])];
            [log appendFormat:@"\n❌❌ error code:\t%@", tfresponse.code];
            [log appendFormat:@"\n❌❌ error msg:\t%@", tfresponse.msg];
            NSLog(@"%@\n\t", log);
        #endif
        
        [[[self.class manager] allRequests] enumerateObjectsUsingBlock:^(BaseRequest * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj cancleRequest];
        }];
        //错误码处理
        NetworkProxy *proxy = [NetworkProxy proxy];
        if ([proxy respondsToSelector:@selector(responseHandling:request:feadback:)]) {
            NetResponseHandleOption option =
            [proxy responseHandling:tfresponse request:request feadback:^(BaseRequest *request, NetResponseHandleFeadbackOption feadbackOption) {
                if (feadbackOption & NetResponseHandleFeadbackResend) {
                    NSArray <BaseRequest *> *requests = [[self.class manager] allRequests].copy;
                    [requests enumerateObjectsUsingBlock:^(BaseRequest * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if (![obj retry2start]) [[self.class manager] requestForIdentifier:obj.requestIdentifier];
                    }];
                }
                else if (feadbackOption & NetResponseHandleFeadbackRemove) {
                    [[self.class manager] removeAllRequest];
                }
            }];
            
            return option;
        }
    }
    return NetResponseHandleUser;
}
@end
