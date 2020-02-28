//
//  NetworkProxy.m
//  network
//
//  Created by luohs on 15/8/3.
//  Copyright (c) 2015年 罗华胜. All rights reserved.
//

#import "NetworkProxy.h"
#import <objc/runtime.h>

@interface NetworkProxy ()
{
    NSMutableDictionary *_handlers;
}
@end

@implementation NetworkProxy
#pragma mark - Public methods
+ (instancetype)proxy
{
    static NetworkProxy *proxy = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        proxy = [NetworkProxy alloc];
        proxy->_handlers = [NSMutableDictionary dictionary];
    });
    return proxy;
}

/**
 *  注册协议以及协议实例
 *
 *  @param protocol 协议
 *  @param handler  协议实例
 */
+ (void)registerProtocol:(Protocol *)protocol
                 handler:(id)handler
{
    if (handler) {
        [[NetworkProxy proxy] registerProtocol:protocol
                                       handler:handler];
    }
    NSLog(@"protocol: %@, class: %@", NSStringFromProtocol(protocol), NSStringFromClass([handler class]));
}
#pragma mark - Private methods
- (void)registerProtocol:(Protocol *)protocol handler:(id)handler
{
    unsigned int numberOfMethods = 0;
    unsigned int numberOfOpmethods = 0;
    //Get all methods in protocol
    struct objc_method_description *methods = protocol_copyMethodDescriptionList(protocol, YES, YES, &numberOfMethods);
    struct objc_method_description *opmethods = protocol_copyMethodDescriptionList(protocol, NO, YES, &numberOfOpmethods);
    //Register protocol methods
    for (unsigned int i = 0; i < numberOfMethods; i++) {
        struct objc_method_description method = methods[i];
        [_handlers setValue:handler forKey:NSStringFromSelector(method.name)];
    }
    
    for (unsigned int i = 0; i < numberOfOpmethods; i++) {
        struct objc_method_description method = opmethods[i];
        [_handlers setValue:handler forKey:NSStringFromSelector(method.name)];
    }

    if (methods) free(methods);
    if (opmethods) free(opmethods);
}

#pragma mark - Methods route
- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
    NSString *methodsName = NSStringFromSelector(sel);
    id handler = [_handlers valueForKey:methodsName];
    
    if (handler != nil && [handler respondsToSelector:sel]) {
        return [handler methodSignatureForSelector:sel];
    }
    else {
        return [NSMethodSignature signatureWithObjCTypes:"@@:"];//[super methodSignatureForSelector:sel];
    }
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    NSString *methodsName = NSStringFromSelector(invocation.selector);
    id handler = [_handlers valueForKey:methodsName];
    
    if (handler != nil && [handler respondsToSelector:invocation.selector]) {
        [invocation invokeWithTarget:handler];
    } else {
        //[super forwardInvocation:invocation];
    }
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    NSString *methodsName = NSStringFromSelector(aSelector);
    id handler = [_handlers valueForKey:methodsName];
    if ([handler respondsToSelector:aSelector]){
        return YES;
    }
    
    return NO;
}

+ (BOOL)proxySetting:(NSDictionary **)proxySetting {
    NSDictionary *proxySettings = (__bridge NSDictionary *)(CFNetworkCopySystemProxySettings());
    NSArray *proxies = (__bridge NSArray *)(CFNetworkCopyProxiesForURL((__bridge CFURLRef _Nonnull)([NSURL URLWithString:@"https://www.baidu.com"]), (__bridge CFDictionaryRef _Nonnull)(proxySettings)));
    NSLog(@"\n%@",proxies);
    
    NSDictionary *settings = proxies[0];
    NSLog(@"%@",[settings objectForKey:(NSString *)kCFProxyHostNameKey]);
    NSLog(@"%@",[settings objectForKey:(NSString *)kCFProxyPortNumberKey]);
    NSLog(@"%@",[settings objectForKey:(NSString *)kCFProxyTypeKey]);
    NSLog(@"%@",[settings objectForKey:(NSString *)kCFProxyUsernameKey]);
    NSLog(@"%@",[settings objectForKey:(NSString *)kCFProxyPasswordKey]);
    
    if ([[settings objectForKey:(NSString *)kCFProxyTypeKey] isEqualToString:@"kCFProxyTypeNone"]) {
        NSLog(@"没设置代理");
        return NO;
    }

    *proxySetting = [NSDictionary dictionaryWithDictionary:settings];
    NSLog(@"设置了代理");
    return YES;
}
@end
