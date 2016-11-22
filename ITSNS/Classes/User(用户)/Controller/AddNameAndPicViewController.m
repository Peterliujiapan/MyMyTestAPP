//
//  AddNameAndPicViewController.m
//  ITSNS
//
//  Created by tarena on 16/6/25.
//  Copyright © 2016年 Ivan. All rights reserved.
//
#import "UIButton+AFNetworking.h"
#import "AddNameAndPicViewController.h"

@interface AddNameAndPicViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *headBtn;
@property (weak, nonatomic) IBOutlet UITextField *nickTF;
@property (nonatomic, strong)NSData *imageData;
@end

@implementation AddNameAndPicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(backAction)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction)];
    
    NSString *nick = [[BmobUser getCurrentUser]objectForKey:@"nick"];
    if (nick.length>0) {
        self.nickTF.text = nick;
    }
   
    NSString *headPath = [[BmobUser getCurrentUser]objectForKey:@"headPath"];
    if (headPath) {
        [self.headBtn setImageForState:UIControlStateNormal withURL:[NSURL URLWithString:headPath]];
    }
    
    
    
}

- (void)backAction {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)doneAction{
    
    BmobUser *user = [BmobUser getCurrentUser];
    
    [user setObject:self.nickTF.text forKey:@"nick"];
    
    if (self.imageData) {
        //如果有图片 先上传图片 再保存数据
        
        BmobFile *file = [[BmobFile alloc]initWithFileName:@"abc.jpg" withFileData:self.imageData];
         NSLog(@"上传前%@",file.url);
        [file saveInBackground:^(BOOL isSuccessful, NSError *error) {
            if (isSuccessful) {
                
                NSLog(@"上传完%@",file.url);
                
                   [user setObject:file.url forKey:@"headPath"];
                
                //更新数据
                [user updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
                    
                    
                    [self dismissViewControllerAnimated:YES completion:nil];
                    
                }];
                
            }
            
            
        }];
        
        
    }else{
        
        //更新数据
        [user updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
            
            
            [self dismissViewControllerAnimated:YES completion:nil];
            
        }];
        
        
    }
  
    
    
}
- (IBAction)imageAction:(id)sender {
    
    UIImagePickerController *vc = [[UIImagePickerController alloc]init];
    vc.delegate =self;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    [self.headBtn setImage:image forState:UIControlStateNormal];
    
    
    if ([[info[UIImagePickerControllerReferenceURL] description] hasSuffix:@"PNG"]) {
        self.imageData = UIImagePNGRepresentation(image);
    }else{
        self.imageData = UIImageJPEGRepresentation(image, .5);
    }
    
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    
}

@end
