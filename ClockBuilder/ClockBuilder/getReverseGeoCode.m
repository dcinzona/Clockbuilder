//
//  getReverseGeoCode.m
//  ClockBuilder
//
//  Created by gtadmin on 3/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "getReverseGeoCode.h"
#import "CoreLocationController.h"
#import "getWeatherData.h"


@implementation getReverseGeoCode

@synthesize CLController, reverseGeocoder, delegate;

- (id)init {
	self = [super init];
	
	if(self != nil) {
        
        
	}
	
	return self;
}


- (void)locationUpdate:(CLLocation *)location {
	//NSLog(@"Location: %@",[location description]);
    [CLController.locMgr stopUpdatingLocation];
    if(!_updatedLocation){
        _updatedLocation = YES;
        [self getReverseGeoCode:location];
    }
}

- (void)locationError:(NSError *)error {
	//NSLog(@"Location ERROR: %@",[error description]);
}

- (void) start
{
    CLController = [[CoreLocationController alloc] init];
    CLController.delegate = self;
    _updatedLocation = NO;
    [CLController.locMgr startUpdatingLocation];
    
}
-(void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error{
    
    NSLog(@"error getting location:%@", error);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"errorGettingLocation" object:nil userInfo:[NSDictionary dictionaryWithObject:error forKey:@"error"]];
    
}
- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark  
                                                                        *)placemark
{
    [self.delegate updatePlaceMark:placemark];
    

}


- (void) getReverseGeoCode:(CLLocation *)location
{
    
    reverseGeocoder = [[MKReverseGeocoder alloc] initWithCoordinate:location.coordinate];

    [reverseGeocoder setDelegate:self];
    [reverseGeocoder start];
}


@end
