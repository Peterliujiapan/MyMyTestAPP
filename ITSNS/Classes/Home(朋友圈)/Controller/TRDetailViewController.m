//
//  TRDetailViewController.m
//  ITSNS
//
//  Created by tarena on 16/6/29.
//  Copyright © 2016年 Ivan. All rights reserved.
//
#import "TRVoicePlayer.h"
#import "Comment.h"
#import "CommentCell.h"
#import "FaceView.h"
#import "FaceUtils.h"
#import "RecordButton.h"
#import "TRDetailViewController.h"
#import "TRITObject.h"
#import "ITObjectView.h"
#import <AVFoundation/AVFoundation.h>
#import "TRUtils.h"
@interface TRDetailViewController ()<UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, strong)AVAudioPlayer *player;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *commentBarView;
@property (nonatomic, strong)YYTextView *commentTV;

@property (nonatomic, strong)NSArray *comments;



@property (nonatomic, strong)FaceView *faceView;
//********多选图片相关
@property (nonatomic, strong)UIScrollView *selectedImageSV;
@property (weak, nonatomic) IBOutlet UILabel *imageCountLabel;


@property (nonatomic, strong)UIScrollView *pickerSV;
@property (nonatomic, strong)UIButton *addImageButton;
@property (nonatomic, strong)NSMutableArray *selectedImageViews;

//录音相关
@property (nonatomic, strong)UIView *recordView;
@property (nonatomic, copy)NSString *voicePath;
@property (nonatomic, strong)UILabel *timeLabel;


@end

@implementation TRDetailViewController
- (IBAction)sendAction:(id)sender {
    
    
    BmobObject *bObj = [BmobObject objectWithClassName:@"Comment"];
    //设置文本
    [bObj setObject:self.commentTV.text forKey:@"text"];
    
    //设置音频
    if (self.voicePath) {
        [bObj setObject:self.voicePath forKey:@"voicePath"];
    }
    
    //谁发送的
    [bObj setObject:[BmobUser getCurrentUser] forKey:@"user"];
    
    
    
    //评论的哪一条消息
    [bObj setObject:self.itObj.bObj forKey:@"source"];
    
//    设置图片
    if (self.selectedImageViews.count>0) {
        
        
        NSMutableArray *imageArr = [NSMutableArray array];
        
        for (int i=0; i<self.selectedImageViews.count; i++) {
            UIImageView *iv = self.selectedImageViews[i];
            
            NSData *imageData = UIImageJPEGRepresentation(iv.image, .5);
            
            [imageArr addObject:@{@"data":imageData,@"filename":[NSString stringWithFormat:@"%d.jpg",i]}];
        }
        
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeAnnularDeterminate;
        hud.labelText = @"Loading。。。";
        //开始上传文件
        [BmobFile filesUploadBatchWithDataArray:imageArr progressBlock:^(int index, float progress) {
            hud.labelText = [NSString stringWithFormat:@"%d/%ld",index+1,self.selectedImageViews.count];
            hud.progress = progress;
            
            NSLog(@"%f",progress);
        } resultBlock:^(NSArray *array, BOOL isSuccessful, NSError *error) {
            [hud hide:YES];
            
            if (isSuccessful) {
                NSMutableArray *imagePaths = [NSMutableArray array];
                
                for (BmobFile *file in array) {
                    [imagePaths addObject:file.url];
                }
                
                //把图片数组添加到评论对象中
                [bObj setObject:imagePaths forKey:@"imagePaths"];
                
                [bObj saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
                    if (isSuccessful) {
                        
                        
                        
                        
                       [self commentSuccessAction];
                    }else{
                        NSLog(@"保存失败：%@",error);
                    }
                }];
                
                
            }else{
                NSLog(@"上传图片失败");
            }
        }];

        
        
        
        
    }else{
        
        [bObj saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
           
            if (isSuccessful) {
                
                [self commentSuccessAction];
                
            }
            
            
        }];
        
        
        
        
    }
    
    
    
}

- (void)loadComments{
    
    BmobQuery *query = [BmobQuery queryWithClassName:@"Comment"];
    
    //设置查询条件
    [query whereKey:@"source" equalTo:self.itObj.bObj];
    
    //user 设置返回数据包含user字段
    [query includeKey:@"user"];
    
    //设置时间倒序
    [query orderByDescending:@"createdAt"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        
        //把BmobObject数组转成自定义的Comment对象数组
        self.comments = [Comment commentArrayFromBmobObjectArray:array];
        
        [self.tableView reloadData];
        
    }];
    
}

-(void)commentSuccessAction{
    
    //Score + 1
    [TRUtils addScore:1];
    
    //在未读表里添加数据
    [TRUtils addUnreadWithObj:self.itObj.bObj andToUser:self.itObj.user];
    
    
    
    //让评论量+1
    [self.itObj addCommentCountWithCompletionBlock:^(id obj) {
       //让Cell改变 但是此位置得不到Cell
        
    }];
    
    
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"提示" message:@"评论完成！" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self loadComments];
        
        [self.commentTV resignFirstResponder];
    }];
    
    [ac addAction:action1];
    [self presentViewController:ac animated:YES completion:nil];
    
}

- (IBAction)clicked:(UIButton *)sender {
    
    
    
    switch (sender.tag) {
        case 0://图片
            
            
            self.commentTV.inputView = self.commentTV.inputView ? nil : self.selectedImageSV;
            [self.commentTV reloadInputViews];
            //如果一张图片都没选 直接去选择图片
            if (self.selectedImageViews.count==0) {
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
        self.timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 20)];
        self.timeLabel.center = CGPointMake(LYSW/2.0, 170);
        [_recordView addSubview:self.timeLabel];
        self.timeLabel.textColor = LYGreenColor;
        self.timeLabel.textAlignment = NSTextAlignmentCenter;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recordFinishAction:) name:@"RecordDidFinishNotification" object:nil];
        
    }
    return _recordView;
}


-(void)recordFinishAction:(NSNotification *)noti{
    
    //显示得到录音时长
    float time = [noti.object[@"time"] floatValue];
    self.timeLabel.text = [NSString stringWithFormat:@"%.2f秒",time];
    
    
    
    //得到录好的音频数据
    NSData *audioData = noti.object[@"data"];
    //上传音频文件
    BmobFile *file = [[BmobFile alloc]initWithFileName:@"audio.amr" withFileData:audioData];
    [file saveInBackground:^(BOOL isSuccessful, NSError *error) {
        if (isSuccessful) {
            self.voicePath = file.url;
            
        }else{
            NSLog(@"音频文件上传失败");
        }
    }];
    
    
}


-(UIScrollView *)selectedImageSV{
    if (!_selectedImageSV) {
        _selectedImageSV=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, LYSW, 216)];
        self.addImageButton=[[UIButton alloc]initWithFrame:CGRectMake(20, 30, 100, 140)];
        [self.addImageButton setImage:[UIImage imageNamed:@"1.png"] forState:UIControlStateNormal];
        [self.selectedImageSV addSubview:self.addImageButton];
        [self.addImageButton addTarget:self action:@selector(addImageAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _selectedImageSV;
}
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



- (IBAction)commentAction:(id)sender {
    
    
    
    
    if (!self.commentTV.isFirstResponder) {
        [self.commentTV becomeFirstResponder];
        
   
        
        
        
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"详情";
    self.selectedImageViews = [NSMutableArray array];
    ITObjectView *objView = [[ITObjectView alloc]initWithFrame:CGRectMake(0, 0, LYSW, [self.itObj getHeigth])];
    
    objView.itObj = self.itObj;
    
    
    
    self.tableView.tableHeaderView = objView;
    
    
    
    //判断是否有录音
    if (self.itObj.voicePath) {
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(playAction)];
        
    }

   
    
    
    self.commentTV = [[YYTextView alloc]initWithFrame:CGRectMake(106, 5, 215, 31)];
    
    self.commentTV.backgroundColor = LYGrayColor;
    [self.commentBarView addSubview:self.commentTV];
      [FaceUtils faceBindingWithTextView:self.commentTV];
    
    
    //监听键盘事件
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardFrameChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    //监听表情按钮的通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(faceBtnAction:) name:@"FaceNotification" object:nil];
    
    
    [self loadComments];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"CommentCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"cell"];
}

-(void)playAction{
    
    
    [TRVoicePlayer playWithVoicePath:self.itObj.voicePath];
    
    
    
}



-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    
    NSLog(@"%@--%@",self.navigationController.topViewController,self);
    //选择图片回来之后要把软键盘弹出来
    if (self.selectedImageViews.count!=0) {
        [self.commentTV becomeFirstResponder];
    }
    
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
            
        }else{//软件盘弹出的时候 把表情隐藏
            self.commentBarView.transform = CGAffineTransformMakeTranslation(0, -keyboardH-44);
            
            
        }
    }];
    
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    [self.commentTV resignFirstResponder];
    
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    
    return self.comments.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
   
    
    cell.comment = self.comments[indexPath.row];
    
 
    
    
    
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    Comment *c = self.comments[indexPath.row];
    
    return 55 + [c getHeigth];

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
        [doneBtn setTitle:@"完成" forState:UIControlStateNormal];
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
    
    
    
    
    for (int i=0; i<self.selectedImageViews.count; i++) {
        UIImageView *iv=self.selectedImageViews[i];
        iv.frame = CGRectMake(20+120*i, 30, 100, 140);
        
        
        [self.selectedImageSV addSubview:iv];
        UIButton *delBtn= [iv.subviews firstObject];
        [delBtn addTarget:self action:@selector(svdeleteaction:) forControlEvents:UIControlEventTouchUpInside];
        
        [delBtn setTitleColor:LYGreenColor forState:UIControlStateNormal];
        iv.userInteractionEnabled=YES;
        [iv addSubview:delBtn];
        
    }
    
    self.selectedImageSV.contentSize=CGSizeMake((self.selectedImageViews.count+1)*120, 0);
    
    self.addImageButton.center = CGPointMake(20+self.selectedImageViews.count*120+self.addImageButton.bounds.size.width/2, self.addImageButton.center.y);
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [self updateImageCountLabel];
}

-(void)svdeleteaction:(UIButton *)btn
{
    [self.selectedImageViews removeObject:btn.superview];
    [btn.superview removeFromSuperview];
    for (int i=0; i<self.selectedImageViews.count; i++) {
        UIImageView *iv=self.selectedImageViews[i];
        [UIView animateWithDuration:0.5 animations:^{
            iv.frame=CGRectMake(20+i*120, 30, 100, 140);
            
        }];
        
    }
    
    self.selectedImageSV.contentSize = CGSizeMake(20+(self.selectedImageViews.count+1)*120, 0);
    [UIView animateWithDuration:0.5 animations:^{
        self.addImageButton.center=CGPointMake(20+self.selectedImageViews.count*120+50, self.addImageButton.center.y);
    }];
    [self updateImageCountLabel];
}
-(void)updateImageCountLabel{
    
    self.imageCountLabel.hidden = self.selectedImageViews.count==0?YES:NO;
    
    self.imageCountLabel.text = @(self.selectedImageViews.count).stringValue;
    
}


@end
