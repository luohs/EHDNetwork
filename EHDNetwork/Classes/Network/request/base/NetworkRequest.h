//
//  NetworkRequest.h
//  network
//
//  Created by luohs on 15/7/2.
//  Copyright (c) 2015年 罗华胜. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RequestProtocol.h"

typedef void (^NetworkBlock)(BaseRequest* request, NSURLSessionDataTask *task, id responseObject, NSError* error);

@interface NetworkRequest : NSObject
@property (nonatomic, retain) NSURLSessionDataTask *sessionDataTask;
#pragma mark - public method
/**	@fn startWithSuccessBlock:failureBlock:
 *	@brief 开始请求
 *	@param networkBlock block
 */
- (NSURLSessionDataTask *)startAsynchronously:(BaseRequest *)request
                                 networkBlock:(NetworkBlock)networkBlock;

/** @fn startWithSynchronizing
 *  @brief 同步方式请求
 */
- (NSURLSessionDataTask *)startSynchronously:(BaseRequest *)request
                                networkBlock:(NetworkBlock)networkBlock;

/**	@fn cancleRequest:
 *	@brief 取消请求
 */
- (void)cancleRequest;

/**   @fn urlRequest:error:
 *    @brief NSURLRequest
 */
+ (NSURLRequest *)urlRequest:(BaseRequest *)request
                       error:(NSError *__autoreleasing *)error;
@end
