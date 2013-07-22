//
//  weatherSingleton.h
//  ClockBuilder
//
//  Created by Gustavo Tandeciarz on 4/29/12.
//  Copyright (c) 2012 GMTAZ.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface weatherSingleton : NSObject <CLLocationManagerDelegate,  NSXMLParserDelegate,UIActionSheetDelegate, UIPickerViewDelegate,UIPickerViewDataSource>{
    
    BOOL tryLocationName;
}


+(weatherSingleton*)sharedInstance;
-(NSString *)currentLocation;
-(NSString *)currentLocationName;
-(void)setLocation:(NSString *)loc;
-(NSDictionary *)currentWeatherData;
-(NSMutableDictionary *)getWeatherData;
-(void)saveWeatherData;
-(BOOL)isThereAWeatherWidget;
-(void)updateWeatherData;
-(NSArray *)getSingleArrayOfPlaces;
-(NSDictionary*)getWeatherForLocation:(NSString*)WOEID;
-(void)saveWeatherDataWithDictionary:(NSMutableDictionary*)data;
//Picker
-(void)setViewForPicker:(UIView *)theView;
-(NSString *)getWeatherIconSet;
-(BOOL)isClimacon;
@end
