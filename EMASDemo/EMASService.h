//
//  EMASService.h
//  EMASDemo
//
//  Created by zhishui.lcq on 2018/1/15.
//  Copyright © 2018年 zhishui.lcq. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EMASService : NSObject

+ (EMASService *)shareInstance;

- (NSString *)appkey;
- (NSString *)appSecret;
- (NSString *)ACCSDomain;
- (NSString *)MTOPDomain;
- (NSString *)ChannelID;
- (NSString *)packageZipPrefixURL;
- (NSString *)OSSBucketName;
- (NSString *)HAReportURL;


@end