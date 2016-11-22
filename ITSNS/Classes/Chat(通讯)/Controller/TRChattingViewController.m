//
//  TRChattingViewController.m
//  ITSNS
//
//  Created by tarena on 16/7/5.
//  Copyright © 2016年 Ivan. All rights reserved.
//
#import "TRVoicePlayer.h"
#import "RecordButton.h"
#import "TRChattingViewController.h"
#import "FaceView.h"
#import "FaceUtils.h"
#import "YYTextView.h"
#import "EaseMobManager.h"
#import "TRMessageCell.h"
@interface TRChattingViewController ()
<UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *commentBarView;
@property (nonatomic, strong)YYTextView *commentTV;
@property (nonatomic, strong)NSMutableArray *messages;

@property (nonatomic, strong)NSArray *comments;



@property (nonatomic, strong)FaceView *faceView;
//********多选图片相关
//@property (nonatomic, strong)UIScrollView *selectedImageSV;
@property (weak, nonatomic) IBOutlet UILabel *imageCountLabel;


@property (nonatomic, strong)UIScrollView *pickerSV;
@property (nonatomic, strong)UIButton *addImageButton;
@property (nonatomic, strong)NSMutableArray *selectedImageViews;

//录音相关
@property (nonatomic, strong)UIView *recordView;
@property (nonatomic, copy)NSString *voicePath;
@property (nonatomic, strong)UILabel *timeLabel;

@end

@implementation TRChattingViewController


- (IBAction)sendAction:(id)sender {
    
    
  EMMessage *message =  [[EaseMobManager shareManager]sendMessageWithText:self.commentTV.text andToName:self.toUser.username];
    
    [self.messages addObject:message];
    [self.tableView reloadData];
    
    [self showLastMessage];
}
- (IBAction)clicked:(UIButton *)sender {
    
    
    
    switch (sender.tag) {
        case 0://图片
            
            
//            self.commentTV.inputView = self.commentTV.inputView ? nil : self.selectedImageSV;
//            [self.commentTV reloadInputViews];
            //如果一张图片都没选 直接去选择图片
//            if (self.selectedImageViews.count==0) {
        {
            //每次选择图片前清空数组
            [self.selectedImageViews removeAllObjects];
            
            
            UIImagePickerController *pick=[UIImagePickerController new];
                pick.delegate=self;
                [self presentViewController:pick animated:YES completion:nil];
            }
            break;
        case 1://表情
            self.commentTV.inputView = self.commentTV.inputView ? nil : self.faceView;
            
            [self.commentTV reloadInputViews];
            break;
            
        case 2://录音
            self.commentTV.inputView = self.commentTV.inputView  ? nil : self.recordView;
            [self.commentTV reloadInputViews];
            break;
            
        default:
            break;
    }
    
}

-(UIView *)recordView{
    if (!_recordView) {
        _recordView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, LYSW, 216)];
        RecordButton *rb = [[RecordButton alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
        [_recordView addSubview:rb];
        rb.center = CGPointMake(LYSW/2.0, 216/2.0);
        
      
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recordFinishAction:) name:@"RecordDidFinishNotification" object:nil];
        
    }
    return _recordView;
}


-(void)recordFinishAction:(NSNotification *)noti{
    
    //显示得到录音时长
    float time = [noti.object[@"time"] floatValue];
 
    
    
    
    //得到录好的音频数据
    NSData *audioData = noti.object[@"data"];
    
   EMMessage *message = [[EaseMobManager shareManager]sendMessageWithVoiceData:audioData andTime:@(time) andToName:self.toUser.username];
    [self.messages addObject:message];
    [self.tableView reloadData];
    [self showLastMessage];
}


//-(UIScrollView *)selectedImageSV{
//    if (!_selectedImageSV) {
//        _selectedImageSV=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, LYSW, 216)];
//        self.addImageButton=[[UIButton alloc]initWithFrame:CGRectMake(20, 30, 100, 140)];
//        [self.addImageButton setImage:[UIImage imageNamed:@"1.png"] forState:UIControlStateNormal];
//        [self.selectedImageSV addSubview:self.addImageButton];
//        [self.addImageButton addTarget:self action:@selector(addImageAction) forControlEvents:UIControlEventTouchUpInside];
//    }
//    return _selectedImageSV;
//}
-(void)addImageAction
{
    if (self.selectedImageViews.count<9) {
        UIImagePickerController *pick=[UIImagePickerController new];
        pick.delegate=self;
        [self presentViewController:pick animated:YES completion:nil];
    }
}


-(FaceView *)faceView{
    
    if (_faceView==nil) {
        _faceView = [[FaceView alloc]initWithFrame:CGRectMake(0, 0, LYSW, 216)];
    }
    
    return _faceView;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [self.toUser objectForKey:@"nick"];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.selectedImageViews = [NSMutableArray array];
    self.commentTV = [[YYTextView alloc]initWithFrame:CGRectMake(106, 5, 215, 31)];
    
    self.commentTV.backgroundColor = LYGrayColor;
    [self.commentBarView addSubview:self.commentTV];
    [FaceUtils faceBindingWithTextView:self.commentTV];
    
    
    //监听键盘事件
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardFrameChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    //监听表情按钮的通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(faceBtnAction:) name:@"FaceNotification" object:nil];
    
    
    self.messages = [NSMutableArray array];
    
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TRMessageCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"cell"];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didReceiveMessageAction:) name:@"接收到消息通知" object:nil];
    
    
    
    
    //得到当前会话 并取出所有的message记录
    
    EMConversation *conversation = [[EaseMob sharedInstance].chatManager conversationForChatter:self.toUser.username conversationType:eConversationTypeChat];
    
    NSArray *historyMessages = [conversation loadAllMessages];
    
    [self.messages addObjectsFromArray:historyMessages];
    
    
}

//接收到好友发送的消息
-(void)didReceiveMessageAction:(NSNotification *)noti{
    
    EMMessage *message = noti.object;
    
    //判断好友是否是当前页面的的好友
    if ([message.from isEqualToString:self.toUser.username]) {
        [self.messages addObject:message];
        
        [self.tableView reloadData];
        [self showLastMessage];
    }
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
      [self showLastMessage];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    
  
  
    
  
    
}
//点击表情按钮时监听事件
-(void)faceBtnAction:(NSNotification *)noti{
    NSString *text = noti.object;
    
    [self.commentTV insertText:text];
    
    
}


-(void)keyboardFrameChange:(NSNotification*)noti{
    CGFloat duration = [noti.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    // 2.动画
    [UIView animateWithDuration:duration animations:^{
        // 取出键盘高度
        CGRect keyboardF = [noti.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        CGFloat keyboardH = keyboardF.size.height;
        
        //判断软键盘是否弹出
        if (keyboardF.origin.y==LYSH) {//收键盘
            self.commentBarView.transform = CGAffineTransformIdentity;
             self.tableView.height = LYSH-44-64;
        }else{//软件盘弹出的时候 把表情隐藏
            self.commentBarView.transform = CGAffineTransformMakeTranslation(0, -keyboardH);
            self.tableView.height = LYSH-44-keyboardH-64;
            
            
            
        }
        
        
        [self showLastMessage];
        
    }];
    
}

-(void)showLastMessage{
    
    if (self.messages.count>0) {
        
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messages.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
    
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    [self.commentTV resignFirstResponder];
    
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.messages.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TRMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.toUser = self.toUser;
    cell.message = self.messages[indexPath.row];
    
    
    
    
    
    EMMessage *message = self.messages[indexPath.row];
    
    //判断时间是不是1分钟以内的
    if (indexPath.row>0) {
        EMMessage *preMessage = self.messages[indexPath.row-1];
        
        float time = message.timestamp-preMessage.timestamp;
    
        if (time<60000) {
            [cell hideTimeLabel:YES];
        }else [cell hideTimeLabel:NO];
        
    }
    
    
    
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    EMMessage *message = self.messages[indexPath.row];
    
    
    id<IEMMessageBody> msgBody = message.messageBodies.firstObject;
    
    self.timeLabel.text = @(message.timestamp).stringValue;
    
    //默认是有显示时间的位置
    float height = 20;
    
    
    //判断时间是不是1分钟以内的
    if (indexPath.row>0) {
         EMMessage *preMessage = self.messages[indexPath.row-1];
        
        float time = message.timestamp-preMessage.timestamp;
  
        if (time<60000) {
            height = 0;
        }
        
    }
   
    
    
    
    switch ((int)msgBody.messageBodyType) {
        case eMessageBodyType_Text:
        {
            EMTextMessageBody *msgBody = message.messageBodies.firstObject;
            
            
            //计算文本高度
            YYTextView *tv = [[YYTextView alloc]initWithFrame:CGRectMake(0, 0, 250, 0)];
            
            tv.text = msgBody.text;
            
            height +=  tv.textLayout.textBoundingSize.height+30;
            
            
            
        }
            
            break;
            
        case eMessageBodyType_Image:
        {
            
            
            height+=100+30;
            
            
        }
            break;
        case eMessageBodyType_Voice:
            
            height+=75;
            break;
    }
    
    return height;
    
    
    
    
   
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    EMMessage *message = self.messages[indexPath.row];
    
    
    id<IEMMessageBody> msgBody = message.messageBodies.firstObject;
   
    
    
 
    
    
    
    
    switch ((int)msgBody.messageBodyType) {
        case eMessageBodyType_Text:
        {
            
            
        }
            
            break;
            
        case eMessageBodyType_Image:
        {
            
            
           
            
            
        }
            break;
        case eMessageBodyType_Voice:
            
        {
         
            TRMessageCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            [cell.voiceView beginAnimation];
            
            //得到录音的data
            EMVoiceMessageBody *body = [message.messageBodies firstObject];
            
            if ([message.from isEqualToString:[BmobUser getCurrentUser].username]) {//自己
                
                [TRVoicePlayer playWithLocalVoicePath:body.localPath];
                
            }else{
               [TRVoicePlayer playWithLocalVoicePath:body.remotePath];
            }
            
            
        }
            
            
            
            break;
    }
    
    
}

#pragma mark 多选图片相关
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    
    
    UIImageView *iv=[[UIImageView alloc]initWithFrame:CGRectMake(self.selectedImageViews.count*80, 0, 80, 80)];
    iv.image=info[UIImagePickerControllerOriginalImage];
    [self.pickerSV addSubview:iv];
    iv.userInteractionEnabled=YES;
    [self.selectedImageViews addObject:iv];
    self.pickerSV.contentSize=CGSizeMake(self.selectedImageViews.count*80, 0);
    UIButton *delBtn =[[UIButton alloc]initWithFrame:CGRectMake(60, 0, 20, 20)];
    [delBtn addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
    [delBtn setTitle:@"X" forState:UIControlStateNormal];
    [delBtn setTitleColor:LYGreenColor forState:UIControlStateNormal];
    [iv addSubview:delBtn];
    if(self.selectedImageViews.count==9)
    {
        [self doneAction];
        
    }
    
    
    
    
    
}
-(void)deleteAction:(UIButton *)btn
{
    [self.selectedImageViews removeObject:btn.superview];
    [btn.superview removeFromSuperview];
    for(int i=0;i<self.selectedImageViews.count;i++)
    {
        UIImageView *iv=self.selectedImageViews[i];
        [UIView animateWithDuration:0.5 animations:^{
            iv.frame=CGRectMake(i*80, 0, 80, 80);
        }];
    }
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    
    
    
    if(navigationController.viewControllers.count==2)
    {
        UIView *v=[[UIView alloc]initWithFrame:CGRectMake(0, 567, 375, 100)];
        [viewController.view addSubview:v];
        self.pickerSV=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 20, 375, 80)];
        self.pickerSV.backgroundColor=LYGrayColor;
        [v addSubview:self.pickerSV];
        UIButton *doneBtn=[[UIButton alloc]initWithFrame:CGRectMake(335, 0, 40, 20)];
        [doneBtn setTitle:@"发送" forState:UIControlStateNormal];
        doneBtn.backgroundColor=[UIColor grayColor];
        [v addSubview:doneBtn];
        [doneBtn addTarget:self action:@selector(doneAction) forControlEvents:UIControlEventTouchUpInside];
        
        //把之前选择的图片添加进去
        for(int i=0;i<self.selectedImageViews.count;i++)
        {
            UIImageView *iv=self.selectedImageViews[i];
            
            iv.frame=CGRectMake(i*80, 0, 80, 80);
            UIButton *delBtn = [iv.subviews firstObject];
            [delBtn addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
            [self.pickerSV addSubview:iv];
        }
    }
}
-(void)doneAction
{
    [self dismissViewControllerAnimated:YES completion:^{
        for (UIImageView *iv in self.selectedImageViews) {
            EMMessage *message =  [[EaseMobManager shareManager]sendMessageWithImage:iv.image andToName:self.toUser.username];
            [self.messages addObject:message];
            
        }
        [self.tableView reloadData];
        
        [self showLastMessage];
    }];
    
    
    
    
   
}

//-(void)svdeleteaction:(UIButton *)btn
//{
//    [self.selectedImageViews removeObject:btn.superview];
//    [btn.superview removeFromSuperview];
//    for (int i=0; i<self.selectedImageViews.count; i++) {
//        UIImageView *iv=self.selectedImageViews[i];
//        [UIView animateWithDuration:0.5 animations:^{
//            iv.frame=CGRectMake(20+i*120, 30, 100, 140);
//            
//        }];
//        
//    }
//    
//    self.selectedImageSV.contentSize = CGSizeMake(20+(self.selectedImageViews.count+1)*120, 0);
//    [UIView animateWithDuration:0.5 animations:^{
//        self.addImageButton.center=CGPointMake(20+self.selectedImageViews.count*120+50, self.addImageButton.center.y);
//    }];
//    [self updateImageCountLabel];
//}
-(void)updateImageCountLabel{
    
    self.imageCountLabel.hidden = self.selectedImageViews.count==0?YES:NO;
    
    self.imageCountLabel.text = @(self.selectedImageViews.count).stringValue;
    
}

@end
