//
//  TRReqeustsTableViewController.m
//  ITSNS
//
//  Created by tarena on 16/7/4.
//  Copyright © 2016年 Ivan. All rights reserved.
//
#import "UIImageView+WebCache.h"
#import "TRReqeustsTableViewController.h"
#import "EaseMobManager.h"
#import "LYUserCell.h"
@interface TRReqeustsTableViewController ()
@property (nonatomic, strong)NSMutableArray *requestUsers;
@end

@implementation TRReqeustsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.tableView registerNib:[UINib nibWithNibName:@"LYUserCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"cell"];
    
    
    
    
   
    
    BmobQuery *query = [BmobQuery queryForUser];
    //设置查询条件
    [query whereKey:@"username" containedIn:[EaseMobManager shareManager].requests];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        
        self.requestUsers = [array mutableCopy];
        
        
        [self.tableView reloadData];
    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
 
    
    return self.requestUsers.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LYUserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    BmobUser *user = self.requestUsers[indexPath.row];
    
    cell.user = user;
    
    
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 56;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *username = [EaseMobManager shareManager].requests[indexPath.row];
    
    
    NSString *myMessage = [NSString stringWithFormat:@"%@请求加您为好友",username];
    
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"提示" message:myMessage preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"接受" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        EMError *error = nil;
        BOOL isSuccess = [[EaseMob sharedInstance].chatManager acceptBuddyRequest:username error:&error];
        if (isSuccess && !error) {
            NSLog(@"发送同意成功");
            [[EaseMobManager shareManager].requests removeObject:username];
            [self.requestUsers removeObjectAtIndex:indexPath.row];
            
            
            
            [self.tableView reloadData];
            
            [[NSNotificationCenter defaultCenter]postNotificationName:@"新的好友通知" object:nil];
            
            
            //更新本地好友
            [[EaseMobManager shareManager]updateLocalFirends];
            
        }
        
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"拒绝" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        EMError *error = nil;
        BOOL isSuccess = [[EaseMob sharedInstance].chatManager rejectBuddyRequest:username  reason:@"太丑" error:&error];
        if (isSuccess && !error) {
            NSLog(@"发送拒绝成功");
            [[EaseMobManager shareManager].requests removeObject:username];
            [self.requestUsers removeObjectAtIndex:indexPath.row];
            
            
            
            [self.tableView reloadData];
        }
    }];
    
    [ac addAction:action1];
    [ac addAction:action2];
    
    
    
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:ac animated:YES completion:nil];

  
    
}

@end
