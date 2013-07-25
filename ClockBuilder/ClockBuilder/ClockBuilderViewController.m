//
//  ClockBuilderViewController.m
//  ClockBuilder
//
//  Created by Gustavo Tandeciarz on 3/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ClockBuilderViewController.h"
#import "textSettingsTableViewIndex.h"
#import "ImagePickerView.h"
#import "RRSGlowLabel.h"
#import "UIView+glowLabelSelections.h"
#import "textBasedWidget.h"
#import "weatherIconView.h"
#import "ClockBuilderAppDelegate.h"
#import "appManagementTableView.h"
#import "savedThemesTVC.h"
#import "manageGeneralSettings.h"
#import "manageWidgetsTableView.h"
#import "ManageWidgetsNavigationController.h"
#import "themeBrowserController.h"
#import "instructionsForTheme.h"
//#import "Reachability/Reachability.h"
#import "settingsUIActionsheetDelegate.h"
#import "CBTheme.h"
#import "CBThemeHelper.h"
#import "themeBrowserNavigationController.h"
#import "SCNavigationBar.h"
#import "RegexKitLite.h"


@implementation ClockBuilderViewController

@synthesize addItem;
@synthesize done;
@synthesize widgetsAdded;
@synthesize toolbar;
@synthesize showToolbar;
@synthesize scaleSlider;
@synthesize flexibleSpace1,openTools, sliderContainer;
@synthesize widgetSelected;
@synthesize bgImage;
@synthesize tapBackground;
@synthesize editField;
@synthesize tabsController;
@synthesize tabItems;
@synthesize actionButtonSheet;
@synthesize deleteThemeDelegate;
@synthesize repeatingTimer;
@synthesize widgetHelper;
@synthesize th;
@synthesize query;
@synthesize timer;
@synthesize pop;


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    if(kIsIpad){
        [self setModalInPopover:YES];
    }
    
    [ApplicationDelegate performSelectorInBackground:@selector(setupThemeFiles) withObject:nil];

    if(/*![[NSUserDefaults standardUserDefaults] boolForKey:@"DidShowiCloudAlert"] && */![[NSUserDefaults standardUserDefaults] boolForKey:@"iCloudEnabled"]){
        if(NSClassFromString(@"NSUbiquitousKeyValueStore")) { // is iOS 5?
            
            if([NSUbiquitousKeyValueStore defaultStore]) {  // is iCloud enabled
                
                NSURL *ubiq = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
                if (ubiq) {
                    //[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"DidShowiCloudAlert"];
                    
                    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"iCloudEnabled"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    //[CBThemeHelper setThemeUbiquity:[[NSUserDefaults standardUserDefaults] boolForKey:@"iCloudEnabled"] overwrite:NO];
                    //[self setupAndStartQuery];
                    
                    
                } else {
                }
                
            } else {
            }
        }
        else {
        }
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showWeatherFinder) name:@"cantGeoLocate" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillEnterForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    [self.view setFrame:self.view.window.frame];
    
    openTools = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"tools.png"] style:UIBarButtonItemStylePlain target:self action:@selector(toggleTools)];
    
    [tools makeButtons];
    weatherIconForecastPicker = [weatherIconPickerTool new];
    [weatherIconForecastPicker setShowView:self];
    
    th = [themeConverter new];
    widgetHelper = [widgetHelperClass new];    
    deleteThemeDelegate = [clearThemeAlertView new];        
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(setScreenVisible:) withObject:@"YES"];
    
    
    [self initWidgetsArray]; 
    UIScreen *mainS = [UIScreen mainScreen];
    screenWidth = mainS.applicationFrame.size.width;
    screenHeight = mainS.applicationFrame.size.height;
    
    screenWidth = [[UIScreen mainScreen] bounds].size.width;
    screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
    
    editField = [[UITextField alloc] initWithFrame:CGRectMake(16, 83, 252, 25)];
    editField.keyboardType = UIKeyboardTypeNamePhonePad;
    
    CGRect bgFrame = CGRectMake(0, 0, screenWidth, screenHeight);
    bgImage = [[UIImageView alloc] initWithFrame:bgFrame]; 
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *appFile = [documentsDirectory stringByAppendingPathComponent:@"LockBackground.png"]; 
    [bgImage setContentMode:UIViewContentModeScaleToFill];
    if(kIsIpad)[bgImage setContentMode:UIViewContentModeTopLeft];
    [bgImage setBackgroundColor:[UIColor blackColor]];    
    [bgImage setImage:[UIImage imageWithContentsOfFile:appFile]];
    
    bgWebView = [[UIWebView alloc] initWithFrame:bgFrame];
    NSString *slideshow = [NSString stringWithContentsOfFile:[documentsDirectory stringByAppendingFormat:@"/tethered/slideshow.html"] encoding:NSUTF8StringEncoding error:nil];    
    
    NSString *imagePath = [documentsDirectory stringByAppendingString:@"/tethered"];
    imagePath = [imagePath stringByReplacingOccurrencesOfString:@"/" withString:@"//"];
    imagePath = [imagePath stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    
    [bgWebView loadHTMLString:slideshow baseURL:[NSURL URLWithString: [NSString stringWithFormat:@"file:/%@//",imagePath]]];
    [bgWebView setBackgroundColor:[UIColor clearColor]];
    [bgWebView setOpaque:NO];
    [bgWebView setDelegate:self];
    bgWebView.alpha = 0;
    [bgWebView setUserInteractionEnabled:NO];
    
    [self.view insertSubview:bgImage atIndex:0];
    
    [self drawBackground];
    
    tapBackground = [UIButton buttonWithType:UIButtonTypeCustom];
    [tapBackground setFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    [tapBackground setBackgroundColor:[UIColor clearColor]];
    [tapBackground addTarget:self action:@selector(tapBG) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview:tapBackground aboveSubview:bgImage];
    [self.view insertSubview:bgWebView belowSubview:tapBackground]; 
    [bgImage setTag:-1];
    
    showToolbar = [UIButton buttonWithType:UIButtonTypeCustom];
    [showToolbar setFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    [showToolbar setBackgroundColor:[UIColor clearColor]];
    [showToolbar addTarget:self action:@selector(showToolbarClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:showToolbar];
    if([self.widgetsAdded count]==0)
    {
        self.toolbar.hidden = NO;    
        showToolbar.hidden = YES;
    }
    else{
        self.toolbar.hidden = YES;
        showToolbar.hidden = NO;
    }
    [CBThemeHelper setBackgroundImage:nil forToolbar:self.toolbar];
    if(!kIsiOS7){
        self.done = [CBThemeHelper createDoneButtonItemWithTitle:@"Close" target:self action:@selector(doneButtonClick:)];
        self.addItem = [CBThemeHelper createDoneButtonItemWithTitle:@"Edit" target:self action:@selector(addButtonClick:)];
    }
    else{
        self.done = [CBThemeHelper createDoneButtonItemWithTitle:@"Close" target:self action:@selector(doneButtonClick:)];
        self.addItem = [CBThemeHelper createDoneButtonItemWithTitle:@"Edit" target:self action:@selector(addButtonClick:)];
    }
    
    [self performSelector:@selector(resetToolbar)];
    [self addWidgetsToView];
    
    [self buildActionSheet];
    
    [self set_Editing:NO];
    
    
    widgetNameView.layer.borderWidth = 1;
    widgetNameView.layer.borderColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:.4].CGColor;
    widgetNameView.layer.backgroundColor = [UIColor colorWithRed:.5 green:.5 blue:.5 alpha:.2].CGColor;
    widgetNameView.layer.cornerRadius = 10;
    widgetNameView.layer.masksToBounds = YES;
    
    //NSLog(@"viewcontroller - VIEW DID LOAD");
    
    
    //ipad/i5 tools alignment
    if(kIsIpad){
        //NSLog(@"widgetNameView origin y: %f",screenHeight);
        [widgetNameView setFrame:CGRectMake(widgetNameView.frame.origin.x, screenHeight - 75, widgetNameView.frame.size.width, widgetNameView.frame.size.height)];
        [ScaleIconImageView setFrame:CGRectMake(170,screenHeight-ScaleIconImageView.frame.size.height+3, ScaleIconImageView.frame.size.width, ScaleIconImageView.frame.size.height)];
        [OpacityIconImageView setFrame:CGRectMake(screenWidth-222,screenHeight-OpacityIconImageView.frame.size.height+3, OpacityIconImageView.frame.size.width, OpacityIconImageView.frame.size.height)];
        
    }
    else{
        [widgetNameView setFrame:CGRectMake(widgetNameView.frame.origin.x, screenHeight - 75, widgetNameView.frame.size.width, widgetNameView.frame.size.height)];
        [ScaleIconImageView setFrame:CGRectMake(ScaleIconImageView.frame.origin.x,
                                                screenHeight-ScaleIconImageView.frame.size.height+3,
                                                ScaleIconImageView.frame.size.width,
                                                ScaleIconImageView.frame.size.height)];
        [OpacityIconImageView setFrame:CGRectMake(OpacityIconImageView.frame.origin.x,
                                                  screenHeight-OpacityIconImageView.frame.size.height+3,
                                                  OpacityIconImageView.frame.size.width,
                                                  OpacityIconImageView.frame.size.height)];
        
    }
    //check for updated GMTSync
    if([th checkIfJB] && ![th isRunningInSimulator]){
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
        dispatch_async(queue, ^{
            GMTThemeSync *themeSync = [GMTThemeSync new];
            NSString *installedGMTSync = [themeSync getGMTSyncVersion];
            NSError *err;
            NSString *latestGMTSync = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://clockbuilder.gmtaz.com/gmtSyncVersion.php"] encoding:NSUTF8StringEncoding error:&err];
            //NSLog(@"installedGMTSync: %@",installedGMTSync);
            //NSLog(@"latestGMTSync: %@",latestGMTSync);
            if(latestGMTSync && ![installedGMTSync isEqualToString:latestGMTSync]){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[GMTHelper sharedInstance] alertWithString:@"GMTSync is out of date.  Please update it using Cydia."];
                });
            }
        });
    }
    
    if(!_coordinatesView){
        NSString *coor = @"X = -0000 px";
        CGSize coorWidth = [coor sizeWithFont:[UIFont systemFontOfSize:12]];
        
        int viewHeight = round((coorWidth.height * 2) + 5);
        
        CGRect coordRect = CGRectMake(kScreenWidth - coorWidth.width - 5,
                                     kScreenHeight - 44 - viewHeight - 5,
                                     coorWidth.width + 5, viewHeight + 5);
        NSLog(@"coordRect: %@", NSStringFromCGRect(coordRect));
        
        _coordinatesView = [[UIView alloc] initWithFrame:coordRect];
        [_coordinatesView setHidden:YES];
        [_coordinatesView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:.6]];
        [self.view addSubview:_coordinatesView];
        _coordinatesViewLabelX = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, coorWidth.width, coorWidth.height)];
        [_coordinatesViewLabelX setFont:[UIFont systemFontOfSize:12]];
        [_coordinatesViewLabelX setTextColor:[UIColor whiteColor]];
        [_coordinatesViewLabelX setBackgroundColor:[UIColor clearColor]];
        [_coordinatesView addSubview:_coordinatesViewLabelX];
        _coordinatesViewLabelY = [[UILabel alloc] initWithFrame:CGRectMake(5, coorWidth.height + 5, coorWidth.width, coorWidth.height)];
        [_coordinatesViewLabelY setFont:[UIFont systemFontOfSize:12]];
        [_coordinatesViewLabelY setTextColor:[UIColor whiteColor]];
        [_coordinatesViewLabelY setBackgroundColor:[UIColor clearColor]];
        [_coordinatesView addSubview:_coordinatesViewLabelY];
        
        NSLog(@"coordinates view frame: %@", NSStringFromCGRect(_coordinatesView.frame));
        [_coordinatesView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tappedCoordinatesView:)]];
    }
    
}
-(void)tappedCoordinatesView:(id)sender{
    [self becomeFirstResponder];
    UIMenuController *coordMenuController = [UIMenuController sharedMenuController];
    UIMenuItem *editWidgetX = [[UIMenuItem alloc]initWithTitle:@"Edit X" action:@selector(editWidgetCoordinateX)];
    UIMenuItem *editWidgetY = [[UIMenuItem alloc]initWithTitle:@"Edit Y" action:@selector(editWidgetCoordinateY)];
    [coordMenuController setMenuItems:[NSArray arrayWithObjects:editWidgetX, editWidgetY, nil]];
    [coordMenuController setTargetRect:_coordinatesView.frame inView:self.view];
    [coordMenuController setMenuVisible:YES animated:YES];
    [[UIMenuController sharedMenuController] setMenuItems:nil];
}
-(void)editWidgetCoordinateX{
    NSString *current =[NSString stringWithFormat:@"%i",(int)self.widgetSelected.frame.origin.x];
    [MKEntryPanel showPanelWithTitle:@"Edit Widget X Position" inView:self.view withText:current numericOnly:YES onTextEntered:^(NSString *inputString) {
        CGRect frame = self.widgetSelected.frame;
        frame.origin.x = [inputString intValue];
        [self.widgetSelected setFrame:frame];
        [self showWidgetCoordinates:self.widgetSelected];
    } onCancel:^{
        [self showWidgetCoordinates:self.widgetSelected];
    }];
}
-(void)editWidgetCoordinateY{
    NSString *current =[NSString stringWithFormat:@"%i",(int)self.widgetSelected.frame.origin.y];
    [MKEntryPanel showPanelWithTitle:@"Edit Widget Y Position" inView:self.view withText:current numericOnly:YES onTextEntered:^(NSString *inputString) {
        CGRect frame = self.widgetSelected.frame;
        frame.origin.y = [inputString intValue];
        [self.widgetSelected setFrame:frame];
        [self showWidgetCoordinates:self.widgetSelected];
    } onCancel:^{
        [self showWidgetCoordinates:self.widgetSelected];
    }];
}


-(void)viewDidDisappear:(BOOL)animated
{
    //bgWebView.alpha = 0;
}
-(void)viewWillDisappear:(BOOL)animated{
    //NSLog(@"VIEWCONTROLLER - view will disappear");
    if([self.timer isValid])
        [self.timer invalidate];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshBG" object:nil];
}
-(void)viewWillAppear:(BOOL)animated
{
    if(kIsiOS7){
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        [self setNeedsStatusBarAppearanceUpdate];
    }
    CGRect coordRect = _coordinatesView.frame;
    coordRect.origin.y = self.view.frame.size.height - 44 - _coordinatesView.bounds.size.height;
    [_coordinatesView setFrame:coordRect];
    
    //NSLog(@"VIEWCONTROLLER - view will APPEAR");
    if([self.timer isValid])
        [self.timer invalidate];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(runTimer) userInfo:nil repeats:YES];
}
-(void)viewDidAppear:(BOOL)animated{
    
    //iCloud Alert
    NSLog(@"view did appear (root view controller");
    [self resetToolbar];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(drawBackground) name:@"refreshBG" object:nil];
    
}

- (void)dealloc
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSMetadataQueryDidFinishGatheringNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSMetadataQueryDidUpdateNotification 
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:@"enableQueryUpdates" 
                                                  object:nil];
    [self.query disableUpdates];
    [self.query stopQuery];
    self.query = nil;
    
    
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    //[super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    //[sounds release];
    //self.widgetsAdded;
}




- (void) initWidgetsArray
{    
    self.widgetsAdded = [widgetHelper getWidgetsList];
}

-(void) runTimer 
{	
    if(!self.presentedViewController)
        [[[UIApplication sharedApplication]delegate]performSelector:@selector(runTimer)];
}
-(void)buildActionSheet
{
    if([th checkIfJB])
    {
    
        self.actionButtonSheet = [[UIActionSheet alloc] initWithTitle:@"Theme Actions"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:@"Clear Theme"
                                                    otherButtonTitles:@"Save Theme",
                                  @"New Save",
                                  @"Share",
                                  @"Set as Lockscreen",
                                  //@"Respring Device",
                                  nil];
    }
    else
    {
        self.actionButtonSheet = [[UIActionSheet alloc] initWithTitle:@"Theme Actions"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:@"Clear Theme"
                                                    otherButtonTitles:@"Save Theme",@"New Save",@"Share", nil];
    }
    self.actionButtonSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        
    [self.actionButtonSheet setBounds:CGRectMake(0,0,320, 408)];
}

-(void)showActionSheet
{
    [self set_Editing:NO];
    self.toolbar.hidden =YES;
    [self performSelector:@selector(saveThemeScreenshot) withObject:nil];  
    //[self.actionButtonSheet showFromToolbar:self.toolbar];
}

- (void) saveThemeScreenshot
{
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        
        CGRect contextRect  = CGRectMake(0, 20, 320, 460);
        
        if(kIsIpad){
            contextRect = CGRectMake(0, 20, 768, 1004);
        }
        
        UIGraphicsBeginImageContext(contextRect.size);	
        
        [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
        
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        
        if(newImage == nil) 
            NSLog(@"could not scale image");
        else {
            
            //pop the context to get back to the default
            UIGraphicsEndImageContext();
            //UIImage *bg = [newImage resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:croppedSize interpolationQuality:1.0];
            NSData *newImageData =  UIImageJPEGRepresentation(newImage, 60);
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);         
            NSString *documentsDirectory = [paths objectAtIndex:0]; 
            NSString *appFilePNG = [documentsDirectory stringByAppendingPathComponent:@"themeScreenshot.jpg"];
            if(![newImageData writeToFile:appFilePNG atomically:YES]){
                NSLog(@"error creating screenshot");
            }

        }
        dispatch_sync(dispatch_get_main_queue(), ^(void) {
            self.toolbar.hidden =NO;
            [self.actionButtonSheet showInView:self.view];//[self.view superview]];
        });        
    });
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// the user clicked one of the OK/Cancel buttons
    //[self.actionButtonSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
    NSString *title = [self.actionButtonSheet buttonTitleAtIndex:buttonIndex];
    
    if([title isEqualToString:@"Save Theme"])
    {        
        NSString *objectID = [[NSUserDefaults standardUserDefaults] objectForKey:kActiveThemeCoreDataIDKey];
        NSLog(@"active theme core data id: %@", objectID);
        [[GMTHelper sharedInstance] notifyToShowGlobalHudWithSpinner:@"Saving Theme" andHide:YES withDelay:10 andDim:YES];
        [CBThemeHelper saveThemeToCoreDatawithDict:nil andObjectID:objectID];
        
    }
    if([title isEqualToString:@"New Save"])
    {
        [[GMTHelper sharedInstance] notifyToShowGlobalHudWithSpinner:@"Saving Theme" andHide:YES withDelay:10 andDim:YES];
        [CBThemeHelper saveThemeToCoreDatawithDict:nil andObjectID:nil];        
    }
    if([title isEqualToString:@"Clear Theme"])
    {
        CustomAlertView *v = [[CustomAlertView alloc] initWithTitle:@"Confirm" message:@"Are you sure you want to reset your current theme?  This cannot be undone.  This will not affect your saved themes." delegate:deleteThemeDelegate cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        [v show];
        [self.toolbar setHidden:NO];
    }
    if([title isEqualToString:@"Set as Lockscreen"])
    {
        //set as lockscreen
        if(th == nil) th = [[themeConverter alloc]init];
        
        if([th checkIfThemeInstalled])
        {
            [th setThemeName:nil];
            [th run:@"NO"];
            
        }
        else
        {
            //alert to download theme.
            CustomAlertView *alert = [[CustomAlertView alloc]initWithTitle:@"Theme not detected" 
                                                           message:@"The Winterboard theme \"TypoClock Builder\" was not detected on your device.  Please download through Cydia and try again." 
                                                          delegate:self 
                                                 cancelButtonTitle:@"OK" 
                                                 otherButtonTitles:@"How?", nil];
            [alert show];
        }
        
    }
    if([title isEqualToString:@"Respring Device"])
    {
        //set as lockscreen
        GMTThemeSync *helper = [GMTThemeSync new];
        [helper respring];
    }
    if([title isEqualToString:@"Share"])
    { 
           NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
           NSString *documentsDirectory = [paths objectAtIndex:0]; 
           NSString *appFileJPG = [documentsDirectory stringByAppendingPathComponent:@"themeScreenshot.jpg"];
           
           UIImage *thmb = [UIImage imageWithContentsOfFile:appFileJPG];
            if (thmb) {
                
                NSArray *activityItems = @[thmb];
                
                UIActivityViewController *activityController =
                [[UIActivityViewController alloc]
                 initWithActivityItems:activityItems applicationActivities:nil];
                
                [self presentViewController:activityController
                                   animated:YES completion:nil];
            }
  
    }
}

-(void)showInstructions
{
    instructionsForTheme *instructions = [[instructionsForTheme alloc] initWithNibName:@"instructionsForTheme" bundle:[NSBundle mainBundle]];
    
    [self presentViewController:instructions animated:YES completion:nil];
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(setScreenVisible:) withObject:@"NO"];
    
};


-(void)set_Editing:(BOOL)yesNo
{
    _editing = YES;//yesNo;
    if(_editing){
        [CBThemeHelper setTitle:@"List" forCustomBarButton:self.addItem];
        [CBThemeHelper setTitle:@"Done" forCustomBarButton:self.done];
    }
    else{
        _editingWidget = NO;
        [CBThemeHelper setTitle:@"Edit" forCustomBarButton:self.addItem];
        [CBThemeHelper setTitle:@"Close" forCustomBarButton:self.done];
    }
}


- (void)resetToolbar
{
    [_coordinatesView setHidden:YES];
    [opacityPopup dismiss];
    [scalePopup dismiss];
    if(!kIsiOS7){
        //[self.toolbar setBackgroundColor:[UIColor clearColor]];
        //[self.toolbar setBackgroundImage:nil forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
        [self.toolbar setFrame:CGRectMake(0, self.view.frame.size.height-44, kScreenWidth, 44)];
    }
    
    UIBarButtonItem *browseButton;
    UIBarButtonItem *settingsButton;
    
    UIBarButtonItem *saveActionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActionSheet)];//showAlertWithEditField
    if(kIsiOS7){
        browseButton = [CBThemeHelper createFontAwesomeDarkBarButtonItemWithIcon:@"icon-tablet" target:self action:@selector(browseButtonClick:)];
        
        settingsButton = [CBThemeHelper createFontAwesomeDarkBarButtonItemWithIcon:@"icon-cogs" target:self action:@selector(settingsButtonClick:)];
    }else{
        settingsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"gears.png"] style:UIBarButtonItemStylePlain target:self action:@selector(settingsButtonClick:)];
        browseButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"themeBrowser.png"] style:UIBarButtonItemStylePlain target:self action:@selector(browseButtonClick:)];
    }
    UIBarButtonItem *flex1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *flex2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    _editing = YES;
    
    if([self.widgetsAdded count]==0)
        [saveActionButton setEnabled:NO];
    else
        [saveActionButton setEnabled:YES];
    
    NSArray *toolbarbuttons = [NSArray arrayWithObjects:self.addItem, flexibleSpace1,browseButton,flex1, saveActionButton,flex2, settingsButton, flexibleSpace1, self.done, nil]; 
    
    [CBThemeHelper setTitle:@"List" forCustomBarButton:self.addItem];
    [CBThemeHelper setTitle:@"Done" forCustomBarButton:self.done];
    
    if(toolbar!=nil){
        [toolbar setItems:toolbarbuttons];    
        [ScaleIconImageView setHidden:YES];
        [OpacityIconImageView setHidden:YES];
        [widgetNameView setHidden:YES];
    }
    if(kIsiOS7){
        //[self toggleToolbar:@"hide"];
        //[self toggleToolbar:@"show"];
        
    }
}


-(void)trySavingTheme:(NSString *)themeName
{
    
    if([self performSelector:@selector(folderExists:) withObject:themeName])
    {
        [self performSelector:@selector(showAlertToSaveTheme)];
    }
    else
    {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        dispatch_async(queue, ^{
            [self saveTheme:themeName];
        });

    }
}

- (BOOL)folderExists:(NSString *)themeName
{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *themesPath = [documentsDirectory stringByAppendingPathComponent:@"myThemes/"];
    
    NSString *dir = [themesPath stringByAppendingFormat:@"%@",themeName];
    BOOL isDirectory;
    
    if([fileManager fileExistsAtPath:dir isDirectory:&isDirectory])
    {
        return YES;
    }    
    return NO;
}
-(void) showAlertToSaveTheme{
    
    
    NSString * alertTitle = @"Same Name Found";
    NSString * message = @"Another theme with this name already exists.";
    CustomAlertView *alert = [[CustomAlertView alloc]initWithTitle:alertTitle
                                                   message:[NSString stringWithFormat:@"%@\n" , message]
                                                  delegate:self
                                         cancelButtonTitle:@"Cancel"
                                         otherButtonTitles:@"Rename", @"Overwrite",nil] ;
    
    [alert show];
    
    
}

- (void) showAlertWithEditField
{    
    [self set_Editing:NO];      
    [MKEntryPanel showPanelWithTitle:@"Save Theme As" inView:self.view onTextEntered:^(NSString *fieldVal) {
        
        [self performSelector:@selector(trySavingTheme:)withObject:fieldVal];

    } onCancel:^{
        
    }];
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [editField resignFirstResponder];
	NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    [self.toolbar setHidden:NO];
    if (buttonIndex == 0)
    { 
        _cantFindYouAlertShowing = NO;
    }
    else
    {
        if([title isEqualToString:@"How?"])
        {
            [self showInstructions];
        }
        else
        {
            NSString *fieldVal = [editField.text copy];
            if(fieldVal != nil && ![fieldVal isEqualToString:@""]) {
                if([title isEqualToString:@"Overwrite"])
                {
                    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
                    dispatch_async(queue, ^{
                        [self saveTheme:fieldVal];
                    });
                    //[self performSelectorInBackground:@selector(saveTheme:) withObject:fieldVal];
                }
                else if([title isEqualToString:@"Rename"])
                {
                    [MKEntryPanel showPanelWithTitle:@"Please enter a new name" inView:self.view onTextEntered:^(NSString *fieldVal) {
                        
                        [self performSelector:@selector(trySavingTheme:)withObject:fieldVal];
                        
                    } onCancel:^{
                        
                    }];
                }
                else if([title isEqualToString:@"OK"])
                {
                    [self performSelector:@selector(trySavingTheme:)withObject:fieldVal];
                }

            }
            else
            {
                [editField resignFirstResponder];
                [editField removeFromSuperview];
                [self performSelectorInBackground:@selector(saveThemeScreenshot) withObject:nil];    
                NSString * alertTitle = @"Error";
                NSString * message = @"The name cannot be blank";
                CustomAlertView *alert = [[CustomAlertView alloc]initWithTitle:alertTitle
                                                               message:[NSString stringWithFormat:@"%@\n\n\n\n" , message]
                                                              delegate:self
                                                     cancelButtonTitle:@"Cancel"
                                                     otherButtonTitles:@"OK",nil] ;
                editField.backgroundColor = [UIColor whiteColor];
                editField.borderStyle = UITextBorderStyleRoundedRect;
                //[self.alert addTextFieldWithValue:@"" label:@"City Name or Zip"];
                [editField becomeFirstResponder];
                [alert addSubview:editField];
                if ([[[UIDevice currentDevice] systemVersion] floatValue] < 4.0) {
                    CGAffineTransform moveUp = CGAffineTransformMakeTranslation(0, 90);
                    [alert setTransform:moveUp];
                }
                [alert show];
            }
        }
    }
}
- (void)saveTheme:(NSString *)themeName
{
    //[CBThemeHelper saveThemeNamed:themeName];
}


-(NSInteger)getFontSizeForPiece:(textBasedWidget *)piece
{
    int fontSize = abs((int)piece.textLabel.font.pointSize) ;
    return fontSize;
}
- (void)initWidget:(UIView *)v index:(NSInteger)i{
    if([self.widgetsAdded count] > 0){
        
        NSDictionary *wd = [[widgetHelper getWidgetsList] objectAtIndex:i];
        if([[wd objectForKey:@"didRotate"] boolValue]){
            NSString *rotationAmount = [[[widgetHelper getWidgetsList] objectAtIndex:i] objectForKey:@"rotateAmount"];
            NSLog(@"rotate amount: %@",rotationAmount);
            
            float rotation = [rotationAmount floatValue];
            if (rotation !=0 ) {
                //rotate text label
                v.transform = CGAffineTransformRotate([v transform], rotation);
            }
            
        }
        
        
        NSInteger tag = i+10;
        [self addGestureRecognizersToPiece:v];
        [v setTag: tag ];
                
        
        if(originalWidgetIndex==0)        
            [self.view insertSubview:v belowSubview:toolbar];    
        else{
            [self.view insertSubview:v atIndex:originalWidgetIndex];
        }
        
        originalWidgetIndex = 0;
        
        if([v class]==[textBasedWidget class])
        {
            //get fontsize for piece
            [self getFontSizeForPiece:(textBasedWidget *)v];
        }
        if(self.widgetSelected!=nil)
            self.widgetSelected = v;
    }
}

- (void) addWidgetToView:(NSString *)cls index:(NSInteger)i
{
    //NSLog(@"adding widget: %d",i);
    if([widgetHelper getWidgetsList] > 0){
        CGRect frame = CGRectFromString([[[widgetHelper getWidgetsList] objectAtIndex:i] objectForKey:@"frame"]);

        if([cls isEqualToString:@"weatherIconView"])
        {
            //check here for climacons
            BOOL renderClimacons = NO;
            if ([[weatherSingleton sharedInstance] isClimacon]) {
                    renderClimacons = YES;
                NSLog(@"isClimacon = YES;");
            }
            else{
                NSLog(@"isClimacon = NO;");
            }
            if(renderClimacons){
                
                textBasedWidget *v = [[textBasedWidget alloc] initWithFrame:frame widgetData:[[widgetHelper getWidgetsList] objectAtIndex:i] indexValue:[NSNumber numberWithInt:i]];
                [self initWidget:v index:i];
                [v setClipsToBounds:NO];
                
            }
            else{
                weatherIconView *v = [[weatherIconView alloc] initWithFrame:frame widgetData:[[widgetHelper getWidgetsList] objectAtIndex:i] indexValue:[NSNumber numberWithInt:i]];
                [self initWidget:v index:i];
            }
        }
        if ([cls isEqualToString:@"textBasedWidget"]) {
            textBasedWidget *v = [[textBasedWidget alloc] initWithFrame:frame widgetData:[[widgetHelper getWidgetsList] objectAtIndex:i] indexValue:[NSNumber numberWithInt:i]];
            [self initWidget:v index:i];
            [v setClipsToBounds:NO];
        }
    }
}

- (void) addWidgetsToView
{
    //redraw widgets      
     for(int i = 0;i<[self.widgetsAdded count]; i++)
     {
         NSString *cls = [[self.widgetsAdded objectAtIndex:i] objectForKey:@"class"];
         [self addWidgetToView:cls index:i];
     }
}

-(void)setOpacityToolbar
{
    NSArray *toolbarbuttons = [NSArray arrayWithObjects:
                               openTools, 
                               flexibleSpace1,
                               scaleButtonItem,
                               flexibleSpace1,
                               //opacitySliderContainer,
                               //flexibleSpace1,
                               opacityButtonItem,
                               flexibleSpace1, 
                               done, nil];
    [toolbar setItems:toolbarbuttons];
}
-(void)setScalingToolbar
{
    NSArray *toolbarbuttons = [NSArray arrayWithObjects:
                               openTools, 
                               flexibleSpace1,
                               scaleButtonItem,
                               flexibleSpace1,
                               //sliderContainer,
                               //flexibleSpace1,
                               opacityButtonItem,
                               flexibleSpace1, 
                               done, nil];
    [toolbar setItems:toolbarbuttons];
}

- (void) selectWidget:(UIView *)widget{
    if(self.widgetSelected !=nil)
    {
        //save widget data here laters
    }
    
    self.widgetSelected = widget;
    if(self.widgetSelected==nil)
    {
        _editingWidget = NO;  
        [widgetNameView setHidden:YES];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"widgetIndex"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        if(_editing){
            [CBThemeHelper setTitle:@"List" forCustomBarButton:self.addItem];
            [CBThemeHelper setTitle:@"Done" forCustomBarButton:self.done];
        }
        if(_toolsOpen)
            [self toggleTools];
        [self resetToolbar];
    }
    else{    
        _editingWidget = YES;
        NSInteger index = [self getIndexFromView:widget];
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",index] forKey:@"widgetIndex"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        NSArray *widgetList = [widgetHelper getWidgetsList];
        NSDictionary *data = [widgetList objectAtIndex:index];        
        data = [self.widgetSelected performSelector:@selector(getWidgetData)];//[[[widgetHelper getWidgetsList] objectAtIndex:index] mutableCopy];
        tools.widgetData = data;
        [weatherIconForecastPicker setWidgetData:data];
        NSString *friendlyName = [data objectForKey:@"className"];
        [widgetNameLabel setText:friendlyName];
        [scaleSlider setValue:1];      
        [opacitySlider setValue:[[data objectForKey:@"opacity"]floatValue]];
        [CBThemeHelper setTitle:@"Done" forCustomBarButton:self.done];
        [widgetNameView setHidden:NO];
        if(!self.toolbar.hidden){
            [self setScalingToolbar];
            //dismiss open popup
            [opacityPopup dismiss];
            opacitySliderVisible = NO;
            [scalePopup dismiss];
            scaleSliderVisible = NO;
        }
        //toggle coordinates view
        [_coordinatesView setHidden:NO];
        [self showWidgetCoordinates:widget];
    }
}

-(void)showWidgetCoordinates:(UIView *)widget{
    [_coordinatesView setHidden:NO];
    float x = widget.frame.origin.x;
    float y = widget.frame.origin.y;
    [_coordinatesViewLabelX setText:[NSString stringWithFormat:@"X = %i px",(int)x]];
    [_coordinatesViewLabelY setText:[NSString stringWithFormat:@"Y = %i px",(int)y]];
}

-(void)setWeatherIconCurrent
{
    NSMutableDictionary *widgetData = [[widgetHelper getWidgetDataFromIndex:self.widgetSelected.tag-10 ]
                                       mutableCopy];
    [widgetData setObject:@"current" forKey:@"forecast"];        
    [self performSelector:@selector(saveWeatherIconWidgetData:) withObject:widgetData];    
}
-(void)setWeatherIconToday
{
    NSMutableDictionary *widgetData = [[widgetHelper getWidgetDataFromIndex:self.widgetSelected.tag-10 ]
                                       mutableCopy];
    [widgetData setObject:@"today" forKey:@"forecast"];        
    [self performSelector:@selector(saveWeatherIconWidgetData:) withObject:widgetData];    
}
-(void)setWeatherIconTomorrow
{
    NSMutableDictionary *widgetData = [[widgetHelper getWidgetDataFromIndex:self.widgetSelected.tag-10 ]
                                       mutableCopy];
    [widgetData setObject:@"tomorrow" forKey:@"forecast"];        
    [self performSelector:@selector(saveWeatherIconWidgetData:) withObject:widgetData];    
}

-(void)showWeatherIconMenuController
{
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    UIMenuItem *alignLeft = [[UIMenuItem alloc] initWithTitle:@"Current" action:@selector(setWeatherIconCurrent)];
    UIMenuItem *alignCenter = [[UIMenuItem alloc] initWithTitle:@"Today" action:@selector(setWeatherIconToday)];
    UIMenuItem *alignRight = [[UIMenuItem alloc] initWithTitle:@"Tomorrow" action:@selector(setWeatherIconTomorrow)];
    
    [self becomeFirstResponder];
    [menuController setMenuItems:[NSArray arrayWithObjects:alignLeft, alignCenter, alignRight,nil]];
    [menuController setTargetRect:CGRectMake(self.widgetSelected.center.x, self.widgetSelected.center.y, 0, 0) inView:self.view];
    [menuController setArrowDirection:UIMenuControllerArrowDefault];
    [menuController setMenuVisible:YES animated:YES];
    
    
}

-(void)toggleToolsType
{
    NSString *selectedWidgetClass = (NSString*)[widgetHelper getWidgetDataFromIndex:[self.widgetSelected tag]-10 FromKey:@"type"];

    if(_textToolsVisible)
    {
        if( [selectedWidgetClass isEqualToString:@"imageWidget"] && ![[weatherSingleton sharedInstance] isClimacon])
        {
            [tools closeTextTools];
            _textToolsVisible = FALSE;
            _toolsOpen = FALSE;
            
            //Open imagetools
            [self showWeatherIconMenuController];
            //[weatherIconForecastPicker showForecastPicker];
        }
        else            
            [self performSelector:@selector(setToolsButtons)];
    }
    else
    {
        if(![selectedWidgetClass isEqualToString:@"imageWidget"] || [[weatherSingleton sharedInstance] isClimacon])
        {
            //Close imagetools
            
            [self performSelector:@selector(setToolsButtons)];
            _textToolsVisible = TRUE;
            [tools openTextTools];
        }
        
    }
    
}

-(void)toggleTools
{
    
    if (_toolsOpen) {
        _toolsOpen = FALSE;
        _textToolsVisible = FALSE;
        [tools closeTextTools];
    }
    else
    {
        _toolsOpen = TRUE;
        
        NSString *selectedWidgetClass = (NSString*)[widgetHelper getWidgetDataFromIndex:[self.widgetSelected tag]-10 FromKey:@"type"];
        if(![selectedWidgetClass isEqualToString:@"imageWidget"] || [[weatherSingleton sharedInstance] isClimacon])
        {
            [tools openTextTools];
            [self performSelector:@selector(setToolsButtons)];
            _textToolsVisible = TRUE;
        }
        else
        {
            _textToolsVisible = FALSE;      
            _toolsOpen = FALSE;
            [self showWeatherIconMenuController];
            //[weatherIconForecastPicker showForecastPicker];
        }
    }
}


- (void) forceWidgetRedraw:(UIView *)widget
{
    if([self.widgetsAdded count] > 0){
        NSInteger i = [widget tag]-10;
        if(i<0)
            i+=10;
        if(self.widgetSelected == nil && widget!=nil)
        {
            self.widgetSelected = widget;
        }
        if(widget==nil && self.widgetSelected != nil)
        {
            widget = self.widgetSelected;
        }
        [self setOriginalWidgetIndex:widget];
        [widget removeFromSuperview];
        //[self initWidgetsArray];
        NSString *cls = [[self.widgetsAdded objectAtIndex:i] objectForKey:@"class"];
        [self addWidgetToView:cls index:i];
    }
}

-(NSString *)widthForCSSWithPX{
    
    int width = [UIScreen mainScreen].bounds.size.width;
    if(kIsIpad){
        width = [UIScreen mainScreen].bounds.size.height;
    }
    NSLog(@"device width: %i", width);
    return [NSString stringWithFormat:@"%ipx",width];
    
}
-(NSString *)heightForCSSWithPX{
    
    int height = [UIScreen mainScreen].bounds.size.height - 20;//status bar in app
    NSLog(@"device height: %i", height);
    
    return [NSString stringWithFormat:@"%ipx",height];
    
}
-(void) drawBackground
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSLog(@"viewcontroller draw background");
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        if([[GMTHelper sharedInstance] parallaxEnabled]){
            
            //NSString *html = [bgWebView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
            //NSLog(@"HTML: %@",html);
            
            NSInteger i = [[NSDate date] timeIntervalSince1970];
            NSString *nowTimestamp = [NSString stringWithFormat:@"%i", i ];
            
            NSString *wallpaperHtml = [[NSBundle mainBundle] pathForResource:@"WallpaperUI" ofType:@"html"];
            
            NSString *wallpaper = [NSString stringWithContentsOfFile:wallpaperHtml encoding:NSUTF8StringEncoding error:nil];
            
            wallpaper = [wallpaper stringByReplacingOccurrencesOfString:@"320px" withString:[self widthForCSSWithPX]];
            //-webkit-perspective: 420px;
            if(kIsIpad){
                //wallpaper = [wallpaper stringByReplacingOccurrencesOfString:@"420px" withString:@"80px"];
            }
            wallpaper = [wallpaper stringByReplacingOccurrencesOfString:@"480px" withString:[self heightForCSSWithPX]];
            wallpaper = [wallpaper stringByReplacingOccurrencesOfString:@"LockBackground.png'" withString:[NSString stringWithFormat:@"LockBackground.png?%@'",nowTimestamp]];
            wallpaper = [wallpaper stringByReplacingOccurrencesOfRegex:@"LockBackground.png\\?[0-9]+'" withString:[NSString stringWithFormat:@"LockBackground.png?%@'",nowTimestamp]];
            
            NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:@""];
            imagePath = [imagePath stringByReplacingOccurrencesOfString:@"/" withString:@"//"];
            imagePath = [imagePath stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
            
            //NSLog(@"wallpaper html: %@",wallpaper);
            [bgWebView loadHTMLString:wallpaper baseURL:[NSURL URLWithString: [NSString stringWithFormat:@"file:/%@//",imagePath]]];
            [bgWebView setAlpha:1];
            [bgImage setAlpha:0];
        }
        else{
            [bgWebView setAlpha:0];
            [bgImage setAlpha:1];
            NSString *appFile = [documentsDirectory stringByAppendingPathComponent:@"LockBackground.png"];
            //NSLog(@"%@",appFile);
            [bgImage setImage:[UIImage imageWithContentsOfFile:appFile]];
            if(kIsIpad)[bgImage setContentMode:UIViewContentModeTopLeft];
            [bgImage setNeedsDisplay];
            [bgImage setNeedsLayout];
        }

    });
}
- (void) appWillEnterForeground {
    NSLog(@"back from background");
    
    if([[GMTHelper sharedInstance] parallaxEnabled]){
        [bgWebView stringByEvaluatingJavaScriptFromString:@"addParallax(true);"];
    }
}

- (void) refreshViews
{
    dispatch_async(dispatch_queue_create("com.gmtaz.Clockbuilder.refreshViewsQueue", NULL), ^{
        _ranInitialRefresh = YES;
        //set addButtonText
        [self set_Editing:_editing];
        
        NSArray *subviews = [self.view subviews];
        for (__strong UIView *v in subviews) {
            if([v tag]>=10)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [v removeFromSuperview];
                });
                v = nil;
            }
        }
        [self initWidgetsArray]; 
        dispatch_async(dispatch_get_main_queue(), ^{
            [self selectWidget:nil];
            [self drawBackground];
            if([self.widgetsAdded count] > 0){
                [self addWidgetsToView];
            }
        });

    });
}
-(void) tapBG
{
    if(!_toolsOpen){
        [self resetToolbar];
        [self selectWidget:nil];
    }
    else{
        [self resetToolbar];
        [self selectWidget:nil];
        //_toolsOpen = FALSE;
        //_textToolsVisible = FALSE;
        //[tools closeTextTools];
    }
}
-(void) closeToolsTapBG
{
    [self resetToolbar];
    [self selectWidget:nil];
}

- (NSInteger) getIndexFromView:(UIView *)v
{
    return [v tag]-10;
}

-(void)setOriginalWidgetIndex:(UIView *)widget
{
    originalWidgetIndex = 0;
    for (UIView *subV in [self.view subviews])
    {
        if(subV == widget){
            break;
        }
        originalWidgetIndex++;
    }
    
}


- (void)setFrameForView:(CGRect)frame widgetView:(UIView *)piece forceRedraw:(BOOL)redraw
{
    //[[[UIApplication sharedApplication] delegate] performSelector:@selector(setScreenVisible:) withObject:@"NO"];
    
    [self setOriginalWidgetIndex:piece];
    NSArray *widgetList = [widgetHelper getWidgetsList];
    NSInteger index = [self getIndexFromView:piece];
    NSMutableDictionary *widget = [[widgetList objectAtIndex:index] mutableCopy];
    [widget setObject:NSStringFromCGRect(frame) forKey:@"frame"];
    [widgetHelper setWidgetData:index withData:widget];        
    [self addWidgetToView:[widget objectForKey:@"class"] index:index];    
    [piece removeFromSuperview];
    
    //[[[UIApplication sharedApplication] delegate] performSelector:@selector(setScreenVisible:) withObject:@"YES"];
}

-(void)showBackgroundImagePicker
{
    NSLog(@"showing bg image picker");
}

#pragma mark toolbar button actions

-(IBAction)scaleButtonClicked:(id)sender
{
    [self setScalingToolbar];
    
    if(opacitySliderVisible){
        [opacityPopup dismiss];
        opacitySliderVisible = NO;
    }
    if(scaleSliderVisible){
        [scalePopup dismiss];
        scaleSliderVisible = NO;
    }
    else{
        [opacityPopup dismiss];
        //[scaleSlider setFrame:CGRectMake(0, 0, 280, scaleSlider.frame.size.height)];
        UISlider *sclSlider = [[UISlider alloc]initWithFrame:CGRectMake(0, 0, 280, scaleSlider.frame.size.height)];
        if(!scalePopup){
            scalePopup = [[SNPopupView alloc]initWithContentView:sclSlider contentSize:sclSlider.frame.size];
        }
        //[scaleSlider setHidden:NO];
        [sclSlider setMinimumValue:scaleSlider.minimumValue];
        [sclSlider setMaximumValue:scaleSlider.maximumValue];
        [sclSlider setValue:scaleSlider.value animated:YES];
        [sclSlider setCenter:scalePopup.center];
        [sclSlider addTarget:self action:@selector(SlideToScaleView:) forControlEvents:UIControlEventValueChanged];
        [sclSlider addTarget:self action:@selector(doneScalingUsingSlider:) forControlEvents:UIControlEventTouchUpInside];
        [sclSlider addTarget:self action:@selector(doneScalingUsingSlider:) forControlEvents:UIControlEventTouchUpOutside];
        [scalePopup showFromBarButtonItem:scaleButtonItem inView:self.view];
        scaleSliderVisible = YES;
    }
}
-(IBAction)opacityButtonClicked:(id)sender
{
    [self setOpacityToolbar];
    if(scaleSliderVisible){
        [scalePopup dismiss];
        scaleSliderVisible = NO;
    }
    if(opacitySliderVisible){
        [opacityPopup dismiss];
        opacitySliderVisible = NO;
    }
    else{
        UISlider *opacSlider = [[UISlider alloc]initWithFrame:CGRectMake(0, 0, 280, opacitySlider.frame.size.height)];
        //[opacitySlider setFrame:CGRectMake(0, 0, 280, opacitySlider.frame.size.height)];
        if(!opacityPopup){
            opacityPopup = [[SNPopupView alloc]initWithContentView:opacSlider contentSize:opacSlider.frame.size];
        }
        [opacSlider setMinimumValue:opacitySlider.minimumValue];
        [opacSlider setMaximumValue:opacitySlider.maximumValue];
        [opacSlider setValue:opacitySlider.value animated:YES];
        [opacSlider setCenter:opacityPopup.center];
        [opacSlider addTarget:self action:@selector(SlideToAlphaView:) forControlEvents:UIControlEventValueChanged];
        [opacSlider addTarget:self action:@selector(doneSettingAlphaUsingSlider:) forControlEvents:UIControlEventTouchUpInside];
        [opacSlider addTarget:self action:@selector(doneSettingAlphaUsingSlider:) forControlEvents:UIControlEventTouchUpOutside];
        [opacityPopup showFromBarButtonItem:opacityButtonItem inView:self.view];
        opacitySliderVisible = YES;
    }
}


- (void)settingsButtonClick:(id)sender
{
    [self set_Editing:NO];
    
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(setScreenVisible:) withObject:@"NO"];
    manageGeneralSettings *generalSettingsView = [[manageGeneralSettings alloc] init];
    UINavigationController *navCon = [self customizedNavigationController];
    [navCon pushViewController:generalSettingsView animated:NO];
    
    [self presentViewController:navCon fromButton:(UIBarButtonItem *)sender];
    
     
    /*
    settingsUIActionsheetDelegate *asDel = [[settingsUIActionsheetDelegate new] autorelease];    
    [asDel showInView:self.view];
    */
}

- (void)browseButtonClick:(id)sender
{
    
    [self set_Editing:NO];
    
    
    savedThemesTVC *savedThemesView = [[savedThemesTVC alloc] initWithStyle:UITableViewStylePlain];
    UINavigationController *navCon = [self customizedNavigationController];
    [navCon pushViewController:savedThemesView animated:NO];
                
    [self presentViewController:navCon fromButton:(UIBarButtonItem*)sender];
    
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(setScreenVisible:) withObject:@"NO"];
    
}


- (IBAction)addButtonClick:(id)sender
{
    
    if(![[CBThemeHelper getTitleCustBarButton:self.addItem] isEqualToString:@"Edit"])//)
    {
        [[[UIApplication sharedApplication] delegate] performSelector:@selector(setScreenVisible:) withObject:@"NO"];
        [self resignFirstResponder];
        manageWidgetsTableView *tbl = [[manageWidgetsTableView alloc] initWithStyle:UITableViewStylePlain];
        UINavigationController *navCon = [self customizedNavigationController];
        [navCon pushViewController:tbl animated:NO];
        

        //[self presentModalViewController:navCon animated:YES];
        [self presentViewController:navCon fromButton:self.addItem];
        if(self.widgetSelected!=nil 
           && [[NSUserDefaults standardUserDefaults] objectForKey:@"widgetIndex"]!=nil)
        {
            NSInteger index = [[[NSUserDefaults standardUserDefaults] objectForKey:@"widgetIndex"] integerValue];
            [tbl editWidget:index];
        }
        [self set_Editing:NO];
    }
    else{
        [self set_Editing:YES];
    }
}
- (IBAction)doneButtonClick:(id)sender{
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(setScreenVisible:) withObject:@"YES"];
    NSString *senderTitle = [CBThemeHelper getTitleCustBarButton:self.done];
    
    BOOL senderDone = [senderTitle isEqualToString:@"Done"];
    
    if(senderDone && !_editingWidget)
    {
        [self set_Editing:NO];
        self.toolbar.hidden = YES;
        showToolbar.hidden = NO;
        [self tapBG];
    }
    else if(senderDone && _editing)
    {
        [self closeToolsTapBG];
    }
    else
    {
        [self set_Editing:NO];
        self.toolbar.hidden = YES;
        showToolbar.hidden = NO;
        [self tapBG];
    }    
}
-(IBAction)showToolbarClick:(id)sender{
    if(!_toolsOpen){
        self.toolbar.hidden = NO;
        showToolbar.hidden = YES;
    }
}

-(void)showWeatherFinder{
    [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
    if(!_cantFindYouAlertShowing){
        CustomAlertView *alert = [[CustomAlertView alloc] initWithTitle:@"Location Error" message:@"We were unable to locate you.  Please enter your location manually" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        _cantFindYouAlertShowing = YES;
        [alert show];
    }
    /*
    UIView *view = self.view;
    if(self.modalViewController){
        view = self.modalViewController.view;
    }*/
    /*
    UIView *view = self.view;
    //@"Enter your city or Postal Code"
    NSString *message =  @"Sorry, we can't find you.  Enter your location";
    [MKEntryPanel showPanelWithTitle:message inView:view onTextEntered:^(NSString *inputString) {
        
        [weatherFinder getLocationFromString:inputString showPickerInView:view onCancel:^{
                
        } onPicked:^(NSDictionary *locationDict) {
            NSLog(@"locationDict:%@", locationDict);
            NSMutableDictionary *settings = [[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"] mutableCopy];
            NSMutableDictionary *data = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"] objectForKey:@"weatherData"] mutableCopy] ;        
            if(data == nil)
                data = [NSMutableDictionary new];
            [data setObject:[locationDict objectForKey:@"locID"] forKey:@"location"];
            [data setObject:[locationDict objectForKey:@"locName"] forKey:@"locationName"];
            [settings setObject:data forKey:@"weatherData"];
            [[NSUserDefaults standardUserDefaults] setObject:settings forKey:@"settings"];
            if([[NSUserDefaults standardUserDefaults] synchronize]){
                [[NSNotificationCenter defaultCenter] postNotificationName:@"startGettingWeather" object:nil];
            }

            
        }];
        
    } onCancel:^{
        
    }];
     */
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    /*
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"useSlideshow"] boolValue]){
        [UIView animateWithDuration:1 animations:^(void) {
            bgWebView.alpha=.01;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:1 animations:^(void) {
                bgWebView.alpha = 1;
            }];
        }];
    }
     */
}// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (BOOL)webView:(UIWebView *)webView2
    shouldStartLoadWithRequest:(NSURLRequest *)request
    navigationType:(UIWebViewNavigationType)navigationType {
    
    NSString *requestString = [[[request URL] absoluteString] stringByReplacingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    //NSLog(requestString);
    
    if ([requestString hasPrefix:@"ios-log:"]) {
        NSString* logString = [[requestString componentsSeparatedByString:@":#iOS#"] objectAtIndex:1];
        NSLog(@"UIWebView console: %@", logString);
        return NO;
    }
    
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)addGestureRecognizersToPiece:(UIView *)piece
{
    /*
    UIRotationGestureRecognizer *rotationGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotatePiece:)];
    [piece addGestureRecognizer:rotationGesture];
    [rotationGesture release];
    
    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scalePiece:)];
    [pinchGesture setDelegate:self];
    [piece addGestureRecognizer:pinchGesture];
    [pinchGesture release];
     */
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panPiece:)];
    [panGesture setMaximumNumberOfTouches:2];
    [panGesture setDelegate:self];
    [piece addGestureRecognizer:panGesture];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showResetMenu:)];
    [piece addGestureRecognizer:longPressGesture];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPiece:)];
    [piece addGestureRecognizer:tapGesture];
}


- (void)adjustAnchorPointForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        UIView *piece = gestureRecognizer.view;
        CGPoint locationInView = [gestureRecognizer locationInView:piece];
        CGPoint locationInSuperview = [gestureRecognizer locationInView:piece.superview];
        
        piece.layer.anchorPoint = CGPointMake(locationInView.x / piece.bounds.size.width, locationInView.y / piece.bounds.size.height);
        piece.center = locationInSuperview;
    }
}







- (void)tapPiece:(UITapGestureRecognizer *)gestureRecognizer
{
    if(self.toolbar.hidden==YES && !_toolsOpen){
        self.toolbar.hidden = NO;
        showToolbar.hidden = YES;
    }    
    else
    {
        if(_editing){
            [self selectWidget:[gestureRecognizer view]];
            if(_toolsOpen)
                [self performSelector:@selector(toggleToolsType)];
            else
                [self toggleTools];
        }
    }
}

#pragma mark -
#pragma mark === Touch handling  ===
#pragma mark

- (void)showResetMenu:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if(_editing)
    {
        if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
            [self selectWidget:[gestureRecognizer view]];     
            UIMenuController *menuController = [UIMenuController sharedMenuController];
            UIMenuItem *resetMenuItem = [[UIMenuItem alloc] initWithTitle:@"Edit" action:@selector(configurePiece:)];
            UIMenuItem *deleteMenuItem = [[UIMenuItem alloc] initWithTitle:@"Delete" action:@selector(removePiece:)];
            CGPoint location = [gestureRecognizer locationInView:[gestureRecognizer view]];
            
            [self becomeFirstResponder];
            [menuController setMenuItems:[NSArray arrayWithObjects:resetMenuItem, deleteMenuItem,nil]];
            [menuController setTargetRect:CGRectMake(location.x, location.y, 0, 0) inView:[gestureRecognizer view]];
            [menuController setMenuVisible:YES animated:YES];
            
            pieceForReset = self.widgetSelected;
            NSString *cls = NSStringFromClass([pieceForReset class]);
            [[NSUserDefaults standardUserDefaults] setObject:cls forKey:@"widgetClass"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}
// animate back to the default anchor point and transform

-(void)updateWidgetTags
{
    [self initWidgetsArray];
    
    for( NSInteger y = 0; y<[[widgetHelper getWidgetsList] count]; y++ )
    {        
        UIView *v = [self.view.subviews objectAtIndex:y+2];
        [v setTag:y+10];
    }
}



- (void)removePiece:(UIMenuController *)controller
{
    [self resignFirstResponder];    
    [widgetHelper removeWidgetAtIndex:[self getIndexFromView:pieceForReset]];
    [self selectWidget:nil];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(queue, ^{
        [self performSelector:@selector(refreshViews)];
    });
}

- (void)configurePiece:(UIMenuController *)controller
{
    
    [self resignFirstResponder];
    if(_editing){
        //[self selectWidget:pieceForReset];  
        if(!_toolsOpen){
            [self toggleTools];
        }
        else{
            [self performSelector:@selector(toggleToolsType)];
        }
        
    }
}
// shift the piece's center by the pan amount
// reset the gesture recognizer's translation to {0, 0} after applying so the next callback is a delta from the current position
- (void)panPiece:(UIPanGestureRecognizer *)gestureRecognizer
{
    if(_editing)
    {
        if(showToolbar.hidden==YES){
            UIView *piece = [gestureRecognizer view];
            [self adjustAnchorPointForGestureRecognizer:gestureRecognizer];
            //  
            
            if([gestureRecognizer state] == UIGestureRecognizerStateBegan )
            {
                [self selectWidget:piece];
                if(_toolsOpen){
                    
                    [tools closeTextTools];
                    
                }
                //set anchorpoint
                CGPoint locationInView = [gestureRecognizer locationInView:piece];
                piece.layer.anchorPoint = CGPointMake(locationInView.x / piece.frame.size.width, locationInView.y / piece.frame.size.height);
            }
            
            if ([gestureRecognizer state] == UIGestureRecognizerStateChanged) {
                
                CGPoint translation = [gestureRecognizer translationInView:[piece superview]];
                CGPoint newcenter = CGPointMake([piece center].x + translation.x, [piece center].y + translation.y);
                if([[[NSUserDefaults standardUserDefaults] objectForKey:@"snapToGrid"] boolValue]){
                    
                    //SNAP TO GRID
                    int gridCubeWidth  = 5;
                    int gridCubeHeight = 5;
                    if([[NSUserDefaults standardUserDefaults] objectForKey:@"gridSize"]){
                        gridCubeWidth =[[[NSUserDefaults standardUserDefaults] objectForKey:@"gridSize"] intValue];
                        gridCubeHeight = gridCubeWidth;
                    }
                    newcenter.x = round(newcenter.x / gridCubeWidth)  * gridCubeWidth;
                    newcenter.y = round(newcenter.y / gridCubeHeight)  * gridCubeHeight;
                }
                
                
                [piece setCenter:newcenter];
                [gestureRecognizer setTranslation:CGPointZero inView:[piece superview]];
                [self showWidgetCoordinates:piece];
                
            }
            if([gestureRecognizer state]==UIGestureRecognizerStateEnded)
            {
                [self selectWidget:piece];
                int newWidth = gestureRecognizer.view.frame.size.width;
                int newHeight = gestureRecognizer.view.frame.size.height;
                int top = gestureRecognizer.view.frame.origin.y;
                int left = gestureRecognizer.view.frame.origin.x;
                
                
                CGRect frame = CGRectMake((int)left, (int)top, (int)newWidth, (int)newHeight);
                [self setFrameForView:frame widgetView:piece forceRedraw:NO];
                
                NSLog(@"widget frame: %@", NSStringFromCGRect(frame));
                [self showWidgetCoordinates:piece];
                
                if(_toolsOpen){
                    //check if widget being dragged was not imageWidget                    
                    NSString *selectedWidgetClass = (NSString*)[widgetHelper getWidgetDataFromIndex:[self.widgetSelected tag]-10 FromKey:@"type"];
                    
                    if( ![selectedWidgetClass isEqualToString:@"imageWidget"] || [[weatherSingleton sharedInstance] isClimacon])
                    {
                        [tools openTextTools];
                        [self performSelector:@selector(toggleToolsType)];
                    }
                    else{
                        _toolsOpen = NO;
                    }
                }
                
            }
        }
    }
    
}

- (IBAction)SlideToScaleView: (id)sender {
    UISlider *slider = (UISlider*)sender;
    if(slider.state == UIControlEventTouchDown){
        [self.widgetSelected setBackgroundColor:[UIColor redColor]];
        if(slider.value < .1){
            slider.value = .1;
        }
        self.widgetSelected.transform = CGAffineTransformMakeScale(slider.value, slider.value);
        [self showWidgetCoordinates:self.widgetSelected];
    }
}
- (IBAction)doneScalingUsingSlider: (id)sender {
    UISlider *slider = (UISlider*)sender;
    int top = self.widgetSelected.frame.origin.y;
    int left = self.widgetSelected.frame.origin.x;
    int sw = self.widgetSelected.frame.size.width;
    int sh = self.widgetSelected.frame.size.height;
    CGRect frame = CGRectMake( (int)left , (int)top, (int)sw, (int)sh);
    
    NSLog(@"widget frame: %@", NSStringFromCGRect(frame));
    
    [self setFrameForView:frame widgetView:self.widgetSelected forceRedraw:YES];
    [self showWidgetCoordinates:self.widgetSelected];
    [slider setValue:1];
}


- (IBAction)SlideToAlphaView: (id)sender {
    UISlider *slider = (UISlider*)sender;
    if(slider.state == UIControlEventTouchDown){
        if([self.widgetSelected respondsToSelector:@selector(updateAlpha:)])
        { 
            [self.widgetSelected performSelector:@selector(updateAlpha:) 
                                      withObject:[NSString stringWithFormat:@"%f",slider.value]];
        }
        //[self.widgetSelected setAlpha:opacitySlider.value];
    }
}
- (IBAction)doneSettingAlphaUsingSlider: (id)sender {
    UISlider *slider = (UISlider*)sender;
    if(slider.state != UIControlEventTouchDown){
        NSInteger index = self.widgetSelected.tag-10;
        NSMutableDictionary *widgetData = [self.widgetSelected performSelector:@selector(getWidgetData)];//[NSMutableDictionary dictionaryWithDictionary:[widgetsAdded objectAtIndex:index]];
        NSString *opS = [NSString stringWithFormat:@"%f", opacitySlider.value];
        if(slider.value <.1){
            opS = @"0.1";
        }
        
        [widgetData setObject:opS forKey:@"opacity"];
        [widgetHelper setWidgetData:index withData:widgetData];
    }
}
-(void)showCoordinates{
    
}

// rotate the piece by the current rotation
// reset the gesture recognizer's rotation to 0 after applying so the next callback is a delta from the current rotation
- (void)rotatePiece:(UIRotationGestureRecognizer *)gestureRecognizer
{
    // VARIABLES: 
    //didRotate (NSSTRING) YES/NO
    //rotateAmount (NSNUMBER) Degrees
    
    //Rotate the RSSglowlabel if widget is rotated.
    
    [self adjustAnchorPointForGestureRecognizer:gestureRecognizer];
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        [gestureRecognizer view].transform = CGAffineTransformRotate([[gestureRecognizer view] transform], [gestureRecognizer rotation]);
        [gestureRecognizer setRotation:0];
        NSLog(@"rotation frame: %i", (int)([[gestureRecognizer.view.layer valueForKeyPath:@"transform.rotation.z"] floatValue]*57.2957795));
        
        
    }
    if([gestureRecognizer state] == UIGestureRecognizerStateEnded)
    {
        //set widget values
        
        NSInteger index = self.widgetSelected.tag-10;
        NSMutableDictionary *widgetData = [self.widgetSelected performSelector:@selector(getWidgetData)];//[[widgetsAdded objectAtIndex:index] mutableCopy];
        [widgetData setObject:@"YES" forKey:@"didRotate"];
        [widgetData setObject:[NSNumber numberWithFloat:[[gestureRecognizer.view.layer valueForKeyPath:@"transform.rotation.z"] floatValue]] forKey:@"rotateAmount"];
        [widgetHelper setWidgetData:index withData:widgetData];
        
        NSLog(@"rotation: %f",[[gestureRecognizer.view.layer valueForKeyPath:@"transform.rotation.z"] floatValue]);//[gestureRecognizer rotation]);
    }
}

// scale the piece by the current scale
// reset the gesture recognizer's rotation to 0 after applying so the next callback is a delta from the current scale
- (void)scalePiece:(UIPinchGestureRecognizer *)gestureRecognizer
{
    if(showToolbar.hidden==YES){     
        if([gestureRecognizer state] == UIGestureRecognizerStateBegan )
        {
            [self selectWidget:[gestureRecognizer view]];  
            [self adjustAnchorPointForGestureRecognizer:gestureRecognizer];
        }        
        if ([gestureRecognizer state] == UIGestureRecognizerStateChanged) {
            [gestureRecognizer view].transform = CGAffineTransformScale([[gestureRecognizer view] transform], [gestureRecognizer scale], [gestureRecognizer scale]);
            [gestureRecognizer setScale:1];
        }
        if([gestureRecognizer state]==UIGestureRecognizerStateEnded){
            //[self selectWidget:[gestureRecognizer view]];
            float newWidth = gestureRecognizer.view.frame.size.width;
            float newHeight = gestureRecognizer.view.frame.size.height;
            float top = gestureRecognizer.view.frame.origin.y;
            float left = gestureRecognizer.view.frame.origin.x;
            CGRect frame = CGRectMake((int)left, (int)top, (int)newWidth, (int)newHeight);
            [self setFrameForView:frame widgetView:self.widgetSelected forceRedraw:YES];
        }
    }
}

#pragma mark Toolbar Button Actions

-(void)setToolsButtons
{
    NSMutableDictionary *widgetData = [self.widgetSelected performSelector:@selector(getWidgetData)];//[[[widgetHelper getWidgetsList] objectAtIndex:index] mutableCopy];
    [tools.fontButton.fontButtonLabel setFont:[UIFont fontWithName:(NSString*)[widgetData objectForKey:@"fontFamily"] size:tools.fontButton.fontButtonLabel.frame.size.height *.8]];
    NSString *alignment = [[widgetData objectForKey:@"textalignment"] capitalizedString];
    [tools.alignmentButton.alignmentIcon setImage:[UIImage imageNamed:[NSString stringWithFormat:@"align%@.png",alignment]]]; 
    NSString *trans = [widgetData objectForKey:@"textTransform"];
    if([trans isEqualToString:@"uppercase"])
        [tools.transformButton.fontLabel setText:[@"Aa" uppercaseString]];
    if([trans isEqualToString:@"lowercase"])
        [tools.transformButton.fontLabel setText:[@"Aa" lowercaseString]];
    if([trans isEqualToString:@""])
        [tools.transformButton.fontLabel setText:@"Aa"];
    
    NSData *colorData = [widgetData objectForKey:@"fontColor"];
    UIColor *fontColor = (UIColor *)[NSKeyedUnarchiver unarchiveObjectWithData:colorData];
    if (!fontColor) {
        fontColor = [UIColor whiteColor];
    }
    [tools.colorButton setSliderValuesFromColor:fontColor];
    [tools.colorButton updateBorderColor:fontColor];
    
    NSData *glowData = [widgetData objectForKey:@"glowColor"];
    UIColor *fontGlow = (UIColor *)[NSKeyedUnarchiver unarchiveObjectWithData:glowData];
    if (!fontGlow) {
        fontGlow = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    }
    float intensity = [[widgetData objectForKey:@"fontSize"] floatValue]*.10;
    if([widgetData objectForKey:@"glowAmount"]!=nil)
        intensity = [[widgetData objectForKey:@"glowAmount"] floatValue];
    [tools.glowButton updateGlow:fontGlow intensity:intensity];
    [tools.glowButton setSliderValuesFromColor:fontGlow intensity:intensity];
    
    [tools.fontButton setHidden:NO];
    [tools.transformButton setHidden:NO];
    [tools.alignmentButton setHidden:NO];
    
    //switch based on widget subclass (datetime vs. weather)
    if([[widgetData objectForKey:@"subClass"]isEqualToString:@"datetime"])
    {
        //show datetimebutton - hide weatherbutton
        [tools.dateFormatButton setHidden:NO];
        [tools.weatherButton setHidden:YES];
        [tools.customTextButton setHidden:YES];
        [tools.dateFormatButton setWidgetData:widgetData];
    }
    if([[widgetData objectForKey:@"subClass"]isEqualToString:@"weather"])
    {
        //show weatherbutton - hide datetimebutton
        [tools.customTextButton setHidden:YES];
        [tools.dateFormatButton setHidden:YES];
        [tools.weatherButton setHidden:NO];
        [tools.weatherButton setWidgetData:widgetData];
        if([[widgetData objectForKey:@"class"] isEqualToString:@"weatherIconView"] && [[weatherSingleton sharedInstance] isClimacon]){
            NSLog(@"tapped on climacon");
            [tools.fontButton setHidden:YES];
            [tools.transformButton setHidden:YES];
            [tools.alignmentButton setHidden:YES];
        }
        
    }
    if([[widgetData objectForKey:@"subClass"]isEqualToString:@"text"])
    {
        //show weatherbutton - hide datetimebutton
        [tools.dateFormatButton setHidden:YES];
        [tools.weatherButton setHidden:YES];
        [tools.customTextButton setHidden:NO];
        [tools.customTextButton setWidgetData:widgetData];
    }
}
-(void)updateFontForText:(NSString *)fontFamily
{
    [self.widgetSelected performSelector:@selector(updateFontForText:) withObject:fontFamily];
}
-(void)saveNewFontForText:(NSString *)fontFamily
{
    NSInteger newFontSize = (NSInteger)[self.widgetSelected performSelector:@selector(updateFontForText:) withObject:fontFamily];    
    NSInteger index = self.widgetSelected.tag-10;
    NSMutableDictionary *widgetData = [self.widgetSelected performSelector:@selector(getWidgetData)];//[[[widgetHelper getWidgetsList] objectAtIndex:index] mutableCopy];
    [widgetData setObject:fontFamily forKey:@"fontFamily"];
    [widgetData setObject:[NSString stringWithFormat:@"%i", newFontSize] forKey:@"fontSize"];    
    [widgetHelper setWidgetData:index withData:widgetData];    
    [tools.fontButton.fontButtonLabel setFont:[UIFont fontWithName:fontFamily 
                                                              size:tools.fontButton.fontButtonLabel.frame.size.height *.8]];
}

-(void)updateTextAlignment:(NSString*)alignment
{
    NSInteger index = self.widgetSelected.tag-10;
    NSMutableDictionary *widgetData = [self.widgetSelected performSelector:@selector(getWidgetData)];//[[[widgetHelper getWidgetsList] objectAtIndex:index] mutableCopy];
    [widgetData setObject:alignment forKey:@"textalignment"];    
    [widgetHelper setWidgetData:index withData:widgetData]; 
    [self.widgetSelected performSelector:@selector(setTextAlignmentTo:) withObject:alignment];
}


-(void)updateTextTransform:(NSString*)trans
{
    NSInteger index = self.widgetSelected.tag-10;
    NSMutableDictionary *widgetData = [self.widgetSelected performSelector:@selector(getWidgetData)];//[[[widgetHelper getWidgetsList] objectAtIndex:index] mutableCopy];
    [widgetData setObject:trans forKey:@"textTransform"];    
    [widgetHelper setWidgetData:index withData:widgetData];        
    [self.widgetSelected performSelector:@selector(setTextTransformTo:) withObject:trans];
}

-(void)updateTextColor:(UIColor *)newColor
{
    [self.widgetSelected performSelector:@selector(setNewTextColor:) withObject:newColor];    
}

-(void)saveTextColor:(UIColor *)newColor
{
    
    NSInteger index = self.widgetSelected.tag-10;
    
    NSMutableDictionary *widgetData = [self.widgetSelected performSelector:@selector(getWidgetData)];//[[[widgetHelper getWidgetsList] objectAtIndex:index] mutableCopy];
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:newColor]; 
    [widgetData setObject:colorData forKey:@"fontColor"];    
    [widgetHelper setWidgetData:index withData:widgetData];        
    [tools.colorButton updateBorderColor:newColor];
}

-(void)updateTextGlow:(UIColor *)newColor intensity:(NSString *)intensity
{
    [self.widgetSelected performSelector:@selector(setNewGlowColor:intensity:) withObject:newColor withObject:intensity];    
}
-(void)saveTextGlow:(UIColor *)newColor intensity:(NSString *)intensity
{
    NSInteger index = self.widgetSelected.tag-10;
    NSMutableDictionary *widgetData = [self.widgetSelected performSelector:@selector(getWidgetData)];//[[[widgetHelper getWidgetsList] objectAtIndex:index] mutableCopy];
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:newColor]; 
    [widgetData setObject:colorData forKey:@"glowColor"];    
    [widgetData setObject:intensity forKey:@"glowAmount"];
    [widgetHelper setWidgetData:index withData:widgetData];        
    [tools.glowButton updateGlow:newColor intensity:[intensity floatValue]];
}


-(void)saveTextDateTimeFormat:(NSString*)dt
{
    NSInteger index = self.widgetSelected.tag-10;
    NSMutableDictionary *widgetData = [self.widgetSelected performSelector:@selector(getWidgetData)];//[[[widgetHelper getWidgetsList] objectAtIndex:index] mutableCopy];
    [widgetData setObject:dt forKey:@"dateFormatOverride"];    
    [widgetHelper setWidgetData:index withData:widgetData]; 
    NSDictionary *wd = [NSDictionary dictionaryWithDictionary:widgetData];
    [self.widgetSelected performSelector:@selector(setNewWidgetData:) withObject:wd];
}


-(void)saveTextWeatherWidgetData:(NSDictionary *)data
{
    [widgetHelper setWidgetData:self.widgetSelected.tag-10 withData:data];
    [self.widgetSelected performSelector:@selector(setNewWidgetData:) withObject:data];
}
-(void)saveWeatherIconWidgetData:(NSDictionary *)data
{
    [widgetHelper setWidgetData:self.widgetSelected.tag-10 withData:data];
    [self.widgetSelected performSelector:@selector(setNewWidgetData:) withObject:data];
}

-(void)toggleToolbar:(NSString *)hideShow
{
    if([hideShow isEqualToString:@"hide"])    {
        self.toolbar.hidden = YES;
        self.showToolbar.hidden = YES;
        if(!ScaleIconImageView.hidden)
            ScaleIconImageView.hidden = YES;
        if(!OpacityIconImageView.hidden)
            OpacityIconImageView.hidden = YES;
    }
    else{
        self.toolbar.hidden = NO;
        [self selectWidget:self.widgetSelected];
    }
}

#pragma mark - MetaDataQuery


- (void)setupAndStartQuery {
    // Create the query object if it does not exist.
    if (!self.query){
        self.query = [[NSMetadataQuery alloc] init];
        if(self.query){
            [self.query setDelegate:self];
            // Search the Documents subdirectory only.
            [self.query setSearchScopes:[NSArray
                                     arrayWithObject:NSMetadataQueryUbiquitousDocumentsScope]];
            
            //NSString* filePattern = @"*.cbTheme";
            NSPredicate *predCbTheme = [NSPredicate predicateWithFormat:@"%K LIKE '*.cbTheme'", NSMetadataItemFSNameKey];
            //NSPredicate *pred = [NSPredicate predicateWithFormat:@"%K LIKE '*'",NSMetadataItemFSNameKey];
            [self.query setPredicate:predCbTheme];
        }
    }
    NSFileManager *fm = [NSFileManager defaultManager];
    NSURL *cloudFilePath = [fm URLForUbiquityContainerIdentifier:nil];
    NSURL *cloudDocumentsPath = [cloudFilePath URLByAppendingPathComponent:@"Documents"];
    NSLog(@"cloudPath: %@",cloudFilePath);
    NSError *error;
    if ([fm fileExistsAtPath:[cloudDocumentsPath path]] == NO && cloudDocumentsPath!=nil)
        if(![fm createDirectoryAtURL:cloudDocumentsPath 
     withIntermediateDirectories:YES 
                      attributes:nil 
                           error:&error])
            NSLog(@"error creating cloud Documents folder: %@", error);
    
    NSError *initateError;
    if(![@"initate" writeToURL:[cloudFilePath URLByAppendingPathComponent:@"initiate"] atomically:YES encoding:NSUTF8StringEncoding error:&initateError]){
        NSLog(@"initiate error: %@", initateError.localizedDescription);
    }
    else {
        [fm removeItemAtURL:[cloudFilePath URLByAppendingPathComponent:@"initiate"] error:nil];
        NSLog(@"initated iCloud");
    }
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(processFiles:)
                                                 name:NSMetadataQueryDidFinishGatheringNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(processFiles:)
                                                 name:NSMetadataQueryDidUpdateNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(enableQueryUpdates:)
                                                 name:@"enableQueryUpdates"
                                               object:nil];
    
    // Start the query and let it run.
    [self.query startQuery];
}
-(void)logQueryUpdates{
    
}

-(void)awakeFromNib{
    [super awakeFromNib];
    //NSLog(@"viewcontroller - AWAKE FROM NIB");
    
    if(!documents)
        documents = [[NSMutableArray alloc]init];
    
    //NSURL *ubiq = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    if ([CBThemeHelper isCloudEnabled]) {
        NSLog(@"AppDelegate: iCloud access!");
        [self setupAndStartQuery];
    } else {
        documents = nil;
        NSLog(@"AppDelegate: No iCloud access (either you are using simulator or, if you are on your phone, you should check settings");
    }
    
}

-(BOOL)checkIfFilesDownloaded:(NSMutableArray *)themeURLS{
    
    BOOL returnValue = NO;
    for (NSURL *fileURL in themeURLS) {
        NSNumber* isIniCloud;
        
        NSArray* conflictedVersions = [NSFileVersion unresolvedConflictVersionsOfItemAtURL:fileURL];
        
        NSFileVersion* currentVersion = [NSFileVersion currentVersionOfItemAtURL:fileURL];
        
        NSFileVersion* newestVersion = currentVersion;
        
        if (conflictedVersions && conflictedVersions.count > 0)
        {
            for (NSFileVersion* version in conflictedVersions)
            {
                if ([[version modificationDate] compare:[newestVersion modificationDate]] == NSOrderedDescending)
                {
                    newestVersion = version;
                }
            }
            
            if (newestVersion != currentVersion)
            {
                [newestVersion replaceItemAtURL:fileURL options:0 error:nil];
                
                NSArray* conflictVersions = [NSFileVersion unresolvedConflictVersionsOfItemAtURL:fileURL];
                
                for (NSFileVersion* fileVersion in conflictVersions)
                {
                    fileVersion.resolved = YES;
                }
                
                [NSFileVersion removeOtherVersionsOfItemAtURL:fileURL error:nil];
            }
            else
            {
                NSArray* conflictVersions = [NSFileVersion unresolvedConflictVersionsOfItemAtURL:fileURL];
                
                for (NSFileVersion* fileVersion in conflictVersions)
                {
                    fileVersion.resolved = YES;
                }
                
                [NSFileVersion removeOtherVersionsOfItemAtURL:fileURL error:nil];    
            }
        }
        
        
        if ([fileURL getResourceValue:&isIniCloud forKey:NSURLIsUbiquitousItemKey error:nil]) {
            // If the item is in iCloud, see if it is downloaded.
            if ([isIniCloud boolValue]) {
                NSNumber*  isDownloaded = nil;
                if ([fileURL getResourceValue:&isDownloaded forKey:NSURLUbiquitousItemIsDownloadedKey error:nil]) {
                    if ([isDownloaded boolValue])
                    {        
                        returnValue = YES;
                    }
                    else{ 
                        NSNumber*  isDownloading = nil;
                        if([fileURL getResourceValue:&isDownloading forKey:NSURLUbiquitousItemIsDownloadingKey error:nil])
                            if ([isDownloading boolValue]) {
                                [[NSFileManager defaultManager] startDownloadingUbiquitousItemAtURL:fileURL error:nil];
                            }    
                        return NO;
                    }
                }
            }
        }
    }
    
    return returnValue;
    
}

- (void)processCloudThemesURLSArray:(NSMutableArray *)themeURLS{
    
    
    if([self checkIfFilesDownloaded:themeURLS]|| themeURLS.count==0){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"doneSettingUpiCloud" object:nil];  
        for (NSURL *fileURL in themeURLS) {
            CBTheme *doc = [[CBTheme alloc] initWithFileURL:fileURL];
            NSError *readError;
            [CBThemeHelper addSkipBackupAttributeToItemAtURL:fileURL];
            if([doc readFromURL:fileURL error:&readError]){
                //NSMutableDictionary *theme = doc.themeDictData;
                NSLog(@"processing: %@", [fileURL.pathComponents objectAtIndex:fileURL.pathComponents.count-1]);
                
                if(fileURL == [themeURLS objectAtIndex:themeURLS.count-1] && ![self.query isGathering]){
                    
                    [self.query enableUpdates];
                }
                
                //import to core data
                [CBThemeHelper asyncConvertFileToCoreDataAtURL:fileURL];
                
                
            }
            else{
                NSLog(@"failed to open from iCloud");
                if(fileURL == [themeURLS objectAtIndex:themeURLS.count-1] && ![self.query isGathering]){
                    [self.query enableUpdates];
                }
            }
        }
        if (themeURLS.count == 0) {
            [self.query enableUpdates];
        }
    }
    else
    {
        //check again after timeout
        
        if(themeURLS.count>0)
            [self performSelector:@selector(processCloudThemesURLSArray:) withObject:themeURLS afterDelay:1];
        
        [self.query enableUpdates];
        
    }
    
    
}
- (void)processFiles:(NSNotification*)aNotification {
    
    // Always disable updates while processing results.
    if(!documents)
        documents = [NSMutableArray new];
    
    [self.query disableUpdates];
    NSArray *queryResults = [query results];    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSMetadataQueryDidFinishGatheringNotification object:nil];
    
    //[query stopQuery];
    NSMutableArray *tempArray = [NSMutableArray new];
    
    for (NSMetadataItem *result in queryResults) {
        NSURL *fileURL = [result valueForAttribute:NSMetadataItemURLKey];
        [tempArray addObject:fileURL];
        NSFileManager *fm = [NSFileManager defaultManager];
        NSError *downloadError;
        BOOL downloading = [fm startDownloadingUbiquitousItemAtURL:fileURL error:&downloadError];
        if(!downloading)
            NSLog(@"error downloading:%@",downloadError.localizedDescription);

    }
    if(tempArray.count == 0){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"doneSettingUpiCloud" object:nil]; 
        
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"downloadThemesFromiCloud" object:nil];  
    }
    [documents removeAllObjects];
    [documents addObjectsFromArray:tempArray];
    [self processCloudThemesURLSArray:documents];
}
- (void)enableQueryUpdates:(NSNotification*)aNotification{
    if(self.query)
        [self.query enableUpdates];
}



- (UINavigationController *)customizedNavigationController
{
    
    if (kIsIpad) {
        UINavigationController *navcon = [[UINavigationController alloc] initWithNibName:nil bundle:nil];
        return navcon;
    }
    else
    {
    themeBrowserNavigationController *navController = [[themeBrowserNavigationController alloc] initWithNibName:nil bundle:nil];
    
    // Ensure the UINavigationBar is created so that it can be archived. If we do not access the
    // navigation bar then it will not be allocated, and thus, it will not be archived by the
    // NSKeyedArchvier.
    [navController navigationBar];
    
    // Archive the navigation controller.
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:navController forKey:@"root"];
    [archiver finishEncoding];
    //[archiver release];
    //[navController release];
    
    // Unarchive the navigation controller and ensure that our UINavigationBar subclass is used.
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    [unarchiver setClass:[SCNavigationBar class] forClassName:@"UINavigationBar"];
    UINavigationController *customizedNavController = [unarchiver decodeObjectForKey:@"root"];
    [unarchiver finishDecoding];
    //[unarchiver release];
    
    // Modify the navigation bar to have a background image.
    SCNavigationBar *navBar = (SCNavigationBar *)[customizedNavController navigationBar];
    //[navBar setTintColor:[UIColor colorWithRed:0.39 green:0.72 blue:0.62 alpha:1.0]];
    [navBar setBackgroundImage:[UIImage imageNamed:@"NavigationBarBackground.png"] forBarMetrics:UIBarMetricsDefault];
    
    
    return customizedNavController;
    }
}

-(void)presentViewController:(UIViewController*)controller fromButton:(UIBarButtonItem*)button{
    
    if (kIsIpad) {
        //use popover
        [self setModalInPopover:YES];
        
        NSLog(@"is ipad - button is: %@",button);
        if(!self.pop){
            self.pop = [[UIPopoverController alloc] initWithContentViewController:controller];
            [self.pop setDelegate:self];
        }
        else
            [self.pop setContentViewController:controller];
        
        
        [self.pop presentPopoverFromBarButtonItem:button permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        
    }
    else
    {
        //push controller
        [self presentViewController:controller animated:YES completion:nil];
        
    }
    
}
-(void)presentViewController:(UIViewController*)controller fromRect:(CGRect)rect{
    
    if (kIsIpad) {
        //use popover
        if(!self.pop){
            self.pop = [[UIPopoverController alloc] initWithContentViewController:controller];
            [self.pop setDelegate:self];
        }
        else
            [self.pop setContentViewController:controller];
        [self.pop presentPopoverFromRect:rect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:NO];
        
    }
    else
    {
        //push controller
        [self presentViewController:controller animated:YES completion:nil];
        
    }
    
}
-(void)dismissPopover:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
    //the latter works fine for Modal segues
}
@end
