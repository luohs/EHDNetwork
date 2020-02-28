//
//  AFHTTPSessionManager+EHDNetwork.h
//  EHDNetwork
//
//  Created by luohs on 2018/3/7.
//

#import <AFNetworking/AFHTTPSessionManager.h>
@interface AFHTTPSessionManager (EHDNetwork)
- (id)synchronouslyPerformMethod:(NSString *)method
                       URLString:(NSString *)URLString
                      parameters:(NSDictionary *)parameters
                            task:(NSURLSessionDataTask *__autoreleasing *)task
                           error:(NSError *__autoreleasing *)error;

- (id)asynchronouslyPerformMethod:(NSString *)method
                        URLString:(NSString *)URLString
                       parameters:(NSDictionary *)parameters
                             task:(NSURLSessionDataTask *__autoreleasing *)taskPtr
                          success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                          failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
@end
