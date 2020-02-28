//
//  NetResponse.h
//  EHDNetwork
//
//  Created by luohs on 2020/2/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NetResponse : NSObject
/// HTTP响应码
@property (nonatomic, assign, readonly) NSInteger statusCode;

/// 服务端返回的数据 data字段 解析为自定义对象
@property (nonatomic, strong, readonly) id _Nullable data;
/// 服务端返回的数据 code字段
@property (nonatomic, copy, readonly) NSString * _Nullable code;
/// 服务端返回的数据 count字段
@property (nonatomic, copy, readonly) NSString * _Nullable count;
/// 服务端返回的数据 msg字段
@property (nonatomic, copy, readonly) NSString * _Nullable serverMsg;
/// 本地适配后的msg 接口失败时才有
@property (nonatomic, copy, readonly) NSString * _Nullable msg;
/// 服务端返回的数据 error对象
@property (nonatomic, copy, readonly) NSError * _Nullable error;

/// 服务端返回的原始数据
@property (nonatomic, copy, readonly) id _Nullable raw;
/// 服务端返回的原始数据解析为字典
@property (nonatomic, copy, readonly) NSDictionary * _Nullable rawDictionary;

@property (nullable, readonly, copy) NSHTTPURLResponse *response;         /* may be nil if no response has been received */

- (nullable instancetype)initWithObject:(id _Nullable )object dataClass:(Class _Nullable )dataClass;

- (nullable instancetype)initWithError:(NSError *_Nullable)error;
@end

NS_ASSUME_NONNULL_END
