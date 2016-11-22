//
//  TRUtils.m
//  ITSNS
//
//  Created by tarena on 16/7/6.
//  Copyright © 2016年 Ivan. All rights reserved.
//

#import "TRUtils.h"

@implementation TRUtils
+(NSString *)parseTimeWithTimeStap:(float)timestap{
    
    timestap/=1000;
    
    NSDate *createDate = [NSDate dateWithTimeIntervalSince1970:timestap];
   
    //获取当前时间对象
    NSDate *nowDate = [NSDate date];
 
    long nowTime = [nowDate timeIntervalSince1970];
    long time = nowTime-timestap;
    if (time<60) {
        return @"刚刚";
    }else if (time<3600){
        return [NSString stringWithFormat:@"%ld分钟前",time/60];
    }else if (time<3600*24){
        return [NSString stringWithFormat:@"%ld小时前",time/3600];
    }else{
        NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
        fmt.dateFormat = @"MM月dd日 HH:mm";
        return [fmt stringFromDate:createDate];
    }
    

    
    
    
    
    
}

+(void)addScore:(int)score{
    
    BmobUser *user = [BmobUser getCurrentUser];
    
    [user incrementKey:@"score" byAmount:score];
    
    
    [user updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        if (isSuccessful) {
            NSLog(@"添加积分成功！");
        }
    }];
    
    
    
    
}

+(void)addUnreadWithObj:(BmobObject *)bObj andToUser:(BmobUser *)bUser{
    
    BmobQuery *query = [BmobQuery queryWithClassName:@"UnRead"];
    //查询指定消息 是否有未读
    [query whereKey:@"itObj" equalTo:bObj];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
       
        if (array.count>0) {
            BmobObject *unReadObj = [array firstObject];
            //让未读次数+1
            [unReadObj incrementKey:@"unreadCount"];
            
            [unReadObj updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
                if (isSuccessful) {
                    NSLog(@"有未读+1");
                }
            }];
            
        }else{//如果没有未读
            
            BmobObject *unReadObj = [BmobObject objectWithClassName:@"UnRead"];
            //设置评论的谁
            [unReadObj setObject:bUser forKey:@"toUser"];
            //设置未读数量
            [unReadObj setObject:@(1) forKey:@"unreadCount"];
            //设置评论的消息
            [unReadObj setObject:bObj forKey:@"itObj"];
            
            
            [unReadObj saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
                if (isSuccessful) {
                    NSLog(@"插入一个新的未读数据");
                }
            }];
        }
    }];
    
    
    
    
    
}
@end
