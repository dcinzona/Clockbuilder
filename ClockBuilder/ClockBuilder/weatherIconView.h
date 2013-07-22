//
//  weatherIconView.h
//  ClockBuilder
//
//  Created by Gustavo Tandeciarz on 3/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "getWeatherData.h"


@interface weatherIconView : UIView{
    NSString * iconID;
    NSString * widgetIconSet;
    NSNumber * indexInList;
}
-(id) initWithFrame:(CGRect)frame widgetData:(NSDictionary *)widgetDataDict indexValue:(NSNumber*)index;
-(UIImage *)getIconImage;
-(NSNumber *) getIndexInList;
-(NSString *)isDayOrNight;

@property (strong, nonatomic) NSMutableDictionary *widgetData;
@property (strong, nonatomic) NSDictionary *weatherData;
@property (strong, nonatomic) NSString *iconID;
@property (strong, nonatomic) NSString *widgetIconSet;
@property (strong, nonatomic) UIImageView *icon;
@property (strong, nonatomic) NSNumber *indexInList;

@end
