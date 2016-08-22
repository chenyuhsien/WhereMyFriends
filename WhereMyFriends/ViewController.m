//
//  ViewController.m
//  WhereMyFriends
//
//  Created by 陳育賢 on 2016/8/16.
//  Copyright © 2016年 YuHsien Chen. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>


@interface ViewController ()  <MKMapViewDelegate,CLLocationManagerDelegate,NSURLSessionDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapViewShow;
@property (strong,nonatomic) CLLocationManager *locationManager;

@property (weak, nonatomic) IBOutlet UISwitch *switchBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initApp];
    
    // Do any additional setup after loading the view, typically from a nib.
    //取得使用者位置
    _locationManager = [CLLocationManager new];
    [_locationManager requestAlwaysAuthorization ];
    
    
   
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self ;
    

    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.activityType = CLActivityTypeAutomotiveNavigation;
    

    [self.locationManager startUpdatingLocation];
    
    
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    CLLocation * currentLocation = locations.lastObject;
    //CLLocation * location = [locations objectAtIndex:0];
    
    double lat = currentLocation.coordinate.latitude; //取得緯度
    double lon = currentLocation.coordinate.longitude; //取得經度
    NSLog(@"現在的緯度是:%f,經度是:%f",lat,lon);
    
    if((self.switchBtn.on == YES)) {
        //回傳自己位置資料API
        NSString *urlString=[NSString stringWithFormat:@"http://class.softarts.cc/FindMyFriends/updateUserLocation.php?GroupName=ap103&UserName=YuHsien&Lat=%f&Lon=%f",lat,lon];
        //取朋友位置的API
        NSString *urlFriends=[NSString stringWithFormat:@"http://class.softarts.cc/FindMyFriends/queryFriendLocations.php?GroupName=ap103"];
        
        //回傳自己位置資料API
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0];
        //取朋友位置的API
        NSURL *url2 = [NSURL URLWithString:urlFriends];
        NSURLRequest *request2 = [NSURLRequest requestWithURL:url2 cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0];
        
        
        // Prepare NSURLSession
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
        
        //[_loadingIndicatorView startAnimating];
        //Part1
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            
            if(error)
            {
                NSLog(@"Error: %@",error.description);
            }
            else
            {
                //            NSString *content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                //            NSLog(@"JSON: %@",content);
                
                // Parse JSON
                NSDictionary *datas = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                NSLog(@"JSON: %@",datas);
                
            }
            
        }];
        
        //從Server裡讀取朋友的位置
        NSURLSessionDataTask *task2 = [session dataTaskWithRequest:request2 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            
            if(error)
            {
                NSLog(@"Error2: %@",error.description);
            }
            else
            {
                //            NSString *content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                //            NSLog(@"JSON: %@",content);
                
                // Parse JSON
                NSDictionary *friDatas = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                NSLog(@"JSON2: %@",friDatas);
                NSString * friLat=[friDatas objectForKey:@"lat"];
                NSString * friLon=[friDatas objectForKey:@"lon"];
            }
            
        }];

        
        
        [task resume];
        [task2 resume];
        
    }
    
    
    
}

-(void) mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    MKCoordinateRegion region = mapView.region;
    NSLog(@"Region Change,Lat/Lon: %f,%f span: %f,%f",region.center.latitude,region.center.longitude,region.span.latitudeDelta,region.span.longitudeDelta);
}



-(void)initApp {
    self.switchBtn.on = NO;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
