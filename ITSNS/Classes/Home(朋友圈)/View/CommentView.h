//
//  CommentView.h
//  ITSNS
//
//  Created by tarena on 16/5/19.
//  Copyright © 2016年 Ivan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageBrowserView.h"
#import "YYTextView.h"
#import "Comment.h"
@interface CommentView : UIView
@property (nonatomic, strong)YYTextView *textView;
@property (nonatomic, strong)ImageBrowserView *imageView;
@property (nonatomic, strong)Comment *comment;
@end
