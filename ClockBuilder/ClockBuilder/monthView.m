//
//  monthView.m
//  ClockBuilder
//
//  Created by gtadmin on 3/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "monthView.h"


@implementation monthView
@synthesize textLabel,monthFormatter;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor: [UIColor clearColor]];
        monthFormatter = [[NSDateFormatter alloc] init];
        [monthFormatter setDateFormat:@"MMMM"];
        float digitW = self.frame.size.width *1;//.44
        float digitH = self.frame.size.height;//1
        float digitFont = self.frame.size.height*.8;//.33
        
        NSString *wClass = NSStringFromClass([self class]);
        NSDictionary *widgetData = [[[[NSUserDefaults standardUserDefaults] 
                                      objectForKey:@"settings"] 
                                     objectForKey:@"widgetsAddedData"] 
                                    objectForKey:wClass] ;
        NSString *digitsFont = [widgetData objectForKey:@"fontFamily"];
        NSData *colorData = [widgetData objectForKey:@"fontColor"];
        UIColor *fontColor = (UIColor *)[NSKeyedUnarchiver unarchiveObjectWithData:colorData];
        
        
        textLabel = [[[RRSGlowLabel alloc] initWithFrame:CGRectMake(5, 0, digitW, digitH)] autorelease];
        [textLabel setFont:[UIFont fontWithName:digitsFont size:digitFont]];
        [textLabel setBackgroundColor:[UIColor clearColor]];
        [textLabel setAdjustsFontSizeToFitWidth:YES];
        [textLabel setTextColor:fontColor];    
        [textLabel setGlowColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0]];
        [textLabel setGlowOffset:CGSizeMake(0, 0)];
        [textLabel setGlowAmount:digitFont*.10];
        [textLabel setTextAlignment:UITextAlignmentLeft];
        
        [self performSelector:@selector(setOpacity)];
        
        [self addSubview: textLabel];
        [self performSelector:@selector(updateView)];
        
    }
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

-(void) updateView 
{
	[textLabel setText:[[monthFormatter stringFromDate:[NSDate date]] uppercaseString]];
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateView) object:nil];
	NSDate* now = [NSDate date];
	NSCalendar* cal = [NSCalendar currentCalendar];
	NSDateComponents* comps = [cal components:NSMinuteCalendarUnit | NSHourCalendarUnit | NSSecondCalendarUnit fromDate:now];
	[self performSelector:@selector(updateView) withObject:nil afterDelay:(60 - comps.second)];
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc
{
    [super dealloc];
    [textLabel release];
    [monthFormatter release];
}

@end
