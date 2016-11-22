//
//  CommentCell.m
//  ITSNS
//
//  Created by tarena on 16/5/19.
//  Copyright © 2016年 Ivan. All rights reserved.
//
#import <UIImageView+AFNetworking.h>
#import "CommentCell.h"
#import "TRVoicePlayer.h"
@implementation CommentCell
-(void)awakeFromNib{
    
    self.commentView = [[CommentView alloc]initWithFrame:CGRectZero];
    
    [self addSubview:self.commentView];
    
}
-(void)setComment:(Comment *)comment{
    _comment = comment;
    
    BmobUser *user = [comment.bObj objectForKey:@"user"];
    [self.headIV sd_setImageWithURL:[NSURL URLWithString:[user objectForKey:@"headPath"]]];
    self.nameLabel.text = [user objectForKey:@"nick"];
    self.timeLabel.text = comment.createTime;
    
    
    
    //判断是否有录音
    if (comment.voicePath) {
        self.audioBtn.hidden = NO;
    }else{
        self.audioBtn.hidden = YES;
    }
    
    
    self.commentView.comment = comment;
    
    self.commentView.frame = CGRectMake(0, 50, LYSW, [comment getHeigth]);
}

- (IBAction)playAction:(id)sender {
    
    [TRVoicePlayer playWithVoicePath:self.comment.voicePath];
    
}

-(void)layoutSubviews{
    [super layoutSubviews];
   self.height = [self.comment getHeigth]+50;
}

@end
