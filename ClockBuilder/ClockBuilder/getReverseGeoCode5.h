//
//  getReverseGeoCode5.h
//  ClockBuilder
//
//  Created by Gustavo Tandeciarz on 4/22/12.
//  Copyright (c) 2012 GMTAZ.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "CoreLocationController.h"

@protocol getReverseGeoCode5Delegate
@required

- (void) updatePlaceMark:(MKPlacemark*)newPlacemark;

@end

@interface getReverseGeoCode5 : NSObject<CoreLocationControllerDelegate, CLLocationManagerDelegate> {
    CoreLocationController *CLController;
    
    CLGeocoder *reverseGeocoder;
    BOOL _updatedLocation;
    
}
@property (nonatomic, retain) CoreLocationController *CLController;
@property (nonatomic, strong) id delegate;
@property (nonatomic, strong) CLGeocoder *reverseGeocoder;


- (void) getReverseGeoCode:(CLLocation *)location;
- (void) start;



@end
