//
//  LYQuestionAndProjectView.m
//  ITSNS
//
//  Created by Ivan on 16/3/6.
//  Copyright © 2016年 Ivan. All rights reserved.
//

#import "ITObjectView.h"
#import "FaceUtils.h"
@implementation ITObjectView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.titleLabel = [[YYTextView alloc]initWithFrame:CGRectMake(LYMargin, 0, LYSW-2*LYMargin, 30)];
        
        [FaceUtils faceBindingWithTextView:self.titleLabel];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.titleLabel];
        
        self.detailTV = [[YYTextView alloc]initWithFrame:CGRectMake(LYMargin, CGRectGetMaxY(self.titleLabel.frame), LYSW-2*LYMargin, 0)];
        [FaceUtils faceBindingWithTextView:self.detailTV];
        self.detailTV.font = [UIFont systemFontOfSize:LYTextSize];
        self.detailTV.textColor = [UIColor grayColor];
        [self addSubview:self.detailTV];
        
        self.imageView = [[ImageBrowserView alloc]initWithFrame:CGRectZero];
    
        [self addSubview:self.imageView];
        //禁止交互
        self.titleLabel.userInteractionEnabled = self.detailTV.userInteractionEnabled = NO;
    }
    return self;
}


-(void)setItObj:(TRITObject *)itObj{
    
    _itObj = itObj;
    
    self.titleLabel.text = itObj.title;
    if (itObj.title.length==0) {
        self.titleLabel.height = 0;
    }else{
        self.titleLabel.height = 30;
    }
    
    self.detailTV.top = CGRectGetMaxY(self.titleLabel.frame)+LYMargin;
    self.detailTV.text = itObj.detail;
     self.detailTV.height = [itObj getDetailHeight];
    
 
        self.imageView.itObj = itObj;
         self.imageView.frame = CGRectMake(LYMargin, CGRectGetMaxY(self.detailTV.frame)+LYMargin, LYSW-2*LYMargin, [itObj getImageHeight]);
        
    
    
    
    
}

@end
