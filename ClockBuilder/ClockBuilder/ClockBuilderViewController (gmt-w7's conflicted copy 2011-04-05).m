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
#import "mySavedThemes.h"
#import "manageGeneralSettings.h"
#import "manageWidgetsTableView.h"
#import "ManageWidgetsNavigationController.h"
#import "themeBrowserController.h"
#import "themeConverter.h"
#import "AlertViewToUploadTheme.h"
#import "instructionsForTheme.h"

@implementation ClockBuilderViewController

@synthesize addItem;
@synthesize done;
@synthesize widgetsAdded;
@synthesize toolbar;
@synthesize showToolbar;
@synthesize scaleSlider;
@synthesize flexibleSpace1,flexibleSpace2, sliderContainer;
@synthesize widgetSelected;
@synthesize bgImage;
@synthesize tapBackground;
@synthesize settings,widgetsAddedData;
@synthesize editField;
@synthesize tabsController;
@synthesize tabItems;
@synthesize actionButtonSheet;
@synthesize deleteThemeDelegate;
@synthesize uploadThemeAlertView;

- (void) initWidgetsArray
{
    
    if([settings count]>0)
        [settings release];
    if([widgetsAddedData count]>0)
        [widgetsAddedData release];
    if([widgetsAdded count]>0)
        [widgetsAdded release];
    
    settings = [[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"] mutableCopy];
    widgetsAddedData = [[self.settings objectForKey:@"widgetsAddedData"] mutableCopy];
    widgetsAdded = [[self.settings objectForKey:@"widgetsList"] mutableCopy];
}

-(void)buildActionSheet
{
    themeConverter *th = [themeConverter new];
    
    if([th checkIfJB])
    {
    
        self.actionButtonSheet = [[UIActionSheet alloc] initWithTitle:@"Theme Actions"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:@"Clear Theme"
                                                    otherButtonTitles:@"Save Theme",@"Share Online",@"Set as Lockscreen", nil];
    }
    else
    {
        self.actionButtonSheet = [[UIActionSheet alloc] initWithTitle:@"Theme Actions"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:@"Clear Theme"
                                                    otherButtonTitles:@"Save Theme",@"Share Online", nil];
    }
        
    [self.actionButtonSheet setBounds:CGRectMake(0,0,320, 408)];
    [th release];
}

-(void)showActionSheet
{
    self.toolbar.hidden =YES;
    [self performSelectorInBackground:@selector(saveThemeScreenshot) withObject:nil];       
    [self.actionButtonSheet showInView:[self.view superview]];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// the user clicked one of the OK/Cancel buttons
    //[self.actionButtonSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
    NSString *title = [self.actionButtonSheet buttonTitleAtIndex:buttonIndex];
    
    if([title isEqualToString:@"Save Theme"])
    {
        [self performSelector:@selector(showAlertWithEditField)];
    }
    if([title isEqualToString:@"Clear Theme"])
    {
        UIAlertView *v = [[UIAlertView alloc] initWithTitle:@"Confirm" message:@"Are you sure you want to reset your current theme?  This cannot be undone.  This will not affect your saved themes." delegate:deleteThemeDelegate cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        [v show];
        [v release];
        [self.toolbar setHidden:NO];
    }
    if([title isEqualToString:@"Share Online"])
    {
        // tagField.
        [uploadThemeAlertView showAlertToUpload];
        [self.toolbar setHidden:NO];

    }
    if([title isEqualToString:@"Set as Lockscreen"])
    {
        //set as lockscreen
        themeConverter *th = [themeConverter new];
        
        if([th checkIfThemeInstalled])
        {
            [th setThemeName:nil];
            [th run:@"NO"];
        }
        else
        {
            //alert to download theme.
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Theme not detected" 
                                                           message:@"The Winterboard theme \"TypoClock Builder\" was not detected on your device.  Please download through Cydia and try again." 
                                                          delegate:self 
                                                 cancelButtonTitle:@"OK" 
                                                 otherButtonTitles:@"How?", nil];
            [alert show];
            [alert release];
        }
        
        [th release];
    }
}

-(void)showInstructions
{
    instructionsForTheme *instructions = [[instructionsForTheme alloc] initWithNibName:@"instructionsForTheme" bundle:[NSBundle mainBundle]];
    
    [self.navigationController pushViewController:instructions animated:YES];
    
    [instructions release];
};

- (void)viewDidLoad
{
    [super viewDidLoad]; 
    
    toolbarIndex = 0;
    for(UIView *tbv in [self.view subviews])
    {
        if(tbv == toolbar)
        {
            break;
        }
        else
            toolbarIndex++;
    }

    
    deleteThemeDelegate = [clearThemeAlertView new];        
    uploadThemeAlertView = [AlertViewToUploadTheme new];
                        
    [self initWidgetsArray]; 
    UIScreen *mainS = [UIScreen mainScreen];
    screenWidth = mainS.applicationFrame.size.width;
    screenHeight = mainS.applicationFrame.size.height;
    
    editField = [[UITextField alloc] initWithFrame:CGRectMake(16, 83, 252, 25)];
    
    CGRect bgFrame = CGRectMake(0, 0, screenWidth, screenHeight);
    bgImage = [[UIImageView alloc] initWithFrame:bgFrame]; 
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *appFile = [documentsDirectory stringByAppendingPathComponent:@"LockBackground.png"]; 
    [bgImage setImage:[UIImage imageWithContentsOfFile:appFile]];
    [bgImage setContentMode:UIViewContentModeScaleAspectFill];
    [bgImage setBackgroundColor:[UIColor blackColor]];
    [self.view insertSubview:bgImage atIndex:0];
    tapBackground = [UIButton buttonWithType:UIButtonTypeCustom];
    [tapBackground setFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    [tapBackground setBackgroundColor:[UIColor clearColor]];
    [tapBackground addTarget:self action:@selector(tapBG) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview:tapBackground aboveSubview:bgImage];
    [bgImage setTag:-1];
    
    
    scaleSlider.minimumValue = .01;
    scaleSlider.maximumValue = 5;//500
    showToolbar = [UIButton buttonWithType:UIButtonTypeCustom];
    [showToolbar setFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    [showToolbar setBackgroundColor:[UIColor clearColor]];
    [showToolbar addTarget:self action:@selector(showToolbarClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:showToolbar];
    if([self.widgetsAdded count]==0)
    {
        toolbar.hidden = NO;    
        showToolbar.hidden = YES;
    }
    else{
        toolbar.hidden = YES;
        showToolbar.hidden = NO;
    }
    [self performSelector:@selector(resetToolbar)];
    [self addWidgetsToView];
    
    [self buildActionSheet];
    
}

- (void)resetToolbar
{
    UIBarButtonItem *saveActionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActionSheet)];//showAlertWithEditField
    UIBarButtonItem *browseButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"browseWeb.png"] style:UIBarButtonItemStylePlain target:self action:@selector(browseButtonClick)];
    UIBarButtonItem *flex1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *flex2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"gears.png"] style:UIBarButtonItemStylePlain target:self action:@selector(settingsButtonClick)];    
    
    if([widgetsAdded count]==0)
        [saveActionButton setEnabled:NO];
    else
        [saveActionButton setEnabled:YES];
    
    NSArray *toolbarbuttons = [NSArray arrayWithObjects:addItem, flexibleSpace1,browseButton,flex1, saveActionButton,flex2, settingsButton, flexibleSpace2, done, nil];
    [addItem setTitle:@"Widgets"];
    [done setTitle:@"Close"];
    [toolbar setItems:toolbarbuttons];    
    [saveActionButton release];
    [browseButton release];
    [settingsButton release];
    [flex1 release];
    [flex2 release];
}


-(void)trySavingTheme:(NSString *)themeName
{
    
    if([self performSelector:@selector(folderExists:) withObject:themeName])
    {
        [self performSelector:@selector(showAlertToSaveTheme)];
    }
    else
    {
        [self performSelectorInBackground:@selector(saveTheme:) withObject:themeName];

    }
}

- (BOOL)folderExists:(NSString *)themeName
{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *themesPath = [documentsDirectory stringByAppendingFormat:@"/myThemes/"];
    
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
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:alertTitle
                                                   message:[NSString stringWithFormat:@"%@\n" , message]
                                                  delegate:self
                                         cancelButtonTitle:@"Cancel"
                                         otherButtonTitles:@"Rename", @"Overwrite",nil] ;
    // tagField.
    [alert show];
    [alert release];
    
    
}

- (void) showAlertWithEditField
{    
    //self.toolbar.hidden =YES;
    //[self performSelectorInBackground:@selector(saveThemeScreenshot) withObject:nil];    
    NSString * alertTitle = @"Save Theme";
    NSString * message = @"Enter Theme Name";
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:alertTitle
                                                   message:[NSString stringWithFormat:@"%@\n\n\n" , message]
                                                  delegate:self
                                         cancelButtonTitle:@"Cancel"
                                         otherButtonTitles:@"OK",nil] ;
    // tagField.
    editField.backgroundColor = [UIColor clearColor];
    editField.tag = 10;
    editField.borderStyle = UITextBorderStyleRoundedRect;
    //[self.alert addTextFieldWithValue:@"" label:@"City Name or Zip"];
    [editField becomeFirstResponder];
    [alert addSubview:editField];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 4.0) {
        CGAffineTransform moveUp = CGAffineTransformMakeTranslation(0, 90);
        [alert setTransform:moveUp];
    }
    [alert show];
    [alert release];
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [editField resignFirstResponder];
	NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    [self.toolbar setHidden:NO];
    NSString *fieldVal = [editField.text copy];
    if (buttonIndex == 0)
    { 
    }
    else
    {
        if([title isEqualToString:@"How?"])
        {
            [self showInstructions];
        }
        else
        {
            if(fieldVal != nil && ![fieldVal isEqualToString:@""]) {
                if([title isEqualToString:@"Overwrite"])
                {
                    [self performSelectorInBackground:@selector(saveTheme:) withObject:fieldVal];
                }
                else if([title isEqualToString:@"Rename"])
                {
                    NSString * alertTitle = @"Save As";
                    NSString * message = @"Please enter a new name.";
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:alertTitle
                                                                   message:[NSString stringWithFormat:@"%@\n\n\n\n" , message]
                                                                  delegate:self
                                                         cancelButtonTitle:@"Cancel"
                                                         otherButtonTitles:@"OK",nil] ;
                    // tagField.
                    editField.backgroundColor = [UIColor clearColor];
                    editField.tag = 10;
                    editField.borderStyle = UITextBorderStyleRoundedRect;
                    //[self.alert addTextFieldWithValue:@"" label:@"City Name or Zip"];
                    [editField becomeFirstResponder];
                    [alert addSubview:editField];
                    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 4.0) {
                        CGAffineTransform moveUp = CGAffineTransformMakeTranslation(0, 90);
                        [alert setTransform:moveUp];
                    }
                    [alert show];
                    [alert release];
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
                [fieldVal release];
                [self performSelectorInBackground:@selector(saveThemeScreenshot) withObject:nil];    
                NSString * alertTitle = @"Error";
                NSString * message = @"The name cannot be blank";
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:alertTitle
                                                               message:[NSString stringWithFormat:@"%@\n\n\n\n" , message]
                                                              delegate:self
                                                     cancelButtonTitle:@"Cancel"
                                                     otherButtonTitles:@"OK",nil] ;
                // tagField.
                editField.backgroundColor = [UIColor clearColor];
                editField.tag = 10;
                editField.borderStyle = UITextBorderStyleRoundedRect;
                //[self.alert addTextFieldWithValue:@"" label:@"City Name or Zip"];
                [editField becomeFirstResponder];
                [alert addSubview:editField];
                if ([[[UIDevice currentDevice] systemVersion] floatValue] < 4.0) {
                    CGAffineTransform moveUp = CGAffineTransformMakeTranslation(0, 90);
                    [alert setTransform:moveUp];
                }
                [alert show];
                [editField release];
                [alert release];
        }
        }
    }
}
- (void)saveTheme:(NSString *)themeName
{
    
    //NSString *timeStamp = [NSString stringWithFormat:@"%d", [[NSDate date] timeIntervalSince1970]];
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //create an array and store result of our search for the documents directory in it
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *themeScreen = [NSString stringWithFormat:@"%@/%@.jpg",documentsDirectory,@"themeScreenshot"];
    UIImage *image= [UIImage imageWithContentsOfFile:themeScreen];
    
    NSData *imageData = UIImageJPEGRepresentation(image, 70); //convert image into .png format.
    
    NSFileManager *fileManager = [NSFileManager defaultManager];//create instance of NSFileManager
    //create NSString object, that holds our exact path to the documents directory
    
    NSString *themeFolder = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/myThemes/%@",themeName]];
    BOOL isDir;

    if(![fileManager fileExistsAtPath:themeFolder isDirectory:(&isDir)])
        [fileManager createDirectoryAtPath:themeFolder withIntermediateDirectories:YES attributes:nil error:nil]; 
    
    NSString *fullPath = [themeFolder stringByAppendingPathComponent:@"/themeScreenshot.jpg"]; //add our image to the path
    [fileManager createFileAtPath:fullPath contents:imageData attributes:nil]; //finally save the path (image)
    
    [[[[NSUserDefaults standardUserDefaults]objectForKey:@"settings"]objectForKey:@"widgetsList"] writeToFile:[themeFolder stringByAppendingFormat:@"/widgetsList.plist"] atomically:YES];
    
    [fileManager copyItemAtPath:[documentsDirectory stringByAppendingFormat:@"/LockBackground.png"] toPath:[themeFolder stringByAppendingFormat:@"/LockBackground.png"] error:nil];
    
    
    helpers *h = [[helpers new] autorelease];
    [h showOverlay:@"Theme Saved" iconImage:nil];
    
    [pool release];
}


-(NSInteger)getFontSizeForPiece:(textBasedWidget *)piece
{
    int fontSize = abs((int)piece.textLabel.font.pointSize) ;
    return fontSize;
}
- (void)initWidget:(UIView *)v index:(NSInteger)i{
    if([widgetsAdded count] > 0){
        NSInteger tag = [[[widgetsAdded objectAtIndex:i] objectForKey:@"widgetTag"] integerValue];
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
    }
}

- (void) addWidgetToView:(NSString *)cls index:(NSInteger)i
{
    //NSLog(@"adding widget: %d",i);
    if([widgetsAdded count] > 0){
        CGRect frame = CGRectFromString([[widgetsAdded objectAtIndex:i] objectForKey:@"frame"]);
        BOOL redraw = [[[NSUserDefaults standardUserDefaults] objectForKey:@"forceRedraw"] boolValue];
        if([cls isEqualToString:@"weatherIconView"])
        {
            weatherIconView *v = [[weatherIconView alloc] initWithFrame:frame widgetData:[widgetsAdded objectAtIndex:i] indexValue:[NSNumber numberWithInt:i]];
            [self initWidget:v index:i];
            if(redraw){
                [self selectWidget:v];  
            }
            [v release];
        }
        if ([cls isEqualToString:@"textBasedWidget"]) {
            textBasedWidget *v = [[textBasedWidget alloc] initWithFrame:frame widgetData:[widgetsAdded objectAtIndex:i] indexValue:[NSNumber numberWithInt:i]];
            [self initWidget:v index:i];
            [v setClipsToBounds:NO];
            if(redraw){
                [self selectWidget:v];  
            }
            [v release];
        }
    }
}

- (void) addWidgetsToView
{
    //redraw widgets      
     for(int i = 0;i<[widgetsAdded count]; i++)
     {
         NSString *cls = [[widgetsAdded objectAtIndex:i] objectForKey:@"class"];
         [self addWidgetToView:cls index:i];
     }
}


- (void) selectWidget:(UIView *)widget{
    self.widgetSelected = widget;
    if(self.widgetSelected==nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"widgetIndex"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [addItem setTitle:@"Widgets"];
        [done setTitle:@"Close"];
        [self resetToolbar];
    }
    else{    
        NSInteger index = [self getIndexFromView:widget];
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",index] forKey:@"widgetIndex"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        NSArray *widgetList = [[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"] objectForKey:@"widgetsList"];
        NSString *friendlyName = [[widgetList objectAtIndex:index] objectForKey:@"className"];
        [addItem setTitle:friendlyName];
        scaleSlider.value = 1;
        NSArray *toolbarbuttons = [NSArray arrayWithObjects:addItem, flexibleSpace1, sliderContainer, flexibleSpace2, done, nil];
        [done setTitle:@"done"];
        [toolbar setItems:toolbarbuttons];   
    }
     
}


- (void) forceWidgetRedraw:(UIView *)widget
{
    if([widgetsAdded count] > 0){
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
        [self initWidgetsArray];
        NSInteger i = [[[NSUserDefaults standardUserDefaults] objectForKey:@"widgetIndex"] integerValue];
        NSString *cls = [[widgetsAdded objectAtIndex:i] objectForKey:@"class"];
        [self addWidgetToView:cls index:i];
    }
}

-(void) drawBackground
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *appFile = [documentsDirectory stringByAppendingPathComponent:@"LockBackground.png"]; 
    [bgImage setImage:[UIImage imageWithContentsOfFile:appFile]];
    [bgImage setNeedsDisplay];
}

- (void) refreshViews
{
    //set addButtonText
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"widgetIndex"];
    [self drawBackground];
    [self initWidgetsArray]; 
    
    
    //Remove All Widgets
    NSArray *subviews = [self.view subviews];
    for (UIView *v in subviews) {
        if([v tag]>=1000)
        {
            [v removeFromSuperview];
        }
    }
    if([widgetsAdded count] > 0){
        [self addWidgetsToView];
    }
    [self selectWidget:nil];
    [pool release];
}
-(void) tapBG
{
    [self resetToolbar];
    [self selectWidget:nil];
}

- (NSInteger) getIndexFromView:(UIView *)v
{
    NSInteger ret = 0;
    for (UIView *subV in [self.view subviews])
    {
        if(subV == v){    
            return ret;
        }
        else
        {
            if(subV.tag>900)
                ret++;
        }
    }
    return  -1;
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
    NSString *frameKey = @"frame";
    NSArray *widgetList = [[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"] objectForKey:@"widgetsList"];
    NSString *index = [NSString stringWithFormat:@"%d", [self getIndexFromView:piece]];
    NSMutableDictionary *widget = [[widgetList objectAtIndex:[index integerValue]] mutableCopy];
    [widget setObject:NSStringFromCGRect(frame) forKey:frameKey];
    
    if(redraw)
        [[NSUserDefaults standardUserDefaults]setObject:@"YES" forKey:@"forceRedraw"];
    else
        [[NSUserDefaults standardUserDefaults]setObject:@"NO" forKey:@"forceRedraw"];    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(saveWidgetSettings:widgetDataDictionary:) withObject:index withObject:widget];
    [widget release];
}


- (void)settingsButtonClick
{
    
    manageGeneralSettings *generalSettingsView = [[manageGeneralSettings alloc] init];
    ManageWidgetsNavigationController *settingsNavView = [[ManageWidgetsNavigationController alloc] initWithRootViewController:generalSettingsView];
    
    [self presentModalViewController:settingsNavView animated:YES];
    
    [generalSettingsView release];
    [settingsNavView release];
}
- (void)browseButtonClick
{
    mySavedThemes *savedThemesView = [[mySavedThemes alloc] init];
    themeBrowserController *themeBrowserCtrl = [[themeBrowserController alloc] init];
    ManageWidgetsNavigationController *savedThemesNavView = [[ManageWidgetsNavigationController alloc] initWithRootViewController:savedThemesView];
    ManageWidgetsNavigationController *themeBrowser = [[ManageWidgetsNavigationController alloc] initWithRootViewController:themeBrowserCtrl];
    
    self.tabItems =  [[NSArray arrayWithObjects:
                       [NSDictionary dictionaryWithObjectsAndKeys:@"downloads.png", @"image", savedThemesNavView, @"viewController", nil],
                       [NSDictionary dictionaryWithObjectsAndKeys:@"web.png", @"image", themeBrowser, @"viewController", nil], nil] retain];
    tabsController = [[[CustomTabBarViewController alloc] initWithViewControllers:tabItems] autorelease];
    [self presentModalViewController:tabsController animated:YES];
    
    [savedThemesNavView release];
    [savedThemesView release];
    [themeBrowser release];
    [themeBrowserCtrl release];

}


- (IBAction)addButtonClick:(id)sender
{
    
    [self resignFirstResponder];
    manageWidgetsTableView *tbl = [[manageWidgetsTableView alloc] initWithStyle:UITableViewStylePlain];
    ManageWidgetsNavigationController *widgetsNavView = [[ManageWidgetsNavigationController alloc] initWithRootViewController:tbl];

    [self presentModalViewController:widgetsNavView animated:YES];
    if(self.widgetSelected!=nil 
       && [[NSUserDefaults standardUserDefaults] objectForKey:@"widgetIndex"]!=nil)
    {
        NSInteger index = [[[NSUserDefaults standardUserDefaults] objectForKey:@"widgetIndex"] integerValue];
        [tbl editWidget:index];
    }    
    [widgetsNavView release];
    [tbl release];
}
- (void) saveThemeScreenshot
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    CGRect contextRect  = CGRectMake(0, 20, 320, 460);
	UIGraphicsBeginImageContext(contextRect.size);	
    
	[self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    if(newImage == nil) 
        NSLog(@"could not scale image");
    else {
        
        //pop the context to get back to the default
        UIGraphicsEndImageContext();
        //UIImage *bg = [newImage resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:croppedSize interpolationQuality:1.0];
        NSData *newImageData =  UIImageJPEGRepresentation(newImage, 70);
        NSFileManager *fileManager = [NSFileManager defaultManager];//create instance of NSFileManager
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);         
        NSString *documentsDirectory = [paths objectAtIndex:0]; 
        NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"themeScreenshot.jpg"]]; //add our image to the path
        
        [fileManager createFileAtPath:fullPath contents:newImageData attributes:nil];
        NSString *appFilePNG = [documentsDirectory stringByAppendingPathComponent:@"themeScreenshot.jpg"];
        if([newImageData writeToFile:appFilePNG atomically:YES])
        {
        }
    }
    
    toolbar.hidden =NO;
    [pool release];
}
- (IBAction)doneButtonClick:(id)sender{
    if([done.title isEqualToString:@"Close"])
    {
        toolbar.hidden = YES;
        showToolbar.hidden = NO;
    }
    
    [self tapBG];
}
-(IBAction)showToolbarClick:(id)sender{
    toolbar.hidden = NO;
    showToolbar.hidden = YES;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.

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
    [panGesture release];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showResetMenu:)];
    [piece addGestureRecognizer:longPressGesture];
    [longPressGesture release];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPiece:)];
    [piece addGestureRecognizer:tapGesture];
    [tapGesture release];
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
    if(toolbar.hidden==YES){
        toolbar.hidden = NO;
        showToolbar.hidden = YES;
    }    
    else
    {
        [self selectWidget:[gestureRecognizer view]];   
    }
}

#pragma mark -
#pragma mark === Touch handling  ===
#pragma mark

- (void)showResetMenu:(UILongPressGestureRecognizer *)gestureRecognizer
{
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        [self selectWidget:[gestureRecognizer view]];     
        UIMenuController *menuController = [UIMenuController sharedMenuController];
        UIMenuItem *resetMenuItem = [[UIMenuItem alloc] initWithTitle:@"Modify" action:@selector(configurePiece:)];
        UIMenuItem *deleteMenuItem = [[UIMenuItem alloc] initWithTitle:@"Delete" action:@selector(removePiece:)];
        CGPoint location = [gestureRecognizer locationInView:[gestureRecognizer view]];
        
        [self becomeFirstResponder];
        [menuController setMenuItems:[NSArray arrayWithObjects:resetMenuItem, deleteMenuItem,nil]];
        [menuController setTargetRect:CGRectMake(location.x, location.y, 0, 0) inView:[gestureRecognizer view]];
        [menuController setMenuVisible:YES animated:YES];
        
        pieceForReset = [gestureRecognizer view];
        [deleteMenuItem release];
        [resetMenuItem release];
        NSString *cls = NSStringFromClass([pieceForReset class]);
        [[NSUserDefaults standardUserDefaults] setObject:cls forKey:@"widgetClass"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
}
// animate back to the default anchor point and transform

- (void)removePiece:(UIMenuController *)controller
{
    
    [self resignFirstResponder];    
    if(self.widgetSelected!=nil 
       && [[NSUserDefaults standardUserDefaults] objectForKey:@"widgetIndex"]!=nil)
    {
        //NSArray *widgetList = [[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"] objectForKey:@"widgetsList"];
        NSString *index = [[NSUserDefaults standardUserDefaults] objectForKey:@"widgetIndex"];
        [[[UIApplication sharedApplication]delegate]performSelector:@selector(removeWidgetAtIndex:)withObject:index];
        //[pieceForReset removeFromSuperview];
        [self selectWidget:nil];
        [self resetToolbar];
    }
    
    
}

- (void)configurePiece:(UIMenuController *)controller
{
    
    [self resignFirstResponder];
    manageWidgetsTableView *tbl = [[manageWidgetsTableView alloc] initWithStyle:UITableViewStylePlain];
    ManageWidgetsNavigationController *v = [[ManageWidgetsNavigationController alloc] initWithRootViewController:tbl];
    [self presentModalViewController:v animated:YES];
    
    if(self.widgetSelected!=nil 
       && [[NSUserDefaults standardUserDefaults] objectForKey:@"widgetIndex"]!=nil)
    {
        //NSArray *widgetList = [[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"] objectForKey:@"widgetsList"];
        NSInteger index = [[[NSUserDefaults standardUserDefaults] objectForKey:@"widgetIndex"] integerValue];
        [tbl editWidget:index];
    }
    
    [v release];
    [tbl release];
    
}
// shift the piece's center by the pan amount
// reset the gesture recognizer's translation to {0, 0} after applying so the next callback is a delta from the current position
- (void)panPiece:(UIPanGestureRecognizer *)gestureRecognizer
{
    
    if(showToolbar.hidden==YES){
        UIView *piece = [gestureRecognizer view];
        [self adjustAnchorPointForGestureRecognizer:gestureRecognizer];
        //  
        
        if([gestureRecognizer state] == UIGestureRecognizerStateBegan )
        {
           [self selectWidget:[gestureRecognizer view]];  
        }
        
        if ([gestureRecognizer state] == UIGestureRecognizerStateChanged) {
            CGPoint translation = [gestureRecognizer translationInView:[piece superview]];
            
            [piece setCenter:CGPointMake([piece center].x + translation.x, [piece center].y + translation.y)];
            [gestureRecognizer setTranslation:CGPointZero inView:[piece superview]];
            
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
        }
    }
    
    //Translate and save to settings so we can move this to CSS.
    
}

- (IBAction)SlideToScaleView: (id)sender {  
    if(scaleSlider.state == UIControlEventTouchDown){
    [self.widgetSelected setBackgroundColor:[UIColor redColor]];
    CGPoint p = CGPointMake(self.widgetSelected.frame.origin.x / (self.widgetSelected.frame.size.width), 
                            self.widgetSelected.frame.origin.y / (self.widgetSelected.frame.size.height));
    if(scaleSlider.value == 0)
        self.widgetSelected.layer.anchorPoint = p;
    self.widgetSelected.transform = CGAffineTransformMakeScale(scaleSlider.value, scaleSlider.value);
    }
}
- (IBAction)doneScalingUsingSlider: (id)sender {   
    int top = self.widgetSelected.frame.origin.y;
    int left = self.widgetSelected.frame.origin.x;
    int sw = self.widgetSelected.frame.size.width;
    int sh = self.widgetSelected.frame.size.height;
    CGRect frame = CGRectMake( (int)left , (int)top, (int)sw, (int)sh);
    [self setFrameForView:frame widgetView:self.widgetSelected forceRedraw:YES];
}
// rotate the piece by the current rotation
// reset the gesture recognizer's rotation to 0 after applying so the next callback is a delta from the current rotation
- (void)rotatePiece:(UIRotationGestureRecognizer *)gestureRecognizer
{
    [self adjustAnchorPointForGestureRecognizer:gestureRecognizer];
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        [gestureRecognizer view].transform = CGAffineTransformRotate([[gestureRecognizer view] transform], [gestureRecognizer rotation]);
        [gestureRecognizer setRotation:0];
        NSLog(@"roation frame: %i", (int)([[gestureRecognizer.view.layer valueForKeyPath:@"transform.rotation.z"] floatValue]*57.2957795));
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



- (void)viewDidUnload
{
    [super viewDidUnload];
    [deleteThemeDelegate release];
    [tabItems release];
    [addItem release];
    [done release];
    [widgetsAdded release];
    [widgetSelected release];
    [scaleSlider release];
    [sliderContainer release];
    [flexibleSpace1 release];
    [flexibleSpace2 release];
    [bgImage release];
    [tapBackground release];
    [settings release];
    [widgetsAddedData release];
    [editField release];
    [tabsController release];
    [showToolbar release];
    [toolbar release];    
    [actionButtonSheet release];
    [uploadThemeAlertView release];
}




@end
