//
//  NSDate+Calibrate.h
//  Pods
//
//  Created by luohs on 2017/2/28.
//
//

#import <Foundation/Foundation.h>

@interface NSDate (Calibrate)

+ (void)setDeviation:(NSTimeInterval)deviation;
+ (instancetype)calibratedTime;

@end
