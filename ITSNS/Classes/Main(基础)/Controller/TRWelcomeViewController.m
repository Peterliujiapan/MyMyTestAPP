//
//  TRWelcomeViewController.m
//  ITSNS
//
//  Created by tarena on 16/7/7.
//  Copyright © 2016年 Ivan. All rights reserved.
//

#import "TRWelcomeViewController.h"
#import "LYWelcomeViewController.h"
@interface TRWelcomeViewController ()

@end

@implementation TRWelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor redColor];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    LYWelcomeViewController *vc = [LYWelcomeViewController new];
    
    
    [UIApplication sharedApplication].keyWindow.rootViewController = [[UINavigationController alloc]initWithRootViewController:vc];
    
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
