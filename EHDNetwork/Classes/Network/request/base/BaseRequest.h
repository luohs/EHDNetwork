//
//  BaseRequest.h
//  network
//
//  Created by luohs on 15/7/2.
//  Copyright (c) 2015年 罗华胜. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RequestProtocol.h"
#import "NetworkProxy.h"

#define EHD_SERVER1 [NSString stringWithFormat:@"%@",[[NetworkProxy proxy] serverHost1]]
#define EHD_SERVER2 [NSString stringWithFormat:@"%@",[[NetworkProxy proxy] serverHost2]]

@interface BaseRequest : NSObject<RequestProtocol>
@property(nonatomic, assign) NSInteger maxRetry;
@property(nonatomic, assign, readonly) NSInteger retryRemaining;
@property (nonatomic, assign) Class tf_dataClass;
- (NSString *)absoluteResolvedPath;
- (NSDictionary *)propertyKeyValues;
- (NSURLRequest *)URLRequest;
@end
