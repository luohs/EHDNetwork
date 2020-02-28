//
//  NetResponseError.h
//  EHDNetwork
//
//  Created by luohs on 2020/2/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NetResponseError : NSError
@property (nonatomic, weak, readonly) id context;

+ (instancetype)errorWithUserInfo:(id)userInfo context:(id)context;
@end

NS_ASSUME_NONNULL_END
