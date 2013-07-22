//
//  GetWeatherData2.h
//  ClockBuilder
//
//  Created by Gustavo Tandeciarz on 4/26/12.
//  Copyright (c) 2012 GMTAZ.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "getReverseGeoCode.h"
#import "getReverseGeoCode5.h"
#import <MapKit/MapKit.h>
#import "xmlWeatherParser.h"

@interface GetWeatherData2 : NSObject{
    
#ifdef __IPHONE_5_0
    getReverseGeoCode5 * gr;
#else
    getReverseGeoCode * gr;
#endif
    MKPlacemark * placemark;
    
    NSNumber * timerInterval;
    xmlWeatherParser *parser;
    BOOL _valid;
    
}



@end
