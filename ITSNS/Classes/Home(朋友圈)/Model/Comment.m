//
//  Comment.m
//  ITSNS
//
//  Created by tarena on 16/5/19.
//  Copyright © 2016年 Ivan. All rights reserved.
//

#import "FaceUtils.h"
#import "Comment.h"
#import "YYTextView.h"
static YYTextView *_commentTextView;
@implementation Comment

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.imagePaths = [NSMutableArray array];
    }
    return self;
}
-(Comment *)initWithBmobObject:(BmobObject *)bObj{
    self = [super init];
    if (self) {
        
        self.text = [bObj objectForKey:@"text"];
        self.imagePaths = [bObj objectForKey:@"imagePaths"];
        self.voicePath = [bObj objectForKey:@"voicePath"];
        self.bObj = bObj;
       
        
        
    }
    
    return self;
    
}






+(NSArray *)commentArrayFromBmobObjectArray:(NSArray *)array{
    
    NSMutableArray *itObjArray = [NSMutableArray array];
    for (BmobObject *bObj in array) {
        Comment *itObj = [[Comment alloc]initWithBmobObject:bObj];
        
        [itObjArray addObject:itObj];
    }
    return itObjArray;
}


-(NSString *)createTime{
    
    // 获得微博发布的具体时间
    NSDate *createDate = self.bObj.createdAt;
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
    
    
    //详情高度
    height+= [self getTextHeight];
    
    if (self.imagePaths.count>0) {
        height += [self getImageHeight]+LYMargin;
    }
    
    return height;
    
}

//showCount
-(float)getTextHeight{
    
    if (self.text.length==0) {
        return 0;
    }
    
    if (!_commentTextView) {
        _commentTextView = [[YYTextView alloc]initWithFrame:CGRectMake(LYMargin, 0, LYSW-LYMargin*2, 0)];
        _commentTextView.font = [UIFont systemFontOfSize:LYTextSize];
        [FaceUtils faceBindingWithTextView:_commentTextView];
    }
    
    _commentTextView.text = self.text;
    
    return _commentTextView.textLayout.textBoundingSize.height;
    
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




@end
