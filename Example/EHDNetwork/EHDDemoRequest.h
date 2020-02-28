//
//  EHDDemoRequest.h
//  EHDNetwork_Example
//
//  Created by luohs on 2017/11/28.
//  Copyright © 2017年 luohs. All rights reserved.
//

//#import <EHDNetwork/BaseRequest.h>
#import <EHDNetwork/EHDNetwork.h>
@interface EHDDemoRequest : BaseRequest
@property (nonatomic, copy) NSString *appKey;
@property (nonatomic, copy) NSString *mobile;
@property (nonatomic, copy) NSString *uuid;
@end
