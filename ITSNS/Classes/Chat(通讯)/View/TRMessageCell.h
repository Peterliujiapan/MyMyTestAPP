//
//  TRMessageCell.h
//  ITSNS
//
//  Created by tarena on 16/7/6.
//  Copyright © 2016年 Ivan. All rights reserved.
//
#import "YYTextView.h"
#import <UIKit/UIKit.h>
#import "EaseMob.h"
#import "TRVoiceView.h"
@interface TRMessageCell : UITableViewCell
@property (nonatomic, strong)EMMessage *message;
@property (nonatomic, strong)BmobUser *toUser;
@property (weak, nonatomic) IBOutlet UIImageView *bubbleIV;
@property (weak, nonatomic) IBOutlet UIImageView *headIV;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIView *messageView;
@property (nonatomic, strong)TRVoiceView *voiceView;
@property (nonatomic, strong)UIImage *bubbleLeftImage;
@property (nonatomic, strong)UIImage *bubbleRightImage;

@property (nonatomic, strong)YYTextView *textView;
@property (nonatomic, strong)UIImageView *messageIV;



-(void)hideTimeLabel:(BOOL)isHidden;
@end
