//
//  EHDPreLoadEntity.h
//  EHDNetwork_Example
//
//  Created by admin on 2018/5/16.
//  Copyright © 2018年 luohs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EHDPreLoadCityEntity : NSObject

@property (nonatomic, copy, readonly) NSString *areaname;
@property (nonatomic, copy, readonly) NSString *citycode;
@property (nonatomic, copy, readonly) NSString *cityname;
@property (nonatomic, copy, readonly) NSString *entityid;

@end

@interface EHDPreLoadUrlEntity : NSObject

@property (nonatomic, copy, readonly) NSString *carinsurcWel;
@property (nonatomic, copy, readonly) NSString *chargeSecurityExplain;
@property (nonatomic, copy, readonly) NSString *chargeServiceExplain;
@property (nonatomic, copy, readonly) NSString *collegeDetail;
@property (nonatomic, copy, readonly) NSString *collegeList;
@property (nonatomic, copy, readonly) NSString *dServiceAgreement;
@property (nonatomic, copy, readonly) NSString *driverAcademyInd;

@end

@interface EHDPreLoadEntity : NSObject

@property (nonatomic, copy, readonly) NSString *configcrc;
@property (nonatomic, copy, readonly) NSString *forceinfo;
@property (nonatomic, copy, readonly) NSString *forceversion;
@property (nonatomic, copy, readonly) NSString *lastversion;
@property (nonatomic, copy, readonly) NSArray *partloadlist;
@property (nonatomic, copy, readonly) EHDPreLoadUrlEntity *preloadUrl;
@property (nonatomic, copy, readonly) NSString *resultstatus;
@property (nonatomic, copy, readonly) NSString *suginfo;

@end
