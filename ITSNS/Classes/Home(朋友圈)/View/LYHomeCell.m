//
//  LYQuestionCell.m
//  ITSNS
//
//  Created by Ivan on 16/1/13.
//  Copyright © 2016年 Ivan. All rights reserved.
//
#import "XHDrawerController.h"
#import "AppDelegate.h"
#import "LYHomeCell.h"
#import "UIImageView+AFNetworking.h"
#import "LYUserInfoViewController.h"
@implementation LYHomeCell
//初始化方法
-(void)awakeFromNib{
    //设置Cell选中背景颜色
    self.selectedBackgroundView = [[UIView alloc]initWithFrame:self.bounds];
    self.selectedBackgroundView.backgroundColor = LYGreenColor;
    //设置按钮的显示效果
    self.likeBtn.layer.borderWidth = self.commentBtn.layer.borderWidth = .5;
    self.likeBtn.layer.cornerRadius = self.commentBtn.layer.cornerRadius = 3;
    self.likeBtn.layer.masksToBounds =  self.commentBtn.layer.masksToBounds = YES;
    self.likeBtn.layer.borderColor =  self.commentBtn.layer.borderColor = [UIColor grayColor].CGColor;
    

 
  //头像的点击事件
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(userInfoAction)];
    [self.headIV addGestureRecognizer:tap];
    self.headIV.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *nameTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(userInfoAction)];
    [self.nameLabel addGestureRecognizer:nameTap];
    self.nameLabel.userInteractionEnabled = YES;
    
    
    
    self.itObjView = [[ITObjectView alloc]initWithFrame:CGRectZero];
    
    [self addSubview:self.itObjView];
}
-(void)userInfoAction{
    
    LYUserInfoViewController *vc = [LYUserInfoViewController new];
    //得到发送当前消息的用户 传递过去
    vc.user =  self.itObj.user;
    
    
   XHDrawerController *dc = (XHDrawerController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    
    UITabBarController *tbc = (UITabBarController *)dc.centerViewController;
    
    UINavigationController *navi = tbc.selectedViewController;
    
    [navi pushViewController:vc animated:YES];
    
    
    
    
}

-(void)setItObj:(TRITObject *)itObj{
    _itObj = itObj;
    
    //让图片 位置 音频 按钮隐藏
    self.imageBtn.hidden = YES;
    self.locationBtn.hidden = YES;
    self.audioBtn.hidden = YES;
  
 
    
    
     //判断是否有音频
    if (itObj.voicePath) {
        self.audioBtn.hidden = NO;
    }
    //判断是否有图片
    if ( itObj.imagePaths) {
        self.imageBtn.hidden = NO;
    }
    //设置浏览量
    [self.likeBtn setTitle:itObj.showCount.stringValue forState:UIControlStateNormal];
    
    //设置评论量
    [self.commentBtn setTitle:itObj.commentCount.stringValue forState:UIControlStateNormal];
 
    //设置头像图片
    [self.headIV sd_setImageWithURL:[NSURL URLWithString:[itObj.user objectForKey:@"headPath"]] placeholderImage:[UIImage imageNamed:@"loadingImage"]];
    //显示名字
    self.nameLabel.text = [itObj.user objectForKey:@"nick"];
    //显示时间
    self.timeLabel.text = [itObj createTime];

    
    
    //显示具体内容
    self.itObjView.frame = CGRectMake(0, 60, LYSW,  [itObj getHeigth]);
    
    self.itObjView.itObj = itObj;
    
}



 
@end
