//
//  WeatherForecast.h
//  Weather
//
//  Created by Eugene Scherba on 1/14/11.
//  Copyright 2011 Boston University. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CFIViewController;

@interface WeatherForecast : NSObject {

	// Parent View Controller
	CFIViewController *viewController;
	
	// Google Weather Service
	NSMutableData *responseData;
	NSURL *theURL;
	
	// Information
	NSString *location;
	NSString *date;
	
	//Current Conditions
	UIImage *icon;
	NSString *temp;
	NSString *humidity;
	NSString *wind;
	NSString *condition;
	
	// Forecast Conditions
	NSMutableArray *days;
	NSMutableArray *icons;
	NSMutableArray *temps;
	NSMutableArray *conditions;
	
}

@property (nonatomic, retain) NSString *location;
@property (nonatomic, retain) NSString *date;

@property (nonatomic, retain) UIImage *icon;
@property (nonatomic, retain) NSString *temp;
@property (nonatomic, retain) NSString *humidity;
@property (nonatomic, retain) NSString *wind;
@property (nonatomic, retain) NSString *condition;

@property (nonatomic, retain) NSMutableArray *days;
@property (nonatomic, retain) NSMutableArray *icons;
@property (nonatomic, retain) NSMutableArray *temps;
@property (nonatomic, retain) NSMutableArray *conditions;

- (void)queryService:(NSString *)city
  withParent:(UIViewController *)controller;

@end
