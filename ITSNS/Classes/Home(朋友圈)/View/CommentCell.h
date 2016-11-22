//
//  CommentCell.h
//  ITSNS
//
//  Created by tarena on 16/5/19.
//  Copyright © 2016年 Ivan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Comment.h"
#import "CommentView.h"
@interface CommentCell : UITableViewCell
@property (nonatomic, strong)CommentView *commentView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *headIV;
@property (weak, nonatomic) IBOutlet UIButton *audioBtn;
@property (nonatomic, strong)Comment *comment;
@end
