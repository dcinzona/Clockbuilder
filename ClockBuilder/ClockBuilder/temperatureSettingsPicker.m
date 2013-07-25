//
//  UIPickerView.m
//  ClockBuilder
//
//  Created by gtadmin on 3/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "temperatureSettingsPicker.h"


@implementation temperatureSettingsPicker

@synthesize pickerView;
@synthesize highLow;
@synthesize forecastTypesArray;
@synthesize selectedTypeItems;
@synthesize temperatureValue;
@synthesize forecastType;

#pragma mark - View lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


-(id)init
{
    self = [super init];
    if(self)
    {
        CGRect pickerFrame = CGRectMake(0, 44, 320, 400);
        self.pickerView = [[UIPickerView alloc] initWithFrame:pickerFrame];
        self.pickerView.dataSource = self;
        self.pickerView.delegate = self;
        [self.pickerView setShowsSelectionIndicator:YES];
        
        self.forecastTypesArray = [NSArray arrayWithObjects:@"Current", @"Today's Forecast",@"Tomorrow's Forecast", nil];
        self.highLow = [NSArray arrayWithObjects:@"High",@"Low", nil];
        self.selectedTypeItems = [NSArray arrayWithObject:@"Current Temperature"];
        
        self.forecastType = @"Current";
        self.temperatureValue = @"Current Temperature";
        
        if(kIsiOS7){
            [self.pickerView setBackgroundColor:[UIColor whiteColor]];
        }
        
    }
    return self;
}

- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    
    return 2;
    //return 1;
}


- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {

    if(component==0)
        return [self.forecastTypesArray count];
    else
        return [self.selectedTypeItems count];
    
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
        return @"";
}
- (void)pickerView:(UIPickerView *)pv didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if(component==0){
        if(row==0){
            self.selectedTypeItems = [NSArray arrayWithObject:@"Current Temperature"];
            self.forecastType = @"Current";
            self.temperatureValue = @"Current Temperature";
        }
        if(row==1){
            self.selectedTypeItems = self.highLow;
            self.forecastType = @"Today's Forecast";
            self.temperatureValue = @"High";
        }
        if(row==2){
            self.selectedTypeItems = self.highLow;
            self.forecastType = @"Tomorrow's Forecast";
            self.temperatureValue = @"High";
        }
        
        [self.pickerView reloadComponent:1];
    }
    else
    {
        if([pv selectedRowInComponent:0]>0)
            self.temperatureValue = [self.highLow objectAtIndex:row];
        else
            self.temperatureValue = @"Current Temperature";            
    }    
}
- (UIView *)pickerView:(UIPickerView *)pv viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label = (UILabel*) view;
    if (label == nil)
    {
        label = [[UILabel alloc] init];
    }
    if(component==0){
        [label setText:[self.forecastTypesArray objectAtIndex:row]];
    }
    else
        [label setText:[self.selectedTypeItems objectAtIndex:row]];
    
    
    [label setShadowColor:[UIColor whiteColor]];
    [label setShadowOffset:CGSizeMake(1, 1)];
    
    [label setTextColor:[UIColor blackColor]];
    [label setFont:[UIFont fontWithName:@"HelveticaNeue" size:14.0]];
    if(kIsiOS7){
        [label setFont:[UIFont systemFontOfSize:16]];
    }
    
    [label setBackgroundColor:[UIColor clearColor]];
    if(kIsiOS7){
        [label setBackgroundColor:[UIColor whiteColor]];
    }
    CGSize rowSize = [pv rowSizeForComponent:component];
    CGRect labelRect = CGRectMake (10, 0, rowSize.width-10, rowSize.height);
    [label setFrame:labelRect];
    
    return label;
}














@end
