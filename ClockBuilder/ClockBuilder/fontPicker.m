//
//  fontPicker.m
//  ClockBuilder
//
//  Created by gtadmin on 4/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "fontPicker.h"


@implementation fontPicker

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
        self.pickerItems = [[NSArray alloc] initWithArray:[NSArray arrayWithObjects:
                                                           @"AmericanTypewriter",
                                                           @"AmericanTypewriter-Bold",
                                                           @"AppleGothic",
                                                           @"Arial-BoldItalicMT",
                                                           @"Arial-BoldMT",
                                                           @"Arial-ItalicMT",
                                                           @"Boycott",
                                                           @"ChalkboardSE-Bold",
                                                           @"ChalkboardSE-Regular",
                                                           @"ChatoBandSmooth",
                                                           @"Courier",
                                                           @"DBLCDTempBlack",
                                                           @"DevanagariSangamMN-Bold",
                                                           @"Futura-CondensedExtraBold",
                                                           @"Futura-Medium",
                                                           @"Futura-MediumItalic",
                                                           @"Georgia",
                                                           @"Georgia-Bold",
                                                           @"Georgia-BoldItalic",
                                                           @"Georgia-Italic",
                                                           @"GrilledCheeseBTNCn",
                                                           @"GrilledCheeseBTNCnBold",
                                                           @"Helvetica",
                                                           @"Helvetica-Bold",
                                                           @"Helvetica-BoldOblique",
                                                           @"Helvetica-Oblique",
                                                           @"HelveticaNeue",
                                                           @"HelveticaNeue-Bold",
                                                           @"HelveticaNeue-BoldItalic",
                                                           @"HelveticaNeue-Italic",
                                                           @"HelveticaNeueLT-Black",
                                                           @"HelveticaNeueLT-Light",
                                                           @"HelveticaNeueLT-UltraLight",
                                                           @"Herculanum",
                                                           @"MarkerFelt-Thin",
                                                           @"MarkerFelt-Wide",
                                                           @"Noteworthy-Bold",
                                                           @"Noteworthy-Light",
                                                           @"Satisfaction",
                                                           @"SnellRoundhand",
                                                           @"SnellRoundhand-Bold",
                                                           @"STHeitiJ-Light",
                                                           @"STHeitiJ-Medium",
                                                           @"SwanSong",
                                                           @"TimesNewRomanPS-BoldItalicMT",
                                                           @"TimesNewRomanPS-BoldMT",
                                                           @"TimesNewRomanPS-ItalicMT",
                                                           @"TimesNewRomanPSMT",
                                                           nil]];
        self.pickerType = pType;
        CGRect pickerFrame = CGRectMake(0, 44, 320, 400);
        self.pickerView = [[UIPickerView alloc] initWithFrame:pickerFrame];
        self.pickerView.dataSource = self;
        self.pickerView.delegate = self;
        [self.pickerView setShowsSelectionIndicator:YES];
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
    [label setText:[[self.pickerItems objectAtIndex:row] capitalizedString]];
    [label setFont:[UIFont fontWithName:[self.pickerItems objectAtIndex:row] size:14]];
    if(kIsiOS7){
        [label setFont:[UIFont fontWithName:[self.pickerItems objectAtIndex:row] size:16]];
    }
    
    [label setShadowColor:[UIColor whiteColor]];
    [label setShadowOffset:CGSizeMake(1, 1)];
    
    // This part just colorizes everything, since you asked about that.
    [label setTextColor:[UIColor blackColor]];
    
    //if([pickerType isEqualToString:@"locations"] && row == 0)
    //   [label setTextColor:[UIColor colorWithRed:.3 green:.3 blue:1.0 alpha:1.0]];
    [label setTextAlignment:NSTextAlignmentCenter];
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
