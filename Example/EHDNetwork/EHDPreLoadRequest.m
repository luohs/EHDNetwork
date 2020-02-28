//
//  EHDPreLoadRequest.m
//  EHDNetwork_Example
//
//  Created by luohs on 2017/11/28.
//  Copyright © 2017年 luohs. All rights reserved.
//

#import "EHDPreLoadRequest.h"

@implementation EHDPreLoadRequest
- (NSString *)apiPath
{
    return [NSString stringWithFormat:@"%@/%@",EHD_SERVER2, @"versioncontrollcs/selectPreLoading"];
}

- (BOOL)useHttps{
    return YES;
}

- (NSSet *)customAcceptableContentTypes
{
    return [NSSet setWithObject:@"text/plain"];
}
@end
