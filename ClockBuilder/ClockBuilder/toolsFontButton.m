//
//  toolsFontButton.m
//  ClockBuilder
//
//  Created by Gustavo Tandeciarz on 4/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "toolsFontButton.h"


@implementation toolsFontButton
@synthesize fontButtonLabel;
@synthesize pickerItems, pickerType, pickerView,pickerAS;


-(void)showFontPicker{
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    toolbar.barStyle = UIBarStyleDefault;
    if(!kIsIpad){
        [toolbar sizeToFit];
    }
    [CBThemeHelper setBackgroundImage:nil forToolbar:toolbar];
    NSMutableArray *barItems = [[NSMutableArray alloc] init];
    UIBarButtonItem *cancelBtn = [CBThemeHelper createDarkButtonItemForStyledToolbarWithTitle:@"Cancel" target:self action:@selector(dismissActionSheet)];
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *doneBtn = [CBThemeHelper createBlueButtonItemWithTitle:@"Done" target:self action:@selector(saveActionSheet)];
    UILabel *titleLabel = [[UILabel alloc] init];
    [titleLabel setText:@"Select Font"];
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
    [pickerAS setBounds:CGRectMake(0,0,320, 408)];
    if(kIsiOS7){
        [titleLabel setCenter:toolbar.center];
        [titleLabel setShadowColor:nil];
        [titleLabel setTextColor:[UIColor darkGrayColor]];
        [pickerAS setBackgroundColor:[UIColor whiteColor]];
        [toolbar setFrame:CGRectMake(0, 0, toolbar.frame.size.width, toolbar.frame.size.height)];
        [pickerAS setBounds:CGRectMake(0,0,320, 340)];
    }
    
    if(kIsIpad){
        UIView *v = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 300)];
        UIViewController *vc = [[UIViewController alloc]init];
        [vc setPreferredContentSize:CGSizeMake(320, 260)];
        [vc setView:v];
        [v addSubview:toolbar];
        [v addSubview:pickerView];
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
-(void)showSetFontSize{
    ClockBuilderViewController * rvc = (ClockBuilderViewController *)self.window.rootViewController;
    int currentFontSize = [rvc.widgetSelected performSelector:@selector(getWidgetFontSize) withObject:nil];
    [MKEntryPanel showPanelWithTitle:@"Set Font Size" inView:self.window.rootViewController.view withText:[NSString stringWithFormat:@"%i",currentFontSize] numericOnly:YES onTextEntered:^(NSString *inputString) {
        [rvc.widgetSelected performSelector:@selector(setWidgetFontSize:) withObject:[NSNumber numberWithInt:[inputString intValue]]];
    } onCancel:^{
        
    }];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}
-(void)fontButtonClick:(id)sender
{
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    UIMenuItem *setFontSize = [[UIMenuItem alloc] initWithTitle:@"Set Size" action:@selector(showSetFontSize)];
    UIMenuItem *changeFont = [[UIMenuItem alloc] initWithTitle:@"Change Font" action:@selector(showFontPicker)];
    
    [self becomeFirstResponder];
    [menuController setMenuItems:[NSArray arrayWithObjects:changeFont, setFontSize,nil]];
    [menuController setTargetRect:CGRectMake(40, 20, 0, 0) inView:self];
    [menuController setArrowDirection:UIMenuControllerArrowDefault];
    [menuController setMenuVisible:YES animated:YES];

}

-(void)dismissActionSheet{
    [pickerAS dismissWithClickedButtonIndex:0 animated:YES];
    if(kIsIpad && pop){
        [pop dismissPopoverAnimated:YES];
    }
    [self.window.rootViewController performSelector:@selector(updateFontForText:) withObject:fontButtonLabel.font.fontName];    
}


-(void)saveActionSheet{
    [pickerAS dismissWithClickedButtonIndex:1 animated:YES];
    
    if(kIsIpad && pop){
        [pop dismissPopoverAnimated:YES];
    }
    
    NSUInteger selectedRow = [pickerView selectedRowInComponent:0];
    NSString *selected = [pickerItems objectAtIndex:selectedRow];
    //Save Font Data
    [self.window.rootViewController performSelector:@selector(saveNewFontForText:) withObject:selected];
}

#pragma mark Picker DataSource

- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    return [pickerItems count];
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    return [[pickerItems objectAtIndex:row] capitalizedString];
}

- (UIView *)pickerView:(UIPickerView *)pv viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label = (UILabel*) view;
    if (label == nil)
    {
        label = [[UILabel alloc] init];
    }
    [label setText:[[pickerItems objectAtIndex:row] capitalizedString]];
    [label setFont:[UIFont fontWithName:[pickerItems objectAtIndex:row] size:14]];
    if(kIsiOS7){
        [label setFont:[UIFont fontWithName:[pickerItems objectAtIndex:row] size:16]];
    }
    [label setShadowColor:[UIColor whiteColor]];
    [label setShadowOffset:CGSizeMake(1, 1)];
    
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
    //NSLog(@"Selected item: %@. Index of selected item: %i", [pickerItems objectAtIndex:row], row);
    NSUInteger selectedRow = [pickerView selectedRowInComponent:0];
    NSString *selected = [pickerItems objectAtIndex:selectedRow];
    [self.window.rootViewController performSelector:@selector(updateFontForText:) withObject:selected];
    
}




#pragma mark life cycle

-(void)build
{
    [self setShowsTouchWhenHighlighted:YES];
    //ios 7 fix
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, 40, 40)];
    
    [self addTarget:self action:@selector(fontButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    self.layer.cornerRadius = 20;
    self.layer.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.7].CGColor;
    self.layer.borderColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0].CGColor;
    self.layer.borderWidth = 4;
    fontButtonLabel = [[UILabel alloc] init];
    [fontButtonLabel setFrame:CGRectMake(5, 5, 30, 30)];
    [fontButtonLabel setTextAlignment:NSTextAlignmentCenter];
    [fontButtonLabel setBackgroundColor:[UIColor clearColor]];
    [fontButtonLabel setFont:[UIFont fontWithName:@"Helvetica" size:(30*.8)]];
    fontButtonLabel.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:.8];
    [fontButtonLabel setText:@"A"];
    [self addSubview:fontButtonLabel];
    
    pickerItems =[[NSArray alloc] initWithArray:[NSArray arrayWithObjects:
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
    pickerType = @"fontFamily";
    CGRect pickerFrame = CGRectMake(0, 44, 320, 400);
    pickerView = [[UIPickerView alloc] initWithFrame:pickerFrame];
    pickerView.dataSource = self;
    pickerView.delegate = self;
    [pickerView setShowsSelectionIndicator:YES];
    [pickerView setBackgroundColor:[UIColor whiteColor]];
    [pickerView setFrame:CGRectMake(0, 24, 320, 400)];
    if(kIsIpad){
        [pickerView setFrame:CGRectMake(0, 44, 320, 400)];
    }
    NSString *title = @"\n\n\n\n\n\n\n\n\n\n\n\n";
    pickerAS = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    [pickerAS addSubview:pickerView];
    
}


@end
