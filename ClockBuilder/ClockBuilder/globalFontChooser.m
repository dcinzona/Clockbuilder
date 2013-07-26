//
//  globalFontChooser.m
//  ClockBuilder
//
//  Created by gtadmin on 4/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "globalFontChooser.h"
#import "PrettyCell.h"


@implementation globalFontChooser
@synthesize settings, AllFonts, widgetList;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        [self checkFonts];
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (NSString *) getFontStringFromWidgetClass
{
    NSInteger index = [[[NSUserDefaults standardUserDefaults] objectForKey:@"widgetIndex"] integerValue];
    return [[widgetList objectAtIndex:index] objectForKey:@"fontFamily"];
}

- (void) getSelectedFontIndexPath
{
    selectedFont = [NSIndexPath indexPathForRow:0 inSection:0];
    NSString *widgetFont = [self getFontStringFromWidgetClass];
    for (NSUInteger x=0; x<[AllFonts count]; x++) {
        if([[AllFonts objectAtIndex:x]isEqualToString:widgetFont])
        {
            selectedFont = [NSIndexPath indexPathForRow:x inSection:0];
        }
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (kIsIpad) {
        self.contentSizeForViewInPopover = kPopoverSize;
    }
    
    [self refreshData];
    UIImageView *TVbgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"fadedBG.JPG"]];
    [self.tableView setBackgroundView:TVbgView];
    
    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tvFooterBG.png"]];
    [bg setContentMode:UIViewContentModeTopLeft];
    [self.tableView setTableFooterView:bg];
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}

- (void) refreshData
{
    settings = [kDataSingleton settings];
    widgetList = [kDataSingleton getWidgetsListFromSettings];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
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
    /*
     NSArray *fonts = [[NSUserDefaults standardUserDefaults] objectForKey:@"fontsList"];
     return [fonts count];
     */
    return [AllFonts count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64;//self.view.window.screen.scale * 64;
}
-(void)addCellAccessory:(UITableViewCell *) cell{
    if(!kIsiOS7){
        UIImageView *accessory = [[ UIImageView alloc ]
                                  initWithImage:[UIImage imageNamed:@"tvCellAccessoryCheck.png" ]];
        cell.accessoryView = accessory;
    }
    else{
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[PrettyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    //NSArray *fontsArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"fontsList"];
    [[cell textLabel]setText:[AllFonts objectAtIndex:indexPath.row]];
    [[cell textLabel]setFont:[UIFont fontWithName:[AllFonts objectAtIndex:indexPath.row] size:16.0]];
    if([[AllFonts objectAtIndex:indexPath.row]isEqualToString:[self getFontStringFromWidgetClass]])
    {
        selectedFont = indexPath;
        [self addCellAccessory:cell];
    }
    else
    {
        cell.accessoryView = nil;    
    }
    
    return cell;
}
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO];
    UIImageView *accessory = [[ UIImageView alloc ] 
                              initWithImage:[UIImage imageNamed:@"tvCellAccessoryCheck.png" ]];
    //if([tableView cellForRowAtIndexPath:selectedFont]!=nil)
    //    [tableView cellForRowAtIndexPath:selectedFont].accessoryView = nil;  
    selectedFont = indexPath;
    if(!kIsiOS7){
    [tableView cellForRowAtIndexPath:selectedFont].accessoryView = accessory;
    }
    else{
        [tableView cellForRowAtIndexPath:selectedFont].accessoryType = UITableViewCellAccessoryCheckmark;
    }
    NSString *font = [[[tableView cellForRowAtIndexPath:indexPath] textLabel]text];
    NSMutableDictionary *widgetData = [kDataSingleton getWidgetDataFromIndex:[[[NSUserDefaults standardUserDefaults]
                                                                               objectForKey:@"widgetIndex"] integerValue]];
    
    [widgetData setObject:font forKey:@"fontFamily"];
    NSString *index = [[NSUserDefaults standardUserDefaults] objectForKey:@"widgetIndex"];
    
    [[NSUserDefaults standardUserDefaults]setObject:@"YES" forKey:@"forceRedraw"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(saveWidgetSettings:widgetDataDictionary:) withObject:index withObject:widgetData];
    [self refreshData];
    [self.tableView reloadData];
}
- (void) checkFonts
{
    
    NSArray *familyNames = [[NSArray alloc] initWithArray:[UIFont familyNames]];
    
    NSArray *fontNames;
    
    NSInteger indFamily, indFont;
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithObjects: nil];
    
    for (indFamily=0; indFamily<[familyNames count]; ++indFamily)
        
    {
        
        //NSLog(@"Family name: %@", [familyNames objectAtIndex:indFamily]);
        
        fontNames = [[NSArray alloc] initWithArray:
                     
                     [UIFont fontNamesForFamilyName:
                      
                      [familyNames objectAtIndex:indFamily]]];
        
        for (indFont=0; indFont<[fontNames count];
             
             ++indFont)
            
        {
            
            // NSLog(@" Font name: %@", [fontNames objectAtIndex:indFont]);
            //if(![[fontNames objectAtIndex:indFont]isEqualToString:@"Zapfino"])
            [tempArray addObject:[fontNames objectAtIndex:indFont]];
        }
        
        
    }
    
    //NSLog(@" Font: %@", tempArray);
    //AllFonts = [[NSArray alloc] initWithArray:[tempArray sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
    
    
    AllFonts = [[NSArray alloc] initWithArray:
                [NSArray arrayWithObjects:
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
    
    
    
    [self getSelectedFontIndexPath];
}



@end
