//
//  Comment.h
//  ITSNS
//
//  Created by tarena on 16/5/19.
//  Copyright © 2016年 Ivan. All rights reserved.
//
#import "TRITObject.h"
#import <Foundation/Foundation.h>
typedef void (^MyCallback)(id obj);
@interface Comment : NSObject

@property (nonatomic, copy)NSString *   text;

@property (nonatomic, copy)NSString *   voicePath;
@property (nonatomic, strong)TRITObject *itObj;


@property (nonatomic, strong)BmobObject *bObj;
@property (nonatomic, strong)NSMutableArray *   imagePaths;


-(Comment *)initWithBmobObject:(BmobObject *)bObj;



//传递进来一个bmob对象数组 返回 ITObj数组
+(NSArray *)commentArrayFromBmobObjectArray:(NSArray *)array;


-(NSString *)createTime;


-(float)getTextHeight;
-(float)getImageHeight;
-(float)getHeigth;
@end
