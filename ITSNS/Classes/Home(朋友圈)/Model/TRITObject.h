//
//  TRITObject.h
//  ITSNS
//
//  Created by tarena on 16/6/28.
//  Copyright © 2016年 Ivan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
typedef void (^MyCallback)(id obj);
@interface TRITObject : NSObject

@property (nonatomic)CLLocationCoordinate2D coord;
@property (nonatomic, strong)NSNumber *showCount;
@property (nonatomic, strong)NSNumber *commentCount;
@property (nonatomic, copy)NSString *title;
@property (nonatomic, copy)NSString *detail;
@property (nonatomic, strong)NSArray *imagePaths;
@property (nonatomic, copy)NSString *voicePath;
@property (nonatomic, strong)BmobUser *user;
@property (nonatomic, strong)NSDate *createAt;

@property (nonatomic, strong)BmobObject *bObj;


-(instancetype)initWithBmobObj:(BmobObject *)bObj;

-(NSString *)createTime;
-(float)getHeigth;
-(float)getImageHeight;
-(float)getDetailHeight;



-(void)addShowCountWithCompletionBlock:(MyCallback)callback;

-(void)addCommentCountWithCompletionBlock:(MyCallback)callback;
@end
