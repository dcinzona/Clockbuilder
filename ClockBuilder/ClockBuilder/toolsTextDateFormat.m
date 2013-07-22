//
//  toolsTextDateFormat.m
//  ClockBuilder
//
//  Created by gtadmin on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "toolsTextDateFormat.h"
#import "widgetHelperClass.h"


@implementation toolsTextDateFormat

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
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    if([_textField.text isEqualToString:@""])
        [dateFormatter setDateFormat:_textField.placeholder];
    else
        [dateFormatter setDateFormat:_textField.text];
    NSString *ret = [dateFormatter stringFromDate:[NSDate date]];
    [resultsLabel setText:ret];
}
- (BOOL)textFieldShouldReturn:(UITextField *)tf {
    
	[tf resignFirstResponder];
    
    if (kIsIpad) {
        [pop dismissPopoverAnimated:YES];
    }
    else{
        [toolsDateTimeView setHidden:YES];
        
        if(![_textField.text isEqualToString:@""])
        {
            [self setdateFormatOverride:_textField.text];
            [self.window.rootViewController performSelector:@selector(saveTextDateTimeFormat:) withObject:_textField.text];      
        }
    }
	return YES;
}

-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController{
    
    NSLog(@"popover controller dismissed");
    
	[_textField resignFirstResponder];
    [toolsDateTimeView setHidden:YES];
    if(![_textField.text isEqualToString:@""])
    {
        [self setdateFormatOverride:_textField.text];
        [self.window.rootViewController performSelector:@selector(saveTextDateTimeFormat:) withObject:_textField.text];
    }
    
}

-(void)build
{
    [self setShowsTouchWhenHighlighted:YES];
    [self addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    self.layer.cornerRadius = 20;
    self.layer.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.7].CGColor;
    self.layer.borderColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0].CGColor;
    self.layer.borderWidth = 4;
    UIImageView *alignmentIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"toolsClock.png"]];
    [alignmentIcon setContentMode:UIViewContentModeScaleAspectFit];
    [alignmentIcon setFrame:CGRectMake(7, 7, 26, 26)];
    [alignmentIcon setBackgroundColor:[UIColor clearColor]];
    [self addSubview:alignmentIcon];
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
    [self setdateFormatOverride:[wd objectForKey:@"dateFormatOverride"]];
    [resultsLabel setFont:[UIFont fontWithName:[wd objectForKey:@"fontFamily"] size:resultsLabel.frame.size.height*.8]];
    [resultsLabel setAdjustsFontSizeToFitWidth:YES];
}

-(void)setdateFormatOverride:(NSString *)df
{
    dateFormatOverride = df;
    [_textField setPlaceholder:df];
    [_textField setText:dateFormatOverride];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:dateFormatOverride];
    NSString *ret = [dateFormatter stringFromDate:[NSDate date]];
    [resultsLabel setText:ret];
}


@end
