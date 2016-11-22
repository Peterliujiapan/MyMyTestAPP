//
//  EaseMobManager.h
//  环信测试
//
//  Created by tarena on 16/7/2.
//  Copyright © 2016年 Tarena. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EaseMob.h>

typedef void (^MyCallback)(id obj);
@interface EaseMobManager : NSObject<EMChatManagerDelegate,IEMChatProgressDelegate>
@property (nonatomic, strong)NSMutableArray *requests;

+ (EaseMobManager *)shareManager;


- (void)registerWithName:(NSString *)name andPW:(NSString *)pw andCallback:(MyCallback )callback;

- (void)loginWithWithName:(NSString *)name andPW:(NSString *)pw andCallback:(MyCallback )callback;;


-(void)addFirendWithName:(NSString *)name;

-(void)removeFirendWithName:(NSString *)name;


-(EMMessage *)sendMessageWithText:(NSString *)text andToName:(NSString *)toName;
-(EMMessage *)sendMessageWithImage:(UIImage *)image andToName:(NSString *)toName;
-(EMMessage *)sendMessageWithVoiceData:(NSData *)data andTime:(NSNumber *)duration andToName:(NSString *)toName;

-(void)updateLocalFirends;
@end
