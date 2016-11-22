//
//  LYLocationViewController.m
//  ITSNS
//
//  Created by Ivan on 16/1/9.
//  Copyright © 2016年 Ivan. All rights reserved.
//
#import "TRDetailViewController.h"
#import "UIImageView+WebCache.h"
#import "TRPointAnnotation.h"
#import "TRAnnotationView.h"
#import "TRITObject.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>//引入地图功能所有的头文件
#import "LYLocationViewController.h"

@interface LYLocationViewController ()<BMKMapViewDelegate>
@property (nonatomic, strong)BMKMapView* mapView;
@end

@implementation LYLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    BMKMapView* mapView = [[BMKMapView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    [self.view addSubview:mapView];
    self.mapView = mapView;
    
    [self.mapView setZoomLevel:15];
    
    
    
    
    
    [self.mapView setTrafficEnabled:YES];
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [_mapView viewWillAppear];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
}
-(void)viewWillDisappear:(BOOL)animated
{
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
}





- (void)mapViewDidFinishLoading:(BMKMapView *)mapView{
    
    [self loadObjsWithCoord:mapView.centerCoordinate];
    
    
}

- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
     [self loadObjsWithCoord:mapView.centerCoordinate];
}

-(void)loadObjsWithCoord:(CLLocationCoordinate2D )coord{
    
    
    
   
    
    
    
    
    
    //删除原来的大头针
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    //删除原来的覆盖物
    [self.mapView removeOverlays:self.mapView.overlays];
    
    
    
    // 添加圆形覆盖物
    BMKCircle *circle = [BMKCircle circleWithCenterCoordinate:coord radius:2000];
    
    [_mapView addOverlay:circle];
    
    
    //检索点击周边的消息
    BmobGeoPoint *point = [[BmobGeoPoint alloc]initWithLongitude:coord.longitude WithLatitude:coord.latitude];
    
    //发请求 获取周边的消息
    BmobQuery *query = [BmobQuery queryWithClassName:@"ITSNSObject"];
    
    [query includeKey:@"user"];
    //设置查询10公里之内的消息
    [query whereKey:@"location" nearGeoPoint:point withinKilometers:2];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        
        for (BmobObject *bObj in array) {
            TRITObject *itObj = [[TRITObject alloc]initWithBmobObj:bObj];
            
            NSLog(@"%@",itObj.title);
            BmobUser *user = [bObj objectForKey:@"user"];
            NSString *nick = [user objectForKey:@"nick"];
            
            //            添加大头针
            TRPointAnnotation *pointAnnotation = [[TRPointAnnotation alloc]init];
            pointAnnotation.itObj = itObj;
            pointAnnotation.coordinate = itObj.coord;
            pointAnnotation.title = nick;
            pointAnnotation.subtitle = itObj.title;
            
            [_mapView addAnnotation:pointAnnotation];
            
            
            
        }
        
        
        
    }];
    
    
    
}

//添加覆盖物View
- (BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id <BMKOverlay>)overlay
{
    //控制添加的覆盖物的具体样式
        BMKCircleView* circleView = [[BMKCircleView alloc] initWithOverlay:overlay];
        circleView.fillColor = [[UIColor alloc] initWithRed:0 green:1 blue:1 alpha:0.2];
         circleView.strokeColor = [[UIColor alloc] initWithRed:0 green:0 blue:1 alpha:0.5];
//        circleView.lineWidth = 5.0;
    
        return circleView;

}

-(BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation{
    
    TRAnnotationView *view = (TRAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"ann"];
    
    if (!view) {
        view = [[TRAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"ann"];
    }
    
    
    TRPointAnnotation *ann = (TRPointAnnotation *)annotation;
    
    TRITObject *itObj = ann.itObj;
    
    BmobUser *user = [itObj.bObj objectForKey:@"user"];
    NSString *headPath = [user objectForKey:@"headPath"];
    
    [view.headIV sd_setImageWithURL:[NSURL URLWithString:headPath]];
    
    return view;
    
}
//-(void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view{
//    
//    
//    TRPointAnnotation *ann = view.annotation;
//    
//    TRITObject *itObj = ann.itObj;
//    
//    TRDetailViewController *vc = [TRDetailViewController new];
//    
//    vc.itObj = itObj;
//    
//    
//    [self.navigationController pushViewController:vc animated:YES];
//
//    
//}
//点击气泡时
- (void)mapView:(BMKMapView *)mapView annotationViewForBubble:(BMKAnnotationView *)view{
    
   
    TRPointAnnotation *ann = view.annotation;
    
    TRITObject *itObj = ann.itObj;
    
    TRDetailViewController *vc = [TRDetailViewController new];
    
    vc.itObj = itObj;
    
    
    [self.navigationController pushViewController:vc animated:YES];

    
}
@end
