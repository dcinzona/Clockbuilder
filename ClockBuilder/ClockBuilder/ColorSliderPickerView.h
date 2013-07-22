//
//  ColorSliderPickerView.h
//  ClockBuilder
//
//  Created by Gustavo Tandeciarz on 4/24/12.
//  Copyright (c) 2012 GMTAZ.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RRSGlowLabel.h"

@interface ColorSliderPickerView : UIView{

    UISlider *sliderR;
    UISlider *sliderG;
    UISlider *sliderB;
    UISlider *sliderA;
    RRSGlowLabel *exampleLabel;
    UIButton *dimView;
    UIButton *whiteButton;
    UIButton *blackButton;
    UIView *sliderView;
}

-(void)setSliderValuesFromColor:(UIColor *)color;
-(void)activateInView:(UIView *)view withColor:(UIColor *)color;

@end
