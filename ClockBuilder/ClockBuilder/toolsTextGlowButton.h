//
//  toolsTextGlowButton.h
//  ClockBuilder
//
//  Created by gtadmin on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "RRSGlowLabel.h"


@interface toolsTextGlowButton : UIButton <UIActionSheetDelegate>{
    IBOutlet UISlider *sliderR;
    IBOutlet UISlider *sliderG;
    IBOutlet UISlider *sliderB;
    IBOutlet UISlider *sliderA;
    IBOutlet UISlider *sliderGlowAmount;
    IBOutlet UIView *sliderView;
    UIPopoverController *pop;
}
@property (nonatomic, strong) UIActionSheet *pickerAS;
@property (nonatomic, strong) RRSGlowLabel *fontButtonLabel;

-(void)build;
-(void)updateGlow:(UIColor *)color intensity:(float)intensity;
-(void)setSliderValuesFromColor:(UIColor *)color intensity:(float)intensity;

@end
