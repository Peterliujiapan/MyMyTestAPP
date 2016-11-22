//
//  TRVoicePlayer.m
//  ITSNS
//
//  Created by tarena on 16/6/29.
//  Copyright © 2016年 Ivan. All rights reserved.
//
#import "amrFileCodec.h"
#import "TRVoicePlayer.h"
static AVAudioPlayer *_player;
@implementation TRVoicePlayer
+(void)playWithVoicePath:(NSString *)path{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:path]];
        //把amr格式转换回 wav格式
        data = DecodeAMRToWAVE(data);
        dispatch_async(dispatch_get_main_queue(), ^{
            //因为局部变量的player播发不了音乐 所以要声明成全局的 因为是静态方法 所以不能是属性 只能是static的全局变量
            _player = [[AVAudioPlayer alloc]initWithData:data error:nil];
            [_player play];
        });
        
        
        
    });
    

}


+(void)playWithLocalVoicePath:(NSString *)path{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *data = [NSData dataWithContentsOfFile:path];
        //把amr格式转换回 wav格式
        data = DecodeAMRToWAVE(data);
        dispatch_async(dispatch_get_main_queue(), ^{
            //因为局部变量的player播发不了音乐 所以要声明成全局的 因为是静态方法 所以不能是属性 只能是static的全局变量
            _player = [[AVAudioPlayer alloc]initWithData:data error:nil];
            [_player play];
        });
        
        
        
    });
    
    
}
@end
