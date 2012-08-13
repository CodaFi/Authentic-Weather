//
//  WeatherForecast.m
//  Weather
//
//  Created by Eugene Scherba on 1/14/11.
//  Copyright 2011 Boston University. All rights reserved.
//

#import "WeatherForecast.h"
#import "CFIViewController.h"
#import "GDataXMLNode.h"

@implementation WeatherForecast


@synthesize location;
@synthesize date;

@synthesize icon;
@synthesize temp;
@synthesize humidity;
@synthesize wind;
@synthesize condition;

@synthesize days;
@synthesize icons;
@synthesize temps;
@synthesize conditions;

#pragma mark Instance Methods

- (void)queryService:(NSString *)city
  withParent:(UIViewController *)controller
{
	viewController = (CFIViewController *)controller;
	[responseData release];
	responseData = [[NSMutableData data] retain];
	NSString *cleanString = [city stringByReplacingOccurrencesOfString:@" " withString:@"+"];
	NSString *url = [NSString stringWithFormat:@"http://www.google.com/ig/api?weather=%@", cleanString];
    
	theURL = [NSURL URLWithString:url];
	NSURLRequest *request = [NSURLRequest requestWithURL:theURL];
	[[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
}

- (void)dealloc
{
	[viewController release];
	
	[responseData release];
	[theURL release];
	
	[location release];
	[date release];
	
	[icon release];
	[temp release];
	[humidity release];
	[wind release];
	[condition release];
	
	[days release];
	[icons release];
	[temps release];
	[conditions release];
	
	[super dealloc];
}

#pragma mark NSURLConnection delegate methods

- (NSURLRequest *)connection:(NSURLConnection *)connection
			 willSendRequest:(NSURLRequest *)request
			redirectResponse:(NSURLResponse *)redirectResponse
{
	[theURL autorelease];
	theURL = [[request URL] retain];
	return request;
}

- (void)connection:(NSURLConnection *)connection
  didReceiveResponse:(NSURLResponse *)response
{
	[responseData setLength:0];
	//[[responseData alloc] init];
}
- (void)connection:(NSURLConnection *)connection
didReceiveData:(NSData *)data
{
	[responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    NSLog(@"%@", [error localizedDescription]);
}

- (void)fetchContent:(NSArray *)nodes {
	//NSString *result = @"";
	for (GDataXMLElement *node in nodes) {
		NSLog(@"%@", node);
	}
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection 
{
    NSError *error;
	NSLog(@"%@",[[NSString alloc]initWithData:responseData encoding:NSUTF8StringEncoding]);
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:responseData options:0 error:&error];
    if (doc == nil || error != nil) {
		NSLog(@"%@", [error localizedDescription]);
		return;
	}
	GDataXMLElement *weather = (GDataXMLElement *)[[doc nodesForXPath:@"/xml_api_reply/weather" error:&error] objectAtIndex:0];
	
	// Forecast Information ///////////////////////////////////////
	
	GDataXMLElement *forecast = (GDataXMLElement *)[[weather nodesForXPath:@"forecast_information" error:&error] objectAtIndex:0];
	location = [[[forecast nodesForXPath:@"city/@data" error:&error] objectAtIndex:0] stringValue];
	date = [[[forecast nodesForXPath:@"forecast_date/@data" error:&error] objectAtIndex:0] stringValue];
	
	// Current Conditions /////////////////////////////////////////
	
	GDataXMLElement *current_conditions = (GDataXMLElement *)[[weather nodesForXPath:@"current_conditions" error:&error] objectAtIndex:0];
	icon = [NSString stringWithFormat:@"http://www.google.com%@", [[[current_conditions nodesForXPath:@"icon/@data" error:&error] objectAtIndex:0] stringValue]];
	NSString *temp_f = [[[current_conditions nodesForXPath:@"temp_f/@data" error:&error] objectAtIndex:0] stringValue];
	NSString *temp_c = [[[current_conditions nodesForXPath:@"temp_c/@data" error:&error] objectAtIndex:0] stringValue];
	temp = [NSString stringWithFormat:@"%@F (%@C)", temp_f, temp_c];
	
	humidity = [[[current_conditions nodesForXPath:@"humidity/@data" error:&error] objectAtIndex:0] stringValue];
	wind = [[[current_conditions nodesForXPath:@"wind_condition/@data" error:&error] objectAtIndex:0] stringValue];
	condition = [[[current_conditions nodesForXPath:@"condition/@data" error:&error] objectAtIndex:0] stringValue];
	
	// Forecast Conditions ////////////////////////////////////////
	
	// Day names
	NSArray *nodes;
	[days release];
	days = [[NSMutableArray alloc] init];
	nodes = [weather nodesForXPath:@"forecast_conditions/day_of_week/@data" error:&error];
	for (GDataXMLElement *node in nodes) {
		[days addObject:[node stringValue]];
	}
	
	// Icons
	[icons release];
	icons = [[NSMutableArray alloc] init];
	nodes = [weather nodesForXPath:@"forecast_conditions/icon/@data" error:&error];
	for (GDataXMLElement *node in nodes) {
		[icons addObject:[NSString stringWithFormat:@"http://www.google.com%@", [node stringValue]]];
	}
	
	// Temperatures (high and low)
	NSMutableArray *highs = [[NSMutableArray alloc] init];
	NSMutableArray *lows = [[NSMutableArray alloc] init];
	nodes = [weather nodesForXPath:@"forecast_conditions/high/@data" error:&error];
	for (GDataXMLElement *node in nodes) {
		[highs addObject:[node stringValue]];
	}
	nodes = [weather nodesForXPath:@"forecast_conditions/low/@data" error:&error];
	for (GDataXMLElement *node in nodes) {
		[lows addObject:[node stringValue]];
	}
	[temps release];
	temps = [[NSMutableArray alloc] init];
	for (NSUInteger i = 0u, mcount = MIN(highs.count, lows.count); i < mcount; i++) {
		[temps addObject:[NSString stringWithFormat:@"%@F/%@F", [highs objectAtIndex:i], [lows objectAtIndex:i]]];
	}
	[highs release];
	[lows release];
	
	// Conditions
	[conditions release];
	conditions = [[NSMutableArray alloc] init];
	nodes = [weather nodesForXPath:@"forecast_conditions/condition/@data" error:&error];
	for (GDataXMLElement *node in nodes) {
		[conditions addObject:[node stringValue]];
	}

    [doc release];
	
	[viewController updateView];
}

@end
