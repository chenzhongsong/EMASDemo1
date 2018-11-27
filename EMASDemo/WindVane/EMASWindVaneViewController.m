//
//  EMASWindVaneViewController.m
//  EMASDemo
//
//  Created by daoche.jb on 2018/9/29.
//  Copyright © 2018年 EMAS. All rights reserved.
//

#import "EMASWindVaneViewController.h"
#import <WindVane/WindVane.h>
#import <WindVaneBridge/WVBridge+Advance.h>
#import <DynamicConfiguration/DynamicConfigurationManager.h>
#import <objc/runtime.h>

@interface EMASWindVaneViewController ()

@end

@implementation EMASWindVaneViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"EMAS";
        self.autoLoadTitle = YES;
        self.allowsControlNavigationBar = YES;
        self.useToolbar = NO;
        self.useWKWebView = WVUseWKWebViewCustom;
        [self supportiOS7WithoutStatusBar];
        
        self.navigationItem.leftBarButtonItems = @[[self backButtonItem]];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor grayColor];
    [self registerJSBridge];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)setLoadUrl:(NSString *)loadUrl
{
    loadUrl = [[DynamicConfigurationManager sharedInstance] redirectUrl:loadUrl];
    [super setLoadUrl:loadUrl];
}

- (void)registerJSBridge {
    __block __weak typeof(self) weak = self;
    // 为 Demo 添加 JSBridge Base.openWindow
    [self registerHandler:@"Base.openWindow"
                withBlock:^(NSDictionary * params, id<WVBridgeCallbackContext> context) {
                    NSString * url = [params wvStringValue:@"url"];
                    if (!url) {
                        [context callbackInvalidParameter:@"url" withMessage:nil];
                        return;
                    } else {
                        EMASWindVaneViewController * newWindow = [[EMASWindVaneViewController alloc] init];
                        newWindow.loadUrl = url;
                        [weak.navigationController pushViewController:newWindow animated:YES];
                        [context callbackSuccess:nil];
                    }
                }];
}

- (UIBarButtonItem *)backButtonItem
{
    UIBarButtonItem *backButtonItem = objc_getAssociatedObject(self, _cmd);
    if (!backButtonItem) {
        backButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"]
                                                          style:UIBarButtonItemStylePlain
                                                         target:self
                                                         action:@selector(backButtonClicked:)];
        objc_setAssociatedObject(self, _cmd, backButtonItem, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return backButtonItem;
}

- (void)backButtonClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end

