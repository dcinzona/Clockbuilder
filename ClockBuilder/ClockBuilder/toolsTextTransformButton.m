//
//  toolsTextTransformButton.m
//  ClockBuilder
//
//  Created by Gustavo Tandeciarz on 4/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "toolsTextTransformButton.h"


@implementation toolsTextTransformButton
@synthesize fontLabel;

-(void)transformUpper
{
    [fontLabel setText:[fontLabel.text uppercaseString]];
    [self.window.rootViewController performSelector:@selector(updateTextTransform:) withObject:@"uppercase"]; 
    
}
-(void)transformLower
{
    [fontLabel setText:[fontLabel.text lowercaseString]];
    [self.window.rootViewController performSelector:@selector(updateTextTransform:) withObject:@"lowercase"]; 
    
}
-(void)transformDefault
{
    [fontLabel setText:[fontLabel.text capitalizedString]];
    [self.window.rootViewController performSelector:@selector(updateTextTransform:) withObject:@""]; 
    
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}


- (void)tapPiece:(id)sender
{
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    UIMenuItem *alignLeft = [[UIMenuItem alloc] initWithTitle:@"Uppercase" action:@selector(transformUpper)];
    UIMenuItem *alignCenter = [[UIMenuItem alloc] initWithTitle:@"Lowercase" action:@selector(transformLower)];
    UIMenuItem *alignRight = [[UIMenuItem alloc] initWithTitle:@"Default" action:@selector(transformDefault)];
    
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
    
    fontLabel = [[UILabel alloc] init];
    [fontLabel setFrame:CGRectMake(5, 5, 30, 30)];
    [fontLabel setTextAlignment:NSTextAlignmentCenter];
    [fontLabel setBackgroundColor:[UIColor clearColor]];
    [fontLabel setFont:[UIFont fontWithName:@"Helvetica" size:(30*.8)]];
    [fontLabel setAdjustsFontSizeToFitWidth:YES];
    fontLabel.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:.8];
    [fontLabel setText:@"Aa"];
    [self addSubview:fontLabel];

}


@end
