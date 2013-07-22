//
//  UIView+SubviewsRecursive.m
//  ClockBuilder
//
//  Created by Gustavo Tandeciarz on 3/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UIView+glowLabelSelections.h"

@implementation UIView (ViewHierarchyLogging)


- (UIColor*) getGlowColor
{
    if([[[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"]  objectForKey:@"widgetsList"] count]>0){
        if([[[NSUserDefaults standardUserDefaults] objectForKey:@"widgetIndex"]integerValue]<[[[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"]  objectForKey:@"widgetsList"] count]){
            NSDictionary *widgetData = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"]  objectForKey:@"widgetsList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults] objectForKey:@"widgetIndex"]integerValue]];
            NSData *colorData =[widgetData objectForKey:@"glowColor"];
            if(colorData != nil)
            {
                return (UIColor *)[NSKeyedUnarchiver unarchiveObjectWithData:colorData];
            }
        }
        else
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"widgetIndex"];
    }
    return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
}


- (void)resetRRSGlowLabel
{
    UIColor *glow = [self getGlowColor];
    for (UIView *subview in self.subviews)
    {
        if([subview class]==[RRSGlowLabel class])
        {
            [(RRSGlowLabel*)subview setGlowColor:glow];
            [(RRSGlowLabel*)subview setGlowAmount:8.0];
            [subview setNeedsDisplay];
        }
        [subview resetRRSGlowLabel];
    }
}
- (void)setSelectedGlow;
{
    for (UIView *subview in self.subviews)
    {
        if([subview class]==[RRSGlowLabel class])
        {
            [(RRSGlowLabel*)subview setGlowColor:[UIColor colorWithRed:1 green:0.0 blue:0.0 alpha:1.0]];
            [(RRSGlowLabel*)subview setGlowAmount:15.0];
            [subview setNeedsDisplay];
        }
        [subview resetRRSGlowLabel];
    }
}
@end