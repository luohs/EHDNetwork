//
//  EHDRecommendServiceStationRequest.m
//  EHDNetwork_Example
//
//  Created by admin on 2018/7/2.
//  Copyright © 2018年 luohs. All rights reserved.
//

#import "EHDRecommendServiceStationRequest.h"

@implementation EHDRecommendServiceStationRequest

- (instancetype)init
{
    self = [super init];
    
    self.city = @"杭州";
    self.latitude = @(30.23964382128834);
    self.latitude = @(120.2410347573055);
    
    return self;
}

- (NSString *)apiPath
{
    return @"http://10.7.30.84/huilianApi/app/serviceStation/recommendServiceStation";
}

@end
