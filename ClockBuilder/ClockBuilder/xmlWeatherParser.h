//
//  xmlWeatherParser.h
//  ClockBuilder
//
//  Created by Gustavo Tandeciarz on 3/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol xmlWeatherParserDelegate <NSObject>

-(void)getArrayOfPlaces:(NSArray*)array woeidArray:(NSArray *)woeids;

@end


@interface xmlWeatherParser : NSObject <NSXMLParserDelegate> {
    
    NSString * locationsString;  
    NSMutableArray * locationsArray;
	NSMutableArray * zips;
	NSMutableArray * places;
	NSMutableDictionary * item;
    NSDictionary *validatedLocation;
	NSMutableString * locID;
    NSNumber *selectedLocation;
	NSString * currentElement;
    NSString *_postalString;
	//id delegate;
}
-(id )initWithLocation:(NSString *)locationStr;
- (void)parseXMLFileAtURL:(NSString *)URL;

@property (nonatomic, strong) NSXMLParser * rssParser;
@property (nonatomic, retain) NSString * locationsString;
@property (nonatomic, retain) NSString * unitString;
@property (nonatomic, retain) NSMutableArray * locationsArray;
@property (nonatomic, retain) NSDictionary *validatedLocation;
@property (nonatomic, assign) id delegate;

@end
