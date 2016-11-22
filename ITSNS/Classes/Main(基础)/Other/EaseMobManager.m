//
//  EaseMobManager.m
//  环信测试
//
//  Created by tarena on 16/7/2.
//  Copyright © 2016年 Tarena. All rights reserved.
//

#import "EaseMobManager.h"
static EaseMobManager *_manager;
@implementation EaseMobManager
+(EaseMobManager *)shareManager{
    
    @synchronized(self) {
        
        if (!_manager) {
            _manager = [[EaseMobManager alloc]init];
          
            
            [[EaseMob sharedInstance].chatManager addDelegate:_manager delegateQueue:nil];
        }
        
    }
    return _manager;
    
}
- (instancetype)init
{
    self = [super init];
    if (self) {
          self.requests = [NSMutableArray array];
    }
    return self;
}
-(void)registerWithName:(NSString *)name andPW:(NSString *)pw andCallback:(MyCallback)callback{
    
    [[EaseMob sharedInstance].chatManager asyncRegisterNewAccount:name password:pw withCompletion:^(NSString *username, NSString *password, EMError *error) {
        if (!error) {
            NSLog(@"注册成功");
            callback(nil);
            
            //登录
            [[EaseMobManager shareManager]loginWithWithName:username andPW:username andCallback:^(id obj) {
                if ([obj isKindOfClass:[NSDictionary class]]) {
                    NSLog(@"登录成功");
                }else{
                    NSLog(@"登录失败");
                }
            }];
            
            
            
        }else{
            callback(error);
        }
        
    } onQueue:nil];
    
}

-(void)loginWithWithName:(NSString *)name andPW:(NSString *)pw andCallback:(MyCallback)callback{
    
    [[EaseMob sharedInstance].chatManager asyncLoginWithUsername:name password:pw completion:^(NSDictionary *loginInfo, EMError *error) {
        if (!error && loginInfo) {
            NSLog(@"登录成功");
            // 设置自动登录
            [[EaseMob sharedInstance].chatManager setIsAutoLoginEnabled:YES];
            callback(loginInfo);
            
        }else{
            callback(error);
        }
        
        
    } onQueue:nil];
    
}


-(void)addFirendWithName:(NSString *)name{
    
    
    EMError *error = nil;
    BOOL isSuccess = [[EaseMob sharedInstance].chatManager addBuddy:name message:@"我想加您为好友" error:&error];
    if (isSuccess && !error) {
        NSLog(@"添加成功");
    }
    
}

//删除好友
-(void)removeFirendWithName:(NSString *)name{
    
    EMError *error = nil;
    // 删除好友
    BOOL isSuccess = [[EaseMob sharedInstance].chatManager removeBuddy:name removeFromRemote:YES error:&error];
    if (isSuccess && !error) {
        NSLog(@"删除成功");
    }
    
}


//发送文本消息
-(EMMessage *)sendMessageWithText:(NSString *)text andToName:(NSString *)toName{
    
    //创建文本消息
    EMChatText *txtChat = [[EMChatText alloc] initWithText:text];
    EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithChatObject:txtChat];
    
    // 生成message
    EMMessage *message = [[EMMessage alloc] initWithReceiver:toName bodies:@[body]];
    message.messageType = eMessageTypeChat; // 设置为单聊消息
    
    
    
    [[EaseMob sharedInstance].chatManager sendMessage:message progress:self error:nil];
    return message;
}

//发送图片消息
-(EMMessage *)sendMessageWithImage:(UIImage *)image andToName:(NSString *)toName{
    
    
    EMChatImage *imgChat = [[EMChatImage alloc] initWithUIImage:image displayName:@"a.jpg"];
    EMImageMessageBody *body = [[EMImageMessageBody alloc] initWithChatObject:imgChat];
    
    // 生成message
    EMMessage *message = [[EMMessage alloc] initWithReceiver:toName bodies:@[body]];
    message.messageType = eMessageTypeChat; // 设置为单聊消息
    
    [[EaseMob sharedInstance].chatManager sendMessage:message progress:self error:nil];
    return message;
    
    
    
}



//发送录音消息
-(EMMessage *)sendMessageWithVoiceData:(NSData *)data andTime:(NSNumber *)duration andToName:(NSString *)toName{
    
    
   
    EMChatVoice *voice = [[EMChatVoice alloc] initWithData:data displayName:@"a.amr"];
    voice.duration = [duration intValue];
    EMVoiceMessageBody *body = [[EMVoiceMessageBody alloc] initWithChatObject:voice];
    
    // 生成message
    EMMessage *message = [[EMMessage alloc] initWithReceiver:toName bodies:@[body]];
    message.messageType = eMessageTypeChat; // 设置为单聊消息
    
    
    
    
    
    [[EaseMob sharedInstance].chatManager sendMessage:message progress:self error:nil];
    return message;
    
    
    
}

#pragma mark 环信代理方法
- (void)didReceiveBuddyRequest:(NSString *)username
                       message:(NSString *)message{
    [self.requests addObject:username];
    
    
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"新的好友通知" object:nil];
    
    
}


- (void)didAcceptedByBuddy:(NSString *)username{
    
      NSString *myMessage = [NSString stringWithFormat:@"%@添加成功",username];
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"提示" message:myMessage preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"新的好友通知" object:nil];
        
        
        
    }];
    
    
    [ac addAction:action1];
  
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:ac animated:YES completion:nil];
    
    
    
    //更新本地好友
    [self updateLocalFirends];
}

-(void)updateLocalFirends{
    
    //加载好友列表
    [[EaseMob sharedInstance].chatManager asyncFetchBuddyListWithCompletion:^(NSArray *buddyList, EMError *error) {
    
        if (!error) {
            
            NSMutableArray *names = [NSMutableArray array];
            NSLog(@"获取成功 -- %@",buddyList);
            
            for (EMBuddy *buddy in buddyList) {
                
                [names addObject:buddy.username];
                
                
            }
            
            //保存数组
            NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/firends.plist"];
            [names writeToFile:path atomically:YES];
            
            
            
        }
        
    } onQueue:nil];
    
    
}
- (void)didRejectedByBuddy:(NSString *)username{
    
    NSString *myMessage = [NSString stringWithFormat:@"%@拒绝了你的请求",username];
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"提示" message:myMessage preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        //保存图片
    }];
    
    
    [ac addAction:action1];
    
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:ac animated:YES completion:nil];
    
    
}

- (void)didReceiveMessage:(EMMessage *)message{
    
    NSString *alertBody = nil;
    
    id<IEMMessageBody> msgBody = message.messageBodies.firstObject;
    
    switch ((int)msgBody.messageBodyType) {
        case eMessageBodyType_Text:
        {
            EMTextMessageBody *msgBody = message.messageBodies.firstObject;
            
            alertBody = [message.from stringByAppendingFormat:@":%@",msgBody.text];
            
        }
            
            break;
            
        case eMessageBodyType_Image:
        {
            
                alertBody = [message.from stringByAppendingFormat:@":[图片消息]"];
            
            
        }
            break;
        case eMessageBodyType_Voice:
            
             alertBody = [message.from stringByAppendingFormat:@":[语音消息]"];
            break;
    }

    
    
    //判断程序在后台的时候提示
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        
        UILocalNotification *noti = [UILocalNotification new];
        
        noti.alertBody = alertBody;
        noti.userInfo = @{@"from":message.from};
        //显示时间为当前时间
        noti.fireDate = [NSDate new];
        
        long currentCount = [UIApplication sharedApplication].applicationIconBadgeNumber;
        noti.applicationIconBadgeNumber = currentCount + 1;
        
        [[UIApplication sharedApplication]scheduleLocalNotification:noti];
        
        
        
        
    }
    
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"接收到消息通知" object:message];
    
    
}

#pragma mark 发送进度delegate
- (void)setProgress:(float)progress
         forMessage:(EMMessage *)message
     forMessageBody:(id<IEMMessageBody>)messageBody{
    
    NSLog(@"进度：%f",progress);
    
}

@end
