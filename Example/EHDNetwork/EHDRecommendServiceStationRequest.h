//
//  EHDRecommendServiceStationRequest.h
//  EHDNetwork_Example
//
//  Created by admin on 2018/7/2.
//  Copyright © 2018年 luohs. All rights reserved.
//

#import <EHDNetwork/EHDNetwork.h>

@interface EHDRecommendServiceStationRequest : BaseRequest

@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSNumber *latitude;
@property (nonatomic, copy) NSString *longitude;

@end
