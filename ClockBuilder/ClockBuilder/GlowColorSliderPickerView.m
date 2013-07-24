//
//  GlowColorSliderPickerView.m
//  ClockBuilder
//
//  Created by Gustavo Tandeciarz on 4/24/12.
//  Copyright (c) 2012 GMTAZ.com. All rights reserved.
//

#import "GlowColorSliderPickerView.h"

@implementation GlowColorSliderPickerView

-(void)activateInView:(UIView *)view withColor:(UIColor *)color andGlowAmount:(float)amount{
    [self setSliderValuesFromColor:color andAmount:amount];
    //[pickerAS showInView:view];
    int screenHeight = 480;
    if(!kIsIpad){
        screenHeight = [UIScreen mainScreen].bounds.size.height;
    }
    [sliderView setFrame:CGRectMake(0, screenHeight, 320, 230)];
    dimView = [UIButton buttonWithType:UIButtonTypeCustom];
    [dimView setFrame:self.frame];
    [dimView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:.5]];
    [dimView setAlpha:0];
    [self addSubview:dimView];
    //[dimView addTarget:self action:@selector(dismissView) forControlEvents:UIControlEventTouchUpInside];
        
    [self setFrame:CGRectMake(0, 0, 320, screenHeight)];
    [self addSubview:sliderView];
    [self addSubview:whiteButton];
    [self addSubview:blackButton];
    UIImageView *ds = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tvFooterBG.png"]];
    [ds setFrame:CGRectMake(0, 44, 320, 10)];
    [ds setContentMode:UIViewContentModeTop];
    [ds setBackgroundColor:[UIColor clearColor]];
    [sliderView addSubview:ds];
    
    [exampleLabel setGlowColor:color];
    [exampleLabel setGlowAmount:amount];
    
    float slidertop = 230;
    if(kIsIpad){
        slidertop = 240;
        if(kIsiOS7){
            slidertop = sliderView.bounds.size.height+55;//toolbar + 16
        }
    }
    
    if(!kIsIpad)
        [view.window addSubview:self];
    else
        [view addSubview:self];
    [whiteButton setFrame:CGRectMake(whiteButton.frame.origin.x, whiteButton.frame.origin.y-80, whiteButton.frame.size.width, whiteButton.frame.size.height)];
    [blackButton setFrame:CGRectMake(blackButton.frame.origin.x, blackButton.frame.origin.y-80, blackButton.frame.size.width, blackButton.frame.size.height)];
    blackButton.layer.borderColor = [UIColor colorWithRed:0.01 green: 0.42 blue: 1 alpha: 1].CGColor;
    [UIView animateWithDuration:.2 animations:^{
        [dimView setAlpha:1];
        [sliderView setFrame:CGRectMake(0, screenHeight-slidertop, 320, 230)];
        [whiteButton setFrame:CGRectMake(whiteButton.frame.origin.x, whiteButton.frame.origin.y+80, whiteButton.frame.size.width, whiteButton.frame.size.height)];
        [blackButton setFrame:CGRectMake(blackButton.frame.origin.x, blackButton.frame.origin.y+80, blackButton.frame.size.width, blackButton.frame.size.height)];
    }];
}
-(void)darkenDimView{
    blackButton.layer.borderColor = [UIColor colorWithRed:0.01 green: 0.42 blue: 1 alpha: 1].CGColor;
    whiteButton.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha: 1].CGColor;
    [blackButton setNeedsLayout];
    [whiteButton setNeedsLayout];
    [UIView animateWithDuration:.2 animations:^{
        [dimView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:.5]];
    }];
}
-(void)lightenDimView{
    blackButton.layer.borderColor = [UIColor colorWithRed:1 green:1 blue:1 alpha: 1].CGColor;
    whiteButton.layer.borderColor = [UIColor colorWithRed:0.01 green: 0.42 blue: 1 alpha: 1].CGColor;
    [blackButton setNeedsLayout];
    [whiteButton setNeedsLayout];
    [UIView animateWithDuration:.2 animations:^{
        [dimView setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:.7]];
    }];
}
-(void)dismissView{
    
    int screenHeight = 480;
    if(!kIsIpad){
        screenHeight = [UIScreen mainScreen].bounds.size.height;
    }
    [UIView animateWithDuration:.2 animations:^{
        [sliderView setFrame:CGRectMake(0, screenHeight, 320, 230)];
        [dimView setAlpha:0];
        [whiteButton setFrame:CGRectMake(whiteButton.frame.origin.x, whiteButton.frame.origin.y-80, whiteButton.frame.size.width, whiteButton.frame.size.height)];
        [blackButton setFrame:CGRectMake(blackButton.frame.origin.x, blackButton.frame.origin.y-80, blackButton.frame.size.width, blackButton.frame.size.height)];
        [whiteButton setAlpha:0];
        [blackButton setAlpha:0];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [self setClipsToBounds:NO];
        
        sliderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 230)];
        [sliderView setBackgroundColor:[UIColor scrollViewTexturedBackgroundColor]];
        //pickerAS = [[UIActionSheet alloc] initWithTitle:@"Set Color" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil]; 
        
        exampleLabel = [[RRSGlowLabel alloc] initWithFrame:CGRectMake(0, -60, 320, 40)];
        [exampleLabel setFont:[UIFont boldSystemFontOfSize:25]];
        [exampleLabel setTextColor:[UIColor whiteColor]];
        [exampleLabel setBackgroundColor:[UIColor clearColor]];
        [exampleLabel setText:@"Selected Color"];
        [exampleLabel setTextAlignment:NSTextAlignmentCenter];
        [exampleLabel setGlowColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:.9]];
        [exampleLabel setGlowAmount:7];
        [exampleLabel setGlowOffset:CGSizeMake(0, 0)];
        [sliderView addSubview:exampleLabel];
        
        sliderR  = [[UISlider alloc] initWithFrame:CGRectMake(130, 66, 172, 23)];
        sliderG  = [[UISlider alloc] initWithFrame:CGRectMake(130, 96, 172, 23)];
        sliderB  = [[UISlider alloc] initWithFrame:CGRectMake(130, 126, 172, 23)];
        sliderA  = [[UISlider alloc] initWithFrame:CGRectMake(130, 156, 172, 23)];
        sliderAmount  = [[UISlider alloc] initWithFrame:CGRectMake(130, 186, 172, 23)];
        [sliderR setMinimumValue:0];
        [sliderR setMaximumValue:1];
        [sliderG setMinimumValue:0];
        [sliderG setMaximumValue:1];
        [sliderB setMinimumValue:0];
        [sliderB setMaximumValue:1];
        [sliderA setMinimumValue:0];
        [sliderA setMaximumValue:1];
        [sliderAmount setMinimumValue:0];
        [sliderAmount setMaximumValue:30];
        [sliderView addSubview:sliderR];
        [sliderView addSubview:sliderG];
        [sliderView addSubview:sliderB];
        [sliderView addSubview:sliderA];
        [sliderView addSubview:sliderAmount];
        
        [sliderR addTarget:self action:@selector(changeColor:) forControlEvents:UIControlEventValueChanged];
        [sliderB addTarget:self action:@selector(changeColor:) forControlEvents:UIControlEventValueChanged];
        [sliderG addTarget:self action:@selector(changeColor:) forControlEvents:UIControlEventValueChanged];
        [sliderA addTarget:self action:@selector(changeColor:) forControlEvents:UIControlEventValueChanged];
        [sliderAmount addTarget:self action:@selector(changeColor:) forControlEvents:UIControlEventValueChanged];
        
        UILabel *labelR = [[UILabel alloc] initWithFrame:CGRectMake(20, 66, 104, 21)];
        UILabel *labelG = [[UILabel alloc] initWithFrame:CGRectMake(20, 96, 104, 21)];
        UILabel *labelB = [[UILabel alloc] initWithFrame:CGRectMake(20, 126, 104, 21)];
        UILabel *labelA = [[UILabel alloc] initWithFrame:CGRectMake(20, 156, 104, 21)];
        UILabel *labelAmount = [[UILabel alloc] initWithFrame:CGRectMake(20, 186, 104, 21)];
        [sliderView addSubview:labelR];
        [sliderView addSubview:labelG];
        [sliderView addSubview:labelB];
        [sliderView addSubview:labelA];
        [sliderView addSubview:labelAmount];
        [labelR setTextColor:[UIColor redColor]];
        [labelG setTextColor:[UIColor greenColor]];
        [labelB setTextColor:[UIColor blueColor]];
        [labelA setTextColor:[UIColor whiteColor]];
        [labelAmount setTextColor:[UIColor whiteColor]];
        [labelR setBackgroundColor:[UIColor clearColor]];
        [labelG setBackgroundColor:[UIColor clearColor]];
        [labelB setBackgroundColor:[UIColor clearColor]];
        [labelA setBackgroundColor:[UIColor clearColor]];
        [labelAmount setBackgroundColor:[UIColor clearColor]];
        [labelR setText:@"Red"];
        [labelG setText:@"Green"];
        [labelB setText:@"Blue"];
        [labelA setText:@"Alpha"];
        [labelAmount setText:@"Glow"];
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        if(!kIsIpad)
            [toolbar sizeToFit];
        [toolbar setClipsToBounds:NO];
        
        [CBThemeHelper setBackgroundImage:nil forToolbar:toolbar];
        NSMutableArray *barItems = [[NSMutableArray alloc] init];
        UIBarButtonItem *cancelBtn = [CBThemeHelper createDarkButtonItemWithTitle:@"Cancel" target:self action:@selector(dismissActionSheet)];
        UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];  
        UIBarButtonItem *doneBtn = [CBThemeHelper createBlueButtonItemWithTitle:@"Done" target:self action:@selector(saveActionSheet)];
        UILabel *titleLabel = [[UILabel alloc] init];
        [titleLabel setText:@"Set Glow Color"];
        if(!kIsiOS7){
            [titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
            [titleLabel setShadowColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:.8]];
            [titleLabel setShadowOffset:CGSizeMake(0, -1.0)];
            [titleLabel setTextColor:[UIColor whiteColor]];
        }
        else{
            [titleLabel setTextColor:[UIColor darkGrayColor]];
            [labelA setTextColor:[UIColor blackColor]];
            [labelAmount setTextColor:[UIColor blackColor]];
            [sliderView setBackgroundColor:[UIColor whiteColor]];
        }
        [titleLabel setFrame:CGRectMake(0, 0, 150, 22)];
        [titleLabel setTextAlignment:NSTextAlignmentCenter];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        UIBarButtonItem *titleItem = [[UIBarButtonItem alloc] initWithCustomView:titleLabel];
        [titleItem setStyle:UIBarButtonItemStylePlain];
        [barItems addObject:cancelBtn];
        [barItems addObject:flexSpace];  
        [barItems addObject:titleItem];
        [barItems addObject:flexSpace];
        [barItems addObject:doneBtn];
        [toolbar setItems:barItems animated:YES];
        [sliderView addSubview:toolbar];
        
        int buttonTop = 40;
        if(kIsiOS7 && kIsIpad){
            buttonTop = 10;
        }
        
        
        whiteButton = [[UIButton alloc] initWithFrame:CGRectMake(270, buttonTop, 30, 30)];
        blackButton = [[UIButton alloc] initWithFrame:CGRectMake(230, buttonTop, 30, 30)];
        [whiteButton setShowsTouchWhenHighlighted:YES];
        [whiteButton addTarget:self action:@selector(lightenDimView) forControlEvents:UIControlEventTouchUpInside];
        whiteButton.layer.cornerRadius = 5;
        whiteButton.layer.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1].CGColor;
        whiteButton.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1].CGColor;
        whiteButton.layer.borderWidth = 3;
        [blackButton setShowsTouchWhenHighlighted:YES];
        [blackButton addTarget:self action:@selector(darkenDimView) forControlEvents:UIControlEventTouchUpInside];
        blackButton.layer.cornerRadius = 5;
        blackButton.layer.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1].CGColor;
        blackButton.layer.borderColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1].CGColor;
        blackButton.layer.borderWidth = 3;
        
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveGlobalTextColor:) name:@"saveGlobalTextColor" object:nil];
        
    }
    return self;
}
-(void)setSliderValuesFromColor:(UIColor *)color andAmount:(float)amount
{
    
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
    sliderAmount.value = amount;
}
-(void)updateAllWidgets:(id)object forKey:(NSString *)key
{
    //itterate through all widgets and set the data to the data.
    
    NSMutableDictionary *settings = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"] ];
    NSMutableArray * widgetsList = [NSMutableArray arrayWithArray:[settings  objectForKey:@"widgetsList"] ] ;
    
    NSInteger x = 0;
    BOOL _shouldUpdate = NO;
    NSMutableArray *a = [NSMutableArray arrayWithArray:widgetsList];
    for(NSDictionary *w in widgetsList)
    {
        if([[w objectForKey:@"class"]isEqualToString:@"textBasedWidget"])
        {
            NSMutableDictionary *w1 = [w mutableCopy];
            [w1 setObject:object forKey:@"glowColor"];
            [w1 setObject:[NSString stringWithFormat:@"%f", sliderAmount.value] forKey:@"glowAmount"];
            [a replaceObjectAtIndex:x withObject:w1];
            _shouldUpdate = YES;
        }
        x++;
    }
    if(_shouldUpdate)
    {
        [settings setObject:a forKey:@"widgetsList"];
        [[NSUserDefaults standardUserDefaults] setObject:settings forKey:@"settings"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        if(kIsIpad)
            [AppDelegate.viewController performSelector:@selector(refreshViews)];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateGlobalTextSettingsTable" object:nil];
    }
}


-(void)updateTextColor:(UIColor *)newColor{
    [exampleLabel setGlowColor:newColor];
    [exampleLabel setGlowAmount:sliderAmount.value];
    [exampleLabel setNeedsDisplay];
    
}

-(void)saveGlobalTextColor:(NSNotification*)note{
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:[[note userInfo] objectForKey:@"color"]];
    
    [self updateAllWidgets:colorData forKey:@"glowColor"];
}


-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"changeGlobalTextColor" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"saveGlobalTextColor" object:nil];
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


#pragma mark Slider Actions

- (IBAction)changeColor: (id)sender {  
    UIColor *newColor = [UIColor colorWithRed:sliderR.value green:sliderG.value blue:sliderB.value alpha:sliderA.value];
    [self updateTextColor:newColor];
}



#pragma mark ActionSheet stuff


-(void)dismissActionSheet{
    [self dismissView];
}


-(void)saveActionSheet{
    UIColor *newColor = [UIColor colorWithRed:sliderR.value green:sliderG.value blue:sliderB.value alpha:sliderA.value];
    NSDictionary *ui = [NSDictionary dictionaryWithObject:newColor forKey:@"color"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"saveGlobalTextColor" object:nil userInfo:ui];
    [self dismissView];
    
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */


@end
