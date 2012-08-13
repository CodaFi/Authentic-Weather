//
//  CFIViewController.m
//  CHECK ✓
//
//  Created by Robert Widmann on 8/13/12.
//  Copyright (c) 2012 CodaFi Inc. All rights reserved.
//

#import "CFIViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface CFIViewController ()

@end

CGFloat const kRefreshViewHeight = 65;

@interface CFIViewController (Private)
- (void)unfoldHeaderToFraction:(CGFloat)fraction;
- (void)refreshData;
@end


@implementation CFIViewController
@synthesize forecast;

- (void)viewDidLoad
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(returnFromBackground) name:UIApplicationWillEnterForegroundNotification object:nil];
    headerView = [[UIView alloc] initWithFrame:CGRectMake(0, -kRefreshViewHeight, self.view.bounds.size.width, kRefreshViewHeight)];
	[headerView setBackgroundColor:[UIColor scrollViewTexturedBackgroundColor]];
	[scrollView addSubview:headerView];
	
	CATransform3D transform = CATransform3DIdentity;
	transform.m34 = -1/500.0;
	[headerView.layer setSublayerTransform:transform];
	
	topView = [[UIView alloc] initWithFrame:CGRectMake(0, -kRefreshViewHeight / 4, headerView.bounds.size.width, kRefreshViewHeight / 2)];
	[topView setBackgroundColor:[UIColor colorWithRed:0.886 green:0.906 blue:0.929 alpha:1]];
	[topView.layer setAnchorPoint:CGPointMake(0.5, 0.0)];
	[headerView addSubview:topView];
	
	topLabel = [[UILabel alloc] initWithFrame:topView.bounds];
	[topLabel setBackgroundColor:[UIColor clearColor]];
	[topLabel setTextAlignment:UITextAlignmentCenter];
	[topLabel setText:@"Pull down to refresh"];
	[topLabel setTextColor:[UIColor colorWithRed:0.395 green:0.427 blue:0.510 alpha:1]];
	[topLabel setShadowColor:[[UIColor whiteColor] colorWithAlphaComponent:0.7]];
	[topLabel setShadowOffset:CGSizeMake(0, 1)];
	[topView addSubview:topLabel];
	
	bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, kRefreshViewHeight * 3 / 4, headerView.bounds.size.width, kRefreshViewHeight / 2)];
	[bottomView setBackgroundColor:[UIColor colorWithRed:0.836 green:0.856 blue:0.879 alpha:1]];
	[bottomView.layer setAnchorPoint:CGPointMake(0.5, 1.0)];
    [headerView addSubview:bottomView];

	bottomLabel = [[UILabel alloc] initWithFrame:bottomView.bounds];
	[bottomLabel setBackgroundColor:[UIColor clearColor]];
	[bottomLabel setText:@"Or look out your damn window..."];
	[bottomLabel setTextAlignment:UITextAlignmentCenter];
	[bottomLabel setTextColor:[UIColor colorWithRed:0.395 green:0.427 blue:0.510 alpha:1]];
	[bottomLabel setShadowColor:[[UIColor whiteColor] colorWithAlphaComponent:0.7]];
	[bottomLabel setShadowOffset:CGSizeMake(0, 1)];
	[bottomView addSubview:bottomLabel];
	
	// Just so it's not white above the refresh view.
	UIView * aboveView = [[UIView alloc] initWithFrame:CGRectMake(0, -self.view.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height - kRefreshViewHeight)];
	[aboveView setBackgroundColor:[UIColor colorWithRed:0.886 green:0.906 blue:0.929 alpha:1]];
	[aboveView setTag:123];
	[scrollView addSubview:aboveView];
	
	refreshing = NO;
    
    [scrollView setContentSize:CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height+1)];
    [scrollView setBounces:YES];
    [scrollView setShowsHorizontalScrollIndicator:NO];
    [scrollView setDelegate:self];
    
    [forcastLabel setAlpha:0.0f];
    [label1 setAlpha:0.0f];
    [label2 setAlpha:0.0f];
    [label3 setAlpha:0.0f];
    [descriptionLabel setAlpha:0.0f];
    [imageView setAlpha:0.0f];

    [activity startAnimating];
    // this creates the CCLocationManager that will find your current location
    if ([CLLocationManager locationServicesEnabled] &&
        [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied) {
        CLLocationManager *locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        [locationManager startUpdatingLocation];
        
        CLGeocoder *geoCoder = [[CLGeocoder alloc]init];
        [geoCoder reverseGeocodeLocation:locationManager.location completionHandler:^(NSArray *placemarks, NSError *error){
            if (error) {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"WTF?" message:@"How am I supposed to get the weather if I don't know where the hell you are?" delegate:self cancelButtonTitle:@"Uh..." otherButtonTitles:@"My Bad", nil];
                [alert show];
            }
            else {
                CLPlacemark * myPlacemark = [placemarks objectAtIndex:0];
                // with the placemark you can now retrieve the city name
                NSString *city = [myPlacemark.addressDictionary objectForKey:(NSString*) kABPersonAddressCityKey];
                forecast = [[WeatherForecast alloc]init];
                [forecast queryService:city withParent:self];
            }
        }];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"WTF?" message:@"How am I supposed to get the weather if I don't know where the hell you are?" delegate:self cancelButtonTitle:@"Uh..." otherButtonTitles:@"My Bad", nil];
        [alert show];
    }

    [super viewDidLoad];
}
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [label1 setText:@"Things"];
    [label2 setText:@"Went"];
    [forcastLabel setTextColor:[UIColor redColor]];
    [forcastLabel setText:@"Wrong."];
    [label3 setText:@""];
    [descriptionLabel setText:@"It's a good thing you have a window"];
    [self updateView];
}
- (void)refreshData {
	
	refreshing = YES;
	
	[topLabel setText:@"Refreshing..."];
	[UIView animateWithDuration:0.2 animations:^{[scrollView setContentInset:UIEdgeInsetsMake(kRefreshViewHeight, 0, 0, 0)];}];
	// this creates the CCLocationManager that will find your current location
    if ([CLLocationManager locationServicesEnabled] &&
        [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied) {
        CLLocationManager *locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        [locationManager startUpdatingLocation];
        
        CLGeocoder *geoCoder = [[CLGeocoder alloc]init];
        [geoCoder reverseGeocodeLocation:locationManager.location completionHandler:^(NSArray *placemarks, NSError *error){
            if (error) {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"WTF?" message:@"How am I supposed to get the weather if I don't know where the hell you are?  Quit reloading and go to settings." delegate:self cancelButtonTitle:@"Uh..." otherButtonTitles:@"My Bad", nil];
                [alert show];

            }
            else {
                CLPlacemark * myPlacemark = [placemarks objectAtIndex:0];
                // with the placemark you can now retrieve the city name
                NSString *city = [myPlacemark.addressDictionary objectForKey:(NSString*) kABPersonAddressCityKey];
                [forecast queryService:city withParent:self];
            }
        }];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"WTF?" message:@"How am I supposed to get the weather if I don't know where the hell you are?  Quit reloading and go to settings." delegate:self cancelButtonTitle:@"Uh..." otherButtonTitles:@"My Bad", nil];
        [alert show];
    }
	
}

-(void)returnFromBackground {
    refreshing = YES;
	
	[UIView animateWithDuration:0.2 animations:^{[scrollView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];}];
	// this creates the CCLocationManager that will find your current location
    if ([CLLocationManager locationServicesEnabled] &&
        [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied) {
        CLLocationManager *locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        [locationManager startUpdatingLocation];
        
        CLGeocoder *geoCoder = [[CLGeocoder alloc]init];
        [geoCoder reverseGeocodeLocation:locationManager.location completionHandler:^(NSArray *placemarks, NSError *error){
            if (error) {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"WTF?" message:@"How am I supposed to get the weather if I don't know where the hell you are?  Quit reloading and go to settings." delegate:self cancelButtonTitle:@"Uh..." otherButtonTitles:@"My Bad", nil];
                [alert show];
                
            }
            else {
                CLPlacemark * myPlacemark = [placemarks objectAtIndex:0];
                // with the placemark you can now retrieve the city name
                NSString *city = [myPlacemark.addressDictionary objectForKey:(NSString*) kABPersonAddressCityKey];
                [forecast queryService:city withParent:self];
            }
        }];
    }
}

- (void)unfoldHeaderToFraction:(CGFloat)fraction {
	[bottomView.layer setTransform:CATransform3DMakeRotation((M_PI / 2) - asinf(fraction), 1, 0, 0)];
	[topView.layer setTransform:CATransform3DMakeRotation(asinf(fraction) + (((M_PI) * 3) / 2) , 1, 0, 0)];
	[topView setFrame:CGRectMake(0, kRefreshViewHeight * (1 - fraction), self.view.bounds.size.width, kRefreshViewHeight / 2)];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView_ {
	
	if (!refreshing){
		
		CGFloat fraction = scrollView_.contentOffset.y / -kRefreshViewHeight;
		if (fraction < 0) fraction = 0;
		if (fraction > 1) fraction = 1;
		
		[self unfoldHeaderToFraction:fraction];
		
		if (fraction == 1)[topLabel setText:@"Release to refresh"];
		else [topLabel setText:@"Pull down to refresh"];
	}
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView_ willDecelerate:(BOOL)decelerate {
	if (scrollView_.contentOffset.y < -kRefreshViewHeight) [self refreshData];
}


-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLGeocoder *geoCoder = [[CLGeocoder alloc]init];
    [geoCoder reverseGeocodeLocation:[locations objectAtIndex:0] completionHandler:^(NSArray *placemarks, NSError *error){
        if (error) {
            NSLog(@"locationManager:%@ didFailWithError:%@", geoCoder, error);
        }
        else {
            CLPlacemark * myPlacemark = [placemarks objectAtIndex:0];
            // with the placemark you can now retrieve the city name
            NSString *city = [myPlacemark.addressDictionary objectForKey:(NSString*) kABPersonAddressCityKey];
            forecast = [[WeatherForecast alloc]init];
            [forecast queryService:city withParent:self];
        }
    }];
}
// this delegate is called when the app successfully finds your current location
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"latitude %+.6f, longitude %+.6f\n",
          newLocation.coordinate.latitude,
          newLocation.coordinate.longitude);
#if __IPHONE_OS_VERSION_MAX_ALLOWED <= 40000
    // this creates a MKReverseGeocoder to find a placemark using the found coordinates
    MKReverseGeocoder *geoCoder = [[MKReverseGeocoder alloc] initWithCoordinate:newLocation.coordinate];
    geoCoder.delegate = self;
    [geoCoder start];
#else
    CLGeocoder *geoCoder = [[CLGeocoder alloc]init];
    [geoCoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error){
        if (error) {
            NSLog(@"locationManager:%@ didFailWithError:%@", geoCoder, error);
        }
        else {
            CLPlacemark * myPlacemark = [placemarks objectAtIndex:0];
            // with the placemark you can now retrieve the city name
            NSString *city = [myPlacemark.addressDictionary objectForKey:(NSString*) kABPersonAddressCityKey];
            forecast = [[WeatherForecast alloc]init];
            [forecast queryService:city withParent:self];
        }
    }];
#endif
}

// this delegate method is called if an error occurs in locating your current location
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"locationManager:%@ didFailWithError:%@", manager, error);
}
// this delegate is called when the reverseGeocoder finds a placemark
- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark
{
    MKPlacemark * myPlacemark = placemark;
    // with the placemark you can now retrieve the city name
    NSString *city = [myPlacemark.addressDictionary objectForKey:(NSString*) kABPersonAddressCityKey];
    forecast = [[WeatherForecast alloc]init];
    [forecast queryService:city withParent:self];
}

// this delegate is called when the reversegeocoder fails to find a placemark
- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error
{
    NSLog(@"reverseGeocoder:%@ didFailWithError:%@", geocoder, error);
}
- (void)updateView {
    if (forecast.condition.lowercaseString.length) {
        [forcastLabel setText:forecast.condition.lowercaseString];
        [label1 setText:@"It's"];
        [label2 setText:@"fucking"];
        [label3 setText:@"now."];
        [descriptionLabel setText:@"You can look outside to get more information"];
    }
    [activity stopAnimating];
    
    if ([forcastLabel.text isEqualToString:@"overcast"]) {
        [forcastLabel setTextColor:[UIColor darkGrayColor]];
        [imageView setImage:[UIImage imageNamed:@"weatherappcloudy.jpg"]];
        [bottomLabel setText:@"Uh, it's called a window, dumbass"];
    }
    if ([forcastLabel.text isEqualToString:@"cloudy"]) {
        [forcastLabel setTextColor:[UIColor grayColor]];
        [imageView setImage:[UIImage imageNamed:@"weatherappcloudy.jpg"]];
        [bottomLabel setText:@"Eyes + Window = Better than this app"];
    }
    if ([forcastLabel.text isEqualToString:@"mostly cloudy"]) {
        [forcastLabel setTextColor:[UIColor darkGrayColor]];
        [forcastLabel setText:@"cloudy"];
        [imageView setImage:[UIImage imageNamed:@"weatherappcloudy.jpg"]];
        [bottomLabel setText:@"Or look out your damn window..."];
    }
    if ([forcastLabel.text isEqualToString:@"sunny"]) {
        [forcastLabel setTextColor:[UIColor orangeColor]];
        [imageView setImage:[UIImage imageNamed:@""]];
        [bottomLabel setText:@"It's sunny, quit refreshing me"];
    }
    if ([forcastLabel.text isEqualToString:@"mostly sunny"]) {
        [forcastLabel setTextColor:[UIColor orangeColor]];
        [forcastLabel setText:@"sunny"];
        [imageView setImage:[UIImage imageNamed:@""]];
        [bottomLabel setText:@"Put me down and go outside"];
    }
    if ([forcastLabel.text isEqualToString:@"rain"] || [forcastLabel.text isEqualToString:@"light rain"]) {
        [forcastLabel setTextColor:[UIColor colorWithRed:27.0f/255.0f green:125.0f/255.0f blue:247.0f/255.0f alpha:1.0f]];
        [forcastLabel setText:@"raining"];
        [imageView setImage:[UIImage imageNamed:@"weatherapprain.jpg"]];
        [bottomLabel setText:@"Or look out your damn window..."];
    }
    [UIView animateWithDuration:0.5 animations:^{
        [forcastLabel setAlpha:1.0f];
        [label1 setAlpha:1.0f];
        [label2 setAlpha:1.0f];
        [label3 setAlpha:1.0f];
        [descriptionLabel setAlpha:1.0f];
        [imageView setAlpha:1.0f];
    }];
    
    refreshing = NO;
    [UIView animateWithDuration:0.2 animations:^{[scrollView setContentInset:UIEdgeInsetsZero];}];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
