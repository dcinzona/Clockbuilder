//
//  getWeatherData.h
//  ClockBuilder
//
//  Created by Gustavo Tandeciarz on 3/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "getReverseGeoCode.h"
#import "getReverseGeoCode5.h"
#import <MapKit/MapKit.h>
#import "xmlWeatherParser.h"
@protocol getWeatherDataDelegate
@optional
- (void)getLocationsArray:(NSArray *)locationNames woeidsArray:(NSArray *)woeids;
- (void)refreshWithNewWeatherData;

@end


@interface getWeatherData : NSObject <getReverseGeoCodeDelegate, getReverseGeoCode5Delegate, xmlWeatherParserDelegate>  {
#ifdef __IPHONE_5_0
    getReverseGeoCode5 * gr;
#else
    getReverseGeoCode * gr;
#endif
    MKPlacemark * placemark;
    id delegate;
    NSNumber * timerInterval;
    xmlWeatherParser *parser;
    BOOL _valid;
    BOOL _updatingLocation;

}
-(void) start;
-(void) stop;
-(void) forceWeatherRefresh;
-(void) getCurrentLocationAndRefresh;
-(void) parseLocations: (NSString *)location;
-(void) getLocationFromPlacemark;
-(NSDictionary*)getWeatherForLocation:(NSString*)WOEID;
- (void) setWeatherData:(NSMutableDictionary *)weatherData;
- (void) setWeatherData:(NSMutableDictionary *)weatherData placeName:(NSString *)name;
#ifdef __IPHONE_5_0
@property (strong, nonatomic) getReverseGeoCode5 *gr;
#else
@property (strong, nonatomic) getReverseGeoCode *gr;
#endif
@property (strong, nonatomic) MKPlacemark *placemark;
@property (nonatomic, retain) xmlWeatherParser *parser;
@property (nonatomic, strong) id delegate;
@property (nonatomic, strong) NSNumber *timerInterval;

@end
