//
//  toolsTextAlignButton.m
//  ClockBuilder
//
//  Created by Gustavo Tandeciarz on 4/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "toolsTextAlignButton.h"


@implementation toolsTextAlignButton
@synthesize alignmentIcon;

-(void)alignLeft
{
    [alignmentIcon setImage:[UIImage imageNamed:@"alignLeft.png"]];
    [self.window.rootViewController performSelector:@selector(updateTextAlignment:) withObject:@"left"]; 
    
}
-(void)alignCenter
{
    [alignmentIcon setImage:[UIImage imageNamed:@"alignCenter.png"]];
    [self.window.rootViewController performSelector:@selector(updateTextAlignment:) withObject:@"center"]; 
    
}
-(void)alignRight
{
    [alignmentIcon setImage:[UIImage imageNamed:@"alignRight.png"]];
    [self.window.rootViewController performSelector:@selector(updateTextAlignment:) withObject:@"right"]; 
    
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}


- (void)tapPiece:(id)sender
{
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    UIMenuItem *alignLeft = [[UIMenuItem alloc] initWithTitle:@"Left" action:@selector(alignLeft)];
    UIMenuItem *alignCenter = [[UIMenuItem alloc] initWithTitle:@"Center" action:@selector(alignCenter)];
    UIMenuItem *alignRight = [[UIMenuItem alloc] initWithTitle:@"Right" action:@selector(alignRight)];
    
    [self becomeFirstResponder];
    [menuController setMenuItems:[NSArray arrayWithObjects:alignLeft, alignCenter, alignRight,nil]];
    [menuController setTargetRect:CGRectMake(40, 20, 0, 0) inView:self];
    [menuController setArrowDirection:UIMenuControllerArrowDefault];
    [menuController setMenuVisible:YES animated:YES];
    
    
    
}
-(void)build
{
    [self setShowsTouchWhenHighlighted:YES];
    //UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPiece:)];
    [self addTarget:self action:@selector(tapPiece:) forControlEvents:UIControlEventTouchUpInside];
    self.layer.cornerRadius = 20;
    self.layer.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.7].CGColor;
    self.layer.borderColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0].CGColor;
    self.layer.borderWidth = 4;
    alignmentIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"alignLeft.png"]];
    [alignmentIcon setContentMode:UIViewContentModeScaleAspectFit];
    [alignmentIcon setFrame:CGRectMake(7, 7, 26, 26)];
    [alignmentIcon setBackgroundColor:[UIColor clearColor]];
    [self addSubview:alignmentIcon];
}


@end
