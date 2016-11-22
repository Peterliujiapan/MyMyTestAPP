//
//  LYUserInfoViewController.m
//  ITSNS
//
//  Created by Ivan on 16/1/9.
//  Copyright © 2016年 Ivan. All rights reserved.
//
#import "EaseMobManager.h"
#import "TRChattingViewController.h"
#import "TRDetailViewController.h"
#import "LYHomeCell.h"
#import "LYUserInfoViewController.h"
#import "TRHeaderView.h"
#import "AddNameAndPicViewController.h"
@interface LYUserInfoViewController ()<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>
@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)NSArray *objs;
@end

@implementation LYUserInfoViewController


- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView = [[UITableView alloc]initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStylePlain];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    
    TRHeaderView *hv = [[[NSBundle mainBundle]loadNibNamed:@"TRHeaderView" owner:self options:nil] firstObject];
    [hv.addBtn addTarget:self action:@selector(addFirendAction:) forControlEvents:UIControlEventTouchUpInside];
    //显示的是自己的信息
    if ([[self.user objectForKey:@"username"] isEqualToString:[BmobUser getCurrentUser].username]) {//如果现实的是自己
        //添加修改按钮
        UIBarButtonItem *editItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editAction)];
        self.navigationItem.rightBarButtonItem = editItem;
        
        //如果是自己按钮失效
        hv.addBtn.enabled = NO;
        [hv.addBtn setBackgroundColor:[UIColor grayColor]];
        
    }else{//别人
        
        //加载好友列表
        [[EaseMob sharedInstance].chatManager asyncFetchBuddyListWithCompletion:^(NSArray *buddyList, EMError *error) {
            if (!error) {
               
                
             
                for (EMBuddy *buddy in buddyList) {
                    NSString *userName = buddy.username;
                    
                    if ([userName isEqualToString:self.user.username]) {
                        
                        //是好友
                        [hv.addBtn setTitle:@"聊天" forState:UIControlStateNormal];
                        hv.addBtn.titleLabel.font = [UIFont systemFontOfSize:15];
                        
                    }
                }
                
               
                
            }
        } onQueue:nil];
        
        
        
        
    }
    
 
    //把自定义控件添加到tableheaderView里
    self.tableView.tableHeaderView = hv;
    
    
    
    [self.tableView registerNib:[UINib nibWithNibName:@"LYHomeCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"cell"];

}



- (void)addFirendAction:(UIButton *)sender {
    
    
    if ([[sender titleForState:UIControlStateNormal] isEqualToString:@"+"]) {
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"提示" message:@"您确认要发出好友请求吗？" preferredStyle:UIAlertControllerStyleAlert];
        
        
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"发出请求" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            
            
            [[EaseMobManager shareManager]addFirendWithName:self.user.username];
            
            
        }];
        UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        
        [ac addAction:action1];
        [ac addAction:action2];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:ac animated:YES completion:nil];
    }else{//进入到聊天页面
        
        
        
        TRChattingViewController *vc = [TRChattingViewController new];
        vc.toUser = self.user;
        
        [self.navigationController pushViewController:vc animated:YES];
        
        
        
    }
    
    
    
}


-(void)editAction{
    AddNameAndPicViewController *vc = [AddNameAndPicViewController new];
    [self presentViewController:[[UINavigationController alloc]initWithRootViewController:vc] animated:YES completion:nil];
    
    
    
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    TRHeaderView *hv = (TRHeaderView *)self.tableView.tableHeaderView;
    
    hv.user = self.user;
    
    //显示的是自己的信息
    if ([[self.user objectForKey:@"username"] isEqualToString:[BmobUser getCurrentUser].username]) {
        hv.user = [BmobUser getCurrentUser];
    }
    
    [self.navigationController.navigationBar.subviews firstObject].hidden = YES;
    
    
    [self loadMessages];
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self.navigationController.navigationBar.subviews firstObject].hidden = NO;
    
    
}

- (void)loadMessages{
    BmobQuery *query = [BmobQuery queryWithClassName:@"ITSNSObject"];
    
    //查询时如果有某个字段是bmobObject类型 需要查询时设置包含
    [query includeKey:@"user"];
    
    //设置查询条件  type = 0；
    
    [query whereKey:@"type" equalTo:@"0"];
    
    
    
    //显示自己的信息
    [query whereKey:@"user" equalTo:self.user];
 
    
    [query orderByDescending:@"createdAt"];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //执行查询请求
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        NSMutableArray *itObjs = [NSMutableArray array];
        for (BmobObject *bObj in array) {
            TRITObject *itObj = [[TRITObject alloc]initWithBmobObj:bObj];
            [itObjs addObject:itObj];
            
        }
        
        
        self.objs = itObjs;
        [self.tableView reloadData];
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
    }];
    
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    
    return self.objs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    LYHomeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    
    cell.itObj = self.objs[indexPath.row];
    
    cell.headIV.userInteractionEnabled = cell.nameLabel.userInteractionEnabled  = NO;
    
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    TRITObject *itObj = self.objs[indexPath.row];
    
    return 60+[itObj getHeigth];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // 通过点击的位置得到cell
    LYHomeCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    
    
    
    
    TRITObject *itObj = self.objs[indexPath.row];
    
    //让浏览量增加1
    [itObj addShowCountWithCompletionBlock:^(id obj) {
        
        cell.itObj = obj;
    }];
    
    
    
    
    
    
    TRDetailViewController *vc = [TRDetailViewController new];
    
    vc.itObj = itObj;
    
    
    [self.navigationController pushViewController:vc animated:YES];
    
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
  
    TRHeaderView *hv = (TRHeaderView *)self.tableView.tableHeaderView;
    
    [hv updateSubViewsWithOffset:scrollView.contentOffset.y];
    
}

@end
