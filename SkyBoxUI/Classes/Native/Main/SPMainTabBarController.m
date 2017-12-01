//
//  SPMainTabBarController.m
//  SkyBoxUitl
//
//  Created by Shao shuqiang on 2017/11/29.
//  Copyright © 2017年 Shao shuqiang. All rights reserved.
//

#import "SPMainTabBarController.h"
#import "SPHomeViewController.h"
#import "SPSearchViewController.h"
#import "SPGameViewController.h"
#import "SPMyCenterViewController.h"
#import "SPNavigationController.h"

#define TTFNAME @"Helvetica"

@interface SPMainTabBarController ()

@end

@implementation SPMainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupTabBarChildController];
    
}

#pragma -mark PrivateMethod
- (void)setupTabBarChildController {
    // 设置tabbar字体大小
    NSDictionary *normalDict = @{NSForegroundColorAttributeName:[SPColorUtil getColor:@"999999" alpha:1],NSFontAttributeName:[UIFont systemFontOfSize:10]};
    NSDictionary *selectedDict = @{NSForegroundColorAttributeName:[SPColorUtil getColor:@"31B3EF" alpha:1],NSFontAttributeName:[UIFont systemFontOfSize:10]};
    [[UITabBarItem appearance] setTitleTextAttributes:normalDict forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:selectedDict forState:UIControlStateSelected];
    
    
    
    NSArray *tabbarTtf = @[@"\ue612",@"\ue610",@"\ue610",@"\ue60c",@"\ue60e"];
    NSArray *tabbarSelTtf = @[@"\ue611",@"\ue60f",@"\ue60f",@"\ue60b",@"\ue60d"];
    NSArray *tabbarTitle = @[@"首页",@"游戏",@"空",@"搜索",@"我的"];
    NSString *selectedColor = @"31B3EF";
    NSString *color = @"999999";
    
    UIViewController *homeVC = [self setuptabBar:[[SPHomeViewController alloc] init] Icontitle:tabbarTtf[0] selIcontitle:tabbarSelTtf[0] color:color selectedColor:selectedColor tabbarTile:tabbarTitle[0]];
    UIViewController *gameVC = [self setuptabBar:[[SPGameViewController alloc] init] Icontitle:tabbarTtf[1] selIcontitle:tabbarSelTtf[1] color:color selectedColor:selectedColor tabbarTile:tabbarTitle[1]];
    
    UIViewController *emptyVC = [self setuptabBar:[[UIViewController alloc] init] Icontitle:tabbarTtf[2] selIcontitle:tabbarSelTtf[2] color:color selectedColor:selectedColor tabbarTile:tabbarTitle[2]];
    
    UIViewController *searchVC = [self setuptabBar:[[SPSearchViewController alloc] init] Icontitle:tabbarTtf[3] selIcontitle:tabbarSelTtf[3] color:color selectedColor:selectedColor tabbarTile:tabbarTitle[3]];
    UIViewController *myCenterVC = [self setuptabBar:[[SPMyCenterViewController alloc] init] Icontitle:tabbarTtf[4] selIcontitle:tabbarSelTtf[4] color:color selectedColor:selectedColor tabbarTile:tabbarTitle[4]];
    
    self.viewControllers = @[homeVC,gameVC,emptyVC,searchVC,myCenterVC];
}

- (UIViewController *)setuptabBar:(UIViewController *)vc Icontitle:(NSString *)Icontitle selIcontitle:(NSString *)selIcontitle color:(NSString *)color selectedColor:(NSString *)selectedColor tabbarTile:(NSString *)tabbarTile
{
    vc.title = tabbarTile;
    //生成图片Image
    UIImage *image = [self imageWithIcon:Icontitle inFont:TTFNAME size:22 color:[SPColorUtil getColor:color alpha:1]];
    //    vc.tabBarItem.imageInsets = UIEdgeInsetsMake(0, 0, 2,2);
    vc.tabBarItem.image= [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *selimage = [self imageWithIcon:selIcontitle inFont:TTFNAME size:22 color:[SPColorUtil getColor:selectedColor alpha:1]];
    vc.tabBarItem.selectedImage = [selimage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    SPNavigationController *nav = [[SPNavigationController alloc] initWithRootViewController:vc];
    [self addChildViewController:nav];
    return nav;
}
    
- (UIImage*)imageWithIcon:(NSString*)iconCode inFont:(NSString*)fontName size:(NSUInteger)size color:(UIColor*)color {
    CGSize imageSize = CGSizeMake(size, size);
    UIGraphicsBeginImageContextWithOptions(imageSize, YES, [[UIScreen mainScreen] scale]);
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, size, size)];
    label.font = [UIFont fontWithName:fontName size:size];
    label.text = iconCode;
    if(color){
        label.textColor = color;
    }
    UIGraphicsBeginImageContextWithOptions(label.bounds.size, NO, 0);
    
    [label drawViewHierarchyInRect:label.bounds afterScreenUpdates:YES];
    
    UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return retImage;
}
    
@end
