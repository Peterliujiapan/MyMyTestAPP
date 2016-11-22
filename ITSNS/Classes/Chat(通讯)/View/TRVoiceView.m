//
//  TRVoiceView.m
//  ITSNS
//
//  Created by tarena on 16/7/6.
//  Copyright © 2016年 Ivan. All rights reserved.
//

#import "TRVoiceView.h"

@implementation TRVoiceView

-(void)awakeFromNib{
    
    self.imageView.animationImages = @[[UIImage imageNamed:@"chat_receiver_audio_playing000"],[UIImage imageNamed:@"chat_receiver_audio_playing001"],[UIImage imageNamed:@"chat_receiver_audio_playing002"],[UIImage imageNamed:@"chat_receiver_audio_playing003"],[UIImage imageNamed:@"chat_receiver_audio_playing_full"],];
    
}

-(void)beginAnimation{
    
    self.imageView.animationDuration = 1;
    self.imageView.animationRepeatCount = self.timeLabel.text.intValue;
    
    
    [self.imageView startAnimating];
    
}

-(void)changeLocation:(BOOL)isSelf{
 
    
    
    
    if (isSelf) {
        self.imageView.transform = CGAffineTransformMakeTranslation(20, 0);
        self.imageView.transform = CGAffineTransformRotate(self.imageView.transform, M_PI);
        self.timeLabel.transform = CGAffineTransformMakeTranslation(-20, 0);
    }else{
        self.imageView.transform = CGAffineTransformIdentity;
        
        self.timeLabel.transform = CGAffineTransformIdentity;
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
