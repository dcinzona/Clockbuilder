//
//  manageGeneralSettings.m
//  ClockBuilder
//
//  Created by gtadmin on 3/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "manageGeneralSettings.h"
#import "weatherSettingsIndex.h"
#import "globalTextSettings.h"
#import "infoViewController.h"
#import "slideShowSettingsNew.h"
#import "PrettyCell.h"
#import "BGImageCell.h"
#import "themeConverter.h"
#import "manageJBSettings.h"
#import "CBThemeHelper.h"

@implementation manageGeneralSettings


#define kTotalCells  8
#define kBackgroundCell 0
#define kClearBackgroundCell 1
#define kWeatherSettingsCell  2
#define kGlobalTextCell  3
#define kSnapToGrid 4
#define kGridSize 5
#define kMilitaryTimeCell  6
#define kParallaxCell  7
#define kLockscreenCell  8
#define kiCloudCell  9

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)dealloc{
    NSLog(@"dealloc settings table");
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
-(void) exitModal
{
    [[[UIApplication sharedApplication]delegate]performSelector:@selector(goBackToRootView)];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    NSLog(@"Settings table did load");
    [super viewDidLoad];
    
    [self setTitle:@"Settings"];
    
    if (kIsIpad) {
        self.contentSizeForViewInPopover = kPopoverSize;
    }
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    if(!kIsiOS7){
        UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tvFooterBG.png"]];
        [bg setContentMode:UIViewContentModeTopLeft];
        [self.tableView setTableFooterView:bg];
        [self.tableView setSectionFooterHeight:0];
        
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
    }
    else{
        
    }
    
    if(kIsIpad){
        
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(exitModal)];
        self.navigationItem.leftBarButtonItem = doneButton;
        
        UIBarButtonItem *infoButton = [[UIBarButtonItem alloc] initWithTitle:@"Info" style:UIBarButtonItemStyleBordered target:self action:@selector(showInfoView)];
        self.navigationItem.rightBarButtonItem = infoButton;
        
    }
    else{
        UIBarButtonItem *doneButton = [CBThemeHelper createDoneButtonItemWithTitle:@"Done" target:self action:@selector(exitModal)];
        self.navigationItem.leftBarButtonItem = doneButton;
        
        
        self.navigationItem.rightBarButtonItem = [CBThemeHelper createDarkButtonItemWithTitle:@"Info" target:self action:@selector(showInfoView)];
                                              
    }
    
    
    showStatusBar = [[UISwitch alloc] initWithFrame:CGRectZero];
    [showStatusBar addTarget: self action: @selector(showStatusBar:) forControlEvents: UIControlEventValueChanged];
    showStatusBar.center = CGPointMake(self.tableView.frame.size.width - (showStatusBar.frame.size.width/2) - 10, 32);
    
    BOOL statusBarPref = YES;
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"showStatusBar"] boolValue]==NO)
        statusBarPref = NO;
    showStatusBar.on = statusBarPref;
    
    disablePaging = [[UISwitch alloc] initWithFrame:CGRectZero];
    [disablePaging addTarget: self action: @selector(togglePaging:) forControlEvents: UIControlEventValueChanged];
    disablePaging.center = CGPointMake(self.tableView.frame.size.width - (disablePaging.frame.size.width/2) - 10, 32);
    
    BOOL paging = [[[NSUserDefaults standardUserDefaults] objectForKey:@"pagingEnabled"] boolValue];
    disablePaging.on = paging;
    
    militaryTime = [[UISwitch alloc] initWithFrame:CGRectZero];
    [militaryTime addTarget: self action: @selector(toggle24hr:) forControlEvents: UIControlEventValueChanged];
    militaryTime.center = CGPointMake(self.tableView.frame.size.width - (militaryTime.frame.size.width/2) - 10, 32);
    
    BOOL mt = [[[NSUserDefaults standardUserDefaults] objectForKey:@"militaryTime"] boolValue];
    militaryTime.on = mt;
    
    if(kIsIpad)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData) name:@"refreshBG" object:nil];
    }
    
    
    CGRect buttonFrame = CGRectMake(0, 0, 100, 32);
    saveBGButton= [CBThemeHelper createBlueUIButtonWithTitle:@"Save" target:self action:@selector(saveBackgroundImageToLibrary) frame:buttonFrame];
    
    [saveBGButton setCenter:CGPointMake(self.tableView.frame.size.width - (saveBGButton.frame.size.width/2) - 10, 32)];
    
    clearBGButton= [CBThemeHelper createBlueUIButtonWithTitle:@"Clear" target:self action:@selector(selectBlackBG) frame:buttonFrame];
    if(kIsiOS7){
        [clearBGButton setTitleColor:kDefaultDeleteColor forState:UIControlStateNormal];
    }
    [clearBGButton setCenter:CGPointMake(self.tableView.frame.size.width - (clearBGButton.frame.size.width/2) - 10, 32)];
    
    
    parallaxSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    [parallaxSwitch addTarget: self action: @selector(toggleParallax:) forControlEvents: UIControlEventValueChanged];
    BOOL parlax = [[[NSUserDefaults standardUserDefaults] objectForKey:@"parallaxEnabled"] boolValue];
    parallaxSwitch.on = parlax;
    
    
    backgroundSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    [backgroundSwitch addTarget: self action: @selector(toggleBackground:) forControlEvents: UIControlEventValueChanged];
    backgroundSwitch.center = CGPointMake(self.tableView.frame.size.width - (backgroundSwitch.frame.size.width/2) - 10, 32);
    BOOL bgOn = [[[NSUserDefaults standardUserDefaults] objectForKey:@"backgroundEnabled"] boolValue];
    backgroundSwitch.on = bgOn;
    
}

- (IBAction)toggleParallax:(id)sender
{
    if([[GMTHelper sharedInstance] checkIfJB]){
        if(![[[NSUserDefaults standardUserDefaults] objectForKey:@"showedParallaxAlert"] boolValue]){
            [[NSUserDefaults standardUserDefaults]setObject:@"YES" forKey:@"showedParallaxAlert"];
            [[GMTHelper sharedInstance] alertWithString:@"Whenever you change this option, you must set the theme as the lockscreen again"];
        }
    }
    
    NSString *keyValue = @"NO";
    if(parallaxSwitch.on)
        keyValue = @"YES";
    [[NSUserDefaults standardUserDefaults] setObject:keyValue forKey:@"parallaxEnabled"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (IBAction)toggleBackground:(id)sender
{
    NSString *keyValue = @"NO";
    if(backgroundSwitch.on){
        keyValue = @"YES";
        if(!imagepicker){
            imagepicker = [[ImagePickerView alloc] init];
            imagepicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            [imagepicker setDelegate:self];
        }
        
        [self presentViewController:imagepicker animated:YES completion:nil];
    }
    else{
        //select black bg
        [self selectBlackBG];
        [[self tableView] reloadData];
    }
    
}

-(void)saveBackgroundImageToLibrary{
    
    [[GMTHelper sharedInstance] notifyToShowGlobalHudWithSpinner:@"Saving to photos" andHide:YES withDelay:10 andDim:YES];
    BOOL is2x = NO;
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        if ((NSInteger)[[UIScreen mainScreen] scale] == 2) {
            is2x = YES;
        }
    }
    
    dispatch_async(dispatch_queue_create("com.gmtaz.clockbuilder.imageQueue", 0ul), ^{
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *appFilePNG = [documentsDirectory stringByAppendingPathComponent:@"LockBackground.png"];
        if(is2x)
        {
            if([[NSFileManager defaultManager] fileExistsAtPath:[documentsDirectory stringByAppendingPathComponent:@"LockBackground@2x.png"]])
                appFilePNG = [documentsDirectory stringByAppendingPathComponent:@"LockBackground@2x.png"];
        }
        UIImage *bgImage = [UIImage imageWithContentsOfFile:appFilePNG];
            if(bgImage){
                
                UIImageWriteToSavedPhotosAlbum(bgImage, nil, nil, nil);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[GMTHelper sharedInstance] showOverlay:@"Saved" iconImage:nil];
                });
                
            }
            else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[GMTHelper sharedInstance] notifyToHideGlobalHud];
                    [[GMTHelper sharedInstance]alertWithString:@"There was an error saving the background"];
                });
            }
    });
    
    
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if([buttonTitle isEqualToString:@"Overwrite"]){
        
        [CBThemeHelper setThemeUbiquity:[[NSUserDefaults standardUserDefaults] boolForKey:@"iCloudEnabled"] overwrite:YES];
        [[self.view window].rootViewController performSelector:@selector(setupAndStartQuery)];
    }
    if([buttonTitle isEqualToString:@"Skip"]){
        
        [CBThemeHelper setThemeUbiquity:[[NSUserDefaults standardUserDefaults] boolForKey:@"iCloudEnabled"] overwrite:NO];
        [[self.view window].rootViewController performSelector:@selector(setupAndStartQuery)];
    }
    if([buttonTitle isEqualToString:@"Proceed"]){
        
        [CBThemeHelper setThemeUbiquity:[[NSUserDefaults standardUserDefaults] boolForKey:@"iCloudEnabled"] overwrite:YES];
        [[self.view window].rootViewController performSelector:@selector(setupAndStartQuery)];
    }
    
}
-(void)setThemeUbiquity:(BOOL)putInIcloud{
    
    //BACKGROUND THIS
    /**/
    
   // [CBThemeHelper setThemeUbiquity:[[NSUserDefaults standardUserDefaults] boolForKey:@"iCloudEnabled"] overwrite:YES];
   // [[self.view window].rootViewController performSelector:@selector(setupAndStartQuery)];
    
    
    NSString *title = @"Proceed";
    NSString *message = @"If you disable iCloud sync, all themes stored in the cloud will not be available on this device while iCloud is disabled";
    if(putInIcloud){
       message = @"Enableing iCloud sync.  We will now attempt to merge all your themes."; 
    }
    
    CustomAlertView *alert = [[CustomAlertView alloc]initWithTitle:title
                                                   message:message
                                                  delegate:self 
                                         cancelButtonTitle:@"Proceed" 
                                         otherButtonTitles:nil];
    [alert show];
}

- (IBAction)toggleiCloud:(id)sender
{
    [self refreshData];
}
- (IBAction)togglePaging:(id)sender
{
    NSString *keyValue = @"NO";
    if(disablePaging.on)
        keyValue = @"YES";
    [[NSUserDefaults standardUserDefaults]setObject:keyValue forKey:@"pagingEnabled"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}
- (IBAction)toggle24hr:(id)sender
{
    NSString *keyValue = @"NO";
    if(militaryTime.on)
        keyValue = @"YES";
    [[NSUserDefaults standardUserDefaults]setObject:keyValue forKey:@"militaryTime"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}
- (IBAction)showStatusBar:(id)sender
{
    NSString *keyValue = @"NO";
    if(showStatusBar.on)
        keyValue = @"YES";
    [[NSUserDefaults standardUserDefaults]setObject:keyValue forKey:@"showStatusBar"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[UIApplication sharedApplication] setStatusBarHidden:!showStatusBar.on withAnimation:YES];
    
}
- (IBAction)setSnapToGrid:(id)sender
{
    UISwitch *snapSwitch = (UISwitch*)sender;
    NSString *keyValue = @"NO";
    if(snapSwitch.on)
        keyValue = @"YES";
    [[NSUserDefaults standardUserDefaults] setObject:keyValue forKey:@"snapToGrid"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}
- (IBAction)setGridSize:(id)sender
{
    UISlider *slider = (UISlider*)sender;
    
    int val = round(slider.value);
    
    [slider setValue:val animated:NO];
    
    NSString *keyValue = [NSString stringWithFormat:@"%i",val];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:kGridSize inSection:0]];
    
    [cell.textLabel setText:[NSString stringWithFormat:@"Grid Size: %i", val]];
    
    [[NSUserDefaults standardUserDefaults] setObject:keyValue forKey:@"gridSize"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}


-(void)showInfoView
{
    infoViewController *iview = [[infoViewController alloc] initWithNibName:@"infoViewController" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:iview animated:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    if(kIsIpad){
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshBG" object:nil];
    }
    NSLog(@"settings table did unload");
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData) name:kApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kApplicationDidBecomeActiveNotification object:nil];
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
    themeConverter *th = [themeConverter new];
    int rows= kTotalCells;
    
    if([th checkIfThemeInstalled])
        rows = kTotalCells + 1;
    return rows;
}

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
#define kViewWidth self.view.frame.size.width
#define kCellHeight 64
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if(indexPath.row==kBackgroundCell){
        static NSString *CellIdentifier = @"CellBG";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[BGImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            
            //[cell addSubview:saveBGButton];
            /*[saveBGButton setFrame:CGRectMake(320-saveBGButton.frame.size.width-20,
                                              (64 - saveBGButton.frame.size.height)/2,
                                              saveBGButton.frame.size.width,
                                              saveBGButton.frame.size.height)];*/
            [cell setAccessoryView:saveBGButton];
        }
        [[cell textLabel] setText:@" Background"];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *appFilePNG = [documentsDirectory stringByAppendingPathComponent:@"LockBackgroundThumb.png"];
        UIImage *bgImage = [UIImage imageWithContentsOfFile:appFilePNG];
        cell.imageView.image = bgImage;
        if(bgImage==nil)
        {
            cell.imageView.image = [UIImage imageNamed:@"LockBackgroundThumb.png"];
        }
        return cell;
    }
    
    if(indexPath.row==kClearBackgroundCell){
        static NSString *CellIdentifier = @"CellBG";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[PrettyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            [cell setAccessoryView:clearBGButton];
        }
        [[cell textLabel] setText:@"Clear Background"];
        return cell;
    }
    if(indexPath.row==kWeatherSettingsCell){
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[PrettyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        [[cell textLabel] setText:@"Weather Settings"];
        [self addCellAccessory:cell];
        
        return cell;
    }
    if(indexPath.row==kGlobalTextCell){
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[PrettyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        [[cell textLabel] setText:@"Modify All Text"];
        [self addCellAccessory:cell];
        
        return cell;
    }
    if(indexPath.row==kSnapToGrid ){
        static NSString *CellIdentifier = @"switchCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[PrettyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            UISwitch *cellSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
            [cellSwitch addTarget:self action:@selector(setSnapToGrid:) forControlEvents:UIControlEventValueChanged];
            [cell setAccessoryView:cellSwitch];
        }
        [[cell textLabel] setText:@"Snap to Grid"];
        UISwitch *sw = (UISwitch *)[cell accessoryView];
        sw.on = [[[NSUserDefaults standardUserDefaults] objectForKey:@"snapToGrid"] boolValue];
        
        return cell;
    }
    if(indexPath.row==kGridSize ){
        static NSString *CellIdentifier = @"sliderCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[PrettyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, 100, 0)];
            slider.continuous = YES;
            [slider setMinimumValue:1];
            [slider setMaximumValue:10];
            [slider addTarget:self action:@selector(setGridSize:) forControlEvents:UIControlEventValueChanged];
            [cell setAccessoryView:slider];
        }
        UISlider *slider = (UISlider *)[cell accessoryView];
        if([[NSUserDefaults standardUserDefaults] objectForKey:@"gridSize"]){
            slider.value = [[[NSUserDefaults standardUserDefaults] objectForKey:@"gridSize"] intValue];
        }
        else{
            slider.value = 5;
            [[NSUserDefaults standardUserDefaults] setObject:@"5" forKey:@"gridSize"];
        }
        [[cell textLabel] setText:[NSString stringWithFormat:@"Grid Size: %i",(int)slider.value]];
        return cell;
    }
    if(indexPath.row==kMilitaryTimeCell ){
        static NSString *CellIdentifier = @"switchCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[PrettyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            /*
            [cell addSubview:militaryTime];
            [militaryTime setFrame:CGRectMake(320-militaryTime.frame.size.width-20,
                                               (64 - militaryTime.frame.size.height)/2,
                                               militaryTime.frame.size.width,
                                               militaryTime.frame.size.height)];
             */
            [cell setAccessoryView:militaryTime];
        }
        [[cell textLabel] setText:@"Use 24hr Time"];        
        
        
        return cell;
    }
    /*
    if(indexPath.row==kiCloudCell ){
        static NSString *CellIdentifier = @"switchCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[PrettyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            [cell addSubview:iCloudSwitch];
            [dbSyncButton setHidden:YES];
            [cell addSubview:dbSyncButton];
            [cell setClipsToBounds:YES];
        }
        [[cell textLabel] setText:@"Link to Dropbox"];        
        
        if([[DBSession sharedSession] isLinked]){
            [dbSyncButton setHidden:NO];
        }
        else
            [dbSyncButton setHidden:YES];
        
        return cell;
    }
     */
    if(indexPath.row==kParallaxCell ){
        static NSString *CellIdentifier = @"switchCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[PrettyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            [cell setAccessoryView:parallaxSwitch];
        }
        [[cell textLabel] setText:@"3D Background Effect"];
        
        return cell;
    }
    if(indexPath.row==kLockscreenCell ){
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[PrettyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        [[cell textLabel] setText:@"Lockscreen Settings"];
        [self addCellAccessory:cell];
        
        return cell;
    }
    return cell;
}

-(void)synchronizeWithDB{
    
}

-(void)refreshData
{
    [self.tableView reloadData];
}

#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*if(indexPath.row == kiCloudCell){
        if([[DBSession sharedSession] isLinked]){
            //return 128;
        }
    }*/
    
    return 64;//self.view.window.screen.scale * 64;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return nil;
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
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.row == kBackgroundCell ){
        if(!imagepicker){
            imagepicker = [[ImagePickerView alloc] init];
            imagepicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            [imagepicker setDelegate:self];
        }
        if(kIsIpad){
            if(!pop)
                pop = [[UIPopoverController alloc] initWithContentViewController:imagepicker];
            [imagepicker setPopover:pop];
            BGImageCell *cell = (BGImageCell*)[tableView cellForRowAtIndexPath:indexPath];
            [pop presentPopoverFromRect:cell.imageView.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
        else{
            [self presentViewController:imagepicker animated:YES completion:nil];
        }

        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    //ImagePickerView *imagepicker = [[ImagePickerView alloc] init];
    //imagepicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    //[imagepicker setDelegate:imagepicker];
    /*
    if(indexPath.row == kBackgroundCell)
    {
        if(!imagepicker){
            imagepicker = [[ImagePickerView alloc] init];
            imagepicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            [imagepicker setDelegate:imagepicker];
        }
        if(kIsIpad)
        {
            [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
            //UIPopoverController *pop = ApplicationDelegate.viewController.pop;
            //[pop setContentViewController:imagepicker];
            if(!pop)
                pop = [[UIPopoverController alloc] initWithContentViewController:imagepicker];
            [imagepicker setPopover:pop];
            BGImageCell *cell = (BGImageCell*)[tableView cellForRowAtIndexPath:indexPath];
            [pop presentPopoverFromRect:cell.imageView.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
        else
        {
            [self presentModalViewController:imagepicker animated:YES];
        }
    }
     */
    if(indexPath.row == kWeatherSettingsCell)
    {
        weatherSettingsIndex *wSettings = [[weatherSettingsIndex alloc] initWithStyle:UITableViewStylePlain];
        [self.navigationController pushViewController:wSettings animated:YES];
    }
    if(indexPath.row == kGlobalTextCell)
    {
        if([self firstTextWidget]!=-1){
            globalTextSettings *wSettings = [[globalTextSettings alloc] initWithStyle:UITableViewStylePlain];
            [self.navigationController pushViewController:wSettings animated:YES];
        }
        else
        {
            CustomAlertView *alert = [[CustomAlertView alloc] initWithTitle:@"Whomp Whomp" message:@"You haven't added any text-based items yet." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];  
    }
    if(indexPath.row==kLockscreenCell)
    {
        //push jb settings
        manageJBSettings *mj = [[manageJBSettings alloc] initWithStyle:UITableViewStylePlain];
        [self.navigationController pushViewController:mj animated:YES];
    }
    if(indexPath.row==kiCloudCell || indexPath.row==kMilitaryTimeCell || indexPath.row == kClearBackgroundCell || indexPath.row == kParallaxCell)
    {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];  
    }
    if(indexPath.row == kClearBackgroundCell){
        [self selectBlackBG];
    }
}


- (void)selectBlackBG
{
    UIImage *black = [UIImage imageNamed:@"blackBG.png"];
    if([[GMTHelper sharedInstance] resizeImageToBackground:black]){
        [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"parallaxEnabled"];
        [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"backgroundEnabled"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [parallaxSwitch setOn:NO];
        [self refreshData];
    }
    //[self dismissModalViewControllerAnimated:YES];
}
-(void)removeLoadingOverlay
{
    [[GMTHelper sharedInstance] notifyToHideGlobalHud];
    if([self.parentViewController respondsToSelector:@selector(viewWillAppear:)])
        [self.parentViewController performSelector:@selector(viewWillAppear:) withObject:nil];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    [[GMTHelper sharedInstance] notifyToShowGlobalHudWithSpinner:@"Scaling Image" andHide:YES withDelay:20 andDim:YES];
    NSOperationQueue *q = [NSOperationQueue new];
    NSInvocationOperation *save = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(saveImageAsynchUsingImage:) object:image];
    [q addOperation:save];
}
-(void)saveImageAsynchUsingImage:(UIImage *)image
{
    if([[GMTHelper sharedInstance] resizeImageToBackground:image]){
        NSString *keyValue = @"YES";
        [[NSUserDefaults standardUserDefaults] setObject:keyValue forKey:@"backgroundEnabled"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    [self performSelector:@selector(removeLoadingOverlay)  onThread:[NSThread mainThread] withObject:nil waitUntilDone:YES];
    if(kIsIpad){
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshBG" object:nil];
            [pop dismissPopoverAnimated:YES];
            //refresh cells
            [self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:kBackgroundCell inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView endUpdates];
        });
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshBG" object:nil];
    });    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	// Dismiss the image selection and close the program
    //don't change current value (in case the user thought to change the bg but changed their mind)
    NSString *keyValue = @"NO";
    BOOL bgenabled = [[[NSUserDefaults standardUserDefaults] objectForKey:@"backgroundEnabled"] boolValue];
    
    if(bgenabled){
        keyValue = @"YES";
    }
    
    NSLog(@"backgroundEnabled: %@", keyValue);
    [[NSUserDefaults standardUserDefaults] setObject:keyValue forKey:@"backgroundEnabled"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [backgroundSwitch setOn:[keyValue boolValue]];
    [self dismissViewControllerAnimated:YES completion:nil];
	//exit(0);
}

-(void)dismissModalViewControllerAnimated:(BOOL)animated{
    if(kIsIpad)
    {
        [pop dismissPopoverAnimated:YES];
        //refresh cells
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:kBackgroundCell inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
    }
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"refreshBG" object:nil];
    [super dismissModalViewControllerAnimated:animated];
}


@end
