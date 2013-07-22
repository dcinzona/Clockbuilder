//
//  widgetTools.h
//  ClockBuilder
//
//  Created by Gustavo Tandeciarz on 4/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "toolsFontButton.h"
#import "toolsTextAlignButton.h"
#import "toolsTextTransformButton.h"
#import "toolsTextColorButton.h"
#import "toolsTextGlowButton.h"
#import "toolsTextDateFormat.h"
#import "toolsTextWeatherButton.h"
#import "toolsCustomTextButton.h"
#import "toggleToolbarButton.h"


@interface widgetTools : NSObject <UIGestureRecognizerDelegate>{
    
    IBOutlet toolsFontButton *fontButton;
    IBOutlet toolsTextAlignButton *alignmentButton;
    IBOutlet toolsTextTransformButton *transformButton;
    IBOutlet toolsTextColorButton *colorButton;
    IBOutlet toolsTextGlowButton *glowButton;
    IBOutlet toolsTextDateFormat *dateFormatButton;
    IBOutlet toolsTextWeatherButton *weatherButton;
    IBOutlet toolsCustomTextButton *customTextButton;
    IBOutlet toggleToolbarButton *toolbarToggleButton;
    BOOL _opening;
}

@property (nonatomic,retain) toolsFontButton *fontButton;
@property (nonatomic,retain) toolsTextAlignButton *alignmentButton;
@property (nonatomic,retain) toolsTextTransformButton *transformButton;
@property (nonatomic,retain) toolsTextColorButton *colorButton;
@property (nonatomic,retain) toolsTextGlowButton *glowButton;
@property (nonatomic,retain) toolsTextDateFormat *dateFormatButton;
@property (nonatomic, retain) toolsTextWeatherButton *weatherButton;
@property (nonatomic, retain) toolsCustomTextButton *customTextButton;
@property (nonatomic, retain) toggleToolbarButton *toolbarToggleButton;
@property (nonatomic,retain) NSDictionary *widgetData;

-(void)openTextTools;
-(void)closeTextTools;
-(void)makeButtons;
-(void)animateOpeningWithButton:(UIView *)v;

@end
