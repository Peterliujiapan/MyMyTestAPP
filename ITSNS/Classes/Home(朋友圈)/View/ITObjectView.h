//
//  LYQuestionAndProjectView.h
//  ITSNS
//
//  Created by Ivan on 16/3/6.
//  Copyright © 2016年 Ivan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TRITObject.h"
#import "YYTextView.h"
#import "ImageBrowserView.h"
@interface ITObjectView : UIView
@property (nonatomic, strong)TRITObject *itObj;

@property (nonatomic, strong)YYTextView *titleLabel;
@property (nonatomic, strong)YYTextView *detailTV;
@property (nonatomic, strong)ImageBrowserView *imageView;

@end
