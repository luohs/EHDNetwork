//
//  RequestParseHelper.h
//  Pods
//
//  Created by luohs on 15/10/23.
//
//

#import <Foundation/Foundation.h>
#import "BaseRequest.h"

#define autoParseSuccessBlock(success, failure, cls) \
        [RequestParseHelper autoParseSuccessBlockWithRequest:self \
        successBlock:success \
        failureBlock:failure \
        modelClass:cls]

//extern const NSInteger ResponseKindInvalid;

@interface RequestParseHelper : NSObject

+ (successBlock)autoParseSuccessBlockWithRequest:(BaseRequest *)request
                                    successBlock:(successBlock)successBlock
                                    failureBlock:(failureBlock)failureBlock
                                      modelClass:(Class)modelClass;

+ (id)dataWithResponse:(id)responseObject;
@end

