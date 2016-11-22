//
//  TRPointAnnotation.h
//  ITSNS
//
//  Created by tarena on 16/7/1.
//  Copyright © 2016年 Ivan. All rights reserved.
//

#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import "TRITObject.h"
@interface TRPointAnnotation : BMKPointAnnotation
@property (nonatomic, strong)TRITObject *itObj;
@end
