//
//  CommentView.m
//  ITSNS
//
//  Created by tarena on 16/5/19.
//  Copyright © 2016年 Ivan. All rights reserved.
//

#import "CommentView.h"
#import "FaceUtils.h"
@implementation CommentView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        
        self.textView = [[YYTextView alloc]initWithFrame:CGRectMake(LYMargin, 0, LYSW-2*LYMargin, 0)];
        [FaceUtils faceBindingWithTextView:self.textView];
        self.textView.font = [UIFont systemFontOfSize:LYTextSize];
        self.textView.textColor = [UIColor lightGrayColor];
        self.textView.userInteractionEnabled = NO;
        [self addSubview:self.textView];
        
        self.imageView = [[ImageBrowserView alloc]initWithFrame:CGRectZero];
        [self addSubview:self.imageView];
    }
    return self;
}

-(void)setComment:(Comment *)comment{
    
    _comment = comment;
    
    
    self.textView.text = comment.text;
    self.textView.height = [comment getTextHeight];
    
    if (comment.imagePaths.count>0) {
        self.imageView.hidden = NO;
        self.imageView.comment = comment;
        self.imageView.frame = CGRectMake(LYMargin, CGRectGetMaxY(self.textView.frame)+LYMargin, LYSW-2*LYMargin, [comment getImageHeight]);
    }else{
        self.imageView.hidden = YES;
    }
    
    
    
}

@end
