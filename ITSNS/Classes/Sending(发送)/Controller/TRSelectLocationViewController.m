//
//  TRSelectLocationViewController.m
//  ITSNS
//
//  Created by tarena on 16/7/1.
//  Copyright © 2016年 Ivan. All rights reserved.
//

#import "TRSelectLocationViewController.h"
#import <MapKit/MapKit.h>
@interface TRSelectLocationViewController ()
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation TRSelectLocationViewController
- (IBAction)tapAction:(UITapGestureRecognizer *)sender {
    
    //得到地图经纬度信息
    CGPoint point = [sender locationInView:sender.view];
    
    //把屏幕坐标 转成经纬度
    
    CLLocationCoordinate2D coord = [self.mapView convertPoint:point toCoordinateFromView:sender.view];
    
    NSLog(@"经度：%f  纬度：%f",coord.longitude,coord.latitude);
    
    [self.navigationController popViewControllerAnimated:YES];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    [ud setFloat:coord.longitude forKey:@"longitude"];
    [ud setFloat:coord.latitude forKey:@"latitude"];
    
    [ud synchronize];
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
