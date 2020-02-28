//
//  NSDate+Calibrate.m
//  Pods
//
//  Created by luohs on 2017/2/28.
//
//

#import "NSDate+Calibrate.h"

static NSTimeInterval internalDeviation;

@implementation NSDate (Calibrate)

+ (void)setDeviation:(NSTimeInterval)deviation
{
    internalDeviation = deviation;
}

+ (instancetype)calibratedTime
{
    return [[NSDate date] dateByAddingTimeInterval:internalDeviation];
}

@end
