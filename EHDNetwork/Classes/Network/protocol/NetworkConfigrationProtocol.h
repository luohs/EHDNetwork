//
//  ConfigHandlerProtocol.h
//  network
//
//  Created by luohs on 15/8/3.
//  Copyright (c) 2015年 罗华胜. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RequestProtocol.h"
@class NetResponse;
@class BaseRequest;
@protocol NetworkConfigrationProtocol <RequestProtocol>
@optional
/**
 *  举例：return @"result"
 */
- (NSString *)responseObjectResultKey;
/**
 *  举例：return @{@"success":@1, @"error":@0}
 */
- (NSDictionary *)responseObjectResultValueMap;
/**
 *  举例：return @"code"
 */
- (NSString *)responseObjectHandlingCodeKey;
/**
 *  code回调 -- TFSupport 0.8.4 以及以后版本
 */
- (void)responseObjectHandlingCode:(NSString *)code;
/**
 *  code回调 -- TFSupport 1.0.6 以及以后版本
 */
- (NetResponseHandleOption)responseObjectHandlingResponse:(NetResponse *)response Request:(BaseRequest *)request DEPRECATED_MSG_ATTRIBUTE("1.0.8 Use responseHandling:request:feadback instead");
/**
 *  code回调 -- TFSupport 1.0.8 以及以后版本
 */
- (NetResponseHandleOption)responseHandling:(NetResponse *)response request:(BaseRequest *)request feadback: (ResponseHandlingFeadback)feadback;
/**
 *  用于网络底层统一处理用户鉴权数据,默认放HTTP Header里
 */
- (NSDictionary *)userOAuthFields;
/**
 *  服务器地址
 *
 *  @return 服务器地址
 */
- (NSString *)serverHost1;
- (NSString *)serverHost2;
@end
