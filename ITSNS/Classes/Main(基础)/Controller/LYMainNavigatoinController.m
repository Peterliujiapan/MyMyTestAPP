//
//  LYMainNavigatoinController.m
//  ITSNS
//
//  Created by Ivan on 16/1/9.
//  Copyright © 2016年 Ivan. All rights reserved.
//
#import "TRUnReadTableViewController.h"
#import "LYTopScoreViewController.h"
#import "RNFrostedSidebar.h"
#import "LYMainNavigatoinController.h"
#import "XHDrawerController.h"
#import "UIImageView+AFNetworking.h"
#import "LYUserInfoViewController.h"
#import "LYHomeViewController.h"
#import "TRMyItem.h"

@interface LYMainNavigatoinController ()<RNFrostedSidebarDelegate>
@end

@implementation LYMainNavigatoinController

-(void)viewDidLoad{
    [super viewDidLoad];
    
  
    
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    //添加按钮
    UIViewController *vc = [self.viewControllers firstObject];
    
    UIBarButtonItem *menuItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"menu.png"] style:UIBarButtonItemStyleDone target:self action:@selector(menuAction)];
    
    //得到导航控制器里面 第一个页面添加
    vc.navigationItem.leftBarButtonItem = menuItem;
    
    TRMyItem *userItem = [[[NSBundle mainBundle]loadNibNamed:@"TRMyItem" owner:self options:nil]firstObject];
    
    [userItem.userBtn addTarget:self action:@selector(showSliderBar) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:userItem];
    
    //得到导航控制器里面 第一个页面添加
    vc.navigationItem.rightBarButtonItem = rightItem;
    self.navigationBar.tintColor = LYGreenColor;
}

-(void)menuAction{
    
    [self.drawerController toggleDrawerSide:XHDrawerSideLeft animated:YES completion:NULL];
}

//右侧边栏
-(void)showSliderBar{
    //通过静态修饰 让内存中只有一个tabbar
    
    NSArray *images = @[
                        [UIImage imageNamed:@"profile"],
                        [UIImage imageNamed:@"question"],
                        [UIImage imageNamed:@"globe"],
                        [UIImage imageNamed:@"star"],
                        [UIImage imageNamed:@"unread"],];
    NSArray *colors = @[
                        [UIColor colorWithRed:240/255.f green:159/255.f blue:254/255.f alpha:1],
                        [UIColor colorWithRed:255/255.f green:137/255.f blue:167/255.f alpha:1],
                        [UIColor colorWithRed:126/255.f green:242/255.f blue:195/255.f alpha:1],
                        [UIColor colorWithRed:119/255.f green:152/255.f blue:255/255.f alpha:1],
                        [UIColor colorWithRed:240/255.f green:159/255.f blue:254/255.f alpha:1],
                        ]
    ;
    
    RNFrostedSidebar *sliderBar = [[RNFrostedSidebar alloc] initWithImages:images selectedIndices:nil borderColors:colors];
    sliderBar.contentView.contentInset = UIEdgeInsetsMake(100, 0, 0, 0);
    sliderBar.tintColor = [UIColor blackColor];
    sliderBar.showFromRight = YES;
    
    //添加用户头像
    UIImageView *headIV = [[UIImageView alloc]initWithFrame:CGRectMake(5, -50, 60, 60)];
    headIV.layer.cornerRadius = 30;
    headIV.layer.masksToBounds = YES;
    headIV.layer.borderColor = [UIColor whiteColor].CGColor;
    headIV.layer.borderWidth = 2;
    //设置用户头像
    BmobUser *user = [BmobUser getCurrentUser];
    NSString *path = [user objectForKey:@"headPath"];
    
        [headIV sd_setImageWithURL:[NSURL URLWithString:path]];
    
    
    [sliderBar.contentView addSubview:headIV];
    
    sliderBar.delegate = self;
    [sliderBar show];
}

- (void)sidebar:(RNFrostedSidebar *)sidebar didTapItemAtIndex:(NSUInteger)index {
    NSLog(@"%ld",index);
    
    [sidebar dismiss];
    UIViewController *vc = nil;
    switch (index) {
        case 0:
       
          vc = [LYUserInfoViewController new];
            ((LYUserInfoViewController *)vc).user = [BmobUser getCurrentUser];
            break;
        case 1://我的问题
            vc = [LYHomeViewController new];
            ((LYHomeViewController *)vc).type = @"1";
            ((LYHomeViewController *)vc).showSelfInfo = YES;
            break;
        case 2://我的项目
            vc = [LYHomeViewController new];
            ((LYHomeViewController *)vc).type = @"2";
            ((LYHomeViewController *)vc).showSelfInfo = YES;
            break;
        case 3://积分排行
        {
            vc = [LYTopScoreViewController new];
        }
            break;
        case 4:
        {
            vc = [TRUnReadTableViewController new];
        }
            break;
    }
    
    [self pushViewController:vc animated:YES];
}


@end
