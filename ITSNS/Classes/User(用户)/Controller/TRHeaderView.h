//
//  TRHeaderView.h
//  ITSNS
//
//  Created by tarena on 16/6/30.
//  Copyright © 2016年 Ivan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TRHeaderView : UIView
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UILabel *friendCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *headIV;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;
@property (weak, nonatomic) IBOutlet UILabel *nickLabel;
@property (weak, nonatomic) IBOutlet UIImageView *coverIV;

@property (nonatomic, strong)BmobUser *user;

-(void)updateSubViewsWithOffset:(float)offset;

@end
