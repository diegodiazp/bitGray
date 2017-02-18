//
//  AppDelegate.h
//  bitGray
//
//  Created by Diego Diaz Pinilla on 15/02/17.
//  Copyright © 2017 Diego Diaz Pinilla. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate,CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property float latitude;
@property float longitude;


@end

