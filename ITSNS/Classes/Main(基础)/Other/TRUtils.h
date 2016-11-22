//
//  TRUtils.h
//  ITSNS
//
//  Created by tarena on 16/7/6.
//  Copyright © 2016年 Ivan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TRUtils : NSObject

+(NSString *)parseTimeWithTimeStap:(float)timestap;

+(void)addScore:(int)score;

+(void)addUnreadWithObj:(BmobObject *)bObj andToUser:(BmobUser *)bUser;
@end
