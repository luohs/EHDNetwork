//
//  NetworkProxy.h
//  network
//
//  Created by luohs on 15/8/3.
//  Copyright (c) 2015年 罗华胜. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetworkConfigrationProtocol.h"

//#ifndef __OPTIMIZE__
#ifdef DEBUG
# define NSLog(...) NSLog(__VA_ARGS__)
#else
# define NSLog(...) {}
#endif

#ifdef DEBUG
#define NETWORK_WIRESHARK 1
#else
#define NETWORK_WIRESHARK ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"etransfarehuodidebugplugin://com.transfar.ehuodi.debugplugin"]]?1:0)
#endif

#pragma mark - NetworkProxy Class
@interface NetworkProxy : NSProxy <NetworkConfigrationProtocol>
/**
 *  instance of NetworkProxy class
 *
 *  @return instance
 */
+ (instancetype)proxy;
/**
 *  注册协议以及协议实例
 *
 *  @param protocol 协议
 *  @param handler  协议实例
 */
+ (void)registerProtocol:(Protocol *)protocol
                 handler:(id)handler;

/**
 *获取网络代理设置信息
*/
+ (BOOL)proxySetting:(NSDictionary **)proxySetting;
@end
