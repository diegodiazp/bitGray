//
//  ViewController.m
//  bitGray
//
//  Created by Diego Diaz Pinilla on 15/02/17.
//  Copyright © 2017 Diego Diaz Pinilla. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
@import GoogleMaps;

@interface ViewController ()
{
    GMSMapView *map;
    CLLocationManager *locationManager;
    GMSMarker *positionMarker;
    NSMutableArray *arrayUsers;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [locationManager requestWhenInUseAuthorization];
    }
    if ([locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [locationManager requestAlwaysAuthorization];
    }
    [locationManager startUpdatingLocation];
    
    _latitude = locationManager.location.coordinate.latitude;
    _longitude = locationManager.location.coordinate.longitude;
    
    GMSCameraPosition *userPos = [GMSCameraPosition cameraWithLatitude:_latitude
                                                             longitude:_longitude
                                                                  zoom:0];
    
    map = [GMSMapView mapWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 50) camera:userPos];
    map.myLocationEnabled = YES;
    map.settings.myLocationButton = YES;
    map.settings.compassButton = YES;
    [self.view addSubview:map];
    
    [self drawUser:_randomNumber];


    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePosition:) name:@"locationSuccess" object:nil];
    
    NSString *urlService = @"http://jsonplaceholder.typicode.com/users";
    
    NSMutableURLRequest *requestUsers = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlService]];
    [requestUsers setHTTPMethod:@"GET"];
    [requestUsers setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * dataEvents = [NSURLConnection sendSynchronousRequest:requestUsers
                                                returningResponse:&response
                                                            error:&error];
    
    arrayUsers = [NSJSONSerialization JSONObjectWithData:dataEvents options:kNilOptions error:nil];

    _randomNumber = arc4random() % [arrayUsers count];

}

-(void)viewDidAppear:(BOOL)animated
{
    _btnSearchUser.layer.borderWidth = 1;
    _btnSearchUser.layer.borderColor = [UIColor blackColor].CGColor;
    
    _btnNearUser.layer.borderWidth = 1;
    _btnNearUser.layer.borderColor = [UIColor blackColor].CGColor;
    
    _btnFarUser.layer.borderWidth = 1;
    _btnFarUser.layer.borderColor = [UIColor blackColor].CGColor;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)updatePosition: (NSNotification *)notificationPos
{
    _latitude = [[notificationPos.userInfo objectForKey:@"lat"] floatValue];
    _longitude = [[notificationPos.userInfo objectForKey:@"long"] floatValue];

    GMSCameraPosition *userPos = [GMSCameraPosition cameraWithLatitude:_latitude
                                                            longitude:_longitude
                                                                 zoom:0];
    map = [GMSMapView mapWithFrame:CGRectMake(0, 0, _mapView.frame.size.width, _mapView.frame.size.height) camera:userPos];
    map.myLocationEnabled = YES;
    map.settings.myLocationButton = YES;
    map.settings.compassButton = YES;
    [_mapView addSubview:map];
    
    [self drawUser:_randomNumber];

}

-(void)drawUser: (NSInteger)numRandom
{
    [map clear];
    float latitude = [[[[[arrayUsers objectAtIndex:numRandom] objectForKey:@"address"]objectForKey:@"geo"] objectForKey:@"lat"] floatValue];
    float longitude = [[[[[arrayUsers objectAtIndex:numRandom] objectForKey:@"address"]objectForKey:@"geo"] objectForKey:@"lng"]floatValue];
    CLLocationCoordinate2D position = CLLocationCoordinate2DMake(latitude, longitude);
    GMSMarker *marker;
    marker = [GMSMarker markerWithPosition:position];
    marker.title = [[arrayUsers objectAtIndex:numRandom] objectForKey:@"name"];
    marker.snippet = [[arrayUsers objectAtIndex:numRandom] objectForKey:@"phone"];
    marker.userData = [arrayUsers objectAtIndex:numRandom];
    marker.appearAnimation = kGMSMarkerAnimationPop;
    marker.map = map;

    GMSCameraPosition *userPos = [GMSCameraPosition cameraWithLatitude:latitude
                                                             longitude:longitude
                                                                  zoom:0];
    [map setCamera:userPos];
}

- (IBAction)searchUser:(id)sender
{
    _randomNumber = arc4random() % [arrayUsers count];
    [self drawUser:_randomNumber];
}

- (IBAction)searchNearUser:(id)sender {
    
    double distanceNear = 0.0;
    double currentDistance = 0.0;
    int index = 0;
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    [locationManager startUpdatingLocation];
    
    CLLocation* locationOwn = [[CLLocation alloc] initWithLatitude: locationManager.location.coordinate.latitude longitude: locationManager.location.coordinate.longitude];

    
    for (NSDictionary *users in arrayUsers)
    {
        float latitude = [[[[users objectForKey:@"address"]objectForKey:@"geo"] objectForKey:@"lat"] floatValue];
        float longitude = [[[[users objectForKey:@"address"]objectForKey:@"geo"] objectForKey:@"lng"] floatValue];
        
        CLLocation* locationUser = [[CLLocation alloc] initWithLatitude: latitude longitude: longitude];
        currentDistance = [locationUser distanceFromLocation: locationOwn];
        
        if ([[users objectForKey:@"id"] intValue] == 1) {
            distanceNear = currentDistance;
        }
        else
        {
            if (currentDistance < distanceNear) {
                distanceNear=currentDistance;
                index = [[users objectForKey:@"id"] intValue] - 1;
            }
        }
        
    }
    
    [self drawUser:index];
}

- (IBAction)searchFarUser:(id)sender {
    
    double distanceFar = 0.0;
    double currentDistance = 0.0;
    int index = 0;
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    [locationManager startUpdatingLocation];
    
    CLLocation* locationOwn = [[CLLocation alloc] initWithLatitude: locationManager.location.coordinate.latitude longitude: locationManager.location.coordinate.longitude];
    
    
    for (NSDictionary *users in arrayUsers)
    {
        float latitude = [[[[users objectForKey:@"address"]objectForKey:@"geo"] objectForKey:@"lat"] floatValue];
        float longitude = [[[[users objectForKey:@"address"]objectForKey:@"geo"] objectForKey:@"lng"] floatValue];
        
        CLLocation* locationUser = [[CLLocation alloc] initWithLatitude: latitude longitude: longitude];
        currentDistance = [locationUser distanceFromLocation: locationOwn];
        
        if ([[users objectForKey:@"id"] intValue] == 1) {
            distanceFar = currentDistance;
        }
        else
        {
            if (currentDistance > distanceFar) {
                distanceFar=currentDistance;
                index = [[users objectForKey:@"id"] intValue] - 1;
            }
        }
        
    }
    
    [self drawUser:index];


}

@end
