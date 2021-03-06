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
//#import <DropboxSDK/DropboxSDK.h>

@implementation manageGeneralSettings


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
    
    
    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tvFooterBG.png"]];
    [bg setContentMode:UIViewContentModeTopLeft];
    [self.tableView setTableFooterView:bg];
    [self.tableView setSectionFooterHeight:0];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];   
    
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
    showStatusBar.center = CGPointMake(250, 32);
    
    BOOL statusBarPref = YES;
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"showStatusBar"] boolValue]==NO)
        statusBarPref = NO;
    showStatusBar.on = statusBarPref;
    
    disablePaging = [[UISwitch alloc] initWithFrame:CGRectZero];
    [disablePaging addTarget: self action: @selector(togglePaging:) forControlEvents: UIControlEventValueChanged];
    disablePaging.center = CGPointMake(250, 32);
    
    BOOL paging = [[[NSUserDefaults standardUserDefaults] objectForKey:@"pagingEnabled"] boolValue];
    disablePaging.on = paging;
    
    militaryTime = [[UISwitch alloc] initWithFrame:CGRectZero];
    [militaryTime addTarget: self action: @selector(toggle24hr:) forControlEvents: UIControlEventValueChanged];
    militaryTime.center = CGPointMake(250, 32);
    
    BOOL mt = [[[NSUserDefaults standardUserDefaults] objectForKey:@"militaryTime"] boolValue];
    militaryTime.on = mt;
    /*
    iCloudSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    [iCloudSwitch addTarget: self action: @selector(toggleiCloud:) forControlEvents: UIControlEventValueChanged];
    iCloudSwitch.center = CGPointMake(250, 32);
    iCloudSwitch.on = [[DBSession sharedSession] isLinked];
    */
    if(kIsIpad)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData) name:@"refreshBG" object:nil];
    }
    
    //Dropbox sync button
    dbSyncButton= [UIButton buttonWithType:UIButtonTypeCustom];
    // Since the buttons can be any width we use a thin image with a stretchable center point
    UIImage *buttonImage = [[UIImage imageNamed:@"ButtonBlue30px.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:5];
    UIImage *buttonPressedImage = [[UIImage imageNamed:@"ButtonBlue30pxSelected.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:5];
    
    [[dbSyncButton titleLabel] setFont:[UIFont boldSystemFontOfSize:12.0]];
    [dbSyncButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [dbSyncButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [dbSyncButton setTitleShadowColor:[UIColor colorWithWhite:0.0 alpha:0.7] forState:UIControlStateNormal];
    [dbSyncButton setTitleShadowColor:[UIColor colorWithWhite:0.0 alpha:0.7] forState:UIControlStateHighlighted];
    [[dbSyncButton titleLabel] setShadowOffset:CGSizeMake(0.0, -1.0)];
    
    CGRect buttonFrame = [dbSyncButton frame];
    buttonFrame.size.width = [@"Sync" sizeWithFont:[UIFont boldSystemFontOfSize:14.0]].width + 20.0;
    buttonFrame.size.height = buttonImage.size.height;
    [dbSyncButton setFrame:buttonFrame];
    
    [dbSyncButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [dbSyncButton setBackgroundImage:buttonPressedImage forState:UIControlStateHighlighted];
    
    [dbSyncButton setTitle:@"Sync" forState:UIControlStateNormal];
    
    [dbSyncButton addTarget:self action:@selector(synchronizeWithDB) forControlEvents:UIControlEventTouchUpInside];
    [dbSyncButton setCenter:CGPointMake(250 - (buttonFrame.size.width + 20), 32)];
    
    
    
    saveBGButton= [UIButton buttonWithType:UIButtonTypeCustom];
    // Since the buttons can be any width we use a thin image with a stretchable center point
    buttonImage = [[UIImage imageNamed:@"ButtonBlue30px.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:5];
    buttonPressedImage = [[UIImage imageNamed:@"ButtonBlue30pxSelected.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:5];
    
    [[saveBGButton titleLabel] setFont:[UIFont boldSystemFontOfSize:12.0]];
    [saveBGButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [saveBGButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [saveBGButton setTitleShadowColor:[UIColor colorWithWhite:0.0 alpha:0.7] forState:UIControlStateNormal];
    [saveBGButton setTitleShadowColor:[UIColor colorWithWhite:0.0 alpha:0.7] forState:UIControlStateHighlighted];
    [[saveBGButton titleLabel] setShadowOffset:CGSizeMake(0.0, -1.0)];
    
    buttonFrame = [saveBGButton frame];
    buttonFrame.size.width = [@"Save to Photos" sizeWithFont:[UIFont boldSystemFontOfSize:14.0]].width + 20.0;
    buttonFrame.size.height = buttonImage.size.height;
    [saveBGButton setFrame:buttonFrame];
    
    [saveBGButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [saveBGButton setBackgroundImage:buttonPressedImage forState:UIControlStateHighlighted];
    
    [saveBGButton setTitle:@"Save to Photos" forState:UIControlStateNormal];
    
    [saveBGButton addTarget:self action:@selector(saveBackgroundImageToLibrary) forControlEvents:UIControlEventTouchUpInside];
    [saveBGButton setCenter:CGPointMake(250, 32)];
    
    
    
    clearBGButton= [UIButton buttonWithType:UIButtonTypeCustom];
    // Since the buttons can be any width we use a thin image with a stretchable center point
    buttonImage = [[UIImage imageNamed:@"ButtonBlue30px.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:5];
    buttonPressedImage = [[UIImage imageNamed:@"ButtonBlue30pxSelected.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:5];
    
    [[clearBGButton titleLabel] setFont:[UIFont boldSystemFontOfSize:12.0]];
    [clearBGButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [clearBGButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [clearBGButton setTitleShadowColor:[UIColor colorWithWhite:0.0 alpha:0.7] forState:UIControlStateNormal];
    [clearBGButton setTitleShadowColor:[UIColor colorWithWhite:0.0 alpha:0.7] forState:UIControlStateHighlighted];
    [[clearBGButton titleLabel] setShadowOffset:CGSizeMake(0.0, -1.0)];
    
    buttonFrame = [clearBGButton frame];
    buttonFrame.size.width = [@"Clear" sizeWithFont:[UIFont boldSystemFontOfSize:14.0]].width + 20.0;
    buttonFrame.size.height = buttonImage.size.height;
    [clearBGButton setFrame:buttonFrame];
    
    [clearBGButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [clearBGButton setBackgroundImage:buttonPressedImage forState:UIControlStateHighlighted];
    
    [clearBGButton setTitle:@"Clear" forState:UIControlStateNormal];
    
    [clearBGButton addTarget:self action:@selector(selectBlackBG) forControlEvents:UIControlEventTouchUpInside];
    [clearBGButton setCenter:CGPointMake(282, 32)];
    
    
    parallaxSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    [parallaxSwitch addTarget: self action: @selector(toggleParallax:) forControlEvents: UIControlEventValueChanged];
    parallaxSwitch.center = CGPointMake(250, 32);
    BOOL parlax = [[[NSUserDefaults standardUserDefaults] objectForKey:@"parallaxEnabled"] boolValue];
    parallaxSwitch.on = parlax;
    
    
    backgroundSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    [backgroundSwitch addTarget: self action: @selector(toggleBackground:) forControlEvents: UIControlEventValueChanged];
    backgroundSwitch.center = CGPointMake(250, 32);
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
    /*
    NSString *keyValue = @"NO";
    if(iCloudSwitch.on){
        keyValue = @"YES";
    }
    if([keyValue boolValue]){
        if(NSClassFromString(@"NSUbiquitousKeyValueStore")) { // is iOS 5?
            
            if([NSUbiquitousKeyValueStore defaultStore]) {  // is iCloud enabled
                
                NSURL *ubiq = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
                if (ubiq) {
                    
                } else {
                    CustomAlertView *iCloudNotEnabled = [[CustomAlertView alloc] initWithTitle:@"Enable iCloud" 
                                                                               message:@"You must enable iCloud support to use this. You can do this in your device settings." 
                                                                              delegate:nil cancelButtonTitle:@"OK, Thanks" otherButtonTitles:nil];
                    [iCloudNotEnabled show];
                    [iCloudSwitch setOn:NO animated:YES];
                    keyValue = @"NO";
                }
                
            } else {
                CustomAlertView *iCloudNotEnabled = [[CustomAlertView alloc] initWithTitle:@"Enable iCloud" 
                                                                           message:@"You must enable iCloud support to use this. You can do this in your device settings." 
                                                                          delegate:nil cancelButtonTitle:@"OK, Thanks" otherButtonTitles:nil];
                [iCloudNotEnabled show];
                [iCloudSwitch setOn:NO animated:YES];
                keyValue = @"NO";
            }
        }
        else {
            
            CustomAlertView *iCloudNotEnabled = [[CustomAlertView alloc] initWithTitle:@"iOS 5 Required" 
                                                                       message:@"You must be running iOS 5 or greater to use iCloud.  Please update your device." 
                                                                      delegate:nil cancelButtonTitle:@"OK, Thanks" otherButtonTitles:nil];
            [iCloudNotEnabled show];
            [iCloudSwitch setOn:NO animated:YES];
            keyValue = @"NO";
        }
        
    }
    [[NSUserDefaults standardUserDefaults] setBool:[keyValue boolValue] forKey:@"iCloudEnabled"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    //if([keyValue boolValue])
        [self setThemeUbiquity:[[NSUserDefaults standardUserDefaults] boolForKey:@"iCloudEnabled"]];
     */
    
    /*  TEMPORARILY DISABLE DB SYNC
    if(!iCloudSwitch.on){
        if ([[DBSession sharedSession] isLinked]){
            NSArray *unlinkIDs= [[DBSession sharedSession]userIds];
            NSLog(@"unlinkID's: %@",unlinkIDs);
            [[DBSession sharedSession] unlinkAll];
        }      
        
    }
    else{
        if (![[DBSession sharedSession] isLinked]) {
            [[DBSession sharedSession] link];
            //[dbSyncButton setHidden:NO];
        }
        else
        {
            NSArray *unlinkIDs= [[DBSession sharedSession]userIds];
            NSLog(@"unlinkID's: %@",unlinkIDs);
            [[DBSession sharedSession] unlinkAll];
            //[dbSyncButton setHidden:YES];
        }
    }
     */
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

#define kTotalCells  6
#define kBackgroundCell 0
#define kClearBackgroundCell 1
#define kWeatherSettingsCell  2
#define kGlobalTextCell  3
#define kMilitaryTimeCell  4
#define kiCloudCell  7
#define kParallaxCell  5
#define kLockscreenCell  6

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
            [cell addSubview:saveBGButton];
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
            [cell addSubview:clearBGButton];
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
        UIImageView *accessory = [[ UIImageView alloc ] 
                                  initWithImage:[UIImage imageNamed:@"tvCellAccessory.png" ]];
        cell.accessoryView = accessory;
        
        return cell;
    }
    if(indexPath.row==kGlobalTextCell){
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[PrettyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        [[cell textLabel] setText:@"Modify All Text"];
        UIImageView *accessory = [[ UIImageView alloc ] 
                                  initWithImage:[UIImage imageNamed:@"tvCellAccessory.png" ]];
        cell.accessoryView = accessory;
        
        return cell;
    }
    if(indexPath.row==kMilitaryTimeCell ){
        static NSString *CellIdentifier = @"switchCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[PrettyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            [cell addSubview:militaryTime];
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
            [cell addSubview:parallaxSwitch];
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
        UIImageView *accessory = [[ UIImageView alloc ] 
                                  initWithImage:[UIImage imageNamed:@"tvCellAccessory.png" ]];
        cell.accessoryView = accessory;
        
        return cell;
    }
    return cell;
}

-(void)synchronizeWithDB{
    //[AppDelegate beginSynchronizing:nil];
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
