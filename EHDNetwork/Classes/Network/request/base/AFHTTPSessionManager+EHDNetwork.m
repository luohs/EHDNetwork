//
//  AFHTTPSessionManager+EHDNetwork.m
//  EHDNetwork
//
//  Created by luohs on 2018/3/7.
//

#import "AFHTTPSessionManager+EHDNetwork.h"
@interface AFHTTPSessionManager ()
- (NSURLSessionDataTask *)dataTaskWithHTTPMethod:(NSString *)method
                                       URLString:(NSString *)URLString
                                      parameters:(id)parameters
                                  uploadProgress:(nullable void (^)(NSProgress *uploadProgress)) uploadProgress
                                downloadProgress:(nullable void (^)(NSProgress *downloadProgress)) downloadProgress
                                         success:(void (^)(NSURLSessionDataTask *, id))success
                                         failure:(void (^)(NSURLSessionDataTask *, NSError *))failure;
@end

@implementation AFHTTPSessionManager (EHDNetwork)
- (id)synchronouslyPerformMethod:(NSString *)method
                       URLString:(NSString *)URLString
                      parameters:(NSDictionary *)parameters
                            task:(NSURLSessionDataTask *__autoreleasing *)taskPtr
                           error:(NSError *__autoreleasing *)outError
{
    if ([NSThread isMainThread] &&
        (self.completionQueue == nil || self.completionQueue == dispatch_get_main_queue())) {
        //经验证，必须为子线程
        self.completionQueue = dispatch_queue_create("AFNetworking+EHDNetwork", NULL);
    }
    
    __block id responseObject = nil;
    __block NSError *error = nil;

    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    NSURLSessionDataTask *task =
    [self dataTaskWithHTTPMethod:method
                       URLString:URLString
                      parameters:parameters
                  uploadProgress:nil
                downloadProgress:nil
                         success:
     ^(NSURLSessionDataTask *unusedTask, id resp) {
         responseObject = resp;
         dispatch_semaphore_signal(semaphore);
     }
                         failure:
     ^(NSURLSessionDataTask *unusedTask, NSError *err) {
         error = err;
         dispatch_semaphore_signal(semaphore);
     }];
    
    [task resume];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    if (taskPtr != nil) *taskPtr = task;
    if (outError != nil) *outError = error;
    
    return responseObject;
}

- (id)asynchronouslyPerformMethod:(NSString *)method
                        URLString:(NSString *)URLString
                       parameters:(NSDictionary *)parameters
                             task:(NSURLSessionDataTask *__autoreleasing *)taskPtr
                          success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                          failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    NSURLSessionDataTask *task =
    [self dataTaskWithHTTPMethod:method
                       URLString:URLString
                      parameters:parameters
                  uploadProgress:nil
                downloadProgress:nil
                         success:success
                         failure:failure];
    
    [task resume];
    
    if (taskPtr != nil) *taskPtr = task;
    
    return nil;
}
@end
