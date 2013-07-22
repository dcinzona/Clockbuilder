//
//  toolsTextColorButton.h
//  ClockBuilder
//
//  Created by Gustavo Tandeciarz on 4/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>



@interface toolsTextColorButton : UIButton <UIActionSheetDelegate, UIPopoverControllerDelegate>{
    IBOutlet UISlider *sliderR;
    IBOutlet UISlider *sliderG;
    IBOutlet UISlider *sliderB;
    IBOutlet UISlider *sliderA;
    IBOutlet UIView *sliderView;
    UIPopoverController *pop;
}
@property (nonatomic, strong) UIActionSheet *pickerAS;
@property (nonatomic, strong) UILabel *fontButtonLabel;

-(void)build;
-(void)updateBorderColor:(UIColor *)color;
-(void)setSliderValuesFromColor:(UIColor *)color;

@end
