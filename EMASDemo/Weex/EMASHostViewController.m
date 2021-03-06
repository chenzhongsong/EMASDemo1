//
//  DemoWeexViewController.m
//  EMASDemo
//
//  Created by daoche.jb on 2018/6/28.
//  Copyright © 2018年 EMAS. All rights reserved.
//

#import "EMASHostViewController.h"
#import <objc/message.h>
#import <WeexSDK/WXDebugTool.h>
#import "UIViewController+EMASWXNaviBar.h"
//#import "EMASWindVaneViewController.h"
#import <DynamicConfiguration/DynamicConfigurationManager.h>

#ifndef WX_LOCATION_NOTIFICATION_RELOAD
#define WX_LOCATION_NOTIFICATION_RELOAD    @"location_reload"
#endif

#ifndef WX_LOCATION_NOTIFICATION_REPLACE
#define WX_LOCATION_NOTIFICATION_REPLACE   @"location_replace"
#endif


BOOL WEEX_DYNAMIC_DELETE = NO;

@interface EMASHostViewController()

@property (nonatomic, copy) NSString *resourceUrlString;
@property (nonatomic, strong) UIWebView *webView;

@end

@implementation EMASHostViewController

- (void)dealloc {
    if (self.wxViewController) {
        [self.wxViewController removeFromParentViewController];
    }
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self = [self initWithNavigatorURL:[NSURL URLWithString:@""]];
    }
    return self;
}

- (instancetype)initWithNavigatorURL:(NSURL *)URL {
    self = [super init];
    if (self) {
        NSString *url = URL.absoluteString;
        
        ///先简单区分本地和远程js
        if ([url rangeOfString:@"/"].location == NSNotFound ||
            [url rangeOfString:@"/"].location == 0) {//本地
            NSString *bundlePath = [NSBundle mainBundle].bundlePath;
            url = [NSString stringWithFormat:@"file://%@/bundlejs/%@", bundlePath,URL.absoluteString];
        }
        
        self.resourceUrlString = url;
        
        NSString * urlString = [[DynamicConfigurationManager sharedInstance] redirectUrl:self.resourceUrlString];
        
        if (!urlString) {
            urlString = @"";
        }
        if (urlString.length == 0 || [urlString containsString:@".js"] || [urlString containsString:@".wx"]) {
            self.wxViewController = [[EMASWXRenderViewController alloc] initWithNavigatorURL:[NSURL URLWithString:urlString] withCustomOptions:@{@"bundleUrl":urlString} withInitData:nil withViewController:self];
            //渲染容器的外部代理。
            self.wxViewController.delegate = self;
        } else {
            //webview打开
            [self wxDegradeToH5:urlString];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNaviBar];
    
    //务必设置这个属性，它与导航栏隐藏属性相关。
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    if (self.wxViewController) {
        //在宿主容器中添加渲染容器和视图。
        [self.view addSubview:self.wxViewController.view];
        [self addChildViewController:self.wxViewController];
    }
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationRefreshInstance:) name:@"RefreshInstance" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationReload:)
                                                 name:WX_LOCATION_NOTIFICATION_RELOAD object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationReplace:)
                                                 name:WX_LOCATION_NOTIFICATION_REPLACE object:nil];
}

- (void)locationReload:(NSNotification *)notification
{
    [self.wxViewController refreshWeex];
}

- (void)locationReplace:(NSNotification *)notification
{
    
}

# pragma mark WXViewController Delegate

//内存报警时销毁非当前实例, 是否销毁通过配置下发。
- (void)wxDidReceiveMemoryWarning {
    id weex_memory_warning_destroy = @"1";
    if (weex_memory_warning_destroy && [@"1" isEqualToString:weex_memory_warning_destroy]) {
        if (self.wxViewController.isViewLoaded && [self.view window] == nil ) {
            [self.wxViewController.instance destroyInstance];
            self.wxViewController.instance = nil;
        }
    }
}

- (void)wxFinishCreateInstance {
    //Weex Instance创建成功
    [self.webView removeFromSuperview];
}

- (void)wxFailCreateInstance:(NSError *)error {
    //Weex Instance创建失败
    NSLog(@"%@", error);
    if ([error.localizedDescription containsString:@"404"] ||
        [error.localizedDescription containsString:@"403"]) {
        NSString *distributionUrl = self.resourceUrlString;
        NSString *dynamicUrl = [[DynamicConfigurationManager sharedInstance] redirectUrl:distributionUrl];
        if (![distributionUrl isEqualToString:dynamicUrl]) {
            [[DynamicConfigurationManager sharedInstance] deleteConfigurationForGoalUrl:self.resourceUrlString];
            WEEX_DYNAMIC_DELETE = YES;
        }
    }
}

- (void)wxFinishRenderInstance {
    //Weex Instance渲染完成

}

- (void)wxDegradeToH5:(NSString *)url
{
    // 正式发布，灰度资源被删，阻止 H5 降级
    if (WEEX_DYNAMIC_DELETE) {
        self.wxViewController.tplURL = [NSURL URLWithString:self.resourceUrlString];
        [self.wxViewController refreshWeex];
        WEEX_DYNAMIC_DELETE = NO;
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
#if 1
        [self.wxViewController.instance destroyInstance];
        [self.wxViewController.weexView removeFromSuperview];
        [self.webView removeFromSuperview];
        
        self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
        [self.view addSubview:self.webView];
        
#else
        EMASWindVaneViewController *vc = [[EMASWindVaneViewController alloc] init];
        vc.loadUrl = url;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
#endif
    });

}


#pragma mark - websocket
- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    if ([@"refresh" isEqualToString:message]) {
        [self.wxViewController refreshWeex];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    
}

#pragma mark - notification
- (void)notificationRefreshInstance:(NSNotification *)notification {
    [self.wxViewController refreshWeex];
}

@end


