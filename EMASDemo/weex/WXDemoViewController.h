//
//  DemoWeexViewController.h
//  EMASDemo
//
//  Created by daoche.jb on 2018/6/28.
//  Copyright © 2018年 EMAS. All rights reserved.
//

#import "ExEMASWXViewController.h"
#import <SRWebSocket.h>

//宿主容器
@interface WXDemoViewController : UIViewController <EMASWXViewControllerProtocol,SRWebSocketDelegate>

@property (nonatomic, strong) SRWebSocket *hotReloadSocket;
@property (nonatomic, copy) NSString *source;

@property(nonatomic, strong) ExEMASWXViewController *wxViewController;

- (id)initWithNavigatorURL:(NSURL *)URL;

@end
