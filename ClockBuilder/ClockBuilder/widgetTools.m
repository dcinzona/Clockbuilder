//
//  widgetTools.m
//  ClockBuilder
//
//  Created by Gustavo Tandeciarz on 4/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "widgetTools.h"


@implementation widgetTools
@synthesize fontButton,
alignmentButton,
transformButton,
colorButton,
glowButton,
dateFormatButton,
weatherButton,
widgetData,
customTextButton,
toolbarToggleButton;



-(void)openTextTools
{    
    _opening = YES;
    NSArray *buttons = [NSArray arrayWithObjects:fontButton,alignmentButton,transformButton,colorButton,glowButton,dateFormatButton,toolbarToggleButton, nil];
    //if([[weatherSingleton sharedInstance] isClimacon]){
    //    buttons = [NSArray arrayWithObjects:colorButton,glowButton,dateFormatButton,toolbarToggleButton, nil];
    //}
    float delay = .05;
    for (UIView *v in buttons) {
        [self performSelector:@selector(animateOpeningWithButton:) withObject:v afterDelay:delay];
        delay +=.05;
    }
}
-(void)closeTextTools
{    
    _opening = NO;
    NSArray *buttons = [NSArray arrayWithObjects:fontButton,alignmentButton,transformButton,colorButton,glowButton,dateFormatButton,toolbarToggleButton, nil];
    float delay = .05;

    for (UIView *v in buttons) {
        [self performSelector:@selector(animateOpeningWithButton:) withObject:v afterDelay:delay];
        delay +=.05;
    }
    //UIWindow * window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    [toolbarToggleButton performSelector:@selector(resetToolbar)];
    //[window.rootViewController performSelector:@selector(toggleToolbar:) withObject:@"show"];
    
}
-(void)animateOpeningWithButton:(UIView *)v
{
    
    NSInteger xRate = 45;
    if(!_opening)
        xRate = -45;
    
    CGRect frameToOpen = CGRectMake(5, v.frame.origin.y, v.frame.size.width, v.frame.size.height);
    
    CGRect frameToClose = CGRectMake(-40, v.frame.origin.y, v.frame.size.width, v.frame.size.height);
    
    CGRect FrameToUse = frameToOpen;
    if(!_opening)
        FrameToUse = frameToClose;
    
    if([v class] != [dateFormatButton class]){
        [UIView animateWithDuration:.2
                         animations:^{
                             v.alpha = 1;
                             //v.transform = CGAffineTransformTranslate(v.transform, xRate,0);
                             [v setFrame:FrameToUse];
                         }
                         completion:^(BOOL finished){                               
                             //NSLog(@"frame x: %f", v.frame.origin.x);
                         }];    
    }
    else
    {
        [UIView animateWithDuration:.2
                         animations:^{
                             dateFormatButton.alpha = 1;
                             //dateFormatButton.transform = CGAffineTransformTranslate(dateFormatButton.transform, xRate,0);
                             [dateFormatButton setFrame:FrameToUse];
                             weatherButton.alpha = 1;
                             //weatherButton.transform = CGAffineTransformTranslate(weatherButton.transform, xRate,0);
                             [weatherButton setFrame:FrameToUse];
                             customTextButton.alpha = 1;
                             //customTextButton.transform = CGAffineTransformTranslate(customTextButton.transform, xRate,0);
                             [customTextButton setFrame:FrameToUse];
                         }
                         completion:^(BOOL finished){  
                         }];    
    }
}


-(void)makeButtons
{
    [fontButton build];    
    [alignmentButton build];
    [transformButton build];
    [colorButton build];
    [glowButton build];
    [dateFormatButton build];
    [weatherButton build];
    [customTextButton build];
    [toolbarToggleButton build];
}



@end
