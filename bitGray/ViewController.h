//
//  ViewController.h
//  bitGray
//
//  Created by Diego Diaz Pinilla on 15/02/17.
//  Copyright © 2017 Diego Diaz Pinilla. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
@import GoogleMaps;

@interface ViewController : UIViewController <GMSMapViewDelegate,CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet UIView *mapView;
@property (strong, nonatomic) IBOutlet UIButton *btnSearchUser;
@property (strong, nonatomic) IBOutlet UIButton *btnNearUser;
@property (strong, nonatomic) IBOutlet UIButton *btnFarUser;
@property float latitude;
@property float longitude;
@property NSInteger randomNumber;

- (IBAction)searchUser:(id)sender;
- (IBAction)searchNearUser:(id)sender;
- (IBAction)searchFarUser:(id)sender;
@end

