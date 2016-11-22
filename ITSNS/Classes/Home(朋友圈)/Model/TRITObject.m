//
//  TRITObject.m
//  ITSNS
//
//  Created by tarena on 16/6/28.
//  Copyright © 2016年 Ivan. All rights reserved.
//
#import "FaceUtils.h"
#import "TRITObject.h"
#import "YYTextView.h"
@implementation TRITObject

static YYTextView *_textView;

- (instancetype)initWithBmobObj:(BmobObject *)bObj
{
    self = [super init];
    if (self) {
        self.bObj = bObj;
        self.showCount = [bObj objectForKey:@"showCount"];
        self.commentCount = [bObj objectForKey:@"commentCount"];
        
        //解析位置信息
        BmobGeoPoint *point = [bObj objectForKey:@"location"];
        
        if (point) {
            self.coord = CLLocationCoordinate2DMake(point.latitude, point.longitude);
        }
        
        self.title = [bObj objectForKey:@"title"];
        self.detail = [bObj objectForKey:@"detail"];
        self.imagePaths = [bObj objectForKey:@"imagePaths"];
        self.voicePath = [bObj objectForKey:@"voicePath"];
        self.user = [bObj objectForKey:@"user"];
        self.createAt = bObj.createdAt;
    }
    return self;
}

-(NSString *)createTime{
    
    // 获得微博发布的具体时间
    NSDate *createDate = self.createAt;
    //获取当前时间对象
    NSDate *nowDate = [NSDate date];
    long createTime = [createDate timeIntervalSince1970];
    long nowTime = [nowDate timeIntervalSince1970];
    long time = nowTime-createTime;
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



-(float)getHeigth{
    
    float height = LYMargin;
    //title高度
    if (self.title.length>0) {
        height+=30;
    }
    
    //详情高度
    height+= [self getDetailHeight];
    
    if (self.imagePaths.count>0) {
        height += [self getImageHeight]+2*LYMargin;
    }
    
    return height;
    
}
-(float)getDetailHeight{
    
    if (self.detail.length==0) {
        return 0;
    }
    if (!_textView) {
        _textView = [[YYTextView alloc]initWithFrame:CGRectMake(LYMargin, 0, LYSW-LYMargin*2, 0)];
        _textView.font = [UIFont systemFontOfSize:LYTextSize];
        [FaceUtils faceBindingWithTextView:_textView];
    }
    
    _textView.text = self.detail;
    
    return _textView.textLayout.textBoundingSize.height;
    
}

-(float)getImageHeight{
    long count = self.imagePaths.count;
    if (count==1) {
        return LYImageSize*2;
    }else if (count>1&&count<=3){
        return LYImageSize;
    }else if (count>3&&count<=6){
        return LYImageSize*2+LYMargin;
    }else if (count>6&&count<=9){
        return LYImageSize*3+2*LYMargin;
    }
    
    return 0;
    
    
}

-(void)addShowCountWithCompletionBlock:(MyCallback)callback{
    
//    [self.bObj setObject:@(self.showCount.intValue + 1) forKey:@"showCount"];
    //让showCount的值递增1
    [self.bObj incrementKey:@"showCount" ];
//    @""   @(3)   bObj
    
    
    //更新数据时 对象类型的字段 需要重新赋值
    [self.bObj setObject:self.user forKey:@"user"];
  
    
    [self.bObj updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
      
        if (isSuccessful) {
            NSLog(@"浏览量增加");
            
            self.showCount = @(self.showCount.intValue + 1);
            
            //让controller响应
            callback(self);
            
            
        }
    }];
    
}

-(void)addCommentCountWithCompletionBlock:(MyCallback)callback{
    
 
    //让showCount的值递增1
    [self.bObj incrementKey:@"commentCount" ];
    //    @""   @(3)   bObj
    
    
    //更新数据时 对象类型的字段 需要重新赋值
    [self.bObj setObject:self.user forKey:@"user"];
    
    
    [self.bObj updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        
        if (isSuccessful) {
            NSLog(@"评论量增加");
            
            self.commentCount = @(self.commentCount.intValue + 1);
            
            //让controller响应
            callback(self);
            
            
        }
    }];
    
}
@end
