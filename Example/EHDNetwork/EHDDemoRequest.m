//
//  EHDDemoRequest.m
//  EHDNetwork_Example
//
//  Created by luohs on 2017/11/28.
//  Copyright © 2017年 luohs. All rights reserved.
//

#import "EHDDemoRequest.h"

@implementation EHDDemoRequest
- (NSString *)apiPath
{
    return [NSString stringWithFormat:@"%@/%@", EHD_SERVER1, @"ehuodiApi/bddatacs/bdCheck"];
}

- (BOOL)useHttps
{
    return YES;
}

- (NSString *)httpMethod
{
    return NetGETHttpMethod;
}
@end
