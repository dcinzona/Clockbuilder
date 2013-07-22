//
//  CoreLocationController.h
//  CoreLocationDemo
//
//  Created by Nicholas Vellios on 8/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@protocol CoreLocationControllerDelegate
@required

- (void)locationUpdate:(CLLocation *)location;
- (void)locationError:(NSError *)error;

@end


@interface CoreLocationController : NSObject <CLLocationManagerDelegate> {
	CLLocationManager * locMgr;
	id _delegate;

}

@property (strong, nonatomic) CLLocationManager *locMgr;
@property (nonatomic, assign) id delegate;

@end

/*
#if TARGET_IPHONE_SIMULATOR 
@interface CLLocationManager (Simulator)
@end

@implementation CLLocationManager (Simulator)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
-(void)startUpdatingLocation {
    CLLocation *powellsTech = [[CLLocation alloc] initWithLatitude:22.28486800 longitude:114.15828440];
    [self.delegate locationManager:self
               didUpdateToLocation:powellsTech
                      fromLocation:powellsTech];
    
}

@end
#pragma clang diagnostic pop

#endif // TARGET_IPHONE_SIMULATOR
 
*/