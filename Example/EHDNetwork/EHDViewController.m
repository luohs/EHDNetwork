//
//  EHDViewController.m
//  EHDNetwork
//
//  Created by luohs on 11/20/2017.
//  Copyright (c) 2017 luohs. All rights reserved.
//

#import "EHDViewController.h"
#import "EHDDemoRequest.h"
#import "EHDPreLoadRequest.h"
#import "EHDPreLoadEntity.h"
#import "EHDRecommendServiceStationRequest.h"
//#import <EHDNetwork/BaseRequest+TFSupport.h>
@interface EHDViewController ()

@end

@implementation EHDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.tag = 1;
    [button setTitle:@"异步" forState:UIControlStateNormal];
    button.frame = CGRectMake((self.view.frame.size.width-100)/2, (self.view.frame.size.height-50)/2, 100, 50);
    button.backgroundColor = [UIColor redColor];
    [button addTarget:self
               action:@selector(action:)
     forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    button2.tag = 2;
    [button2 setTitle:@"同步" forState:UIControlStateNormal];
    button2.frame = CGRectMake((self.view.frame.size.width-100)/2, (self.view.frame.size.height-200)/2, 100, 50);
    button2.backgroundColor = [UIColor brownColor];
    [button2 addTarget:self
               action:@selector(action:)
     forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button2];
}

- (void)action:(UIButton *)button
{
    NSLog(@"===begin===");
    if (button.tag == 1) {
        EHDPreLoadRequest *autoParseRequest = [[EHDPreLoadRequest alloc] init];
        autoParseRequest.role = @"driver";
        autoParseRequest.os = @"iOS";
        autoParseRequest.tf_dataClass = [EHDPreLoadEntity class];
        [autoParseRequest startAsynchronously:^(BaseRequest *request, NetResponse *response) {
            EHDPreLoadEntity *entity = response.data;
            NSLog(@"resultstatus = %@", entity.resultstatus);
            NSLog(@"suginfo = %@", entity.suginfo);
            NSLog(@"======end======");
        }];
    }
    
    if (button.tag == 2) {
        EHDDemoRequest *demorequest = [[EHDDemoRequest alloc] init];
        demorequest.appKey = @"1da1bd1493cc";
        [demorequest startSynchronously:^(BaseRequest *request, NetResponse *response) {
            NSLog(@"%@", response.data);
            NSLog(@"======end======");
        }];
    }
    
    NSDictionary *settings = nil;
    [NetworkProxy proxySetting:&settings];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
