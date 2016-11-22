//
//  TRMessageCell.m
//  ITSNS
//
//  Created by tarena on 16/7/6.
//  Copyright © 2016年 Ivan. All rights reserved.
//

#import "TRMessageCell.h"
#import "TRUtils.h"
@implementation TRMessageCell

- (void)awakeFromNib {
    // Initialization code
    self.selectedBackgroundView = [[UIView alloc]initWithFrame:self.bounds];
    
    
    self.selectedBackgroundView.backgroundColor = [UIColor clearColor];
    
    self.headIV.layer.cornerRadius = self.headIV.width/2;
    self.headIV.layer.masksToBounds = YES;
    
    self.bubbleRightImage = [[UIImage imageNamed:@"chat_send_nor"] resizableImageWithCapInsets:UIEdgeInsetsMake(32, 25, 16, 20) resizingMode:UIImageResizingModeStretch];
    
       self.bubbleLeftImage = [[UIImage imageNamed:@"chat_recive_nor"] resizableImageWithCapInsets:UIEdgeInsetsMake(19, 22, 31, 35) resizingMode:UIImageResizingModeStretch];
    
    self.textView = [[YYTextView alloc]initWithFrame:CGRectZero];
    
    [self.bubbleIV addSubview:self.textView];
    
    self.messageIV = [[UIImageView alloc]initWithFrame:CGRectZero];
    [self.bubbleIV addSubview:self.messageIV];
    
    //因为是xib自定义控件
    self.voiceView = [[[NSBundle mainBundle]loadNibNamed:@"TRVoiceView" owner:self options:nil]firstObject];
    [self.bubbleIV addSubview:self.voiceView];
    
}



-(void)setMessage:(EMMessage *)message{
    _message = message;
    
    id<IEMMessageBody> msgBody = message.messageBodies.firstObject;
    
    self.timeLabel.text = [TRUtils parseTimeWithTimeStap:message.timestamp];
    //把图片 文本 音频 都隐藏
      self.messageIV.hidden = self.textView.hidden = self.voiceView.hidden = YES;
    
    switch ((int)msgBody.messageBodyType) {
        case eMessageBodyType_Text:
        {
          
            self.textView.hidden = NO;
            
            EMTextMessageBody *msgBody = message.messageBodies.firstObject;
            
            
            self.textView.frame = CGRectMake(17, 12, 250, 0);
            
            self.textView.text = msgBody.text;
            
            
            self.textView.size = self.textView.textLayout.textBoundingSize;
            
            self.bubbleIV.size = CGSizeMake(self.textView.size.width+34, self.textView.size.height+22);
            
            
            
            
            
            
            
          
            
            
            
            
            
        }
            
            break;
            
        case eMessageBodyType_Image:
        {
            
            self.messageIV.hidden = NO;
            EMImageMessageBody *imgBody = [message.messageBodies firstObject];
            
            
         
            self.messageIV.frame = CGRectMake(17, 12, 100, 100);
            
            self.bubbleIV.size = CGSizeMake(100+34, 100+22);
        
            
//            //判断是自己发的还是对方
            if ([message.from isEqualToString:[BmobUser getCurrentUser].username]) {//自己
                
                self.messageIV.image = [UIImage imageWithContentsOfFile:imgBody.localPath];
                
            }else{
                  self.messageIV.image = [UIImage imageWithContentsOfFile:imgBody.remotePath];
            }
//
//                cell.textLabel.text = @"对方发送了一张图片消息";
//                
//                cell.textLabel.textAlignment = NSTextAlignmentLeft;
//            }else{
//                
//                cell.textLabel.text = @"我发送了一张图片消息";
//                cell.textLabel.textAlignment = NSTextAlignmentRight;
//            }
            
            
            
            
            
        }
            break;
        case eMessageBodyType_Voice:
        {
            EMVoiceMessageBody *voiceBody = [message.messageBodies firstObject];
            
            self.voiceView.timeLabel.text = [NSString stringWithFormat:@"%ld\"",voiceBody.duration];
            self.voiceView.origin = CGPointMake(17, 12);
            
            self.voiceView.hidden = NO;
            
            self.bubbleIV.size = CGSizeMake(60+34, 25+22);
            
            
            
            //判断是自己发的还是对方
            if ([message.from isEqualToString:[BmobUser getCurrentUser].username]) {//自己
                
                [self.voiceView changeLocation:YES];
                
            }else{
                 [self.voiceView changeLocation:NO];
            }
//
            
        }
            
            break;
    }
    
    
    
    
    NSLog(@"%@------%@",message.from,self.toUser.username);
    //判断是自己发的还是对方
    if (![message.from isEqualToString:[BmobUser getCurrentUser].username]) {//对方发的
        
        NSLog(@"%@",self.toUser);
        [self.headIV sd_setImageWithURL:[NSURL URLWithString:[self.toUser  objectForKey:@"headPath"]]];
        self.headIV.left = LYMargin;
        self.bubbleIV.image = self.bubbleLeftImage;
        self.bubbleIV.left = LYMargin+self.headIV.width;
    }else{//自己
        
        
        
        
        
        self.bubbleIV.left = LYSW-LYMargin-self.bubbleIV.width-self.headIV.width;
        self.headIV.left = LYSW-LYMargin-self.headIV.width;
        [self.headIV sd_setImageWithURL:[NSURL URLWithString:[[BmobUser getCurrentUser]  objectForKey:@"headPath"]]];
        
        
        self.bubbleIV.image = self.bubbleRightImage;
        
    }


}

-(void)hideTimeLabel:(BOOL)isHidden{
    
    if (isHidden) {
        self.timeLabel.hidden = YES;
        
        self.messageView.transform = CGAffineTransformMakeTranslation(0, -20);
    }else{
        self.timeLabel.hidden = NO;
        //重置
        self.messageView.transform = CGAffineTransformIdentity;
    }
    
    
}

@end
