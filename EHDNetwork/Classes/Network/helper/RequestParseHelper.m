//
//  RequestParseHelper.m
//  Pods
//
//  Created by luohs on 15/10/23.
//
//

#import "RequestParseHelper.h"
#import "NSDate+Calibrate.h"
#import <MJExtension/MJExtension.h>

const long long ResponseKindInvalid = -999999999999;

NSString * const ResponseObjectResultKey  = @"result";
NSString * const ResponseObjectMessageKey = @"msg";
NSString * const ResponseObjectKindKey    = @"kind";
NSString * const ResponseObjectDataKey    = @"data";
NSString * const ResponseObjectNowTimeKey = @"nowTime";

@implementation RequestParseHelper

+ (successBlock)autoParseSuccessBlockWithRequest:(BaseRequest *)request
                                    successBlock:(successBlock)successBlock
                                    failureBlock:(failureBlock)failureBlock
                                      modelClass:(Class)modelClass
{
    request.originalSuccessBlock = successBlock;
    request.originalFailureBlock = failureBlock;
    
    return ^(BaseRequest *request, id responseObject) {
        if (![RequestParseHelper resultWithResponse:responseObject]) {
            NSError *error = [NSError errorWithDomain:@"com.luohs.network.error.helper.autoparse" code:NSURLErrorUnknown userInfo:responseObject];
            if (failureBlock) {
                failureBlock(request, error);
            }
            return;
        }
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            id obj = [RequestParseHelper parsedObjectWithResponseObject:responseObject modelClass:modelClass];
            if (successBlock) {
                successBlock(request, obj);
            }
        }
    };
}

+ (id)dataWithResponse:(id)responseObject
{
    if ([responseObject isKindOfClass:NSDictionary.class]) {
        return responseObject[ResponseObjectDataKey];
    }
    return nil;
}

+ (BOOL)resultWithResponse:(id)responseObject
{
    if ([responseObject isKindOfClass:[NSDictionary class]]) {
        NSString *resultKey = @"result";
        if ([[[NetworkProxy proxy] responseObjectResultKey] length]) {
            resultKey = [[NetworkProxy proxy] responseObjectResultKey];
        }
        
        NSDictionary *resultMap = @{@"success":@1, @"error":@0};
        if ([[[NetworkProxy proxy] responseObjectResultValueMap] count]) {
            resultMap = [[NetworkProxy proxy] responseObjectResultValueMap];
        }
        
        id result = responseObject[resultKey];
        if ([result respondsToSelector:@selector(boolValue)]) {
            return [result boolValue];
        }
    }
    
    return NO;
}

+ (NSString *)nowTimeWithResponseObject:(id)responseObject
{
    if ([responseObject isKindOfClass:NSDictionary.class]) {
        NSString *nowTime = responseObject[ResponseObjectNowTimeKey];
        if ([nowTime isKindOfClass:NSString.class]) {
            return nowTime;
        }
    }
    return nil;
}

+ (id)parsedObjectWithDictionary:(NSDictionary *)dictionary
                      modelClass:(Class)modelClass
                         nowTime:(NSString *)nowTime
                           error:(NSError **)e
{
    if ([dictionary isKindOfClass:NSDictionary.class]) {
        id model = [modelClass mj_objectWithKeyValues:dictionary];
        return model;
    }
    return nil;
}

+ (id)parsedObjectWithResponseObject:(id)responseObject modelClass:(Class)modelClass
{
    id data = [self dataWithResponse:responseObject];
    NSString *nowTime = [self nowTimeWithResponseObject:responseObject];
    
    if (nowTime) {
        static NSOperationQueue *queue;
        if (!queue) {
            queue = [[NSOperationQueue alloc] init];
            queue.maxConcurrentOperationCount = 1;
        }
        [queue addOperationWithBlock:^{
            static NSDateFormatter *dateFormatter = nil;
            if (!dateFormatter) {
                dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            }
            if ([nowTime isKindOfClass:NSString.class] && nowTime.length) {
                NSDate *date = [dateFormatter dateFromString:nowTime];
                if (date) {
                    NSTimeInterval interval = [date timeIntervalSinceDate:[NSDate date]];
                    [NSDate setDeviation:interval];
                }
            }
        }];
    }
    
    NSError *e = nil;
    id ret = nil;
    if ([data isKindOfClass:NSDictionary.class]) {
        ret = [self parsedObjectWithDictionary:data modelClass:modelClass nowTime:nowTime error:&e];
        
    } else if ([data isKindOfClass:NSArray.class]) {
        NSMutableArray *array = [NSMutableArray array];
        for (NSDictionary *dictionary in data) {
            id model = [self parsedObjectWithDictionary:dictionary modelClass:modelClass nowTime:nowTime error:&e];
            if (model) {
                [array addObject:model];
            } else {
                NSLog(@"PARSE ERROR: can not parse dictionary!!!");
            }
        }
        ret = array;
        
    } else if (data) {
        NSLog(@"PARSE ERROR: can not parse data!!!");
    }
    
    // print error
    if (e) {
        NSLog(@"PARSE ERROR: %@", e);
    }
    return ret;
}

@end
