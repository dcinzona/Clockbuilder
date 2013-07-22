//
//  weatherIconPickerTool.m
//  ClockBuilder
//
//  Created by gtadmin on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "weatherIconPickerTool.h"


@implementation weatherIconPickerTool
-(void) addToolbarToPicker:(NSString *)title
{
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    toolbar.barStyle = UIBarStyleBlackOpaque;
    [toolbar sizeToFit];
    [CBThemeHelper setBackgroundImage:nil forToolbar:toolbar];
    NSMutableArray *barItems = [[NSMutableArray alloc] init];
    UIBarButtonItem *cancelBtn = [CBThemeHelper createDarkButtonItemWithTitle:@"Cancel" target:self action:@selector(dismissActionSheet)];
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];  
    UIBarButtonItem *doneBtn = [CBThemeHelper createBlueButtonItemWithTitle:@"Done" target:self action:@selector(saveActionSheet)];
    UILabel *titleLabel = [[UILabel alloc] init];
    [titleLabel setText:title];
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
    [pickerAS addSubview:picker.pickerView];
    [pickerAS showInView:showView.view];
    [pickerAS setBounds:CGRectMake(0,0,320, 408)];
}

-(void)setShowView:(UIViewController *)v
{
    showView = v;
}

-(void)dismissActionSheet{
    [pickerAS dismissWithClickedButtonIndex:0 animated:YES];
}
-(void)saveActionSheet{
    [pickerAS dismissWithClickedButtonIndex:1 animated:YES];
    NSUInteger selectedRow = [picker.pickerView selectedRowInComponent:0];
    NSString *selected = [picker.pickerItems objectAtIndex:selectedRow];
    NSMutableDictionary *widgetData = [data mutableCopy];
    //set alignment for widget data
    [widgetData setObject:[selected lowercaseString] forKey:@"forecast"];    
    
    [showView performSelector:@selector(saveWeatherIconWidgetData:) withObject:widgetData];    
    
    
}
-(void)setWidgetData:(NSDictionary *)wd
{
    data = wd;
}
#pragma mark Show Pickers
- (void) showForecastPicker
{
    NSArray *pickerList = [NSArray arrayWithObjects:@"Current", @"Today", @"Tomorrow", nil];
    picker = [[WidgetPickerViewController alloc] initWithPickerItems:pickerList pickerType:@"forecast"];
    NSString *title = @"Forecast Type:";
    pickerAS = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"cancel" destructiveButtonTitle:nil otherButtonTitles:nil];
    [self addToolbarToPicker:title];
}

@end
