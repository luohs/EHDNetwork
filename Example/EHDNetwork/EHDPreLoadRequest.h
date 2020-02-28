//
//  EHDPreLoadRequest.h
//  EHDNetwork_Example
//
//  Created by luohs on 2017/11/28.
//  Copyright © 2017年 luohs. All rights reserved.
//

//#import <EHDNetwork/BaseRequest.h>
#import <EHDNetwork/EHDNetwork.h>
@interface EHDPreLoadRequest : BaseRequest
@property (nonatomic, copy) NSString *role;
@property (nonatomic, copy) NSString *os;
@end
