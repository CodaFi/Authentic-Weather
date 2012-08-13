//
//  CFIViewController.h
//  CHECK ✓
//
//  Created by Robert Widmann on 8/13/12.
//  Copyright (c) 2012 CodaFi Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeatherForecast.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <AddressBook/AddressBook.h>



@interface CFIViewController : UIViewController<CLLocationManagerDelegate, MKReverseGeocoderDelegate, UIScrollViewDelegate, UIAlertViewDelegate> {
    UIView * headerView;
	
	UIView * topView;
	UIView * bottomView;
	
	UILabel * topLabel;
	UILabel * bottomLabel;
	
	BOOL refreshing;
    
    IBOutlet UIScrollView *scrollView;
    
    IBOutlet UILabel *forcastLabel;
    IBOutlet UILabel *label1;
    IBOutlet UILabel *label2;
    IBOutlet UILabel *label3;
    IBOutlet UILabel *descriptionLabel;
    IBOutlet UIImageView *imageView;

    IBOutlet UIActivityIndicatorView *activity;
        
}
- (void)updateView;

@property (nonatomic, retain) WeatherForecast *forecast;

@end
