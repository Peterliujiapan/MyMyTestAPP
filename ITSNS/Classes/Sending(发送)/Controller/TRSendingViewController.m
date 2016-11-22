//
//  TRViewController.m
//  ITSNS
//
//  Created by tarena on 16/6/25.
//  Copyright © 2016年 Ivan. All rights reserved.
//
#import "TRUtils.h"
#import "TRSelectLocationViewController.h"
#import <MapKit/MapKit.h>
#import "RecordButton.h"
#import "FaceUtils.h"
#import "FaceView.h"
#import "TRSendingViewController.h"
#import "YYTextView.h"
@interface TRSendingViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,YYTextViewDelegate>

@property (nonatomic)CLLocationCoordinate2D coord;


@property (weak, nonatomic) IBOutlet UIButton *locationbtn;

@property (nonatomic, strong) IBOutlet UIView *buttonView;

@property (nonatomic, strong)YYTextView *titleTV;
@property (nonatomic, strong)YYTextView *detailTV;
@property (nonatomic, strong)YYTextView *currentTV;




@property (weak, nonatomic) IBOutlet UILabel *locationLabel;



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

@implementation TRSendingViewController
- (IBAction)clicked:(UIButton *)sender {
    
    
     
    switch (sender.tag) {
        case 0://图片
         
            
             self.currentTV.inputView = self.currentTV.inputView ? nil : self.selectedImageSV;
            [self.currentTV reloadInputViews];
            //如果一张图片都没选 直接去选择图片
            if (self.selectedImageViews.count==0) {
                UIImagePickerController *pick=[UIImagePickerController new];
                pick.delegate=self;
                [self presentViewController:pick animated:YES completion:nil];
            }
            break;
        case 1://表情
            self.currentTV.inputView = self.currentTV.inputView ? nil : self.faceView;
            
            [self.currentTV reloadInputViews];
            break;
            
        case 2://录音
            self.currentTV.inputView = self.currentTV.inputView  ? nil : self.recordView;
            [self.currentTV reloadInputViews];
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

//    标题
-(YYTextView *)titleTV{
    if (!_titleTV) {
        YYTextView *titleTV=[[YYTextView alloc]initWithFrame:CGRectMake(LYMargin, 64, LYSW-2*LYMargin, 30)];
        titleTV.delegate = self;
        titleTV.placeholderText=@"标题  (可选)";
        titleTV.placeholderFont=[UIFont systemFontOfSize:14];
        titleTV.font=[UIFont systemFontOfSize:14];
        [self.view addSubview:titleTV];
        _titleTV = titleTV;
        [FaceUtils faceBindingWithTextView:_titleTV];
        
        [self.buttonView removeFromSuperview];
        _titleTV.inputAccessoryView = self.buttonView;
        
    }
    return _titleTV;
}

-(YYTextView *)contentTV{
    if (!_detailTV) {
        YYTextView *detailTV=[[YYTextView alloc]initWithFrame:CGRectMake(LYMargin, 115, LYSW-2*LYMargin, 150)];
        detailTV.delegate = self;
        [FaceUtils faceBindingWithTextView:detailTV];
        [self.view addSubview:detailTV];
        _detailTV=detailTV;
        
        _detailTV.inputAccessoryView = self.buttonView;
    }
    return _detailTV;
}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.currentTV resignFirstResponder];
}

-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    [self.titleTV becomeFirstResponder];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    double longitude = [ud doubleForKey:@"longitude"];
    double latitude = [ud floatForKey:@"latitude"];
    self.coord = CLLocationCoordinate2DMake(latitude, longitude);
    
    if (longitude==0&&latitude==0) {
        self.locationLabel.text = @"请选择位置";
    }else{
        self.locationLabel.text = [NSString stringWithFormat:@"%lf&%lf",longitude,latitude];
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
       self.selectedImageViews=[NSMutableArray array];
    
    //监听表情按钮的通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(faceBtnAction:) name:@"FaceNotification" object:nil];
  
}

//点击表情按钮时监听事件
-(void)faceBtnAction:(NSNotification *)noti{
    NSString *text = noti.object;
    
    [self.currentTV insertText:text];
    
    
}


-(void)initUI{
    self.imageCountLabel.layer.cornerRadius = 8;
    self.imageCountLabel.layer.masksToBounds = YES;
    self.imageCountLabel.hidden = YES;
    
    UIView *line=[[UIView alloc]initWithFrame:CGRectMake(0, 97, 375, 1)];
    line.backgroundColor = LYGrayColor;
    [self.view addSubview:line];
    self.locationbtn.layer.cornerRadius=15;
    
    [self.titleTV becomeFirstResponder];
    
    self.contentTV.text = @"";
    
    switch (self.type.intValue) {
        case 0:
            self.title = @"新建消息";
            break;
            
        case 1:
            self.title = @"新建问题";
            break;
            
        case 2:
            self.title = @"新建项目";
            break;
    }
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(backAction)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"发布" style:UIBarButtonItemStyleDone target:self action:@selector(sendAction)];
    
    self.navigationController.navigationBar.tintColor = LYGreenColor;
}

-(void)backAction{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)locationAction:(id)sender {
    TRSelectLocationViewController *vc = [TRSelectLocationViewController new];
    
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void)sendAction{
    
    
    BmobObject *bOBj = [BmobObject objectWithClassName:@"ITSNSObject"];
    //判断是否有位置
    if (self.coord.longitude!=0&&self.coord.latitude!=0) {
        
        BmobGeoPoint *point = [[BmobGeoPoint alloc]initWithLongitude:self.coord.longitude WithLatitude:self.coord.latitude];
        [bOBj setObject:point forKey:@"location"];
        
        
        
    }
    
    
    [bOBj setObject:@(0) forKey:@"showCount"];
    [bOBj setObject:@(0) forKey:@"commentCount"];
    

    [bOBj setObject:self.titleTV.text forKey:@"title"];
    [bOBj setObject:self.detailTV.text forKey:@"detail"];
    //取值 0 1 2  0朋友圈消息 1问题 2项目
    [bOBj setObject:self.type forKey:@"type"];
    //添加用户字段 用来区分到底是谁发的
    [bOBj setObject:[BmobUser getCurrentUser] forKey:@"user"];
    
    
    //添加录音字段
    if (self.voicePath) {
         [bOBj setObject:self.voicePath forKey:@"voicePath"];
    }
   
    
    
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
                [bOBj setObject:imagePaths forKey:@"imagePaths"];
                
                [bOBj saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
                    if (isSuccessful) {
                        NSLog(@"保存成功！");
                        
                        //增加积分
                        int score = [self.type intValue]+1;
                        [TRUtils addScore:score];
                        
                        [self dismissViewControllerAnimated:YES completion:nil];
                    }else{
                        NSLog(@"保存失败：%@",error);
                    }
                }];
                
                
            }else{
                NSLog(@"上传图片失败");
            }
        }];
        
    }else{

    
    [bOBj saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        if (isSuccessful) {
            NSLog(@"保存成功！");
            
            //增加积分
            int score = [self.type intValue]+1;
            [TRUtils addScore:score];
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }else{
            NSLog(@"保存失败：%@",error);
        }
    }];
    
    }
    
    
    
    
    
}




- (void)textViewDidBeginEditing:(YYTextView *)textView{
    
    
    self.currentTV = textView;
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
        
        //得到页面中sv 把高度 -100
       UIView *cv = [viewController.view.subviews firstObject];
        cv.height -= 100;
     
        
        
        
        UIView *v=[[UIView alloc]initWithFrame:CGRectMake(0, 567, 375, 100)];
        v.backgroundColor = [UIColor whiteColor];
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
