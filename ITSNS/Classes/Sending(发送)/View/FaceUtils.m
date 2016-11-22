//
//  FaceUtils.m
//  表情键盘
//
//  Created by tarena on 16/6/20.
//  Copyright © 2016年 Tarena. All rights reserved.
//

#import "FaceUtils.h"

@implementation FaceUtils
+(void)faceBindingWithTextView:(YYTextView *)tv{
    
    
    //如何在文本中显示表情
    YYTextSimpleEmoticonParser *parser = [[YYTextSimpleEmoticonParser alloc]init];
    
 
    
    NSString *path = [[NSBundle mainBundle]pathForResource:@"default" ofType:@"plist"];
    
    NSArray *faceArr = [NSArray arrayWithContentsOfFile:path];
    NSMutableDictionary *emoticonMapper = [NSMutableDictionary dictionary];
    
    for (NSDictionary *faceDic in faceArr) {
        NSString *text = faceDic[@"chs"];
        NSString *imageName = faceDic[@"png"];
        
        [emoticonMapper setObject:[UIImage imageNamed:imageName] forKey:text];
    }
    
    
    parser.emoticonMapper = emoticonMapper;
    
    tv.textParser = parser;

    
    
}
@end
