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
    dispatch_queue_t queue;
}


@property (strong, nonatomic) RRSGlowLabel* textLabel;
//@property (nonatomic, retain) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) NSMutableDictionary *widgetData;
@property (strong, nonatomic) NSDictionary *weatherData;
@property (strong, nonatomic) NSNumber *indexInList;
@property (strong,nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSMutableArray *widgetsList;


- (NSNumber *) getIndexInList;
-(void) setWidgetFontSizeForClimaconWithFloat:(float)number;
-(void) updateFrameForFontSize;
- (id) initWithFrame:(CGRect)frame widgetData:(NSDictionary *)widgetDataDict indexValue:(NSNumber*)index;

- (void) refreshWithNewWeatherData;

- (UIColor*) getGlowColor;
- (void) setTimer;
- (NSTextAlignment) setTextAlignment;
- (NSString *) transformGivenText:(NSString *)str;
- (void)setTextAlignmentTo:(NSString *)align;
- (BOOL) getIsClimacon;
- (void) setWidgetFontSize:(NSNumber *)number;
- (int) getWidgetFontSize;
@end
