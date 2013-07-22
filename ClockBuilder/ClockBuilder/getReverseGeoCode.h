//
//  getReverseGeoCode.h
//  ClockBuilder
//
//  Created by gtadmin on 3/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "CoreLocationController.h"


@protocol getReverseGeoCodeDelegate
@required

- (void) updatePlaceMark:(MKPlacemark*)newPlacemark;

@end

//#warning CLGeocoder is ios 5 or greater only

@interface getReverseGeoCode : NSObject <CoreLocationControllerDelegate, CLLocationManagerDelegate> {
    CoreLocationController *CLController;
    BOOL _updatedLocation;
	id delegate;
}
@property (nonatomic, strong) CoreLocationController *CLController;
@property (nonatomic, strong) id delegate;

- (void) getReverseGeoCode:(CLLocation *)location;
- (void) start;

@end
