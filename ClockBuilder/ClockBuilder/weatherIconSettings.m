//
//  weatherWidgetSettings.m
//  ClockBuilder
//
//  Created by gtadmin on 3/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

/* -------------------------------------------------
 Settings to manage here:
 
 iconSet
 forecast
 opacity
 
 
 */

#import <QuartzCore/QuartzCore.h>
#import "weatherIconSettings.h"
#import "BGImageCell.h"
//#import "Reachability.h"
#import "UIImageView+WebCache.h"
#import "SDImageCache.h"

@implementation weatherIconSettings
@synthesize SelectedCell, 
settings, 
slider, 
widgetData,
widgetsList, 
pickerAS,
picker;

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
}
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void) saveWidgetData
{
    [[NSUserDefaults standardUserDefaults]setObject:@"YES" forKey:@"forceRedraw"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(saveWidgetSettings:widgetDataDictionary:) withObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"widgetIndex"] withObject:widgetData];
}

- (void) initVariables
{
    
    self.settings = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"]];
    self.widgetsList = [NSMutableArray arrayWithArray:[self.settings  objectForKey:@"widgetsList"]];
    self.widgetData = [NSMutableDictionary dictionaryWithDictionary:[self.widgetsList objectAtIndex:[[[NSUserDefaults standardUserDefaults] objectForKey:@"widgetIndex"] integerValue] ]] ;
    
    UIColor *ret = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
    
    if([self.widgetData objectForKey:@"glowColor"] == nil)
    {
        NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:ret];
        [self.widgetData setObject:colorData forKey:@"glowColor"];
        [self saveWidgetData];
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initVariables];
    
  //[self.navigationController.navigationBar setBarStyle:UIBarStyleBlackOpaque];
    self.slider = [[UISlider alloc] initWithFrame:CGRectMake(170, 10, 125, 50)];
    [self.slider addTarget:self action:@selector(setOpacitySlider:) forControlEvents:UIControlEventValueChanged];
    [self.slider setMinimumValue:.01];
    [self.slider setMaximumValue:1];
    
    
    UIImageView *TVbgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"fadedBG.JPG"]];
    [self.tableView setBackgroundView:TVbgView];
    
    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tvFooterBG.png"]];
    [bg setContentMode:UIViewContentModeTopLeft];
    [self.tableView setTableFooterView:bg];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    NSString *cls = [self.widgetData objectForKey:@"className"];
    self.title = [NSString stringWithFormat:@"%@ Settings",  cls];
    
    if(![NSStringFromClass([[self parentViewController] class])isEqualToString:@"ManageWidgetsNavigationController"])
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonItemStylePlain target:self action:@selector(closeModal)];
    
}

- (void) closeModal
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self initVariables];
    [self saveWidgetData];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self saveWidgetData];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self saveWidgetData];
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
    return 2;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64;//self.view.window.screen.scale * 64;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    // Configure the cell...
    if(indexPath.row==0)
    {
        if (cell == nil) {
            cell = [[PrettyCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        
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
        [cell setSelected:NO];
    }
    if(indexPath.row==1)
    {
        if (cell == nil) {
            cell = [[PrettyCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        
        [[cell textLabel] setText:@"Select Forecast Report"];
        
        NSString *title = [self.widgetData objectForKey:@"forecast"];
        if([title isEqualToString:@""])
            title=@"left";
        [[cell detailTextLabel] setText:[NSString stringWithFormat:@"Weather Report: %@",title]];
        [cell setSelected:NO];
    }

    
    
    return cell;
}


- (void)setOpacitySlider:(UISlider*)sender
{
    self.SelectedCell = [NSIndexPath indexPathForRow:0 inSection:0];
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
    [self.pickerAS addSubview:self.picker.pickerView];
    [self.pickerAS showInView:[self.view superview]];
    [self.pickerAS setBounds:CGRectMake(0,0,320, 408)];
}

-(void)dismissActionSheet{
    [self.pickerAS dismissWithClickedButtonIndex:0 animated:YES];
    self.picker = nil;
    self.pickerAS = nil;    
    [self.tableView deselectRowAtIndexPath:self.SelectedCell animated:YES]; 
    self.SelectedCell = nil;
}
-(void)saveActionSheet{
    [self.pickerAS dismissWithClickedButtonIndex:1 animated:YES];
    NSUInteger selectedRow = [self.picker.pickerView selectedRowInComponent:0];
    NSString *selected = [self.picker.pickerItems objectAtIndex:selectedRow];
    
    if([self.picker.pickerType isEqualToString:@"forecast"])
    {
        [[[self.tableView cellForRowAtIndexPath:self.SelectedCell] detailTextLabel] setText:[NSString stringWithFormat:@"Weather Report: %@", [selected capitalizedString]]];
    }
    if([self.picker.pickerType isEqualToString:@"iconSet"])
    {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:self.SelectedCell];
        [[cell detailTextLabel] setText:[NSString stringWithFormat:@"%@", selected]];
        [cell.imageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@.png",[[NSString stringWithFormat:@"%@", selected] lowercaseString]]]];
    }
    
    //set alignment for widget data
    [self.widgetData setObject:selected forKey:self.picker.pickerType];     
    [self.tableView deselectRowAtIndexPath:self.SelectedCell animated:YES]; 
    self.SelectedCell = nil;
    self.picker = nil;
    self.pickerAS = nil;
}

#pragma mark Show Pickers
- (void) showForecastPicker
{
    NSArray *pickerList = [NSArray arrayWithObjects:@"Current", @"Today", @"Tomorrow", nil];
    self.picker = [[WidgetPickerViewController alloc] initWithPickerItems:pickerList pickerType:@"forecast"];
    NSString *title = @"Forecast Type:";
    self.pickerAS = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"cancel" destructiveButtonTitle:nil otherButtonTitles:nil];
    [self addToolbarToPicker:title];
}
- (void) showIconSetPicker
{
    NSArray *pickerList = [NSArray arrayWithObjects:@"HTC", @"Tick", @"Flat", @"Yahoo", nil];
    self.picker = [[WidgetPickerViewController alloc] initWithPickerItems:pickerList pickerType:@"iconSet"];
    NSString *title = @"Forecast Type:";
    self.pickerAS = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"cancel" destructiveButtonTitle:nil otherButtonTitles:nil];
    [self addToolbarToPicker:title];
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    self.SelectedCell = indexPath;
    if(indexPath.row==0){ 
        [self.tableView deselectRowAtIndexPath:self.SelectedCell animated:YES]; 
    }
    if(indexPath.row==1){
        [self showForecastPicker];
    }
    
}


@end

