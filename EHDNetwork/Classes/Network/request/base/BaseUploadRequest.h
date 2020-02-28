//
//  BaseUploadRequest.h
//  EHDNetwork
//
//  Created by luohs on 2018/2/27.
//

#import <EHDNetwork/EHDNetwork.h>

@interface BaseUploadRequest : BaseRequest
@property (nonatomic, strong) NSArray<NSURL *> *fileURLs;
@property (nonatomic, strong) NSArray<NSData *> *fileDatas;
@property (nonatomic, copy) NSString *name;
@end
