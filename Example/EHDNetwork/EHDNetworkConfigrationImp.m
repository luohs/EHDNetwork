//
//  EHDNetworkConfigrationImp.m
//  EHDNetwork_Example
//
//  Created by luohs on 2017/11/30.
//  Copyright © 2017年 luohs. All rights reserved.
//

#import "EHDNetworkConfigrationImp.h"
@implementation EHDNetworkConfigrationImp
- (NSString *)serverHost1
{
    return @"ehuodiapi.tf56.com";
}

- (NSString *)serverHost2
{
    return @"ehuodiapitest.tf56.com";
}

- (NSDictionary *)userOAuthFields
{
    return @{@"key1":@"value1", @"key2":@"value2"};
}

//- (BOOL)userOAuthFieldsInURI
//{
//    return YES;
//}
@end
