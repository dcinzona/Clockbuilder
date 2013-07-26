//
//  textSettingsTableViewIndex.m
//  ClockBuilder
//
//  Created by gtadmin on 3/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "textSettingsTableViewIndex.h"
#import "chooseFont.h"
#import "PrettyCell.h"

@implementation textSettingsTableViewIndex
@synthesize SelectedCell, 
settings, 
slider, 
widgetData,
widgetsList, 
pickerAS,
pickerASType,
picker,
tempPicker,
textField,
weatherData;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    self.settings = nil;
    self.widgetsList = nil;
    self.widgetData = nil;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.SelectedCell = nil;
    self.settings = nil;
    self.slider = nil;
    self.widgetData = nil;
    self.widgetsList = nil;
    self.pickerAS = nil;
    self.picker = nil;
    self.tempPicker = nil;
    self.textField = nil;
    self.weatherData = nil;
    self.pickerASType = nil;
}
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void) saveWidgetData
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:@"YES" forKey:@"forceRedraw"];
    [prefs synchronize];
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(saveWidgetSettings:widgetDataDictionary:) withObject:[prefs objectForKey:@"widgetIndex"] withObject:self.widgetData];
}

- (void) initVariables
{
    
    self.settings = [kDataSingleton getSettings];
    self.widgetsList = [kDataSingleton getWidgetsListFromSettings];
    self.widgetData = [NSMutableDictionary dictionaryWithDictionary:
                       [kDataSingleton getWidgetDataFromIndex: [[[NSUserDefaults standardUserDefaults] objectForKey:@"widgetIndex"] integerValue]]];
    
    self.weatherData = [self.settings objectForKey:@"weatherData"];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (kIsIpad) {
        self.contentSizeForViewInPopover = kPopoverSize;
    }
    
    
    [self initVariables];
    
  //[self.navigationController.navigationBar setBarStyle:UIBarStyleBlackOpaque];
    self.slider = [[UISlider alloc] initWithFrame:CGRectMake(170, 10, 125, 50)];
    [self.slider addTarget:self action:@selector(setOpacitySlider:) forControlEvents:UIControlEventValueChanged];
    [self.slider setMinimumValue:.01];
    [self.slider setMaximumValue:1];
    self.textField =  [[UITextField alloc] initWithFrame:CGRectMake(140, 22, 160, 22)];
    [self.textField setBackgroundColor:[UIColor clearColor]];
    [self.textField setTextColor:[UIColor whiteColor]];
    [self.textField setDelegate:self];
    if([[self.widgetData objectForKey:@"subClass"]isEqualToString:@"datetime"])
        [self.textField addTarget:self action:@selector(updateDateUsingContentsOfTextField:) forControlEvents:UIControlEventEditingChanged];
    [self.textField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self.textField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [self.textField setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.0]];
    [self.textField setTextColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:.9]];
    [self.textField setKeyboardType:UIKeyboardTypeDefault];
    [self.textField setReturnKeyType:UIReturnKeyDone];
    
    /*
    UIImageView *TVbgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"fadedBG.JPG"]];
    [self.tableView setBackgroundView:TVbgView];
     */
    
    UIImageView *bg2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, [UIScreen mainScreen].bounds.size.height)];
    [bg2 setImage:[UIImage imageNamed:@"tableGradient"]];
    [bg2 setContentMode:UIViewContentModeTop];
    UIView *bgView = [[UIView alloc] initWithFrame:self.view.frame];
    [self.tableView setBackgroundView:bgView];
    [bgView addSubview:bg2];
    UIColor *tableBGColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"office"]];
    [bgView setBackgroundColor:tableBGColor];
    [self.tableView setBackgroundColor:tableBGColor];
    
    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tvFooterBG.png"]];
    [bg setContentMode:UIViewContentModeTopLeft];
    [self.tableView setTableFooterView:bg];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];

    NSString *cls = [self.widgetData objectForKey:@"className"];
    self.title = [NSString stringWithFormat:@"%@ Settings",  cls];
    
    [self.navigationItem setLeftBarButtonItem: [CBThemeHelper createBackButtonItemWithTitle:@"Settings" target:self.navigationController action:@selector(popViewControllerAnimated:)]];

}
- (void) goBackPressed
{
    [self saveWidgetData];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)updateDateUsingContentsOfTextField:(id*)sender
{
    [self updateDateTimeLabel:[self.textField text]];
}

- (BOOL)textFieldShouldReturn:(UITextField *)tf {
	if (tf == self.textField) {
		[self.textField resignFirstResponder];
        
        if([[self.widgetData objectForKey:@"subClass"]isEqualToString:@"datetime"]){
            [self updateDateTimeLabel:[self.textField text]];
            [self.widgetData setObject:[self.textField text] forKey:@"dateFormatOverride"];
        }
        if([[self.widgetData objectForKey:@"subClass"]isEqualToString:@"text"]){
            [self.widgetData setObject:[self.textField text] forKey:@"text"];
            [self.tableView reloadData];
        }
        if([[self.widgetData objectForKey:@"subClass"]isEqualToString:@"weather"]){
            if([[self.widgetData objectForKey:@"className"]isEqualToString:@"Weather Location"])
                [self.widgetData setObject:[self.textField text] forKey:@"text"];
            
            [self.tableView reloadData];
        }
	}
	return YES;
}

- (void) closeModal
{        
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self initVariables];
    //[self saveWidgetData];
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{    [super viewWillDisappear:animated];
    [self saveWidgetData];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return 7;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64;//self.view.window.screen.scale * 64;
}

#define _conditionalCell 6

-(void)addCellAccessory:(UITableViewCell *) cell{
    if(!kIsiOS7){
        UIImageView *accessory = [[ UIImageView alloc ]
                                  initWithImage:[UIImage imageNamed:@"tvCellAccessory.png" ]];
        cell.accessoryView = accessory;
    }
    else{
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[PrettyCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    // Configure the cell...
    if(indexPath.row==0)
    {
        [[cell textLabel] setText:@"Select Font"];
        [[cell detailTextLabel] setText:[self.widgetData objectForKey:@"fontFamily"]];//Set to text font for widget
        
        UIImageView *accessory = [[ UIImageView alloc ] 
                                  initWithImage:[UIImage imageNamed:@"tvCellAccessory.png" ]];
        cell.accessoryView = accessory;
    }
    if(indexPath.row==1)
    {
        [[cell textLabel] setText:@"Select Color"];
        
        UIColor *color = (UIColor *)[NSKeyedUnarchiver unarchiveObjectWithData:[self.widgetData objectForKey:@"fontColor"]];
        NSString *desc = [NSString stringWithFormat:@"Color: %@",[[[NSString stringWithFormat:@"%@",color] stringByReplacingOccurrencesOfString:@"UIDeviceRGBColorSpace " withString:@""] stringByReplacingOccurrencesOfString:@"UIDeviceWhiteColorSpace" withString:@"1 1"] ];
        
        [[cell detailTextLabel] setTextColor:color];
        const CGFloat *c = CGColorGetComponents(color.CGColor);  
        if(c[CGColorGetNumberOfComponents(color.CGColor)-1]==0)
        {
            desc = @"Transparent";
            [[cell detailTextLabel] setTextColor:[UIColor whiteColor]];
        }
        [[cell detailTextLabel] setText:desc]; 
        [self addCellAccessory:cell];
    }
    if(indexPath.row==2)
    {
        [[cell textLabel] setText:@"Select Glow Color"];
        
        UIColor *color = (UIColor *)[NSKeyedUnarchiver unarchiveObjectWithData:[self.widgetData objectForKey:@"glowColor"]];
        NSString *desc = [NSString stringWithFormat:@"Glow: %@",[[[NSString stringWithFormat:@"%@",color] stringByReplacingOccurrencesOfString:@"UIDeviceRGBColorSpace " withString:@""] stringByReplacingOccurrencesOfString:@"UIDeviceWhiteColorSpace" withString:@"1 1"] ];
        
        [[cell detailTextLabel] setTextColor:color];
        const CGFloat *c = CGColorGetComponents(color.CGColor);  
        if(c[CGColorGetNumberOfComponents(color.CGColor)-1]==0)
        {
            desc = @"Transparent";
            [[cell detailTextLabel] setTextColor:[UIColor whiteColor]];
        }
        [[cell detailTextLabel] setText:desc]; 
        [self addCellAccessory:cell];
    }
    if(indexPath.row==3)
    {
        [[cell textLabel] setText:@"Set Opacity"];
        
        NSString *opacity = [self.widgetData objectForKey:@"opacity"];
        if([opacity isEqualToString:@""])
            opacity=@"1.0";
        [[cell detailTextLabel] setText:[NSString stringWithFormat:@"Opacity: %@",opacity]];
        if([[cell subviews] indexOfObject:self.slider]==NSNotFound)
        {            
            [self.slider setValue:[opacity floatValue]];
            [cell addSubview:self.slider];
        }
    }
    if(indexPath.row==4)
    {   
        NSString *alignment = [self.widgetData objectForKey:@"textalignment"];
        NSArray * alignments= [NSArray arrayWithObjects: @"left", @"center", @"right", nil];
        NSArray * segs = [NSArray arrayWithObjects: @"left", @"center", @"right", nil];
        UISegmentedControl *segmentedControl= [[UISegmentedControl alloc] initWithItems: segs];
        segmentedControl.segmentedControlStyle= UISegmentedControlStyleBar;
        segmentedControl.selectedSegmentIndex= [alignments indexOfObject:alignment];
        
        [segmentedControl addTarget: self action: @selector(setAlignment:) forControlEvents: UIControlEventValueChanged];
        segmentedControl.frame  = CGRectMake(150, 16, 140, 30);
        segmentedControl.tintColor= [UIColor grayColor];
        [cell addSubview:segmentedControl];    
        [[cell textLabel]setText:@"Text Align"];
    }
    if(indexPath.row==5)
    {   
        NSString *tt = [self.widgetData objectForKey:@"textTransform"];
        if(tt == nil)
            tt = @"default";
        NSArray * transformations= [NSArray arrayWithObjects: @"uppercase", @"lowercase", @"default", nil];
        NSArray * segs = [NSArray arrayWithObjects: @"uppercase", @"lowercase", @"default", nil];
        UISegmentedControl *segmentedControl= [[UISegmentedControl alloc] initWithItems: segs];
        segmentedControl.segmentedControlStyle= UISegmentedControlStyleBar;
        segmentedControl.selectedSegmentIndex= [transformations indexOfObject:tt];
        
        [segmentedControl addTarget: self action: @selector(setTextTransform:) forControlEvents: UIControlEventValueChanged];
        segmentedControl.frame  = CGRectMake(20, 16, 280, 30);
        segmentedControl.tintColor= [UIColor grayColor];
        [cell addSubview:segmentedControl];    
    }
    if(indexPath.row==_conditionalCell)
    {
        [[cell textLabel] setText:@"Conditional Cell"];
        NSString *widgetSubType = [self.widgetData objectForKey:@"subClass"];

        if([widgetSubType isEqualToString:@"datetime"]){
            [[cell textLabel] setText:@"Set Date Format"];
            [[cell detailTextLabel] setText:[NSString stringWithFormat:@"Result: %@",[self updateDateTimeLabel:nil]]];
            [self.textField setText:[self.widgetData objectForKey:@"dateFormatOverride"]];
            if ([[cell subviews] indexOfObject:self.textField]==NSNotFound) {
                [cell addSubview:self.textField];
            }
        }
        if([widgetSubType isEqualToString:@"text"]){
            [[cell textLabel] setText:@"Custom Text"];
            [[cell detailTextLabel] setText:[NSString stringWithFormat:@"%@", [self.widgetData objectForKey:@"text"]]];
            if([cell.detailTextLabel.text isEqualToString:@""])
                [cell.detailTextLabel setText:@"(No Text)"];
            self.textField.placeholder = @"Enter Custom Text";
            if ([[cell subviews] indexOfObject:self.textField]==NSNotFound) {
                [cell addSubview:self.textField];
            }
        }
        if([widgetSubType isEqualToString:@"weather"]){
            //Location Customization
            if([[self.widgetData objectForKey:@"className"] isEqualToString:@"Location"]){
                    [[cell textLabel] setText:@"Override Location"];
                    [[cell detailTextLabel] setText:[NSString stringWithFormat:@"%@", [self.widgetData objectForKey:@"text"]]];
                    if([cell.detailTextLabel.text isEqualToString:@""])
                        [cell.detailTextLabel setText:@"(Current Location)"];
                    self.textField.placeholder = @"Custom Text";
                    if ([[cell subviews] indexOfObject:self.textField]==NSNotFound) {
                        [cell addSubview:self.textField];
                }
            }
            if([[self.widgetData objectForKey:@"className"] isEqualToString:@"Conditions"]){
                [[cell textLabel] setText:@"Conditions Forecast:"];
                NSString *detail = [NSString stringWithFormat:@"%@'s Conditions",[[self.widgetData objectForKey:@"forecast"] capitalizedString]];
                if([[self.widgetData objectForKey:@"forecast"]isEqualToString:@"current"])
                    detail = [NSString stringWithFormat:@"%@ Conditions",[[self.widgetData objectForKey:@"forecast"] capitalizedString]];
                [[cell detailTextLabel] setText:detail]; 
                [self addCellAccessory:cell];

            }
            if([[self.widgetData objectForKey:@"className"] isEqualToString:@"Temperature"]){
                [[cell textLabel] setText:@"Temperature Forecast:"];
                NSString *detail = [NSString stringWithFormat:@"%@'s %@",[[self.widgetData objectForKey:@"forecast"] capitalizedString], [self.widgetData objectForKey:@"textItemType"]];
                if([[self.widgetData objectForKey:@"forecast"]isEqualToString:@"current"])
                    detail = @"Current Temperature";
                [[cell detailTextLabel] setText:detail]; 
                [self addCellAccessory:cell];
            }
        }
        
    }
    
    
    return cell;
}
- (void)setAlignment:(id)sender
{
    UISegmentedControl *seg = (UISegmentedControl *)sender;
    int clickedSegment= [seg selectedSegmentIndex];
    NSArray * alignments= [NSArray arrayWithObjects: @"left", @"center", @"right", nil];
    [self.widgetData setObject:[alignments objectAtIndex:clickedSegment] forKey:@"textalignment"];
    
}
- (void)setTextTransform:(id)sender
{
    UISegmentedControl *seg = (UISegmentedControl *)sender;
    int clickedSegment= [seg selectedSegmentIndex];
    NSArray * alignments= [NSArray arrayWithObjects: @"uppercase", @"lowercase", @"default", nil];
    [self.widgetData setObject:[alignments objectAtIndex:clickedSegment] forKey:@"textTransform"];
    
}
- (NSString *)updateDateTimeLabel:(NSString*)dateFormat
{
    if(dateFormat==nil)
        dateFormat = [self.widgetData objectForKey:@"dateFormatOverride"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:dateFormat];
    NSString *ret = [dateFormatter stringFromDate:[NSDate date]];
    NSInteger _c = _conditionalCell;
    NSIndexPath *ip = [NSIndexPath indexPathForRow:_c inSection:0] ;
    [[[self.tableView cellForRowAtIndexPath:ip]     
       detailTextLabel]
      setText:[NSString stringWithFormat:@"Result: %@", ret] 
      ];
    return ret;
}

-(void)updateCellDetailsFromSlider:(UISlider *)sender{
    self.SelectedCell = [NSIndexPath indexPathForRow:3 inSection:0];
    [[[self.tableView cellForRowAtIndexPath:self.SelectedCell] detailTextLabel] setText:[NSString stringWithFormat:@"Opacity: %f",[sender value]]];
}

- (void)setOpacitySlider:(UISlider*)sender
{
    self.SelectedCell = [NSIndexPath indexPathForRow:3 inSection:0];
    [[[self.tableView cellForRowAtIndexPath:self.SelectedCell] detailTextLabel] setText:[NSString stringWithFormat:@"Opacity: %f",[sender value]]];
    NSString *opS = [NSString stringWithFormat:@"%f",[sender value]];
    [self.widgetData setObject:opS forKey:@"opacity"];
}

#pragma mark Picker Actions


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
    [self.pickerAS addSubview:toolbar];    
    if([self.pickerASType isEqualToString:@"picker"])
        [self.pickerAS addSubview:self.picker.pickerView];
    else
        [self.pickerAS addSubview:self.tempPicker.pickerView];
    
    [self.pickerAS showInView:[self.view superview]];
    [self.pickerAS setBounds:CGRectMake(0,0,320, 408)];  
}

-(void)dismissActionSheet{
    [self.pickerAS dismissWithClickedButtonIndex:0 animated:YES];
    if([self.pickerASType isEqualToString:@"tempPicker"])
        self.tempPicker = nil;
    else
        self.picker = nil;
    self.pickerAS = nil;
    [[self.tableView cellForRowAtIndexPath:self.SelectedCell] setSelected:NO animated:YES];
    self.SelectedCell = nil;
}


-(void)saveActionSheet{
    [self.pickerAS dismissWithClickedButtonIndex:1 animated:YES];
    
    if([self.pickerASType isEqualToString:@"picker"]){
        NSUInteger selectedRow = [self.picker.pickerView selectedRowInComponent:0];
        NSString *selected = [self.picker.pickerItems objectAtIndex:selectedRow];
        if([self.picker.pickerType isEqualToString:@"textalignment"]){
            [[[self.tableView cellForRowAtIndexPath:self.SelectedCell] detailTextLabel] setText:[NSString stringWithFormat:@"Current Alignment: %@", [selected capitalizedString]]];
            [self.widgetData setObject:selected forKey:self.picker.pickerType];
        }
        if([self.picker.pickerType isEqualToString:@"conditions"]){
            [[[self.tableView cellForRowAtIndexPath:self.SelectedCell] detailTextLabel] setText:[NSString stringWithFormat:@"%@", [selected capitalizedString]]];
            
            NSString *newForecast = [[selected stringByReplacingOccurrencesOfString:@"'s Forecast" withString:@""] lowercaseString];
            
            [self.widgetData setObject:newForecast forKey:@"forecast"];
        }
        self.picker = nil;
    }
    else
    {
        NSString *forecast = [[self.tempPicker.forecastType stringByReplacingOccurrencesOfString:@"'s Forecast" withString:@""] lowercaseString];
        NSString *textItemType = [self.tempPicker.temperatureValue stringByReplacingOccurrencesOfString:@"Current " withString:@""];
        [self.widgetData setObject:forecast forKey:@"forecast"];
        [self.widgetData setObject:textItemType forKey:@"textItemType"];
        [[[self.tableView cellForRowAtIndexPath:self.SelectedCell] detailTextLabel] setText:[NSString stringWithFormat:@"%@'s %@", [forecast capitalizedString],textItemType]];
        if([forecast isEqualToString:@"current"])
            [[[self.tableView cellForRowAtIndexPath:self.SelectedCell] detailTextLabel] setText:@"Current Temperature"];
            
        
        self.tempPicker = nil;
    }
    
    //set alignment for widget data   
    [self.tableView deselectRowAtIndexPath:self.SelectedCell animated:YES];  
    self.SelectedCell = nil;
    self.pickerAS = nil;
}

#pragma mark Show Pickers
- (void) showAlignmentPicker
{
    NSArray *pickerList = [NSArray arrayWithObjects:@"left", @"center", @"right", nil];
    self.picker = [[WidgetPickerViewController alloc] initWithPickerItems:pickerList pickerType:@"textalignment"];
    NSString *title = @"Text Align:";
    self.pickerASType = @"picker";
    self.pickerAS = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"cancel" destructiveButtonTitle:nil otherButtonTitles:nil];
    [self addToolbarToPicker:title];
}
- (void) showConditionsPicker
{
    NSArray *pickerList = [NSArray arrayWithObjects:@"Current", @"Today's Forecast", @"Tomorrow's Forecast", nil];
    self.picker = [[WidgetPickerViewController alloc] initWithPickerItems:pickerList pickerType:@"conditions"];
    NSString *title = @"Forecast";
    self.pickerASType = @"picker";
    self.pickerAS = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"cancel" destructiveButtonTitle:nil otherButtonTitles:nil];
    [self addToolbarToPicker:title];
}
- (void) showTemperatureSettingsPicker
{
    self.tempPicker = [[temperatureSettingsPicker alloc] init];
    NSString *title = @"Forecast / Temp";
    self.pickerASType = @"tempPicker";
    self.pickerAS = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"cancel" destructiveButtonTitle:nil otherButtonTitles:nil];
    [self addToolbarToPicker:title];
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    self.SelectedCell = indexPath;
    if(indexPath.row==0){
         chooseFont *fontChooser = [[chooseFont alloc]initWithStyle:UITableViewStylePlain];
         [self.navigationController pushViewController:fontChooser animated:YES];
        [self.tableView deselectRowAtIndexPath:self.SelectedCell animated:YES];  
    }
   
    if(indexPath.row==3){
        [self.tableView deselectRowAtIndexPath:self.SelectedCell animated:YES];   
    }
    if(indexPath.row==4 || indexPath.row == 5){
        //[self showAlignmentPicker];
        [self.tableView deselectRowAtIndexPath:self.SelectedCell animated:YES];  
    }
    if(indexPath.row==_conditionalCell){
        NSString *widgetSubType = [self.widgetData objectForKey:@"subClass"];
        if([widgetSubType isEqualToString:@"weather"] && ![[self.widgetData objectForKey:@"className"] isEqualToString:@"Location"]){
            //show picker
            if([[self.widgetData objectForKey:@"className"] isEqualToString:@"Conditions"]){
                [self showConditionsPicker];
            }
            if([[self.widgetData objectForKey:@"className"] isEqualToString:@"Temperature"]){
                [self showTemperatureSettingsPicker];
            }
        }
        else
        {
            [self.textField becomeFirstResponder];
            [self.tableView deselectRowAtIndexPath:self.SelectedCell animated:YES];   
        }
    }

}


@end
