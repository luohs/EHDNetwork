//
//  EHDPreLoadEntity.m
//  EHDNetwork_Example
//
//  Created by admin on 2018/5/16.
//  Copyright © 2018年 luohs. All rights reserved.
//

#import "EHDPreLoadEntity.h"
#import <MJExtension/MJExtension.h>

@implementation EHDPreLoadCityEntity

@end

@implementation EHDPreLoadUrlEntity

@end

@implementation EHDPreLoadEntity

+ (NSDictionary *)mj_objectClassInArray
{
    return @{@"partloadlist" : NSStringFromClass([EHDPreLoadCityEntity class])};
}

@end
