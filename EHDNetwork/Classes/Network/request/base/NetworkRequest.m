//
//  NetworkRequest.m
//  network
//
//  Created by luohs on 15/7/2.
//  Copyright (c) 2015年 罗华胜. All rights reserved.
//

#import "NetworkRequest.h"
#import "BaseRequest.h"
#import "BaseUploadRequest.h"
#import "NetworkProxy.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "AFHTTPSessionManager.h"
#import "AFHTTPSessionManager+EHDNetwork.h"
#if NET_HTTPDNS_ENABLE
#import <EHDHttpDNS/HttpDNS.h>
#endif
#if NET_CRYPT_ENABLE
#import <EHDCryptCipherService/EHDCryptCipherService.h>
#endif

#define TWOWAY_AUTH 0

NSString * const NetworkHostKey = @"host";
NSString * const NetworkHostSeperator = @":";

static NSString * const ClientP12Key = @"com.cn.hsyuntai.client.p12";

#pragma mark - networkRechable
BOOL networkRechable(void)
{
    struct sockaddr_storage zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.ss_len = sizeof(zeroAddress);
    zeroAddress.ss_family = AF_INET;
    
    // Recover reachability flags
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    //获得连接的标志
    BOOL flag = SCNetworkReachabilityGetFlags(reachability, &flags);
    CFRelease(reachability);
    
    //如果不能获取连接标志，则不能连接网络，直接返回
    if (!flag) {
        return NO;
    }
    
    BOOL reachable = flags & kSCNetworkFlagsReachable;
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
    return (reachable&&!needsConnection) ? YES : NO;
}

#pragma mark - AFHTTPRequestOperationManager request block
typedef void (^afMultipartFormDataBlock)(id <AFMultipartFormData> formData);

#pragma mark - AFHTTPSessionManager request block
typedef void (^afSessionSuccessBlock)(NSURLSessionDataTask *task, id responseObject);
typedef void (^afSessionFailureBlock)(NSURLSessionDataTask *task, NSError *error);
typedef NSURLSessionAuthChallengeDisposition (^afSessionChallengeBlock)(NSURLSession *session,
                                                                        NSURLAuthenticationChallenge *challenge,
                                                                        NSURLCredential * __autoreleasing *credential);

#pragma mark - NetworkRequest
@interface NetworkRequest ()
//@property (nonatomic, retain) NSURLSessionDataTask *sessionDataTask;
@end

@implementation NetworkRequest
#pragma mark - init
+ (id)manager
{
    return [[self class] sessionManager];
}

- (void)dealloc
{
#ifdef DEBUG
    NSMutableString *log = [NSMutableString string];
//    [log appendFormat:@"\n🚮🚮🚮🚮🚮🚮🚮🚮🚮🚮\t"];
    [log appendFormat:@"\n%@ dealloc 🚮🚮\n\n\t", NSStringFromClass([self class])];
    NSLog(@"\n%@\n\t", log);
#endif
    self.sessionDataTask = nil;
}

#pragma mark - public method
- (NSURLSessionDataTask *)startAsynchronously:(BaseRequest *)request
                                 networkBlock:(NetworkBlock)networkBlock
{

    NSURLSessionDataTask *task = nil;
    if (!networkRechable()){
        networkBlock(request, nil, nil, [NSError errorWithDomain:NSURLErrorDomain
                                                       code:NSURLErrorNotConnectedToInternet
                                                   userInfo:@{@"msg":@"网络错误，请检查网络"}]);
        return task;
    }
    
    //设置序列化参数
    [[self class] setRequestSerializerWithRequest:request];
    
    //设置双向认证
    [self setSecurityPolicyWithRequest:request
                               manager:[self.class manager]];
    //设置用户鉴权请求头参数
    [[self class] setRequestSerializerHTTPHeaderWithRequest:request];
    [[self class] setResponseSerializerAcceptableContentTypesWithRequest:request];
    
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        });
    } else {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    }
    
    afSessionSuccessBlock afsuccess = [[[self class] sessionSuccessBlock:networkBlock request:request] copy];
    afSessionFailureBlock affailure = [[[self class] sessionFailureBlock:networkBlock request:request] copy];
    AFHTTPSessionManager *manager = [[self class] manager];

    id parameters = nil;
    NSString *absoluteString = nil;
    [self.class absoluteString:&absoluteString parameters:&parameters request:request];
    
    if ([request isKindOfClass:[BaseUploadRequest class]] ||
        [request isMemberOfClass:[BaseUploadRequest class]]){
        task = [manager POST:absoluteString
                  parameters:parameters
   constructingBodyWithBlock:[self.class multipartFormDataBlock:request]
                    progress:nil
                     success:afsuccess
                     failure:affailure];
    }
    else {
        [manager asynchronouslyPerformMethod:[request httpMethod]
                                   URLString:absoluteString
                                  parameters:parameters
                                        task:&task
                                     success:afsuccess
                                     failure:affailure];
    }

#ifdef DEBUG
    NSMutableString *log = [NSMutableString string];
    [log appendFormat:@"\n\nHTTP Class:\n\t%@", NSStringFromClass([request class])];
    [log appendFormat:@"\n\nHTTP Start Times:\n\t%@", @(request.retryRemaining+1)];
    [log appendFormat:@"\n\nHTTP URL:\n\t%@", task.originalRequest.URL];
    [log appendFormat:@"\n\nHTTP Method:\n\t%@", task.originalRequest.HTTPMethod];
    [log appendFormat:@"\n\nHTTP Header:\n\t%@", task.originalRequest.allHTTPHeaderFields];
    [log appendFormat:@"\n\nHTTP Body:\n\t%@\n\t", [[NSString alloc] initWithData:task.originalRequest.HTTPBody encoding:NSUTF8StringEncoding]];
    [log appendFormat:@"\n\nHTTP acceptContentTypes:\n\t%@\n\t", manager.responseSerializer.acceptableContentTypes];
    NSLog(@"%@", log);
#endif
    
    return task;
}

/** @fn startWithSynchronizing
 *  @brief 同步方式请求
 */
- (NSURLSessionDataTask *)startSynchronously:(BaseRequest *)request
                                networkBlock:(NetworkBlock)networkBlock
{
    id responseObject = nil;
    NSURLSessionDataTask *task = nil;
    NSError *error = nil;
    
    if (!networkRechable()){
        networkBlock(request, nil, nil, [NSError errorWithDomain:NSURLErrorDomain
                                                       code:NSURLErrorNotConnectedToInternet
                                                   userInfo:@{@"msg":@"网络错误，请检查网络"}]);
        return task;
    }
    
    //设置序列化参数
    [[self class] setRequestSerializerWithRequest:request];
    
    //设置双向认证
    [self setSecurityPolicyWithRequest:request
                               manager:[[self class] manager]];
    //设置用户鉴权请求头参数
    [[self class] setRequestSerializerHTTPHeaderWithRequest:request];
    [[self class] setResponseSerializerAcceptableContentTypesWithRequest:request];

    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        });
    } else {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    }
    
    AFHTTPSessionManager *manager = [[self class] manager];
    id parameters = nil;
    NSString *absoluteString = nil;
    [self.class absoluteString:&absoluteString parameters:&parameters request:request];
    responseObject = [manager synchronouslyPerformMethod:[request httpMethod]
                                               URLString:absoluteString
                                              parameters:parameters
                                                    task:&task
                                                   error:&error];
#ifdef DEBUG
    NSMutableString *log = [NSMutableString string];
    [log appendFormat:@"\n\nHTTP Class:\n\t%@", NSStringFromClass([request class])];
    [log appendFormat:@"\n\nHTTP Start Times:\n\t%@", @(request.retryRemaining+1)];
    [log appendFormat:@"\n\nHTTP URL:\n\t%@", task.originalRequest.URL];
    [log appendFormat:@"\n\nHTTP Method:\n\t%@", task.originalRequest.HTTPMethod];
    [log appendFormat:@"\n\nHTTP Header:\n\t%@", task.originalRequest.allHTTPHeaderFields];
    [log appendFormat:@"\n\nHTTP Body:\n\t%@\n\t", [[NSString alloc] initWithData:task.originalRequest.HTTPBody encoding:NSUTF8StringEncoding]];
    [log appendFormat:@"\n\nHTTP acceptContentTypes:\n\t%@\n\t", manager.responseSerializer.acceptableContentTypes];
    NSLog(@"\n%@", log);
    
    NSMutableString *log2 = [NSMutableString string];
    [log2 appendFormat:@"\n%@ response: \n\t%@", NSStringFromClass([request class]), task.response];
    [log2 appendFormat:@"\n\n%@ responseObject: \n\t%@", NSStringFromClass(request.class), responseObject];
    NSLog(@"\n%@", log2);
#endif
    
    if (networkBlock) networkBlock(request, task, responseObject, error);
    
    return nil;
}

/**	@fn cancleRequest:
 *	@brief 取消请求
 */
- (void)cancleRequest
{

    if (self.sessionDataTask){
        [self.sessionDataTask suspend];
        [self.sessionDataTask cancel];
    }
    
    #ifdef DEBUG
        NSMutableString *log = [NSMutableString string];
        [log appendFormat:@"\n%@ task cancel\n\n\t", NSStringFromClass([self class])];
        [log appendFormat:@"\ntask state:%@\n\n\t", @(self.sessionDataTask.state)];
        NSLog(@"\n%@\n\t", log);
    #endif
}

#pragma mark - private method
+ (afMultipartFormDataBlock)multipartFormDataBlock:(BaseRequest *)request
{
    return ^(id <AFMultipartFormData> formData) {
        if ([request isKindOfClass:[BaseUploadRequest class]] ||
            [request isMemberOfClass:[BaseUploadRequest class]]) {
            BaseUploadRequest *uploadRequest = (BaseUploadRequest *)request;
            for (NSURL *fileURL in uploadRequest.fileURLs){
                NSError *error = nil;
                [formData appendPartWithFileURL:fileURL
                                           name:uploadRequest.name
                                          error:&error];
            }
            
            for (NSData *data in uploadRequest.fileDatas){
                [formData appendPartWithFileData:data
                                            name:uploadRequest.name
                                        fileName:@"file.png"
                                        mimeType:@"application/octet-stream"];
            }
        }
    };
}

+ (OSStatus)extractIdentity:(SecIdentityRef*)identity
                withP12Data:(CFDataRef)inP12Data
{
    if (inP12Data == NULL) return errSecUnimplemented;
    
    const void *keys[] = {kSecImportExportPassphrase};
    const void *values[] = {CFSTR("hsyuntai@zhzx19F")};
    CFDictionaryRef options = CFDictionaryCreate(NULL, keys, values, 1, NULL, NULL);
    CFArrayRef items = CFArrayCreate(NULL, 0, 0, NULL);
    OSStatus securityError = SecPKCS12Import(inP12Data, options, &items);
    if (errSecSuccess == securityError){
        CFDictionaryRef ident = CFArrayGetValueAtIndex(items, 0);
        const void *tempIdentity = NULL;
        tempIdentity = CFDictionaryGetValue(ident, kSecImportItemIdentity);
        *identity = (SecIdentityRef)tempIdentity;
    }
    
    if (options) CFRelease(options);
//    if (items) CFRelease(items);
    
    return securityError;
}

+ (NSURLCredential *)credential
{
    static NSURLCredential *credential = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSData *PKCS12DataOrigin = [[self class] dataWithNamed:@"client.p12" inBundle:[NSBundle bundleForClass:[self class]]];
        NSData *PKCS12Data = [[self class] decryptData:PKCS12DataOrigin];
        CFDataRef inPKCS12Data = (__bridge CFDataRef)PKCS12Data;
        SecIdentityRef identity = NULL;
        OSStatus securityError = [[self class] extractIdentity:&identity
                                                   withP12Data:inPKCS12Data];
        if (securityError != errSecSuccess) {
            inPKCS12Data = (__bridge CFDataRef)PKCS12DataOrigin;
            securityError = [[self class] extractIdentity:&identity
                                              withP12Data:inPKCS12Data];
        }
        
        if (securityError == errSecSuccess) {
            SecCertificateRef certificate = NULL;
            SecIdentityCopyCertificate (identity, &certificate);
            const void *certs[] = {certificate};
            CFArrayRef certArray = CFArrayCreate(kCFAllocatorDefault, certs, 1, NULL);
            credential = [NSURLCredential credentialWithIdentity:identity
                                                    certificates:(__bridge NSArray*)certArray
                                                     persistence:NSURLCredentialPersistencePermanent];
            if (certArray) CFRelease(certArray);
        }
    });
    
    return credential;
}

+ (NSData *)dataWithNamed:(NSString *)name inBundle:(NSBundle *)bundle
{
    NSArray *paths = [bundle pathsForResourcesOfType:@"bundle" inDirectory:@"."];
    for (NSString *path in paths) {
        NSString *file = [NSString stringWithFormat:@"%@/%@", path, name];
        NSData *data = [[NSData alloc] initWithContentsOfFile:file];
        if (data) return data;
    }
    return nil;
}

+ (NSDictionary *)paramsWithRequest:(BaseRequest *)request
{
    NSDictionary *paramKeyPaths = nil;
    if ([request respondsToSelector:@selector(paramKeyPathsByPropertyKey)]) {
        paramKeyPaths = [request paramKeyPathsByPropertyKey];
    }

    NSDictionary *params = [request propertyKeyValues];
    if (paramKeyPaths.count) {
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        for (NSString *key in params.allKeys) {
            NSString *newKey = key;
            if (paramKeyPaths[newKey]) {
                newKey = paramKeyPaths[newKey];
            }
            dictionary[newKey] = params[key];
        }
        params = dictionary;
    }
    
    if ([request respondsToSelector:@selector(customHTTPBodyObject)]){
        params = [request customHTTPBodyObject];
    }
    
    NSLog(@"%@'s property:%@", NSStringFromClass(request.class), params);
    return params;
}

+ (OauthFieldsOption)oauthFieldsOptionWithRequest:(BaseRequest *)request
{
    if ([request respondsToSelector:@selector(oauthOption)]) {
        return [request oauthOption];
    }
    else if ([[NetworkProxy proxy] respondsToSelector:@selector(oauthOption)]){
        return [[NetworkProxy proxy] oauthOption];
    }
    return OauthFieldsHTTPURI;
}


+ (void)absoluteString:(NSString **)absoluteString
            parameters:(NSDictionary **)parameters
               request:(BaseRequest *)request
{
    NSString *URLString = [request absoluteResolvedPath];
    NSDictionary *params = [[self class] paramsWithRequest:request];
    
    OauthFieldsOption option = [self oauthFieldsOptionWithRequest:request];
    if (option == OauthFieldsHTTPURI) {
        NSString *query = AFQueryStringFromParameters([[NetworkProxy proxy] userOAuthFields]);
        if (query && query.length > 0) {
            NSURL *url = [NSURL URLWithString:URLString];
            URLString = [URLString stringByAppendingFormat:url.query ? @"&%@" : @"?%@", query];
        }
    }
    else if (option == OauthFieldsHTTPAuto) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:params];
        [dic addEntriesFromDictionary:[[NetworkProxy proxy] userOAuthFields]];
        params = dic;
    }
    
    if (![[self class].requestSerializer.HTTPMethodsEncodingParametersInURI containsObject:[[request httpMethod] uppercaseString]]) {
        if ([request respondsToSelector:@selector(requestParametersInURI)] &&
            [request requestParametersInURI]) {
            NSString *query = AFQueryStringFromParameters(params);
            if (query && query.length > 0) {
                NSURL *url = [NSURL URLWithString:URLString];
                URLString = [URLString stringByAppendingFormat:url.query ? @"&%@" : @"?%@", query];
            }
            params = nil;
        }
    }
    *absoluteString = URLString;
    *parameters = params;
}

+ (NSURLRequest *)urlRequest:(BaseRequest *)request
                       error:(NSError *__autoreleasing *)error
{
    //拼接接口地址
    id parameters = nil;
    NSString *absoluteString = nil;
    [self.class absoluteString:&absoluteString parameters:&parameters request:request];
    NSMutableURLRequest *urlRequest =
    [self.class.requestSerializer requestWithMethod:[request httpMethod]
                                          URLString:absoluteString
                                         parameters:parameters
                                              error:error];
    NSLog(@"NSURLRequest absoluteString: %@", urlRequest.URL.absoluteString);
    
    if (*error) {
        return nil;
    }
    
    return urlRequest;
}

+ (void)setRequestSerializerWithRequest:(BaseRequest *)request
{
    [[self class] setRequestSerializer:[AFHTTPRequestSerializer serializer]];
    if ([[request httpMethod] isEqualToString:NetPOSTHttpMethod] &&
        [request respondsToSelector:@selector(customHTTPHeaderFields)]){
        NSDictionary *fields = [request customHTTPHeaderFields];
        if ([[fields valueForKey:@"Content-Type"] isEqualToString:@"application/json"]) {
            [[self class] setRequestSerializer:[AFJSONRequestSerializer serializer]];
        }
    }
}

+ (void)setRequestSerializer:(AFHTTPRequestSerializer *)requestSerializer
{
    if ([[[self class] manager] isKindOfClass:[AFHTTPSessionManager class]]){
        ((AFHTTPSessionManager *)[[self class] manager]).requestSerializer = requestSerializer;
    }
}

+ (AFHTTPRequestSerializer *)requestSerializer
{
    if ([[[self class] manager] isKindOfClass:[AFHTTPSessionManager class]]){
        return ((AFHTTPSessionManager *)[[self class] manager]).requestSerializer;
    }
    
    return nil;
}

+ (AFHTTPResponseSerializer *)responseSerializer
{
    return [AFCompoundResponseSerializer compoundSerializerWithResponseSerializers:@[[AFJSONResponseSerializer serializer],
                                                                                     [AFXMLParserResponseSerializer serializer],
                                                                                     [AFImageResponseSerializer serializer]]];
}

+ (AFSecurityPolicy *)securityPolicy
{
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    [securityPolicy setAllowInvalidCertificates:NO];
    [securityPolicy setValidatesDomainName:YES];
    return securityPolicy;
}

- (void)setSecurityPolicyWithRequest:(BaseRequest *)request
                             manager:(id)manager
{
    AFSecurityPolicy *policy = [AFSecurityPolicy defaultPolicy];
    NSURLCredential *credential = nil;
    afSessionChallengeBlock block = NULL;
    
    if ([request useHttps]){
        if (TWOWAY_AUTH) {
            policy = [[self class] securityPolicy];
        }
        credential = [[self class] credential];
        block = [self sessionChallengeBlock:manager];
    }
    
    if ([manager respondsToSelector:@selector(setSecurityPolicy:)]){
        [manager setSecurityPolicy:policy];
    }

    if ([manager respondsToSelector:@selector(setSessionDidReceiveAuthenticationChallengeBlock:)]){
        [manager setSessionDidReceiveAuthenticationChallengeBlock:block];
    }
}

+ (void)setRequestSerializerHTTPHeaderWithRequest:(BaseRequest *)request
{
    AFHTTPRequestSerializer *requestSerializer = [[self class] requestSerializer];
    
    OauthFieldsOption option = [self oauthFieldsOptionWithRequest:request];
    NSMutableDictionary *fields = [NSMutableDictionary dictionary];
    if (option == OauthFieldsHTTPHead) {
        fields = [NSMutableDictionary dictionaryWithDictionary:[[NetworkProxy proxy] userOAuthFields]];
    }

#if NET_HTTPDNS_ENABLE
    NSString *path = [request apiPath];
    if (![path hasPrefix:NetProtocolHttp]) {
        path = [NetProtocolHttp stringByAppendingString:path];
    }
    NSURL *url = [NSURL URLWithString:path];
    NSString *host = url.host;
    NSNumber *port = url.port;
    if (host && port) {
        host = [NSString stringWithFormat:@"%@%@%@", host, NetworkHostSeperator, port];
    }

    fields[NetworkHostKey] = host;
#endif
    
    if ([request respondsToSelector:@selector(customHTTPHeaderFields)]){
        [fields addEntriesFromDictionary:[request customHTTPHeaderFields]];
    }
    
    [fields enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSNumber class]]){
            [requestSerializer setValue:[obj stringValue] forHTTPHeaderField:key];
        }
        else if ([obj isKindOfClass:[NSString class]]){
            [requestSerializer setValue:obj forHTTPHeaderField:key];
        }
    }];
}

+ (void)setResponseSerializerAcceptableContentTypesWithRequest:(BaseRequest *)request
{
    AFCompoundResponseSerializer *responseSerializer = (AFCompoundResponseSerializer *)((AFHTTPSessionManager *)[[self class] manager]).responseSerializer;
    NSMutableSet *contentTypes = [NSMutableSet setWithSet:responseSerializer.acceptableContentTypes];
    if ([request respondsToSelector:@selector(customAcceptableContentTypes)]){
        [contentTypes unionSet:[request customAcceptableContentTypes]];
        responseSerializer.acceptableContentTypes = contentTypes;
    }
}

+ (NSData *)decryptData:(NSData *)data
{
    NSData *ret = nil;
#if NET_CRYPT_ENABLE
    EHDCryptCipherService *cipher = [[EHDCryptCipherService alloc] init];
    ret = [cipher aesDecryptData:[data copy] withKey:ClientP12Key];
#endif
    return ret?:[data copy];
}

#pragma mark - AFHTTPSessionManager class
+ (AFHTTPSessionManager *)sessionManager
{
    static dispatch_once_t onceToken;
    static AFHTTPSessionManager *manager;
    dispatch_once(&onceToken, ^{
//        manager = [AFHTTPSessionManager manager];
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        if (NETWORK_WIRESHARK == 0){
            configuration.connectionProxyDictionary = @{};
        }
        /*
        configuration.connectionProxyDictionary = @{
            @"HTTPEnable":@YES,
            (id)kCFStreamPropertyHTTPProxyHost:@"127.0.0.1",
            (id)kCFStreamPropertyHTTPProxyPort:@80,
            @"HTTPSEnable":@YES,
            (id)kCFStreamPropertyHTTPSProxyHost:@"127.0.0.1",
            (id)kCFStreamPropertyHTTPSProxyPort:@80
        };
         */
        manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];

        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.responseSerializer = [[self class] responseSerializer];
        manager.completionQueue = dispatch_queue_create("AFNetworking+EHDNetwork", NULL);
    });
    return manager;
}

+ (afSessionSuccessBlock)sessionSuccessBlock:(NetworkBlock)block request:(BaseRequest *)request
{
    return ^(NSURLSessionDataTask *task, id responseObject){
        #ifdef DEBUG
            NSMutableString *log = [NSMutableString string];
            [log appendFormat:@"\n%@ response: \n\t%@", NSStringFromClass([request class]), task.response];
            [log appendFormat:@"\n\n%@ responseObject: \n\t%@", NSStringFromClass(request.class), responseObject];
            NSLog(@"\n%@", log);
        #endif
        
        if (block) {
            if (![NSThread isMainThread]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                    block(request, task ,responseObject, nil);
                });
            } else {
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                block(request, task ,responseObject, nil);
            }
        }
    };
}

+ (afSessionFailureBlock)sessionFailureBlock:(NetworkBlock)block request:(BaseRequest *)request
{
    return ^(NSURLSessionDataTask *task, NSError *error){
        #ifdef DEBUG
            NSMutableString *log = [NSMutableString string];
            [log appendFormat:@"\n%@ response: \n\t%@", NSStringFromClass([request class]), task.response];
            [log appendFormat:@"\n\n%@ responseObject: \n\t%@", NSStringFromClass(request.class), error];
            NSLog(@"\n%@", log);
        #endif
        if (block) {
            if (![NSThread isMainThread]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                    block(request, task, nil, error);
                });
            } else {
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                block(request, task, nil, error);
            }
        }
    };
}

- (afSessionChallengeBlock)sessionChallengeBlock:(AFHTTPSessionManager *)manager
{
    __weak AFHTTPSessionManager *weakManager = manager;
    __weak typeof (self) weakSelf = self;
    return ^NSURLSessionAuthChallengeDisposition(NSURLSession*session, NSURLAuthenticationChallenge *challenge, NSURLCredential *__autoreleasing*_credential) {
        NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
        __autoreleasing NSURLCredential *credential = nil;
        NSURLSessionDataTask *task = weakSelf.sessionDataTask;
        NSString *domain = task.originalRequest.allHTTPHeaderFields[NetworkHostKey];
        if (domain.length == 0) {
            domain = task.currentRequest.allHTTPHeaderFields[NetworkHostKey];
        }
        NSArray *components = [domain componentsSeparatedByString:NetworkHostSeperator];
        domain = components.firstObject;
        
        if (domain.length == 0) {
            NSLog(@"ERROR: domain = nil");
            domain = challenge.protectionSpace.host;
        }
        
        if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
            if([weakManager.securityPolicy evaluateServerTrust:challenge.protectionSpace.serverTrust
                                                     forDomain:domain]) {
                credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
                if(credential) {
                    disposition =NSURLSessionAuthChallengeUseCredential;
                }
                else {
                    disposition =NSURLSessionAuthChallengePerformDefaultHandling;
                }
            }
            else {
                disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
            }
        }
        else {
            credential = [[self class] credential];
            if (credential) {
                disposition = NSURLSessionAuthChallengeUseCredential;
            }
        }
        *_credential = credential;
        return disposition;
    };
}
@end
