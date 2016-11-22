//
//  LYTopScoreUserCell.m
//  ITSNS
//
//  Created by Ivan on 16/1/22.
//  Copyright © 2016年 Ivan. All rights reserved.
//
#import "UIImageView+WebCache.h"
#import "LYTopScoreUserCell.h"
#import "TRUtils.h"
@implementation LYTopScoreUserCell
-(void)awakeFromNib{
    self.scoreLabel.layer.cornerRadius = 4;
    self.scoreLabel.layer.masksToBounds = YES;
}
- (void)setUser:(BmobUser *)user{
    _user = user;
    self.nameLabel.text = [user objectForKey:@"nick"];
    self.scoreLabel.text = [[user objectForKey:@"score"] stringValue];
    self.timeLabel.text = [TRUtils parseTimeWithTimeStap:user.createdAt.timeIntervalSince1970];
    
    
    
    
    [self.headIV sd_setImageWithURL:[NSURL URLWithString: [user objectForKey:@"headPath"]]];
    
    
}

@end
