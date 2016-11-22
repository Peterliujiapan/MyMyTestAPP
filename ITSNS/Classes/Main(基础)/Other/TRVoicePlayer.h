//
//  TRVoicePlayer.h
//  ITSNS
//
//  Created by tarena on 16/6/29.
//  Copyright © 2016年 Ivan. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>

@interface TRVoicePlayer : NSObject

+(void)playWithVoicePath:(NSString *)path;

+(void)playWithLocalVoicePath:(NSString *)path;
@end
