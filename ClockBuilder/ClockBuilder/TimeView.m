//
//  TimeView.m
//  ClockBuilder
//
//  Created by Gustavo Tandeciarz on 3/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "TimeView.h"


@implementation TimeView

@synthesize hourFormatter, minuteFormatter, textLabel, timeFormatter;


- (id) initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	[self setBackgroundColor: [UIColor clearColor]];
	timeFormatter = [[NSDateFormatter alloc] init];
    NSString *digitsFont = [[[[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"] 
                              objectForKey:@"widgetsAddedData"] 
                             objectForKey:[NSString stringWithFormat:@"%@",[self class]]] 
                            objectForKey:@"fontFamily"];
    
    //set these based on frame
    
    float digitFont = self.frame.size.height*.8;//.33
    
    NSData *colorData = [[[[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"] 
                           objectForKey:@"widgetsAddedData"] 
                          objectForKey:[NSString stringWithFormat:@"%@",[self class]]] 
                         objectForKey:@"fontColor"];
    UIColor *fontColor = (UIColor *)[NSKeyedUnarchiver unarchiveObjectWithData:colorData];
    
    textLabel = [[[RRSGlowLabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)] autorelease];
    [textLabel setTextColor:fontColor];
    [textLabel setFont:[UIFont fontWithName:digitsFont size:digitFont]];
    [textLabel setAdjustsFontSizeToFitWidth:YES];
    [textLabel setBackgroundColor:[UIColor clearColor]];
    [textLabel setGlowColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0]];
    [textLabel setGlowOffset:CGSizeMake(0, 0)];
    [textLabel setGlowAmount:digitFont*.10];
    [textLabel setTextAlignment:UITextAlignmentCenter];
    
    [self performSelector:@selector(setOpacity)];
    
    [self addSubview:textLabel];
	[self setDateFormat];
    
	return self;
}

- (void)setOpacity
{
    CGFloat opacity= 1;
    NSString *alpha = [[[[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"] 
                                       objectForKey:@"widgetsAddedData"] 
                                      objectForKey:[NSString stringWithFormat:@"%@",[self class]]] 
                                     objectForKey:@"opacity"];
    if(alpha!=nil && [alpha floatValue]>0)
    {
        opacity = [alpha floatValue];
    }
    [self setAlpha:opacity];
}

- (void)updateTime
{
    [textLabel setText:[timeFormatter stringFromDate:[NSDate date]]];
}

- (void)setDateFormat
{
	NSDateFormatter *checkDateFormatFormatter = [[NSDateFormatter alloc] init];
	[checkDateFormatFormatter setDateStyle:NSDateFormatterNoStyle];
    [checkDateFormatFormatter setTimeStyle:NSDateFormatterShortStyle];	
    NSString *dateString = [checkDateFormatFormatter stringFromDate:[NSDate date]];
    NSRange amRange = [dateString rangeOfString:[checkDateFormatFormatter AMSymbol]];
    NSRange pmRange = [dateString rangeOfString:[checkDateFormatFormatter PMSymbol]];
	
    BOOL is24Hour = (amRange.location == NSNotFound) && (pmRange.location == NSNotFound);
    
    NSString *use24h = [[[NSUserDefaults standardUserDefaults] objectForKey:@"Settings"] objectForKey:@"Use 24 Hour Time"];
    
    if([use24h isEqualToString:@"YES"])
        is24Hour = TRUE;
	if (is24Hour) {
		[hourFormatter setDateFormat:@"HH"];
	} else {
		[checkDateFormatFormatter setDateFormat:@"a"];		
		[hourFormatter setDateFormat:@"hh"];
	}
	[timeFormatter setDateFormat:@"hh:mm"];
	[minuteFormatter setDateFormat:@"mm"]; 
    
	[self updateView];
	[checkDateFormatFormatter release];
}

-(void) updateView 
{
    [self updateTime];
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateView) object:nil];
	
	NSDate* now = [NSDate date];
	NSCalendar* cal = [NSCalendar currentCalendar];
	NSDateComponents* comps = [cal components:NSMinuteCalendarUnit | NSHourCalendarUnit | NSSecondCalendarUnit fromDate:now];
	[self performSelector:@selector(updateView) withObject:nil afterDelay:(60 - comps.second)];
    
}




- (void)dealloc
{
	[hourFormatter release];
	[minuteFormatter release];
    [textLabel release];
    [timeFormatter release];
    [super dealloc];
}

@end
