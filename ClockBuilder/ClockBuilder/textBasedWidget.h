//
//  textBasedWidget.h
//  ClockBuilder
//
//  Created by gtadmin on 3/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RRSGlowLabel.h"

@interface textBasedWidget : UIView {
    NSDateFormatter *dateFormatter;
    NSNumber * indexInList;
    BOOL shouldUpdate;
    BOOL isWeather;
    BOOL isClimacon;
}


@property (strong, nonatomic) RRSGlowLabel* textLabel;
//@property (nonatomic, retain) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) NSMutableDictionary *widgetData;
@property (strong, nonatomic) NSDictionary *weatherData;
@property (strong, nonatomic) NSNumber *indexInList;
@property (strong,nonatomic) NSTimer *timer;


- (NSNumber *) getIndexInList;
- (id) initWithFrame:(CGRect)frame widgetData:(NSDictionary *)widgetDataDict indexValue:(NSNumber*)index;

- (void) refreshWithNewWeatherData;

- (UIColor*) getGlowColor;
- (void) setTimer;
- (UITextAlignment) setTextAlignment;
- (NSString *)transformGivenText:(NSString *)str;
- (void)setTextAlignmentTo:(NSString *)align;


@end
