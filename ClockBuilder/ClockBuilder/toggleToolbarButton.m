//
//  toggleToolbarButton.m
//  ClockBuilder
//
//  Created by gtadmin on 7/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "toggleToolbarButton.h"

@implementation toggleToolbarButton

@synthesize alignmentIcon;

-(void)hidetoolbar
{
    toolbarHidden = YES;
    [alignmentIcon setImage:[UIImage imageNamed:@"toolbarHideButtonUp.png"]];
    [self.window.rootViewController performSelector:@selector(toggleToolbar:) withObject:@"hide"]; 
    
}
-(void)showtoolbar
{
    toolbarHidden = NO;
    [alignmentIcon setImage:[UIImage imageNamed:@"toolbarHideButton.png"]];
    [self.window.rootViewController performSelector:@selector(toggleToolbar:) withObject:@"show"]; 
    
}
-(void)resetToolbar
{
    toolbarHidden = NO;
    [alignmentIcon setImage:[UIImage imageNamed:@"toolbarHideButton.png"]];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}


- (void)tapPiece:(id)sender
{
    if(!toolbarHidden)
    {
        [self hidetoolbar];
    }
    else
    {
        [self showtoolbar];
    }
    
}
-(void)build
{
    toolbarHidden = NO;
    [self setShowsTouchWhenHighlighted:YES];
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, 40, 40)];
    //UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPiece:)];
    [self addTarget:self action:@selector(tapPiece:) forControlEvents:UIControlEventTouchUpInside];
    self.layer.cornerRadius = 20;
    self.layer.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.7].CGColor;
    self.layer.borderColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0].CGColor;
    self.layer.borderWidth = 4;
    alignmentIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"toolbarHideButton.png"]];
    [alignmentIcon setContentMode:UIViewContentModeScaleAspectFit];
    [alignmentIcon setFrame:CGRectMake(7, 7, 26, 26)];
    [alignmentIcon setBackgroundColor:[UIColor clearColor]];
    [self addSubview:alignmentIcon];
}


@end
