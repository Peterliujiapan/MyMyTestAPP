//
//  LYHomeViewController.m
//  ITSNS
//
//  Created by Ivan on 16/1/9.
//  Copyright © 2016年 Ivan. All rights reserved.
//
#import "SVPullToRefresh.h"
#import "TRDetailViewController.h"
#import "LYHomeViewController.h"
#import "AppDelegate.h"
#import "LYHomeCell.h"
#import "TRITObject.h"

@interface LYHomeViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong)NSMutableArray *objs;
@property (nonatomic, strong)UITableView *tableView;




@end

@implementation LYHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor grayColor];
    

    
    UITableView *tableView = [[UITableView alloc]initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStylePlain];
    
    [self.view addSubview:tableView];
    tableView.dataSource = self;
    tableView.delegate = self;
    self.tableView = tableView;
    
    tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    
    [tableView registerNib:[UINib nibWithNibName:@"LYHomeCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"cell"];
    
    [tableView addPullToRefreshWithActionHandler:^{
        [self loadMessagesWithSkipCount:0];
    }];
 
    //触发下拉刷新
     [tableView triggerPullToRefresh];
    
    
    //上拉加载
    
    [tableView addInfiniteScrollingWithActionHandler:^{
       
        
        [self loadMessagesWithSkipCount:self.objs.count];
        
        
        
    }];
    
}



-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    
    NSIndexPath *seletedIndexPath = [self.tableView indexPathForSelectedRow];
    
    
    if (seletedIndexPath) {
        //自己刷新数据
        //    LYHomeCell *cell = [self.tableView cellForRowAtIndexPath:seletedIndexPath];
        
        //    cell.itObj = self.objs[seletedIndexPath.row];
        
        //让tableView去刷新
        [self.tableView reloadRowsAtIndexPaths:@[seletedIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        //取消选中效果
        [self.tableView deselectRowAtIndexPath:seletedIndexPath animated:YES];
    }

    
    
}

- (void)loadMessagesWithSkipCount:(int)count{
    BmobQuery *query = [BmobQuery queryWithClassName:@"ITSNSObject"];
    
    //查询时如果有某个字段是bmobObject类型 需要查询时设置包含
    [query includeKey:@"user"];
    
    //设置查询条件  type = 0；
    
    [query whereKey:@"type" equalTo:self.type];
    
    //设置请求数量为20
    query.limit = 20;
    
    //设置跳过的消息数量
    query.skip = count;
  
    
    //判断是否显示自己的信息
    if (self.showSelfInfo) {
        [query whereKey:@"user" equalTo:[BmobUser getCurrentUser]];
    }
    
    [query orderByDescending:@"createdAt"];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //执行查询请求
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        NSMutableArray *itObjs = [NSMutableArray array];
        for (BmobObject *bObj in array) {
            TRITObject *itObj = [[TRITObject alloc]initWithBmobObj:bObj];
            [itObjs addObject:itObj];
        }
        //请求第一页数据
        if (query.skip==0) {
            self.objs = itObjs;
        }else{//不是第一页
            [self.objs addObjectsFromArray:itObjs];
            
        }
        
        
        [self.tableView reloadData];
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if (self.tableView.pullToRefreshView.state == SVPullToRefreshStateLoading) {
            //结束刷新动画
            [self.tableView.pullToRefreshView stopAnimating];
        }
      
        if (self.tableView.infiniteScrollingView.state == SVPullToRefreshStateLoading) {
            //结束上拉加载动画
            [self.tableView.infiniteScrollingView stopAnimating];
        }
        
        
    }];
    
    
//大写转小写
//    NSString *s = @"ABc";
//    s = [s lowercaseString];
//    NSLog(@"%@",s);

}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return self.objs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    LYHomeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
   
    
    cell.itObj = self.objs[indexPath.row];
  
    
 
    
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

@end
