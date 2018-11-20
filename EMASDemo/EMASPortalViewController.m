//
//  EMASPortalViewController.m
//  EMASDemo
//
//  Created by daoche.jb on 2018/11/8.
//  Copyright © 2018 EMAS. All rights reserved.
//

#import "EMASPortalViewController.h"
#import "EMASNativeViewController.h"
#import "EMASWindVaneScanViewController.h"
#import "EMASWeexContainerService.h"

@interface EMASPortalViewController ()

@end

@implementation EMASPortalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSNumber *scaffoldType = [[EMASWeexContainerService shareInstance] scaffoldType];
    NSInteger scaffoldTypeInt = scaffoldType.integerValue;
    
    if (scaffoldTypeInt == 2) {
        //weex脚手架
        NSNumber *tabSize = [[EMASWeexContainerService shareInstance] tabSize];
        NSInteger tabSizeInt = tabSize.integerValue;
        
        if (!tabSize || tabSizeInt < 0) {
            //非weex脚手架,有weex，没有H5
            self.H5Button.hidden = YES;
        }
    } else if (scaffoldTypeInt == 4) {
        //纯H5脚手架
        self.weexButton.hidden = YES;
    } else if (scaffoldTypeInt == (2 | 4)) {
        //weex + H5 脚手架
        
    } else {
        //Native脚手架
        
    }
    
}

- (IBAction)didWeexShowButtonClicked:(id)sender {
    EMASNativeViewController *controller = [[EMASNativeViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)didH5ShowButtonClicked:(id)sender {
    EMASWindVaneScanViewController *controller = [[EMASWindVaneScanViewController alloc] init];
    //controller.loadUrl = @"http://wapp.m.taobao.com/app/windvane/jsbridge.html";
    //controller.loadUrl = @"http://chaoshi.m.tmall.com";
    [self.navigationController pushViewController:controller animated:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
