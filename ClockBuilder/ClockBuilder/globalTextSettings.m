//
//  globalTextSettings.m
//  ClockBuilder
//
//  Created by gtadmin on 4/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "globalTextSettings.h"
#import "globalFontChooser.h"
#import "PrettyCell.h"
#import "fontPicker.h"
#import "ColorSliderPickerView.h"
#import "GlowColorSliderPickerView.h"

@implementation globalTextSettings
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
    //Do nothing here... all widget data get's individually saved.
}



-(NSInteger)firstTextWidget
{
    NSInteger x = 0;
    for(NSDictionary *dic in [[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"] objectForKey:@"widgetsList"])
    {
        if([[dic objectForKey:@"class"]isEqualToString:@"textBasedWidget"])
            return x;
        else
            x++;
    }
    return -1;
}

- (void) initVariables
{
    self.settings = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"] ];
    self.widgetsList = [NSMutableArray arrayWithArray:[self.settings  objectForKey:@"widgetsList"] ] ;
    self.widgetData = [NSMutableDictionary dictionaryWithDictionary:[self.widgetsList objectAtIndex:[self firstTextWidget]]];
    self.weatherData = [self.settings objectForKey:@"weatherData"];
    [self.tableView reloadData];
}

-(void)updateAllWidgets:(id)object forKey:(NSString *)key
{
    //itterate through all widgets and set the data to the data.
    NSInteger x = 0;
    BOOL _shouldUpdate = NO;
    NSMutableArray *a = [self.widgetsList mutableCopy];
    for(NSDictionary *w in self.widgetsList)
    {
        if([[w objectForKey:@"class"]isEqualToString:@"textBasedWidget"]||
           [[weatherSingleton sharedInstance]isClimacon])
        {
            NSLog(@"updateAllWidgets: setting object: %@",object);
            NSMutableDictionary *w1 = [w mutableCopy];
            [w1 setObject:object forKey:key];
            [a replaceObjectAtIndex:x withObject:w1];
            _shouldUpdate = YES;
        }
        x++;
    }
    if(_shouldUpdate)
    {
        [self.settings setObject:a forKey:@"widgetsList"];
        [[NSUserDefaults standardUserDefaults] setObject:self.settings forKey:@"settings"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        if(kIsIpad)
            [AppDelegate.viewController performSelector:@selector(refreshViews)];
        [self initVariables];
    }
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
    [self.slider addTarget:self action:@selector(setOpacitySlider:) forControlEvents:UIControlEventTouchUpInside];
    [self.slider setMinimumValue:.01];
    [self.slider setMaximumValue:1];
    
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
    
    self.title = @"Change All Text";
    
    if(!kIsIpad)
        [self.navigationItem setLeftBarButtonItem: [CBThemeHelper createBackButtonItemWithTitle:@"Settings" target:self.navigationController action:@selector(popViewControllerAnimated:)]];
    
    
}
- (void) goBackPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) closeModal
{        
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self initVariables];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initVariables) name:@"updateGlobalTextSettingsTable" object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{    
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateGlobalTextSettingsTable" object:nil];
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
    return 6;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64;//self.view.window.screen.scale * 64;
}

#define _conditionalCell 6

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
        if(!color)
            color = [UIColor whiteColor];
        NSString *desc = [NSString stringWithFormat:@"Color: %@",[[[NSString stringWithFormat:@"%@",color] stringByReplacingOccurrencesOfString:@"UIDeviceRGBColorSpace " withString:@""] stringByReplacingOccurrencesOfString:@"UIDeviceWhiteColorSpace" withString:@"1 1"] ];
        
        [[cell detailTextLabel] setTextColor:color];
        const CGFloat *c = CGColorGetComponents(color.CGColor);  
        if(c[CGColorGetNumberOfComponents(color.CGColor)-1]==0)
        {
            desc = @"Transparent";
            [[cell detailTextLabel] setTextColor:[UIColor whiteColor]];
        }
        [[cell detailTextLabel] setText:desc]; 
        UIImageView *accessory = [[ UIImageView alloc ] 
                                  initWithImage:[UIImage imageNamed:@"tvCellAccessory.png" ]];
        cell.accessoryView = accessory;     
    }
    if(indexPath.row==2)
    {
        [[cell textLabel] setText:@"Select Glow Color"];
        
        UIColor *color = (UIColor *)[NSKeyedUnarchiver unarchiveObjectWithData:[self.widgetData objectForKey:@"glowColor"]];
        if(!color)
            color = [UIColor blackColor];
        NSString *desc = [NSString stringWithFormat:@"Glow: %@",[[[NSString stringWithFormat:@"%@",color] stringByReplacingOccurrencesOfString:@"UIDeviceRGBColorSpace " withString:@""] stringByReplacingOccurrencesOfString:@"UIDeviceWhiteColorSpace" withString:@"1 1"] ];
        
        [[cell detailTextLabel] setTextColor:color];
        const CGFloat *c = CGColorGetComponents(color.CGColor);  
        if(c[CGColorGetNumberOfComponents(color.CGColor)-1]==0)
        {
            desc = @"Transparent";
            [[cell detailTextLabel] setTextColor:[UIColor whiteColor]];
        }
        [[cell detailTextLabel] setText:desc]; 
        UIImageView *accessory = [[ UIImageView alloc ] 
                                  initWithImage:[UIImage imageNamed:@"tvCellAccessory.png" ]];
        cell.accessoryView = accessory;     
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
        
        BOOL addSeg = YES;
        for (UIView *v in cell.subviews) {
            if(v.tag==300){
                addSeg = NO;
                break;
            }
        }
        if(addSeg){
            NSString *alignment = [self.widgetData objectForKey:@"textalignment"];
            NSArray * alignments= [NSArray arrayWithObjects: @"left", @"center", @"right", nil];
            NSArray * segs = [NSArray arrayWithObjects: @"left", @"center", @"right", nil];
            UISegmentedControl *segmentedControl= [[UISegmentedControl alloc] initWithItems: segs];
            segmentedControl.segmentedControlStyle= UISegmentedControlStyleBar;
            segmentedControl.selectedSegmentIndex= [alignments indexOfObject:alignment];
            
            [segmentedControl addTarget: self action: @selector(setAlignment:) forControlEvents: UIControlEventValueChanged];
            segmentedControl.frame  = CGRectMake(150, 16, 140, 30);
            segmentedControl.tintColor= [UIColor grayColor];
            segmentedControl.tag = 300;
            [cell addSubview:segmentedControl];
        }
        [[cell textLabel]setText:@"Text Align"];
    }
    if(indexPath.row==5)
    {   
        NSString *tt = [self.widgetData objectForKey:@"textTransform"];
        if(tt == nil)
            tt = @"default";
        
        BOOL addSeg = YES;
        for (UIView *v in cell.subviews) {
            if(v.tag==301){
                addSeg = NO;
                break;
            }
        }
        if(addSeg){        
            NSArray * transformations= [NSArray arrayWithObjects: @"uppercase", @"lowercase", @"default", nil];
            NSArray * segs = [NSArray arrayWithObjects: @"uppercase", @"lowercase", @"default", nil];
            UISegmentedControl *segmentedControl= [[UISegmentedControl alloc] initWithItems: segs];
            segmentedControl.segmentedControlStyle= UISegmentedControlStyleBar;
            segmentedControl.selectedSegmentIndex= [transformations indexOfObject:tt];
            
            [segmentedControl addTarget: self action: @selector(setTextTransform:) forControlEvents: UIControlEventValueChanged];
            segmentedControl.frame  = CGRectMake(20, 16, 280, 30);
            segmentedControl.tintColor= [UIColor grayColor];
            segmentedControl.tag = 301;
            [cell addSubview:segmentedControl];
        }
    }
    
    return cell;
}
- (void)setAlignment:(id)sender
{
    UISegmentedControl *seg = (UISegmentedControl *)sender;
    int clickedSegment= [seg selectedSegmentIndex];
    NSArray * alignments= [NSArray arrayWithObjects: @"left", @"center", @"right", nil];
    [self updateAllWidgets:[alignments objectAtIndex:clickedSegment] forKey:@"textalignment"];
    
}
- (void)setTextTransform:(id)sender
{
    UISegmentedControl *seg = (UISegmentedControl *)sender;
    int clickedSegment= [seg selectedSegmentIndex];
    NSArray * alignments= [NSArray arrayWithObjects: @"uppercase", @"lowercase", @"default", nil];
    [self updateAllWidgets:[alignments objectAtIndex:clickedSegment] forKey:@"textTransform"];
    
}
- (void)setOpacitySlider:(UISlider*)sender
{
    self.SelectedCell = [NSIndexPath indexPathForRow:3 inSection:0];
    [[[self.tableView cellForRowAtIndexPath:self.SelectedCell] detailTextLabel] setText:[NSString stringWithFormat:@"Opacity: %f",[sender value]]];
    NSString *opS = [NSString stringWithFormat:@"%f",[sender value]];
    [self updateAllWidgets:opS forKey:@"opacity"];
}

#pragma mark Picker Actions


-(void) addToolbarToPicker:(NSString *)title
{
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    toolbar.barStyle = UIBarStyleBlackOpaque;
    if (!kIsIpad) {
        [toolbar sizeToFit];
    }
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
        if([self.picker.pickerType isEqualToString:@"fontFamily"]){
            [[[self.tableView cellForRowAtIndexPath:self.SelectedCell] detailTextLabel] setText:[NSString stringWithFormat:@"%@", [selected capitalizedString]]];
            [self updateAllWidgets:selected forKey:self.picker.pickerType];
        }
    }
    //set alignment for widget data   
    [self.tableView deselectRowAtIndexPath:self.SelectedCell animated:YES];  
    self.SelectedCell = nil;
    self.pickerAS = nil;
}

#pragma mark Show Pickers
- (void) showFontPicker
{
    NSArray *pickerList = [NSArray arrayWithObjects:@"left", @"center", @"right", nil];
    self.picker = (WidgetPickerViewController *)[[fontPicker alloc] initWithPickerItems:pickerList pickerType:@"fontFamily"];
    NSString *title = @"Font Family";
    self.pickerASType = @"picker";
    self.pickerAS = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"cancel" destructiveButtonTitle:nil otherButtonTitles:nil];
    [self addToolbarToPicker:title];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    self.SelectedCell = indexPath;
    if(indexPath.row==0){
        [self showFontPicker];
    }
    if(indexPath.row==1){
        ColorSliderPickerView *colorpicker = [[ColorSliderPickerView alloc] initWithFrame:CGRectMake(0, 0, 320, 360)];
        UIColor *color = (UIColor *)[NSKeyedUnarchiver unarchiveObjectWithData:[self.widgetData objectForKey:@"fontColor"]];

        if(!color){ color=[UIColor whiteColor];}
         
        NSLog(@"selected color: %@", color);
        
        [colorpicker activateInView:self.view withColor:color];
        [self.tableView deselectRowAtIndexPath:self.SelectedCell animated:YES];  
    }
    if(indexPath.row==2){
        UIColor *color = (UIColor *)[NSKeyedUnarchiver unarchiveObjectWithData:[self.widgetData objectForKey:@"glowColor"]];
        if(!color) color=[UIColor blackColor];
        NSString *glowAmount = [self.widgetData objectForKey:@"glowAmount"];
        GlowColorSliderPickerView *glowPicker = [[GlowColorSliderPickerView alloc] initWithFrame:CGRectMake(0, 0, 320, 360)];
        [glowPicker activateInView:self.view withColor:color andGlowAmount:[glowAmount floatValue]];
        [self.tableView deselectRowAtIndexPath:self.SelectedCell animated:YES];  
    }
    if(indexPath.row==3){
        [self.tableView deselectRowAtIndexPath:self.SelectedCell animated:YES];   
    }
    if(indexPath.row==4 || indexPath.row == 5){
        [self.tableView deselectRowAtIndexPath:self.SelectedCell animated:YES];  
    }
    
}
- (void)colorPickerViewController:(ColorPickerViewController *)colorPicker didSelectColor:(UIColor *)color;
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:self.SelectedCell];
    NSString *desc = [NSString stringWithFormat:@"Color: %@",[[NSString stringWithFormat:@"%@",color] stringByReplacingOccurrencesOfString:@"UIDeviceRGBColorSpace " withString:@""] ];

    
    [[cell detailTextLabel] setTextColor:color];
    const CGFloat *c = CGColorGetComponents(color.CGColor);  
    if(c[CGColorGetNumberOfComponents(color.CGColor)-1]==0)
    {
        desc = @"Transparent";
        [[cell detailTextLabel] setTextColor:[UIColor whiteColor]];
    }
    
    
    [[cell detailTextLabel] setText:desc];
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:color];
    if(self.SelectedCell.row==1)
        [self updateAllWidgets:colorData forKey:@"fontColor"];
    if(self.SelectedCell.row==2)
        [self updateAllWidgets:colorData forKey:@"glowColor"];
    [colorPicker.parentViewController dismissViewControllerAnimated:YES completion:nil];
}


@end
