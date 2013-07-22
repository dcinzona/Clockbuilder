//
//  UIPickerView.m
//  ClockBuilder
//
//  Created by gtadmin on 3/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "addWidgetPicker.h"


@implementation addWidgetPicker

@synthesize pickerView;
@synthesize dateTimeItems;
@synthesize weatherItems;
@synthesize widgetTypesArray;
@synthesize selectedTypeItems;
@synthesize widgetClass;
@synthesize widgetType;

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
        
        self.widgetTypesArray = [NSArray arrayWithObjects:@"Date/Time", @"Weather",@"Custom Text", nil];
        
        self.dateTimeItems = [NSArray arrayWithObjects:@"Clock",@"AM/PM Symbol",@"Day (Digit)",@"Day (Name)",@"Month",@"Year", nil];
        self.weatherItems = [NSArray arrayWithObjects:@"Weather Icon",@"Location Name",@"Temperature",@"Conditions", nil];
        
        self.selectedTypeItems = self.dateTimeItems;
        //[self.pickerView selectRow:0 inComponent:0 animated:NO];
        //[self.pickerView selectRow:0 inComponent:1 animated:NO];
        
        self.widgetClass = @"TimeView";
        self.widgetType = @"dateTime";
        
        if(kIsiOS7){
            
            [self.pickerView setBackgroundColor:[UIColor whiteColor]];            
            [self.pickerView setFrame:CGRectMake(0,
                                                self.pickerView.frame.origin.y-15,
                                                self.pickerView.frame.size.width,
                                                self.pickerView.frame.size.height
                                                )];
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
        return [self.widgetTypesArray count];
    else
        return [self.selectedTypeItems count];
    
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
        return @"";
}
- (void)pickerView:(UIPickerView *)pv didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if(component==0){
        if(row==0){
            self.selectedTypeItems = self.dateTimeItems;
            self.widgetType = @"dateTime";
            self.widgetClass = @"TimeView";
        }
        if(row==1){
            self.selectedTypeItems = self.weatherItems;
            self.widgetType = @"weather";
            self.widgetClass = @"weatherIconView";
        }
        if(row==2){
            self.selectedTypeItems = [NSArray arrayWithObject:@"Custom Text"];
            self.widgetType = @"text";
            self.widgetClass = @"customTextView";
        }
        
        [self.pickerView reloadComponent:1];
    }
    else
    {
        //set widgetClass here
        /*
         self.dateTimeItems = [NSArray arrayWithObjects:@"Clock",@"AM/PM Symbol",@"Day (Digit)",@"Day (Name)",@"Month",@"Year", nil];
        // self.weatherItems = [NSArray arrayWithObjects:@"Weather Icon",@"Location Name",@"Temperature",@"Conditions", nil];
         */
        if([pv selectedRowInComponent:0]==0)
        {//DATE TIME WIDGETS -- Clock -- AMPM -- Day Num -- Day Name -- Month -- Year
            NSString *cls = @"TimeView";
            self.widgetType = @"dateTime";
            switch (row) {
                case 0:
                    cls = @"TimeView";
                    break;
                case 1:
                    cls = @"AMPMView";
                    break;
                case 2:
                    cls = @"DayNumberView";
                    break;
                case 3:
                    cls = @"DayView";
                    break;
                case 4:
                    cls = @"monthView";
                    break;
                case 5:
                    cls = @"YearView";
                    break;
                default:
                    break;
            }
            self.widgetClass = cls;
        }
        if([pv selectedRowInComponent:0]==1)
        {//WEATHER WIDGETS -- weatherIconView -- weatherTextView
            if(row==0)
            {
                self.widgetClass = @"weatherIconView";
                self.widgetType = @"Weather";
            }
            else
            {
                self.widgetClass = @"weatherTextView";
                switch (row) {
                    case 1:
                        self.widgetType = @"Location";
                        break;
                    case 2:
                        self.widgetType = @"Temperature";
                        break;
                    case 3:
                        self.widgetType = @"Conditions";
                        break;
                    default:
                        break;
                }
            }
        }
        if([pv selectedRowInComponent:0]==2)
        {//Custom Text
            self.widgetClass = @"customTextView";
        }
        
        
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
        [label setText:[self.widgetTypesArray objectAtIndex:row]];
    }
    else
        [label setText:[self.selectedTypeItems objectAtIndex:row]];
    
    
    [label setShadowColor:[UIColor whiteColor]];
    [label setShadowOffset:CGSizeMake(1, 1)];
    
    [label setTextColor:[UIColor blackColor]];
    [label setFont:[UIFont fontWithName:@"HelveticaNeue" size:14.0]];
    
    
    [label setBackgroundColor:[UIColor clearColor]];
    CGSize rowSize = [pv rowSizeForComponent:component];
    CGRect labelRect = CGRectMake (10, 0, rowSize.width-10, rowSize.height);
    [label setFrame:labelRect];
    
    return label;
}














@end
