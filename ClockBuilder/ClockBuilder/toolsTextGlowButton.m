//
//  toolsTextGlowButton.m
//  ClockBuilder
//
//  Created by gtadmin on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "toolsTextGlowButton.h"


@implementation toolsTextGlowButton
@synthesize pickerAS,
fontButtonLabel;

-(void)build{
    [self setShowsTouchWhenHighlighted:YES];
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, 40, 40)];
    [self addTarget:self action:@selector(fontButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    self.layer.cornerRadius = 20;
    self.layer.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:.7].CGColor;
    self.layer.borderColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0].CGColor;
    self.layer.borderWidth = 4;
    fontButtonLabel = [[RRSGlowLabel alloc] init];
    [fontButtonLabel setFrame:CGRectMake(5, 5, 30, 30)];
    [fontButtonLabel setTextAlignment:UITextAlignmentCenter];
    [fontButtonLabel setBackgroundColor:[UIColor clearColor]];
    [fontButtonLabel setFont:[UIFont fontWithName:@"Helvetica" size:(30*.8)]];
    fontButtonLabel.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:.8];
    [fontButtonLabel setText:@"A"];
    [self addSubview:fontButtonLabel];
    NSString *title =@"\n\n\n\n\n\n\n\n\n\n\n";
    if(kIsiOS7){
        title =@"\n\n\n\n\n\n\n\n\n\n\n\n";
    }
    pickerAS = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    [pickerAS addSubview:sliderView];  
}

-(void)updateGlow:(UIColor *)color intensity:(float)intensity
{
    [fontButtonLabel setGlowColor:color];
    [fontButtonLabel setGlowAmount:intensity];
    [fontButtonLabel setNeedsDisplay];
}

- (NSString *)colorSpaceString:(UIColor *)color {
	switch (CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor))) {
		case kCGColorSpaceModelUnknown:
			return @"kCGColorSpaceModelUnknown";
		case kCGColorSpaceModelMonochrome:
			return @"kCGColorSpaceModelMonochrome";
		case kCGColorSpaceModelRGB:
			return @"kCGColorSpaceModelRGB";
		case kCGColorSpaceModelCMYK:
			return @"kCGColorSpaceModelCMYK";
		case kCGColorSpaceModelLab:
			return @"kCGColorSpaceModelLab";
		case kCGColorSpaceModelDeviceN:
			return @"kCGColorSpaceModelDeviceN";
		case kCGColorSpaceModelIndexed:
			return @"kCGColorSpaceModelIndexed";
		case kCGColorSpaceModelPattern:
			return @"kCGColorSpaceModelPattern";
		default:
			return @"Not a valid color space";
	}
}
-(void)setSliderValuesFromColor:(UIColor *)color intensity:(float)intensity
{
    
    if(!color){
        color = [UIColor whiteColor];
    }
    if(color == [UIColor whiteColor])
        color = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
    if(color == [UIColor blackColor])
        color = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    
    const float* rgba = CGColorGetComponents(color.CGColor);
    float r = rgba[0];
    float g = rgba[1];
    float b = rgba[2];
    float a = rgba[3];
    
    //NSLog(@"color space model: %@", [self colorSpaceString:color]);
    if(CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor))==kCGColorSpaceModelMonochrome)
    {
        r = g = b = rgba[0];
        a = rgba[1];
    }
    sliderA.value = a;
    sliderB.value = b;
    sliderG.value = g;
    sliderR.value = r;
    sliderGlowAmount.value = intensity;
}
#pragma mark Slider Actions

- (IBAction)changeColor: (id)sender {  
    UIColor *newColor = [UIColor colorWithRed:sliderR.value green:sliderG.value blue:sliderB.value alpha:sliderA.value];
    NSString *intensity = [NSString stringWithFormat:@"%f", sliderGlowAmount.value];
    [self.window.rootViewController performSelector:@selector(updateTextGlow:intensity:) withObject:newColor withObject:intensity];      
}
//saveTextGlow:(UIColor *)newColor intensity:(NSString *)intensity
#pragma mark ActionSheet stuff

-(void)fontButtonClick:(id)sender
{
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    toolbar.barStyle = UIBarStyleBlackOpaque;
    if(!kIsIpad){
        [toolbar sizeToFit];
    }
    [CBThemeHelper setBackgroundImage:nil forToolbar:toolbar];
    NSMutableArray *barItems = [[NSMutableArray alloc] init];
    UIBarButtonItem *cancelBtn = [CBThemeHelper createDarkButtonItemWithTitle:@"Cancel" target:self action:@selector(dismissActionSheet)];
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];  
    UIBarButtonItem *doneBtn = [CBThemeHelper createBlueButtonItemWithTitle:@"Done" target:self action:@selector(saveActionSheet)];
    UILabel *titleLabel = [[UILabel alloc] init];
    [titleLabel setText:@"Set Color"];
    [titleLabel setShadowColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:.5]];
    [titleLabel setShadowOffset:CGSizeMake(0, -1.0)];
    [titleLabel setFrame:CGRectMake(0, 0, 150, 22)];
    [titleLabel setTextAlignment:UITextAlignmentCenter];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    UIBarButtonItem *titleItem = [[UIBarButtonItem alloc] initWithCustomView:titleLabel];
    [titleItem setStyle:UIBarButtonItemStylePlain];
    [barItems addObject:cancelBtn];
    [barItems addObject:flexSpace];  
    [barItems addObject:titleItem];
    [barItems addObject:flexSpace];
    [barItems addObject:doneBtn];
    [toolbar setItems:barItems animated:YES];
    [pickerAS addSubview:toolbar];    
    [pickerAS setBounds:CGRectMake(0,0,320, 400)];    
    [self setSliderValuesFromColor:fontButtonLabel.glowColor intensity:fontButtonLabel.glowAmount];
    if(kIsiOS7){
        [titleLabel setCenter:toolbar.center];
        [titleLabel setShadowColor:nil];
        [titleLabel setTextColor:[UIColor darkGrayColor]];
        [pickerAS setBackgroundColor:[UIColor whiteColor]];
        [sliderView setBackgroundColor:[UIColor whiteColor]];
        [sliderView setFrame:CGRectMake(0, 20, sliderView.frame.size.width, sliderView.frame.size.height)];
        [toolbar setFrame:CGRectMake(0, 0, toolbar.frame.size.width, toolbar.frame.size.height)];
        [pickerAS setBounds:CGRectMake(0,0,320, 340)];
        for (UIView *lbl in sliderView.subviews) {
            if([NSStringFromClass(lbl.class) isEqualToString:NSStringFromClass(UILabel.class)]){
                NSString * lblcolor = [NSString stringWithFormat:@"%@",[(UILabel*)lbl textColor]];
                NSString * whitecolor = [NSString stringWithFormat:@"%@",[UIColor colorWithRed:1 green:1 blue:1 alpha:1]];
                if([lblcolor isEqualToString:whitecolor]){
                    [(UILabel *)lbl setTextColor:[UIColor darkGrayColor]];
                }
            }
        }
    }
    
    if(kIsIpad){
        UIView *v = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 225)];
        UIViewController *vc = [[UIViewController alloc]init];
        [vc setContentSizeForViewInPopover:CGSizeMake(320, 225)];
        [v addSubview:sliderView];
        [v addSubview:toolbar];
        [vc setView:v];
        [sliderView setBackgroundColor:[UIColor viewFlipsideBackgroundColor]];
        if(!pop)
            pop = [[UIPopoverController alloc] initWithContentViewController:vc];
        [pop setContentViewController:vc];
        [pop presentPopoverFromRect:self.frame inView:ApplicationDelegate.viewController.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        //[pickerAS showFromRect:self.frame inView:self.window.rootViewController.view animated:YES];
    }
    else{
        [pickerAS showInView:self.window.rootViewController.view];
    }
    
}

-(void)dismissActionSheet{
    [pickerAS dismissWithClickedButtonIndex:0 animated:YES];
    if(kIsIpad && pop){
        [pop dismissPopoverAnimated:YES];
    }
    [self.window.rootViewController performSelector:@selector(updateTextGlow:intensity:) withObject:fontButtonLabel.glowColor withObject:[NSString stringWithFormat:@"%f", fontButtonLabel.glowAmount]];        
}


-(void)saveActionSheet{
    [pickerAS dismissWithClickedButtonIndex:1 animated:YES];
    if(kIsIpad && pop){
        [pop dismissPopoverAnimated:YES];
    }
    UIColor *newColor = [UIColor colorWithRed:sliderR.value green:sliderG.value blue:sliderB.value alpha:sliderA.value];
    NSString *intensity = [NSString stringWithFormat:@"%f", sliderGlowAmount.value];
    [self.window.rootViewController performSelector:@selector(saveTextGlow:intensity:) withObject:newColor withObject:intensity];        
}


@end
