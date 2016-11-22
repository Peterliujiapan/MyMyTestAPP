//
//  TRAnnotationView.m
//  ITSNS
//
//  Created by tarena on 16/7/1.
//  Copyright © 2016年 Ivan. All rights reserved.
//

#import "TRAnnotationView.h"

@implementation TRAnnotationView


- (instancetype)initWithAnnotation:(id<BMKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.image = [UIImage imageNamed:@"nearby_map_content"];
        self.bounds = CGRectMake(0, 0, 45, 50);
        
        
        
        self.headIV = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 35, 35)];
        
        
        [self addSubview:self.headIV];
    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
