//
//  GlowColorSliderPickerView.h
//  ClockBuilder
//
//  Created by Gustavo Tandeciarz on 4/24/12.
//  Copyright (c) 2012 GMTAZ.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RRSGlowLabel.h"
#import <QuartzCore/QuartzCore.h>

@interface GlowColorSliderPickerView : UIView
{
    
    UISlider *sliderR;
    UISlider *sliderG;
    UISlider *sliderB;
    UISlider *sliderA;
    UISlider *sliderAmount;
    RRSGlowLabel *exampleLabel;
    UIButton *dimView;
    UIButton *whiteButton;
    UIButton *blackButton;
    UIView *sliderView;
}

-(void)setSliderValuesFromColor:(UIColor *)color andAmount:(float)amount;
-(void)activateInView:(UIView *)view withColor:(UIColor *)color andGlowAmount:(float)amount;

@end
