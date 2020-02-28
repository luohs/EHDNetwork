//
//  RequestProtocol.h
//  network
//
//  Created by luohs on 15/7/30.
//  Copyright (c) 2015年 罗华胜. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, OauthFieldsOption) {
    OauthFieldsHTTPHead = 0, //oauth数据放在header里
    OauthFieldsHTTPURI = 1, //oauth数据不论是POST还是GET都拼接在query里
    OauthFieldsHTTPAuto = 2,//oauth数据POST拼接在body里，GET拼接在query里
    OauthFieldsHTTPNone = 3 //oauth数据不拼接
};

typedef NS_OPTIONS(NSInteger, NetResponseHandleOption){
    NetResponseHandleUser           = 1 << 0,   //业务层处理
    NetResponseHandleFramework      = 1 << 1,   //网络层处理
};

typedef NS_OPTIONS(NSInteger, NetResponseHandleFeadbackOption){
    NetResponseHandleFeadbackResend           = 1 << 0,   //队列重新发送
    NetResponseHandleFeadbackRemove           = 1 << 1,   //清空队列
    NetResponseHandleFeadbackReserved         = 1 << 2, //预留字段
};

extern NSString * const NetPOSTHttpMethod;
extern NSString * const NetPUTHttpMethod;
extern NSString * const NetGETHttpMethod;
extern NSString * const NetDELETEHttpMethod;

extern NSString * const NetProtocolHttp;
extern NSString * const NetProtocolHttps;
extern BOOL networkRechable(void);

@class BaseRequest;
@class NetResponse;
typedef void (^SuccessBlock)(BaseRequest* request, id responseObject) DEPRECATED_MSG_ATTRIBUTE("1.0.8 Use Callback instead");
typedef void (^FailureBlock)(BaseRequest* request, NSError* error) DEPRECATED_MSG_ATTRIBUTE("1.0.8 Use Callback instead");
typedef void (^CompleteBlock)(BaseRequest* request, NSURLResponse *response, id responseObject, NSError *error) DEPRECATED_MSG_ATTRIBUTE("1.0.8 Use Callback instead");
typedef void (^Callback)(BaseRequest* request, NetResponse* response);

typedef void (^ResponseHandlingFeadback)(BaseRequest* request, NetResponseHandleFeadbackOption feadbackOption);
@protocol RequestProtocol <NSObject>

@required
/**	@fn apiPath:
 *	@brief 子类必须需重写该方法。
 *	@return apiPath
 */
- (NSString *)apiPath;

@optional
/**	@fn handleErrorMsg:
 *	@brief 是否自己处理error msg，（处理服务端返回的4000开头的错误信息）。
 *	@return YES 自己处理 底层不需要统一处理, NO 由底层统一处理
 */
- (BOOL)handleErrorMsg;

/**    @fn userOAuthFieldsInURI:
 *    @brief 对于 - (NSDictionary *)userOAuthFields 鉴权数据默认设置到HTTP HEAD里，可通过实现该协议将公共参数设置到HTTP URI中
 *    @return YES OR NO
 */
- (BOOL)userOAuthFieldsInURI DEPRECATED_MSG_ATTRIBUTE("1.0.6 Use oauthOption instead");

/**   @fn oauthOption
 *    @brief 针对 - (NSDictionary *)userOAuthFields 鉴权数据进行拼接操作
 *    @return 0: 放在HEAD里，1: POST、GET 都放在URI里，2: POST放在body里，GET放在URI里，3: 不拼接到任何位置
 */
- (OauthFieldsOption)oauthOption;

/**   @fn requestParametersInURI:
 *    @brief 表单参数是否拼接到URL中
 *    @return YES OR NO
 */
- (BOOL)requestParametersInURI;

/**	@fn useHttps:
 *	@brief 是否采用https。
 *	@return YES->https,NO->http
 */
- (BOOL)useHttps;
/**	@fn httpMethod:
 *	@brief 请求方式。
 *	@return 请求方式
 */
- (NSString *)httpMethod;

/**	@fn paramKeyPathsByPropertyKey:
 *	@brief request成员变量键值修改。
 *	@return 修改值与原值一一对应的字典
 */
- (NSDictionary *)paramKeyPathsByPropertyKey;

/**	@fn customHTTPHeaderFields:
 *	@brief request Custom HTTPHeaderFields。
 *	@return Custom HTTPHeaderFields
 */
- (NSDictionary *)customHTTPHeaderFields;

/**	@fn customHTTPBodyObject:
 *	@brief request Custom HTTPBodyObject。
 *	@return Custom HTTPBodyObject
 */
- (id)customHTTPBodyObject;

/**   @fn customAcceptableContentTypes:
 *    @brief response Custom ContentTypes。
 *    @return Custom ContentTypes
 *    @such as [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", nil]
 */
- (NSSet *)customAcceptableContentTypes;

/**	@fn startWithSuccessBlock:failureBlock:
 *	@brief 开始请求，如果返回自定义数据模型，子类需重写该方法。
 *	@param success block
 *  @param failure block
 */
- (void)startWithSuccessBlock:(SuccessBlock)success
                 failureBlock:(FailureBlock)failure DEPRECATED_MSG_ATTRIBUTE("1.0.8 Use startAsynchronously: instead");

/**  @fn startWithSuccessBlock:failureBlock:
 *   @brief 开始请求，如果返回自定义数据模型，子类需重写该方法。
 *   @param completion block
 */
- (void)startWithCompleteBlock:(CompleteBlock)completion DEPRECATED_MSG_ATTRIBUTE("1.0.8 Use startAsynchronously: instead");

/** @fn startAsynchronously:
 *  @brief 异步请求方式。
 */
- (void)startAsynchronously:(Callback)callback;

/** @fn startSynchronously
 *  @brief 同步方式请求
 */
- (void)startSynchronously:(Callback)callback;

/**	@fn cancleRequest:
 *	@brief 取消请求。
 */
- (void)cancleRequest;
@end
