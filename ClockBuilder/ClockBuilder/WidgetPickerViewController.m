//
//  UIPickerView.m
//  ClockBuilder
//
//  Created by gtadmin on 3/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "WidgetPickerViewController.h"


@implementation WidgetPickerViewController

@synthesize pickerItems, pickerType, pickerView;


#pragma mark - View lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


-(id) initWithPickerItems: (NSArray *)list pickerType:(NSString *)pType
{
    self = [super init];
    if(self){
        self.pickerItems = [NSArray arrayWithArray:list];
        self.pickerType = pType;
        CGRect pickerFrame = CGRectMake(0, 44, 320, 400);
        self.pickerView = [[UIPickerView alloc] initWithFrame:pickerFrame];
        self.pickerView.dataSource = self;
        self.pickerView.delegate = self;
        [self.pickerView setShowsSelectionIndicator:YES];
        if(kIsiOS7){
            [self.pickerView setBackgroundColor:[UIColor whiteColor]];
        }
    }
    return  self;
}
- (void)dealloc
{
    self.pickerItems = nil;
    self.pickerType = nil;
    self.pickerView = nil;
}

- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.pickerItems count];
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    return [[self.pickerItems objectAtIndex:row] capitalizedString];
}

- (UIView *)pickerView:(UIPickerView *)pv viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label = (UILabel*) view;
    if (label == nil)
    {
        label = [[UILabel alloc] init];
    }
    if([self.pickerType isEqualToString:@"iconSet"])
    {
        [label setText:[self.pickerItems objectAtIndex:row]];
    }
    else
        [label setText:[[self.pickerItems objectAtIndex:row] capitalizedString]];
    [label setShadowColor:[UIColor whiteColor]];
    [label setShadowOffset:CGSizeMake(1, 1)];
    
    // This part just colorizes everything, since you asked about that.
    [label setTextColor:[UIColor blackColor]];
    
    //if([pickerType isEqualToString:@"locations"] && row == 0)
     //   [label setTextColor:[UIColor colorWithRed:.3 green:.3 blue:1.0 alpha:1.0]];
    
    [label setBackgroundColor:[UIColor clearColor]];
    CGSize rowSize = [pv rowSizeForComponent:component];
    CGRect labelRect = CGRectMake (10, 0, rowSize.width-20, rowSize.height);
    [label setFrame:labelRect];
    
    return label;
}
- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    //NSLog(@"Selected item: %@. Index of selected item: %i", [pickerItems objectAtIndex:row], row);
    
    
}




@end
