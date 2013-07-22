//
//  TimeView.h
//  ClockBuilder
//
//  Created by Gustavo Tandeciarz on 3/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RRSGlowLabel.h"

@interface TimeView : UIView <UIGestureRecognizerDelegate>{
    


}
/*
 @property (nonatomic, retain) CustomFontMyFont* hourLabel;
@property (nonatomic, retain) CustomFontMyFont* minuteLabel;
@property (nonatomic, retain) CustomFontMyFont* colonLabel;
 */
@property (nonatomic, retain) RRSGlowLabel* textLabel;
@property (nonatomic, retain) NSDateFormatter *hourFormatter;
@property (nonatomic, retain) NSDateFormatter *minuteFormatter;
@property (nonatomic, retain) NSDateFormatter *timeFormatter;

-(void) setDateFormat;
-(void) updateView;

@end
