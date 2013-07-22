//
//  getReverseGeoCode5.m
//  ClockBuilder
//
//  Created by Gustavo Tandeciarz on 4/22/12.
//  Copyright (c) 2012 GMTAZ.com. All rights reserved.
//

#import "getReverseGeoCode5.h"

@implementation getReverseGeoCode5

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
    if(!CLController){
        CLController = [[CoreLocationController alloc] init];
        CLController.delegate = self;
    }
    _updatedLocation = NO;
    [CLController.locMgr startUpdatingLocation];
    
}
-(void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error{
    
    NSLog(@"error getting location:%@", error);
    
    _updatedLocation = NO;
    
}
- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark  
                                                                        *)placemark
{
    [self.delegate updatePlaceMark:placemark];
    
    
}


- (void) getReverseGeoCode:(CLLocation *)location
{
    
     reverseGeocoder = [[CLGeocoder alloc] init];
    
    [reverseGeocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error){
       
        
     if([placemarks count]>0)
         [self.delegate updatePlaceMark:[placemarks objectAtIndex:0]];
        else{
            if (error) {
                NSLog(@"error reverseGeocode: %@",[error localizedDescription]);
                
            }
        }
     }];
    
    //[reverseGeocoder start];
}



@end
