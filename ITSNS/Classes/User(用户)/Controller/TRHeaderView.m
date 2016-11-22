//
//  TRHeaderView.m
//  ITSNS
//
//  Created by tarena on 16/6/30.
//  Copyright © 2016年 Ivan. All rights reserved.
//
#import "TRChattingViewController.h"
#import "UIImageView+WebCache.h"
#import "TRHeaderView.h"
#import "RNBlurModalView.h"
#import "EaseMobManager.h"
@implementation TRHeaderView

-(void)awakeFromNib{
    
    self.headIV.layer.cornerRadius = self.addBtn.layer.cornerRadius = 5;
    
    self.headIV.layer.masksToBounds = self.addBtn.layer.masksToBounds = YES;
    
    
    
    
}

-(void)setUser:(BmobUser *)user{
    _user = user;
    
    NSString *headPath = [user objectForKey:@"headPath"];
    
    NSString *nick = [user objectForKey:@"nick"];
    
//    NSString *score = [[user objectForKey:@"socre"] stringValue];
    
    self.nickLabel.text = nick;
//    SDWebImage
    [self.headIV sd_setImageWithURL:[NSURL URLWithString:headPath]];
    
    
    
    [self.coverIV sd_setImageWithURL:[NSURL URLWithString:headPath]  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
        self.coverIV.image = [image boxblurImageWithBlur:.5];
        
    }];
    
    
    
}

- (void)updateSubViewsWithOffset:(float)offset{
    float y = -offset-64;
    
    
    if (y>0&&y<100) {
        //    1-3
        float scale = y/200 + 1;
        
        self.coverIV.transform = CGAffineTransformMakeScale(scale, scale);
    }

    NSLog(@"%f",y);
    //让label隐藏 并让图片缩放
    if (y>-100&&y<0) {
        
              [self bringSubviewToFront:self.headIV];
        self.topView.alpha = 1- -y/100;
        
//        100/x = .7
//        0-0.5
        float scale = 1 - -y/(100/.4);
        self.headIV.transform = CGAffineTransformMakeScale(scale, scale);
//        1   0.5
    }
    
    
    //让头像向下移动
    if (y<-100&&y>-210) {
        float offsetY = 100+y;
        NSLog(@"---%f",self.headIV.center.y);
         self.headIV.center = CGPointMake(self.headIV.center.x, 112-offsetY);
        
        [self bringSubviewToFront:self.bottomView];
        
    }
    
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
