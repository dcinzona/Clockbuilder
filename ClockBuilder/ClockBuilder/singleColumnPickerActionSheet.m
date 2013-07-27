//
//  singleColumnPickerActionSheet.m
//  ClockBuilder
//
//  Created by gtadmin on 5/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "singleColumnPickerActionSheet.h"
#import "ClockBuilderAppDelegate.h"

@implementation singleColumnPickerActionSheet
@synthesize pickerItems, pickerType, pickerView,pickerAS;
@synthesize cancelBlock = _cancelBlock;
@synthesize closeBlock = _closeBlock;

-(void)dismissActionSheet{
    
    [pickerAS dismissWithClickedButtonIndex:0 animated:YES]; 
    self.cancelBlock();
}


-(void)saveActionSheet{
    
    [pickerAS dismissWithClickedButtonIndex:1 animated:YES];
    
    NSUInteger selectedRow = [pickerView selectedRowInComponent:0];
    NSString *selected = [pickerItems objectAtIndex:selectedRow];
    self.closeBlock(selected);
}

#pragma mark Picker DataSource

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
    [label setText:[[pickerItems objectAtIndex:row] capitalizedString]];
    [label setShadowColor:[UIColor whiteColor]];
    [label setShadowOffset:CGSizeMake(1, 1)];
    if(kIsiOS7){
        [label setFont:[UIFont systemFontOfSize:16]];
    }
    // This part just colorizes everything, since you asked about that.
    [label setTextColor:[UIColor blackColor]];
    [label setTextAlignment:NSTextAlignmentCenter];
    
    //if([pickerType isEqualToString:@"locations"] && row == 0)
    //   [label setTextColor:[UIColor colorWithRed:.3 green:.3 blue:1.0 alpha:1.0]];
    
    [label setBackgroundColor:[UIColor clearColor]];
    CGSize rowSize = [pv rowSizeForComponent:component];
    CGRect labelRect = CGRectMake (10, 0, rowSize.width-20, rowSize.height);
    [label setFrame:labelRect];
    
    return label;
}
- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
}

-(void)showPickerWithTitle:(NSString *)title inView:(UIView *)view withList:(NSArray *)list{
    self.pickerItems = [NSArray arrayWithArray:list];
    CGRect pickerFrame = CGRectMake(0, 44, 320, 400);
    pickerView = [[UIPickerView alloc] initWithFrame:pickerFrame];
    pickerView.dataSource = self;
    pickerView.delegate = self;
    [pickerView setShowsSelectionIndicator:YES];
    [pickerView selectRow:0 inComponent:0 animated:NO];
    pickerAS = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"cancel" destructiveButtonTitle:nil otherButtonTitles:nil];
    [pickerAS addSubview:pickerView];
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    toolbar.barStyle = UIBarStyleBlackOpaque;
    [toolbar sizeToFit];
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
    [pickerAS showInView:view];
    [pickerAS setBounds:CGRectMake(0,0,320, 408)];      

}

-(void)showPickerWithTitle:(NSString *)title inView:(UIView *)view withPickerList:(NSArray *)pickerList onPicked:(CloseBlock)pickedItemBlock onCancelBlock:(CancelBlock)cancelPicking{
    
    //singleColumnPickerActionSheet *picker = [[singleColumnPickerActionSheet alloc] init];
    //picker.cancelBlock = cancelPicking;
    //picker.closeBlock = pickedItemBlock;
    //[picker showPickerWithTitle:title inView:view withList:pickerList];
    [self showPickerWithTitle:title inView:view withList:pickerList];
}



#pragma mark life cycle


-(void)dealloc
{
    NSLog(@"dealloc singleColumnPickerActionSheet");
    self.pickerItems = nil;
}
@end
