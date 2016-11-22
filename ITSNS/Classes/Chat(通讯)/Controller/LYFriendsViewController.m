//
//  LYFriendsViewController.m
//  ITSNS
//
//  Created by Ivan on 16/1/10.
//  Copyright © 2016年 Ivan. All rights reserved.
//
#import "LYUserInfoViewController.h"
#import "LYUserCell.h"
#import "UIImageView+WebCache.h"
#import "TRReqeustsTableViewController.h"
#import "EaseMobManager.h"
#import "LYFriendsViewController.h"

@interface LYFriendsViewController ()<UITableViewDataSource ,UITableViewDelegate,UISearchResultsUpdating>
@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)NSMutableArray *friends;
@property (nonatomic, strong)NSArray *results;
@property (nonatomic, strong)UISearchController *searchController;
@end

@implementation LYFriendsViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    UITableView *tableView= [[UITableView alloc]initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    
    
    
    [self loadFirends];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loadFirends) name:@"新的好友通知" object:nil];
    
    [tableView registerNib:[UINib nibWithNibName:@"LYUserCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"cell"];
    
    
    self.searchController = [[UISearchController alloc]initWithSearchResultsController:nil];
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchResultsUpdater = self;
    
    self.tableView.tableHeaderView = self.searchController.searchBar;
    
}

-(void)loadFirends{
    
    
    //加载好友列表
    [[EaseMob sharedInstance].chatManager asyncFetchBuddyListWithCompletion:^(NSArray *buddyList, EMError *error) {
        if (!error) {
            NSLog(@"获取成功 -- %@",buddyList);
            
            //创建数组 添加好友名称
            NSMutableArray *names = [NSMutableArray array];
            for (EMBuddy *buddy in buddyList) {
                NSString *userName = buddy.username;
                
                [names addObject:userName];
            }
            
            BmobQuery *query = [BmobQuery queryForUser];
            //设置查询条件
            [query whereKey:@"username" containedIn:names];
            
            [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
                
                self.friends = [array mutableCopy];
                
                
                [self.tableView reloadData];
            }];
            
        }
    } onQueue:nil];
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    
    
    
    NSString *text = searchController.searchBar.text;
    
    self.results = nil;
    //如果没有内容就不搜索
    if (!text||text.length==0) {
        [self.tableView reloadData];
        return;
    }
    
    BmobQuery *query = [BmobQuery queryForUser];
    //设置模糊查询
    [query whereKey:@"nick" matchesWithRegex:text];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        
        self.results = array;
        [self.tableView reloadData];
    }];
    
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.searchController.isActive) {
        return 1;
    }
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    
    if (self.searchController.isActive) {
        return self.results.count;
    }
    
    if (section==0) {
        return 1;
    }
    
    return self.friends.count;
    
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    LYUserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    if (self.searchController.isActive) {
        
        cell.user = self.results[indexPath.row];
        
        
    }else{
        
        if (indexPath.section==0&&indexPath.row==0) {
            
            
            cell.nameLabel.text = @"好友请求";
            cell.detailLabel.text = [NSString stringWithFormat:@"%ld",[EaseMobManager shareManager].requests.count];
            cell.headIV.image = [UIImage imageNamed:@"icon"];
        }else{
            BmobUser *user = self.friends[indexPath.row];
            
            cell.user = user;
            
        }
        
        
    }
    return cell;
    
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if (self.searchController.isActive) {
        
        
        LYUserInfoViewController *vc = [LYUserInfoViewController new];
        vc.user = self.results[indexPath.row];
        [self.navigationController pushViewController:vc animated:YES];
        
    }else{
        if (indexPath.section==0) {//好友请求
            TRReqeustsTableViewController *vc = [TRReqeustsTableViewController new];
            
            [self.navigationController pushViewController:vc animated:YES];
        }else{
            
            LYUserInfoViewController *vc = [LYUserInfoViewController new];
            vc.user = self.friends[indexPath.row];
            [self.navigationController pushViewController:vc animated:YES];
            
        }
    }
}


-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if (self.searchController.isActive) {
        return NO;
    }else{
        //好友请求不能删
        if (indexPath.section==0) {
            return NO;
        }
        
        
    }
    
    return YES;
}

//删除好友
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //删除
        BmobUser *user = self.friends[indexPath.row];
        //服务器
        [[EaseMobManager shareManager]removeFirendWithName:user.username];
        //数据源
        [self.friends removeObject:user];
        //        界面
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        
        
    }
    
    
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 56;
}

@end
