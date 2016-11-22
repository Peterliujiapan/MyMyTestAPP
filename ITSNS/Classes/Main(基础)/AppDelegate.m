//
//  AppDelegate.m
//  ITSNS
//
//  Created by Ivan on 16/1/9.
//  Copyright © 2016年 Ivan. All rights reserved.
//
#import "TRWelcomeViewController.h"
#import "AppDelegate.h"
#import "XHDrawerController.h"
#import "LYLeftMenuViewController.h"
#import "LYMainTabbarController.h"
#import "Bmob.h"
#import "LYWelcomeViewController.h"
#import "LYMainNavigatoinController.h"
#import "AppDelegate+EaseMod.h"
#import "EaseMobManager.h"
#import "TRChattingViewController.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
 

    
    
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    [self.window makeKeyAndVisible];
    
    
    //初始化百度地图
    
    self.mapManager = [[BMKMapManager alloc]init];
    // 如果要关注网络及授权验证事件，请设定     generalDelegate参数
    BOOL ret = [_mapManager start:@"vV3v6uhKwijzBsXbbyPfnYdISvMSFEAz"  generalDelegate:nil];
    if (!ret) {
        NSLog(@"manager start failed!");
    }
    
    
    //初始化Bmob
    [Bmob registerWithAppKey:@"ed4dfde7e1ed83a500f01fd7cf4c5bcc"];
    
    //初始化环信
    [self initEaseMob:application andOptions:launchOptions];
    
    //给环信添加delegate
    [EaseMobManager shareManager];
    
    
    
    
    
    
    
    
    NSString *currentVersion = [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults
                          ];
    NSString *version = [ud objectForKey:@"version"];
    
    if ([version isEqualToString:currentVersion]) {//显示正常页面
        //判断是否登录
        if ([BmobUser getCurrentUser]) {
            //        登陆过显示主页
            [self showHomeVC];
        }else{
            //显示登录页面
            self.window.rootViewController = LYNavi([[LYWelcomeViewController alloc]init]);
            
        }

        
        
        
        
    }else{//不相等
        //显示欢迎页面
        
        
        
        
        [ud setObject:currentVersion forKey:@"version"];
        [ud synchronize];
        
        
        TRWelcomeViewController *vc = [TRWelcomeViewController new];
        
        self.window.rootViewController = vc;
        
        
    }
    
    
    NSLog(@"%@",[NSBundle mainBundle].infoDictionary);
    
    
    
    
    
    
    
    
    
    
   
    
    return YES;
}

-(void)showHomeVC{
    XHDrawerController *drawerController = [[XHDrawerController alloc]init];
    drawerController.springAnimationOn = YES;
    LYLeftMenuViewController *menuVC = [[LYLeftMenuViewController alloc]init];
    drawerController.leftViewController = menuVC;
    
    
    self.tabbarController = [[LYMainTabbarController alloc]init];
    drawerController.centerViewController = self.tabbarController;
    
    self.window.rootViewController = drawerController;
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(nonnull NSDictionary *)userInfo{
    
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    NSString *username = userInfo[@"f"];
    
      [self jumpToChattingPageWithUserName:username];
    
    
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    
    NSString *username = notification.userInfo[@"from"];
    
    [self jumpToChattingPageWithUserName:username];
    
    
    
}

-(void)jumpToChattingPageWithUserName:(NSString *)username{
    TRChattingViewController *vc = [TRChattingViewController new];
    
    BmobQuery *query = [BmobQuery queryForUser];
    [query whereKey:@"username" equalTo:username];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        
        if (array.count>0) {
            BmobUser *user = [array firstObject];
            
            vc.toUser = user;
            
            
            UINavigationController *navi =  self.tabbarController.selectedViewController;
            
            
            [navi pushViewController:vc animated:YES];
            
        }
        
        
    }];

}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
