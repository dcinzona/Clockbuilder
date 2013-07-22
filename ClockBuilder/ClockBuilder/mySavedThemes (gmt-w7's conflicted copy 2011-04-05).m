//
//  mySavedThemes.m
//  ClockBuilder
//
//  Created by gtadmin on 3/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "mySavedThemes.h"
#import "themeScreenshotView.h"
#import <QuartzCore/QuartzCore.h>
#import "ASICloudFilesRequest.h"
#import "ASICloudFilesObjectRequest.h"
#import "ASICloudFilesObject.h"
#import "uploadThemesController.h"
#import "themeConverter.h"
#import "instructionsForTheme.h"

@implementation mySavedThemes
@synthesize scrollView;
@synthesize piece;
@synthesize themesArray;
@synthesize activateThemeButton;
@synthesize editField;

#define kViewFrameWidth  320
#define kViewFrameHeight  410// i.e. more than 320

#pragma mark ScrollView functions

- (UIImage*)loadImage:(NSString*)imageName {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", imageName]];
    
    return [UIImage imageWithContentsOfFile:fullPath];
    
}

-(NSArray *)getThemesList
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSFileManager *fM = [NSFileManager defaultManager];
    NSString *themesPath = [documentsDirectory stringByAppendingFormat:@"/myThemes/"];
    NSArray *fileList = [fM contentsOfDirectoryAtPath:themesPath error:nil];
    NSMutableArray *directoryList = [[NSMutableArray alloc] init];
    for(NSString *file in fileList) {
        NSString *path = [themesPath stringByAppendingPathComponent:file];
        BOOL isDir;
        [fM fileExistsAtPath:path isDirectory:(&isDir)];
        if(isDir) {
            [directoryList addObject:file];
        }
    }
    self.themesArray = [directoryList copy];
    [directoryList release];
    return self.themesArray;
}

- (NSString *)getPathForTheme:(NSInteger)index
{
    NSArray *previews = [self getThemesList];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *themesPath = [documentsDirectory stringByAppendingFormat:@"/myThemes/"];
    NSString *dir = [themesPath stringByAppendingFormat:@"%@",[previews objectAtIndex:index]];
    return  dir;
}

- (void)makeThemeActive:(id)sender
{
    
    [sender setBackgroundColor:[UIColor colorWithRed:.2 green:.2 blue:.2 alpha:.3]];
    NSInteger index = currentPage;
    NSString *dir = [self getPathForTheme:index];
    NSArray *widgetsList = [NSArray arrayWithContentsOfFile:[dir stringByAppendingFormat:@"/widgetsList.plist"]];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSFileManager *fManager = [NSFileManager defaultManager];
    NSError *error1;
    NSError *error2;
    NSString *targetBG = [documentsDirectory stringByAppendingFormat:@"/LockBackground.png"];
    if([fManager fileExistsAtPath:targetBG])
    {
        if(![fManager removeItemAtPath:targetBG error:&error1])
            NSLog(@"error: %@",[error1 localizedDescription]);
    }
    if(![fManager copyItemAtPath:[dir stringByAppendingFormat:@"/LockBackground.png"] toPath:[documentsDirectory stringByAppendingFormat:@"/LockBackground.png"] error:&error2])
    {
        NSLog(@"error: %@",[error2 localizedDescription]);
    }
    
    
    
    [[[UIApplication sharedApplication]delegate]performSelector:@selector(activateTheme:) withObject:widgetsList];
    
}

- (void)highlightMe:(id)sender
{
    [sender setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:.6]];
}

- (void)unhighlightMe:(id)sender
{
    [sender setBackgroundColor:[UIColor colorWithRed:.1 green:.1 blue:.1 alpha:.3]];
}
- (void)createActivationButton
{
    
    activateThemeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    activateThemeButton.frame = CGRectMake(60, 330, 200, 20);
    [activateThemeButton setTitle:@"" forState:UIControlStateNormal];
    //[btn setTitle:@"Set As Active" forState:UIControlEventTouchDown];
    [activateThemeButton setAlpha:.8];
    [activateThemeButton setExclusiveTouch:YES];
    [[activateThemeButton titleLabel] setFont:[UIFont fontWithName:@"Helvetica" size:10]];
    [activateThemeButton.titleLabel setShadowColor:[UIColor whiteColor]];
    [activateThemeButton.titleLabel setShadowOffset:CGSizeMake(1, 1)];
    
    [activateThemeButton setReversesTitleShadowWhenHighlighted:YES];
    [activateThemeButton addTarget:self action:@selector(highlightMe:) forControlEvents:UIControlEventTouchDown];    
    [activateThemeButton addTarget:self action:@selector(makeThemeActive:) forControlEvents:UIControlEventTouchUpInside];
    [activateThemeButton addTarget:self action:@selector(unhighlightMe:) forControlEvents:UIControlEventTouchUpOutside];
    
    [[activateThemeButton layer]setCornerRadius:10];
    [activateThemeButton.layer setMasksToBounds:YES];
    [activateThemeButton.layer setBorderWidth:1];
    [activateThemeButton setBackgroundColor:[UIColor colorWithRed:.1 green:.1 blue:.1 alpha:.3]];
    [activateThemeButton.layer setBorderColor:[[UIColor colorWithRed:.1 green:.1 blue:.1 alpha:.5] CGColor]];
    
    [activateThemeButton setHidden:YES];
    
}

- (void) renderScrollview
{
    
    //remove all subviews
    for (UIView * subV in [self.scrollView subviews]) {
        if([subV class]==[themeScreenshotView class])
            [subV removeFromSuperview];
    }
    
    
    
    NSArray *previews = [self getThemesList];
    
    NSInteger pages = [previews count];
    
    self.scrollView.bounces = YES;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    [self.scrollView setCanCancelContentTouches:YES];
    [self.scrollView setContentSize:CGSizeMake(kViewFrameWidth * pages, 0)];
    [self.scrollView setContentOffset:CGPointMake(0, 0)];
    NSInteger page = 0;
    currentPage = page;
    if([previews count]>0){
        NSString *title = [NSString stringWithFormat:@"Activate %@",[themesArray objectAtIndex:currentPage]];
        [activateThemeButton setTitle:title forState:UIControlStateNormal];
        for(NSString *themeName in previews)
        {
            
            CGRect frame = CGRectMake(0, 0, 240, 360);
            themeScreenshotView *themeSS = [[themeScreenshotView alloc] initWithFrame:frame themeName:themeName];
            [themeSS setUserInteractionEnabled:YES];
            [themeSS setTag:page];
            themeSS.frame = CGRectMake((kViewFrameWidth*page)+40,0,240,360);
            [themeSS setClipsToBounds:NO];
            UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showDeleteMenu:)];
            [themeSS addGestureRecognizer:longPressGesture];
            [longPressGesture release];
            [self.scrollView addSubview:themeSS];
            [themeSS release];
            page++;
        }
        [activateThemeButton setHidden:NO];
        [noThemes setHidden:YES];
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
    }
    else
    {
        [activateThemeButton setHidden:YES];
        [noThemes setHidden:NO];
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)sv {
    currentPage = sv.contentOffset.x / kViewFrameWidth;
    NSString *title = [NSString stringWithFormat:@"Activate %@",[themesArray objectAtIndex:currentPage]];
    [activateThemeButton setTitle:title forState:UIControlStateNormal];

    //NSLog(@"page: %d",currentPage);
}

#pragma mark INIT
- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code
        //scrollView = [[UIScrollView alloc] initWithFrame:frame];
        currentPage = 0;
        CGRect scrollFrame;
        scrollFrame.origin.x = 0;
        scrollFrame.origin.y = 0; 
        scrollFrame.size.width = kViewFrameWidth;
        scrollFrame.size.height = kViewFrameHeight;
        
        self.scrollView = [[UIScrollView alloc] initWithFrame:scrollFrame];
        [self.scrollView setDelegate:self];
        [self.view addSubview:self.scrollView];
        [self createActivationButton];
        [self.view addSubview:activateThemeButton];
        
        [self renderScrollview];
        
        noThemes = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NoThemes.png"]];
        noThemes.center = CGPointMake(self.view.center.x-10, self.view.center.y-80); 
        [self.view addSubview:noThemes];
        
        
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"  style:UIBarButtonItemStyleBordered target:self action:@selector(exitModal)];
        self.navigationItem.leftBarButtonItem = doneButton;
        [doneButton release];
        UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(alertToSave)];
        self.navigationItem.rightBarButtonItem = shareButton;
        [shareButton release];
        
        [self setTitle:@"My Themes"];
        
    }
    return self;

}
-(void)viewWillAppear:(BOOL)animated
{
    [self renderScrollview];
}
-(void) exitModal
{
    [[[UIApplication sharedApplication]delegate]performSelector:@selector(goBackToRootView)];
}

-(void) viewDidUnload{
    [super viewDidUnload];
    [self.scrollView release];
    [self.piece release];
    [self.themesArray release];
    [self.editField release];
}

#pragma mark Gestures

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

-(void) saveToLockscreen{
    
    themeConverter *th = [themeConverter new];
    if([th checkIfThemeInstalled])
    {//save to lockscreen
        
        [th setThemeName:[themesArray objectAtIndex:currentPage]];
        [th run:@"NO"];
        
    }
    else
    {//theme not installed - give instructions on where to get theme
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

-(void)showInstructions
{
    instructionsForTheme *instructions = [[instructionsForTheme alloc] initWithNibName:@"instructionsForTheme" bundle:[NSBundle mainBundle]];
        
    [self.navigationController pushViewController:instructions animated:YES];
    
    [instructions release];
};


- (void)showDeleteMenu:(UILongPressGestureRecognizer *)gestureRecognizer
{

    
    
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        UIMenuController *menuController = [UIMenuController sharedMenuController];
        UIMenuItem *resetMenuItem = [[UIMenuItem alloc] initWithTitle:@"Delete" action:@selector(removePiece:) ];
        UIMenuItem *renameMenuItem = [[UIMenuItem alloc] initWithTitle:@"Rename" action:@selector(showAlertToSaveTheme) ]; 
        UIMenuItem *setAsLockscreen = [[UIMenuItem alloc] initWithTitle:@"Lockscreen" action:@selector(saveToLockscreen) ];   
        themeConverter *th = [themeConverter new];
        if([th checkIfJB])
        {
            [menuController setMenuItems:[NSArray arrayWithObjects:renameMenuItem,resetMenuItem,setAsLockscreen, nil]];
        }
        else
            [menuController setMenuItems:[NSArray arrayWithObjects:renameMenuItem,resetMenuItem, nil]];
        [th release];
        
        CGPoint location = [gestureRecognizer locationInView:[gestureRecognizer view]];
        
        [self becomeFirstResponder];
        [menuController setTargetRect:CGRectMake(location.x, location.y, 0, 0) inView:[gestureRecognizer view]];
        [menuController setMenuVisible:YES animated:YES];
        
        self.piece = [gestureRecognizer view];
        [renameMenuItem release];
        [resetMenuItem release];
    }
    
}
- (void)showRenameMenu:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        UIMenuController *menuController = [UIMenuController sharedMenuController];
        UIMenuItem *resetMenuItem = [[UIMenuItem alloc] initWithTitle:@"Rename Theme" action:@selector(renamePiece:) ];
        CGPoint location = [gestureRecognizer locationInView:[gestureRecognizer view]];
        
        [self becomeFirstResponder];
        [menuController setMenuItems:[NSArray arrayWithObject:resetMenuItem]];
        [menuController setTargetRect:CGRectMake(location.x, location.y, 0, 0) inView:[gestureRecognizer view]];
        [menuController setMenuVisible:YES animated:YES];
        
        self.piece = [gestureRecognizer view];
        [resetMenuItem release];
    }
    
}
- (void)renamePiece:(UIMenuController *)controller
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Rename Theme" message:@"The name cannot be blank\n\n\n\n" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Rename", nil];
    editField = [[UITextField alloc] initWithFrame:CGRectMake(16, 83, 252, 25)];
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

// animate back to the default anchor point and transform
- (void)removePiece:(UIMenuController *)controller
{
    NSString *dir = [self getPathForTheme:[self.piece tag]];
    
    NSFileManager *fManager = [NSFileManager defaultManager];

    NSError *error;
    NSArray *files = [fManager contentsOfDirectoryAtPath:dir error:&error];
    //remove files within
    for (NSString *file in files) {
        [fManager removeItemAtPath: [dir stringByAppendingPathComponent:file] error:&error];
        
        if (error) {
            //deal with it
        }
    }
    //remove directory
    if([fManager removeItemAtPath:dir error:&error])
    {
    }
    [self renderScrollview];
    
}
-(void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark Save To Web

- (void)alertToSave
{
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Share This Theme"
                                                      message:@""
                                                     delegate:self
                                            cancelButtonTitle:@"Cancel"
                                            otherButtonTitles:@"Upload", nil];

    [message show];
    [message release];
}


#pragma mark Save Methods

- (void) saveToCloud
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:YES];
    [ASICloudFilesRequest setUsername:@"dcinzona"];
    [ASICloudFilesRequest setApiKey:[[[[NSUserDefaults standardUserDefaults]objectForKey:@"settings"]objectForKey:@"cloud"]objectForKey:@"APIKey"] ];
    [ASICloudFilesRequest authenticate];
    ASICloudFilesObjectRequest *request = 
    [ASICloudFilesObjectRequest listRequestWithContainer:@"clockBuilderThemes"];//@"clockBuilderThemes"];
    [request setDelegate:self];
    [request setShouldContinueWhenAppEntersBackground:YES];
    [request startAsynchronous];
    
    [pool release];
}

- (void)requestFinished:(ASICloudFilesObjectRequest *)request
{
    // Use when fetching text data
    //NSString *responseString = [request responseString];
    
    // Use when fetching binary data
    //NSData *responseData = [request responseData];
    NSString *themeName = [self.themesArray objectAtIndex:currentPage];
    
    NSMutableArray *themeNamesIncloud = [NSMutableArray new];
    NSArray *objects = [request objects];
    for(ASICloudFilesObject *object in objects)
    {
        if([object.contentType isEqualToString:@"application/directory"] && [object.name isEqualToString:themeName])
        {
            //NSLog(@"Object Name: %@",object.data);
            [themeNamesIncloud addObject:object.name];
        }
    }
    
    if([themeNamesIncloud count]>0){
        [self performSelector:@selector(getFullObject:themesInCloud:) withObject:themeName withObject:[NSArray arrayWithArray:themeNamesIncloud]];
        return;
    }
    
    NSString *themeDir = [self getPathForTheme:currentPage];
    
    uploadThemesController *qup= [uploadThemesController new];
    [qup saveThemeToCloud:themeName themePath:themeDir];
}

-(void)getFullObject:(NSString *)themeName themesInCloud:(NSArray *)themesInCloud
{
    ASICloudFilesObjectRequest *request = [ASICloudFilesObjectRequest 
                                          getObjectRequestWithContainer:@"clockBuilderThemes" 
                                          objectPath:[NSString stringWithFormat:@"%@",themeName]];
    [request setCompletionBlock:^{
        // Use when fetching text data
        
        ASICloudFilesObject *object = [request object];
        
        NSString *UDID = [UIDevice currentDevice].uniqueIdentifier;
        if([[object.metadata objectForKey:@"Udid"]isEqualToString:UDID]){
            
            NSString *themeDir = [self getPathForTheme:currentPage];
            
            uploadThemesController *qup= [uploadThemesController new];
            [qup saveThemeToCloud:themeName themePath:themeDir];
        }
        else
        {
            //alert user theme with name already exists and to rename theme
            [self performSelector:@selector(showAlertToSaveTheme)];
        }
    }];
    [request setFailedBlock:^{
        NSError *error = [request error];
        NSLog(@"error: %@",[error description]);
    }];
    [request startAsynchronous];
}
-(void) showAlertToSaveTheme{
    
      
    NSString * alertTitle = @"Rename Theme";
    NSString * message = @"Please type in the new name below.";
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:alertTitle
                                                   message:[NSString stringWithFormat:@"%@\n\n\n" , message]
                                                  delegate:self
                                         cancelButtonTitle:@"Cancel"
                                         otherButtonTitles:@"Rename",nil] ;
    // tagField.
    editField = [[UITextField alloc] initWithFrame:CGRectMake(16, 83, 252, 25)];
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
	if([title isEqualToString:@"Cancel"])
	{
        
	}
    else if([title isEqualToString:@"How?"])
	{
        [self showInstructions];
        
	}
	else if([title isEqualToString:@"Upload"])
	{
        [self performSelector:@selector(saveToCloud)];
        //[self performSelectorInBackground:@selector(saveToCloud) withObject:nil];
	}
	else if([title isEqualToString:@"Rename"])
	{
        NSString *fieldVal = [editField.text copy];
        if(fieldVal != nil && ![fieldVal isEqualToString:@""]) {
            [self performSelector:@selector(renameTheme:) withObject:fieldVal];
            [editField resignFirstResponder];
            [editField removeFromSuperview];
            [fieldVal release];
        }
        else
        {
            [editField resignFirstResponder];
            [editField removeFromSuperview];
            [fieldVal release];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"The name cannot be blank\n\n\n\n" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Rename", nil];
            editField = [[UITextField alloc] initWithFrame:CGRectMake(16, 83, 252, 25)];
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

- (void)renameTheme:(NSString *)NewName
{
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *themesPath = [documentsDirectory stringByAppendingFormat:@"/myThemes/"];
    NSString *origPath = [themesPath stringByAppendingFormat:@"%@",[themesArray objectAtIndex:currentPage]];
    NSString *newPath = [themesPath stringByAppendingFormat:@"%@",NewName];
    
    NSError *error;
    
    if ([fileMgr moveItemAtPath:origPath toPath:newPath error:&error] != YES)
        NSLog(@"Unable to move file: %@", [error localizedDescription]);
    else
        [self renderScrollview];
    
}


- (void)requestFailed:(ASIHTTPRequest *)request
{
    //NSError *error = [request error];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc
{
    //[self.scrollView release];
    [super dealloc];
}

@end
