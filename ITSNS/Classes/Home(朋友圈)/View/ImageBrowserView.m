//
//  WeiboImageView.m
//
//
//  Created by tarena on 16/5/10.
//  Copyright © 2016年 tarena. All rights reserved.
//
#import "PhotoBroswerVC.h"
#import "ImageBrowserView.h"
#import "UIImageView+AFNetworking.h"
@implementation ImageBrowserView


-(void)setItObj:(TRITObject *)itObj{
    _itObj = itObj;
    
    //清空自身显示的之前的图片
    for (UIImageView *iv in self.subviews) {
        [iv removeFromSuperview];
    }
    
    
    if (itObj.imagePaths.count==1) {
        UIImageView *iv = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, LYSW-2*LYMargin, 2*LYImageSize)];
        NSString *path = itObj.imagePaths[0];
        
        iv.contentMode = UIViewContentModeScaleAspectFill;
        [iv sd_setImageWithURL:[NSURL URLWithString:path] placeholderImage:[UIImage imageNamed:@"loadingImage"]];
        iv.clipsToBounds = YES;
        iv.tag = 0;
        [self addSubview:iv];
        //给图片添加点击手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
        [iv addGestureRecognizer:tap];
        iv.userInteractionEnabled = YES;
        
    }else{
        
        for (int i=0; i<itObj.imagePaths.count; i++) {
            UIImageView *iv = [[UIImageView alloc]initWithFrame:CGRectMake(i%3*(LYImageSize+LYMargin), i/3*(LYImageSize+LYMargin), LYImageSize, LYImageSize)];
            NSString *path = itObj.imagePaths[i];
            
            iv.contentMode = UIViewContentModeScaleAspectFill;
            iv.clipsToBounds = YES;
            [iv sd_setImageWithURL:[NSURL URLWithString:path] placeholderImage:[UIImage imageNamed:@"loadingImage"]];
            
            iv.tag = i;
            [self addSubview:iv];
            //给图片添加点击手势
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
            [iv addGestureRecognizer:tap];
            iv.userInteractionEnabled = YES;
            
        }
        
        
        
        
    }
    
}


-(void)setComment:(Comment *)comment{
    _comment = comment;
    
    
    //清空自身显示的之前的图片
    for (UIImageView *iv in self.subviews) {
        [iv removeFromSuperview];
    }
    
    
    if (comment.imagePaths.count==1) {
        UIImageView *iv = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, LYSW-2*LYMargin, 2*LYImageSize)];
        NSString *path = comment.imagePaths[0];
        
        iv.contentMode = UIViewContentModeScaleAspectFill;
        [iv sd_setImageWithURL:[NSURL URLWithString:path] placeholderImage:[UIImage imageNamed:@"loadingImage"]];
        iv.clipsToBounds = YES;
        iv.tag = 0;
        [self addSubview:iv];
        //给图片添加点击手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
        [iv addGestureRecognizer:tap];
        iv.userInteractionEnabled = YES;
        
    }else{
        
        for (int i=0; i<comment.imagePaths.count; i++) {
            UIImageView *iv = [[UIImageView alloc]initWithFrame:CGRectMake(i%3*(LYImageSize+LYMargin), i/3*(LYImageSize+LYMargin), LYImageSize, LYImageSize)];
            NSString *path = comment.imagePaths[i];
            
            iv.contentMode = UIViewContentModeScaleAspectFill;
            iv.clipsToBounds = YES;
            [iv sd_setImageWithURL:[NSURL URLWithString:path] placeholderImage:[UIImage imageNamed:@"loadingImage"]];
            
            iv.tag = i;
            [self addSubview:iv];
            //给图片添加点击手势
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
            [iv addGestureRecognizer:tap];
            iv.userInteractionEnabled = YES;
            
        }
        
        
        
        
    }
    
}


//*****************************
-(void)tapAction:(UITapGestureRecognizer *)tap{
    
    UIImageView *iv = (UIImageView *)tap.view;
    //[UIApplication sharedApplication].keyWindow.rootViewController 得到的是当前程序window的根页面
    [PhotoBroswerVC show:[UIApplication sharedApplication].keyWindow.rootViewController type:PhotoBroswerVCTypeZoom index:iv.tag photoModelBlock:^NSArray *{
        
        NSMutableArray *modelsM = [NSMutableArray arrayWithCapacity:self.itObj.imagePaths.count];
        
        
        for (NSUInteger i = 0; i< self.itObj.imagePaths.count; i++) {
            PhotoModel *pbModel=[[PhotoModel alloc] init];
            pbModel.mid = i + 1;
            
            NSString *path = self.itObj.imagePaths[i];
            
            //设置查看大图的时候的图片地址
            pbModel.image_HD_U = path;
            
            //源图片的frame
            UIImageView *imageV =(UIImageView *) self.subviews[i];
            pbModel.sourceImageView = imageV;
            [modelsM addObject:pbModel];
        }
        return modelsM;
    }];
    
}
//************************

@end
