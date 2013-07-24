//
//  UIPickerView.m
//  ClockBuilder
//
//  Created by gtadmin on 3/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "WidgetPickerViewCascading.h"


@implementation WidgetPickerViewCascading

@synthesize pickerItems;
@synthesize pickerType;
@synthesize pickerView;
@synthesize pickerComponentItems;

#pragma mark - View lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


-(id) initWithPickerItems: (NSArray *)listOfArrays pickerType:(NSString *)ptype;
{
    self = [super init];
    if(self){
        self.pickerItems = [[NSArray alloc] initWithArray:listOfArrays];
        self.pickerType = ptype;
        CGRect pickerFrame = CGRectMake(0, 44, 320, 400);
        self.pickerView = [[UIPickerView alloc] initWithFrame:pickerFrame];
        self.pickerView.dataSource = self;
        self.pickerView.delegate = self;
        [self.pickerView setShowsSelectionIndicator:YES];
        self.pickerComponentItems = [NSArray arrayWithArray:[[self.pickerItems objectAtIndex:1]objectAtIndex:0]];
        if(kIsiOS7){
            [self.pickerView setBackgroundColor:[UIColor whiteColor]];
            [self.pickerView.inputView setBackgroundColor:[UIColor whiteColor]];
        }
    }
    return  self;
}
- (void)dealloc
{
    self.pickerComponentItems = nil;
    self.pickerItems = nil;
    self.pickerType = nil;
    self.pickerView = nil;
}

- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    
    return [pickerItems count];
    //return 1;
}


- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {

    if(component==0)
        return [[self.pickerItems objectAtIndex:component] count];
    else
        return [self.pickerComponentItems count];
    
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
        return [[self.pickerItems objectAtIndex:component] objectAtIndex:row];
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if(component<[self.pickerItems count]-1){
        
        //[self.pickerComponentItems release];
        
        self.pickerComponentItems = [NSArray arrayWithArray:[[self.pickerItems objectAtIndex:component+1] objectAtIndex:row]];
        
        [self.pickerView reloadComponent:component+1];
    }
    else
    {
        
    }
}
- (UIView *)pickerView:(UIPickerView *)pv viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label = (UILabel*) view;
    if (label == nil)
    {
        label = [[UILabel alloc] init];
    }
    if(component==0)
        [label setText:[[self.pickerItems objectAtIndex:component] objectAtIndex:row]];
    else
        [label setText:[self.pickerComponentItems objectAtIndex:row]];
    [label setShadowColor:[UIColor whiteColor]];
    [label setShadowOffset:CGSizeMake(1, 1)];
    
    [label setTextColor:[UIColor blackColor]];
    
    [label setBackgroundColor:[UIColor clearColor]];
    if(kIsiOS7){
        [label setBackgroundColor:[UIColor whiteColor]];
    }
    CGSize rowSize = [pv rowSizeForComponent:component];
    CGRect labelRect = CGRectMake (5, 0, rowSize.width-5, rowSize.height);
    [label setFrame:labelRect];
    
    return label;
}




@end
