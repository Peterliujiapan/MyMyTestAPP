//
//  LYMainTabbarController.m
//  ITSNS
//
//  Created by Ivan on 16/1/9.
//  Copyright © 2016年 Ivan. All rights reserved.
//


#import "TRSendingViewController.h"
#import "SphereMenu.h"
#import "AddNameAndPicViewController.h"
#import "LYMainTabbarController.h"
#import "LYSettingsViewController.h"
#import "LYMainTabbarController.h"
#import "LYHomeViewController.h"
#import "LYLocationViewController.h"
#import "LYProjectViewController.h"
#import "LYQViewController.h"
#import "LYMessageListViewController.h"
#import "LYFriendsViewController.h"
#import "LYMainNavigatoinController.h"
@interface LYMainTabbarController ()<SphereMenuDelegate>
@property (nonatomic, strong)SphereMenu *sphereMenu;
@end

@implementation LYMainTabbarController
-(void)checkingUnread{
    
    BmobQuery *query = [BmobQuery queryWithClassName:@"UnRead"];
    [query whereKey:@"toUser" equalTo:[BmobUser getCurrentUser]];
    //包含itobj字段详情
    [query includeKey:@"itObj"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        int total = 0;
        for (BmobObject *unread in array) {
            
            int count = [[unread objectForKey:@"unreadCount"] intValue];
            
            total+=count;
        }
        
        
        NSLog(@"未读总数：%d",total);
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"UnReadNotification" object:@(total)];
        
    }];

    
}
- (void)viewDidLoad {
    [super viewDidLoad];
 
    
    //开始检测未读
    [self checkingUnread];
    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(checkingUnread) userInfo:nil repeats:YES];
  
    LYHomeViewController *hvc = [[LYHomeViewController alloc]init];
    hvc.type = @"0";
    LYMessageListViewController *mlvc = [[LYMessageListViewController alloc]init];
    LYFriendsViewController *fvc = [[LYFriendsViewController alloc]init];
    LYLocationViewController *lvc = [[LYLocationViewController alloc]init];
    LYHomeViewController *qvc = [[LYHomeViewController alloc]init];
     qvc.type = @"1";
    LYHomeViewController *pvc = [[LYHomeViewController alloc]init];
     pvc.type = @"2";
    LYSettingsViewController *svc = [[LYSettingsViewController alloc]init];
    NSArray *titles = @[@"朋友圈",@"消息列表",@"好友列表",@"位置服务",@"热门问题",@"热门项目",@"设置页面",];
    hvc.title = titles[0];
    mlvc.title = titles[1];
    fvc.title = titles[2];
    lvc.title = titles[3];
    qvc.title = titles[4];
    pvc.title = titles[5];
    svc.title = titles[6];
    
    
    [self addChildViewController:LYNavi(hvc)];
    [self addChildViewController:LYNavi(mlvc)];
    [self addChildViewController:LYNavi(fvc)];
    [self addChildViewController:LYNavi(lvc)];
    [self addChildViewController:LYNavi(qvc)];
    [self addChildViewController:LYNavi(pvc)];
    [self addChildViewController:LYNavi(svc)];
   
    
    self.tabBar.hidden = YES;
    [self addSendButtons];
}

-(void)addSendButtons{
    UIImage *startImage = [UIImage imageNamed:@"start"];
    UIImage *image1 = [UIImage imageNamed:@"icon-twitter"];
    UIImage *image2 = [UIImage imageNamed:@"icon-email"];
    UIImage *image3 = [UIImage imageNamed:@"icon-facebook"];
    NSArray *images = @[image1, image2, image3];
    SphereMenu *sphereMenu = [[SphereMenu alloc] initWithStartPoint:CGPointMake(267, 40)
                                                         startImage:startImage
                                                      submenuImages:images];
    sphereMenu.delegate = self;
    [self.view addSubview:sphereMenu];
    
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panAction:)];
    [sphereMenu addGestureRecognizer:pan];
    self.sphereMenu = sphereMenu;
    
    
}
-(void)panAction:(UIPanGestureRecognizer *)pan{
    
    pan.view.center = [pan locationInView:self.view];
    
    [self.sphereMenu  shrinkSubmenu];
}

- (void)sphereDidSelected:(int)index{
    NSLog(@"%d",index);
    
    TRSendingViewController *vc = [TRSendingViewController new];
    
    vc.type = @(index).stringValue;
    
    [self presentViewController:[[UINavigationController alloc]initWithRootViewController:vc] animated:YES completion:nil];
    
    
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    NSString *nick = [[BmobUser getCurrentUser]objectForKey:@"nick"];
    NSString *headPath = [[BmobUser getCurrentUser]objectForKey:@"headPath"];
    if (!nick||!headPath) {
        
        AddNameAndPicViewController *vc = [AddNameAndPicViewController new];
        
        [self presentViewController:[[UINavigationController alloc]initWithRootViewController:vc] animated:YES completion:nil];
        
    }
    
    
}

@end
