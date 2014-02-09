//
//  toolsTextWeatherButton.m
//  ClockBuilder
//
//  Created by gtadmin on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "toolsTextWeatherButton.h"


@implementation toolsTextWeatherButton

-(void)buttonClick:(id)sender
{
    NSString *widgetSubType = [data objectForKey:@"subClass"];
    if([widgetSubType isEqualToString:@"weather"] && ![[data objectForKey:@"className"] isEqualToString:@"Location"]){
        //show picker
        if([[data objectForKey:@"className"] isEqualToString:@"Conditions"] ||
           [[data objectForKey:@"className"] isEqualToString:@"Weather Icon"]){
            [self showConditionsPicker];
        }
        if([[data objectForKey:@"className"] isEqualToString:@"Temperature"]){
            [self showTemperatureSettingsPicker];
        }
        
        [toolsDateTimeView setHidden:YES];
    }
    else
    {
        if (kIsIpad) {
            
            UIViewController *vc = [[UIViewController alloc]init];
            [vc setContentSizeForViewInPopover:CGSizeMake(320, 350)];
            [vc setView:toolsDateTimeView];
            [toolsDateTimeView setBackgroundColor:[UIColor viewFlipsideBackgroundColor]];
            if(!pop)
                pop = [[UIPopoverController alloc] initWithContentViewController:vc];
            [pop setDelegate:self];
            [pop setContentViewController:vc];
            
            [pop presentPopoverFromRect:self.frame inView:ApplicationDelegate.viewController.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
        else{
            
        }
        [toolsDateTimeView setHidden:NO];
        [_textField becomeFirstResponder];
    }
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
    [toolsDateTimeView setHidden:YES];
    
    NSMutableDictionary *widgetData = [data mutableCopy];
    [widgetData setObject:_textField.text forKey:@"text"];
    [self setWidgetData:widgetData];
    [self.window.rootViewController performSelector:@selector(saveTextWeatherWidgetData:) withObject:data];
    if (kIsIpad) {
        [pop dismissPopoverAnimated:YES];
    }
	return YES;
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
    UIImageView *alignmentIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"weatherButton.png"]];
    [alignmentIcon setContentMode:UIViewContentModeScaleAspectFit];
    [alignmentIcon setFrame:CGRectMake(7, 7, 26, 26)];
    [alignmentIcon setBackgroundColor:[UIColor clearColor]];
    [self addSubview:alignmentIcon];
    [_textField addTarget:self action:@selector(updateDateUsingContentsOfTextField:) forControlEvents:UIControlEventEditingChanged];
    [_textField setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:.3]];
    [resultsLabel setAdjustsFontSizeToFitWidth:YES];
}
-(void)setWidgetData:(NSDictionary *)wd
{
    data = wd;
    [resultsLabel setFont:[UIFont fontWithName:[wd objectForKey:@"fontFamily"] size:resultsLabel.frame.size.height*.8]];
    if([[wd objectForKey:@"text"] isEqualToString:@""])
    {
        [resultsLabel setText:[[[kDataSingleton getSettings]objectForKey:@"weatherData"]objectForKey:@"locationName"]];
    }
    else
        [resultsLabel setText:[wd objectForKey:@"text"]];
}


-(void) addToolbarToPicker:(NSString *)title
{
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    toolbar.barStyle = UIBarStyleBlackOpaque;
    if(!kIsIpad){
        [toolbar sizeToFit];
    }
    [CBThemeHelper setBackgroundImage:nil forToolbar:toolbar];
    NSMutableArray *barItems = [[NSMutableArray alloc] init];
    UIBarButtonItem *cancelBtn = [CBThemeHelper createDarkButtonItemForStyledToolbarWithTitle:@"Cancel" target:self action:@selector(dismissActionSheet)];
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];  
    UIBarButtonItem *doneBtn = [CBThemeHelper createBlueButtonItemWithTitle:@"Done" target:self action:@selector(saveActionSheet)];
    UILabel *titleLabel = [[UILabel alloc] init];
    [titleLabel setText:title];
    [titleLabel setShadowColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:.5]];
    [titleLabel setShadowOffset:CGSizeMake(0, -1.0)];
    [titleLabel setFrame:CGRectMake(0, 0, 150, 22)];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
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
    if([pickerType isEqualToString:@"picker"])
        [pickerAS addSubview:picker.pickerView];
    else
        [pickerAS addSubview:tempPicker.pickerView];
    
    [pickerAS setBounds:CGRectMake(0,0,320, 408)];
    if(kIsiOS7){
        [titleLabel setCenter:toolbar.center];
        [titleLabel setShadowColor:nil];
        [titleLabel setTextColor:[UIColor darkGrayColor]];
        [pickerAS setBackgroundColor:[UIColor whiteColor]];
        [toolbar setFrame:CGRectMake(0, -20, toolbar.frame.size.width, toolbar.frame.size.height)];
        [pickerAS setBounds:CGRectMake(0,0,320, 340)];
    }
    
    if(kIsIpad){
        UIView *v = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 300)];
        UIViewController *vc = [[UIViewController alloc]init];
        [vc setContentSizeForViewInPopover:CGSizeMake(320, 260)];
        [vc setView:v];
        [v addSubview:toolbar];
        if([pickerType isEqualToString:@"tempPicker"]){
            [v addSubview:tempPicker.pickerView];
        }
        else
            [v addSubview:picker.pickerView];
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
    if([pickerType isEqualToString:@"tempPicker"])
        ;
    else
        ;
}


-(void)saveActionSheet{
    [pickerAS dismissWithClickedButtonIndex:1 animated:YES];
    if(kIsIpad && pop){
        [pop dismissPopoverAnimated:YES];
    }
    NSMutableDictionary *widgetData = [data mutableCopy];
    if([pickerType isEqualToString:@"picker"]){
        NSUInteger selectedRow = [picker.pickerView selectedRowInComponent:0];
        NSString *selected = [picker.pickerItems objectAtIndex:selectedRow];
        if([picker.pickerType isEqualToString:@"conditions"]){
            
            NSString *newForecast = [[selected stringByReplacingOccurrencesOfString:@"'s Forecast" withString:@""] lowercaseString];
            
            [widgetData setObject:newForecast forKey:@"forecast"];
        }
    }
    else
    {
        NSString *forecast = [[tempPicker.forecastType stringByReplacingOccurrencesOfString:@"'s Forecast" withString:@""] lowercaseString];
        NSString *textItemType = [tempPicker.temperatureValue stringByReplacingOccurrencesOfString:@"Current " withString:@""];
        [widgetData setObject:forecast forKey:@"forecast"];
        [widgetData setObject:textItemType forKey:@"textItemType"];    
    }
    
    //save widget data and update view  
    
    [self setWidgetData:widgetData];
    [self.window.rootViewController performSelector:@selector(saveTextWeatherWidgetData:) withObject:data];    
    
    
}




- (void) showConditionsPicker
{
    NSArray *pickerList = [NSArray arrayWithObjects:@"Current", @"Today's Forecast", @"Tomorrow's Forecast", nil];
    picker = [[WidgetPickerViewController alloc] initWithPickerItems:pickerList pickerType:@"conditions"];
    NSString *title = @"Forecast";
    pickerType = @"picker";
    NSString *titleBlank = @"\n\n\n\n\n\n\n\n\n";
    if(!kIsiOS7){
        pickerAS = [[UIActionSheet alloc] initWithTitle:titleBlank delegate:self cancelButtonTitle:@"cancel" destructiveButtonTitle:nil otherButtonTitles:nil];
    }else{
        [pickerView setBackgroundColor:[UIColor whiteColor]];
        [picker.pickerView setFrame:CGRectMake(0, 24, 320, 400)];
        NSString *title = @"\n\n\n\n\n\n\n\n\n\n\n\n";
        pickerAS = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    }
    [self addToolbarToPicker:title];
}
- (void) showTemperatureSettingsPicker
{
    tempPicker = [[temperatureSettingsPicker alloc] init];
    NSString *title = @"Forecast / Temp";
    pickerType = @"tempPicker";
    NSString *titleBlank = @"\n\n\n\n\n\n\n\n\n";
    if(!kIsiOS7){
        pickerAS = [[UIActionSheet alloc] initWithTitle:titleBlank delegate:self cancelButtonTitle:@"cancel" destructiveButtonTitle:nil otherButtonTitles:nil];
    }else{
        [pickerView setBackgroundColor:[UIColor whiteColor]];
        [tempPicker.pickerView setFrame:CGRectMake(0, 24, 320, 400)];
        NSString *title = @"\n\n\n\n\n\n\n\n\n\n\n\n";
        pickerAS = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    }
    [self addToolbarToPicker:title];
}


@end
