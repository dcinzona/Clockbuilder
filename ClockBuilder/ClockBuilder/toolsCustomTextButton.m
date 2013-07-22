//
//  toolsCustomTextButton.m
//  ClockBuilder
//
//  Created by gtadmin on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "toolsCustomTextButton.h"


@implementation toolsCustomTextButton

-(void)buttonClick:(id)sender
{
    [toolsDateTimeView setHidden:NO];
    if (kIsIpad) {
        [pop presentPopoverFromRect:self.frame inView:ApplicationDelegate.viewController.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else{
        
    }
    [_textField becomeFirstResponder];
}
- (void)updateDateUsingContentsOfTextField:(id*)sender
{
    if([_textField.text isEqualToString:@""])
        [resultsLabel setText:_textField.placeholder];
    else
        [resultsLabel setText:_textField.text];
}
- (BOOL)textFieldShouldReturn:(UITextField *)tf {
    
	[tf resignFirstResponder];
    if (kIsIpad) {
        [pop dismissPopoverAnimated:YES];
        [_textField resignFirstResponder];
        [toolsDateTimeView setHidden:YES];
        if(![_textField.text isEqualToString:@""])
        {
            NSMutableDictionary *d = [data mutableCopy];
            [d setObject:_textField.text forKey:@"text"];
            [self setWidgetData:d];
            [self.window.rootViewController performSelector:@selector(saveTextWeatherWidgetData:) withObject:d];
        }
    }
    else{
        [toolsDateTimeView setHidden:YES];
        if(![_textField.text isEqualToString:@""])
        {
            NSMutableDictionary *d = [data mutableCopy];
            [d setObject:_textField.text forKey:@"text"];
            [self setWidgetData:d];
            [self.window.rootViewController performSelector:@selector(saveTextWeatherWidgetData:) withObject:d];      
        }
    }
	return YES;
}

-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController{
    
    NSLog(@"popover controller dismissed");
    
    
}

-(void)build
{
    [self setShowsTouchWhenHighlighted:YES];
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, 40, 40)];
    [self addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    self.layer.cornerRadius = 20;
    self.layer.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.7].CGColor;
    self.layer.borderColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0].CGColor;
    self.layer.borderWidth = 4;
    /*
    UIImageView *alignmentIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"toolsClock.png"]];//change to text icon
    [alignmentIcon setContentMode:UIViewContentModeScaleAspectFit];
    [alignmentIcon setFrame:CGRectMake(7, 7, 26, 26)];
    [alignmentIcon setBackgroundColor:[UIColor clearColor]];
    [self addSubview:alignmentIcon];
     */
    UILabel * fontLabel = [[UILabel alloc] init];
    [fontLabel setFrame:CGRectMake(5, 5, 30, 30)];
    [fontLabel setTextAlignment:UITextAlignmentCenter];
    [fontLabel setBackgroundColor:[UIColor clearColor]];
    [fontLabel setFont:[UIFont fontWithName:@"Helvetica" size:(30*.8)]];
    [fontLabel setAdjustsFontSizeToFitWidth:YES];
    fontLabel.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:.8];
    [fontLabel setText:@"\"T\""];
    [self addSubview:fontLabel];
    [_textField addTarget:self action:@selector(updateDateUsingContentsOfTextField:) forControlEvents:UIControlEventEditingChanged];
    [_textField setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:.3]];
    [_textField setTextColor:[UIColor whiteColor]];
    
    if(kIsIpad){
        
        if(!pop){
            UIViewController *vc = [[UIViewController alloc]init];
            [vc setContentSizeForViewInPopover:CGSizeMake(320, 350)];
            [vc setView:toolsDateTimeView];
            [toolsDateTimeView setBackgroundColor:[UIColor viewFlipsideBackgroundColor]];
            if(!pop)
                pop = [[UIPopoverController alloc] initWithContentViewController:vc];
            [pop setDelegate:self];
            [pop setContentViewController:vc];
        }
        
        
    }
}

-(void)setWidgetData:(NSDictionary *)wd
{
    data = wd;
    NSLog(@"text data: %@", wd);
    [self setdateFormatOverride:[wd objectForKey:@"text"]];
    [resultsLabel setFont:[UIFont fontWithName:[wd objectForKey:@"fontFamily"] size:resultsLabel.frame.size.height*.8]];
    [resultsLabel setAdjustsFontSizeToFitWidth:YES];
}

-(void)setdateFormatOverride:(NSString *)df
{
    dateFormatOverride = df;
    [_textField setPlaceholder:df];
    [_textField setText:dateFormatOverride];
    [resultsLabel setText:df];
}


@end
