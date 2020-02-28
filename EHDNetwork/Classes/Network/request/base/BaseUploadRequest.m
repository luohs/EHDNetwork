//
//  BaseUploadRequest.m
//  EHDNetwork
//
//  Created by luohs on 2018/2/27.
//

#import "BaseUploadRequest.h"

@implementation BaseUploadRequest
- (id)init
{
    self = [super init];
    if (self) {
        self.name = @"file";
    }
    return self;
}
@end
