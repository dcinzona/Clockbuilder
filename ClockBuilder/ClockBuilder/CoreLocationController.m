//
//  CoreLocationController.m
//  CoreLocationDemo
//
//  Created by Nicholas Vellios on 8/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CoreLocationController.h"


@implementation CoreLocationController

@synthesize locMgr, delegate;

- (id)init {
	self = [super init];
	
	if(self != nil) {		
    	self.locMgr = [[CLLocationManager alloc] init];
		self.locMgr.delegate = self;
        [self.locMgr setDesiredAccuracy:1000];
	}
	
	return self;
}
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	if([self.delegate conformsToProtocol:@protocol(CoreLocationControllerDelegate)]) {
		[self.delegate locationUpdate:newLocation];
        [self.locMgr stopUpdatingLocation];
	}
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	if([self.delegate conformsToProtocol:@protocol(CoreLocationControllerDelegate)]) {
		[self.delegate locationError:error];
	}
}

- (void)dealloc {
	self.locMgr = nil;
}

@end
