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
#import "Reachability.h"

@implementation mySavedThemes
@synthesize scrollView;
@synthesize piece;
@synthesize activateThemeButton;
@synthesize editField;
@synthesize helper;
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
    themesArray = [[NSArray arrayWithArray:directoryList] mutableCopy];
    [directoryList release];
    return themesArray;
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
-(void)saveImageThumb:(UIImage *)image
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	if (image != nil) {
        // the path to write file
		
		UIImage *sourceImage = image;
		UIImage *newImage = nil;        
		CGSize imageSize = sourceImage.size;
		CGSize targetSize = CGSizeMake(50, 50);
		CGFloat width = imageSize.width;
		CGFloat height = imageSize.height;
		CGFloat targetWidth = targetSize.width;
		CGFloat targetHeight = targetSize.height;
		CGFloat scaleFactor = 0.0;
		CGFloat scaledWidth = targetWidth;
		CGFloat scaledHeight = targetHeight;
		CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
		
		if (CGSizeEqualToSize(imageSize, targetSize) == NO) 
        {
			CGFloat widthFactor = targetWidth / width;
			CGFloat heightFactor = targetHeight / height;
			
			if (widthFactor > heightFactor) 
                scaleFactor = widthFactor; // scale to fit height
			else
                scaleFactor = heightFactor; // scale to fit width
			scaledWidth  = width * scaleFactor;
			scaledHeight = height * scaleFactor;
			
			// center the image
			if (widthFactor > heightFactor)
			{
                thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5; 
			}
			else 
                if (widthFactor < heightFactor)
				{
					thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
				}
        }       
		
		UIGraphicsBeginImageContext(targetSize); // this will crop
		
		CGRect thumbnailRect = CGRectZero;
		thumbnailRect.origin = thumbnailPoint;
		thumbnailRect.size.width  = scaledWidth;
		thumbnailRect.size.height = scaledHeight;
		
		[sourceImage drawInRect:thumbnailRect];
		
		newImage = UIGraphicsGetImageFromCurrentImageContext();
		if(newImage == nil) 
			NSLog(@"could not scale image");
		else {
			
			//pop the context to get back to the default
			UIGraphicsEndImageContext();
			//UIImage *bg = [newImage resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:croppedSize interpolationQuality:1.0];
			NSData *newImageData =  UIImagePNGRepresentation(newImage);
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *appFilePNG = [documentsDirectory stringByAppendingPathComponent:@"LockBackgroundThumb.png"];
            if([newImageData writeToFile:appFilePNG atomically:YES])
            {
                //[self.parentViewController.parentViewController performSelector:@selector(setBgImageImage)];                   
                //[self performSelector:@selector(removeLoadingOverlay)  onThread:[NSThread mainThread] withObject:nil waitUntilDone:YES];
                //[self dismissModalViewControllerAnimated:YES];
            }
		}
    }
    [pool release];
}

- (void)makeThemeActive
{
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
    
    UIImage *imageThumb = [UIImage imageWithContentsOfFile:targetBG];
    
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(queue, ^{
        [self saveImageThumb:imageThumb];
    });
    
    [[[UIApplication sharedApplication]delegate]performSelector:@selector(activateTheme:) withObject:widgetsList];
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
    
    [self.scrollView setContentSize:CGSizeMake(kViewFrameWidth * pages, 0)];
    [self.scrollView setContentOffset:CGPointMake(0, 0)];
    NSInteger page = 0;
    currentPage = page;
    if([previews count]>0){
        NSString *title = [themesArray objectAtIndex:currentPage];
        [activateThemeButton setTitle:title forState:UIControlStateNormal];
        for(NSString *themeName in previews)
        {
            
            CGRect frame = CGRectMake(0, 0, 240, 360);
            themeScreenshotView *themeSS = [[themeScreenshotView alloc] initWithFrame:frame];
            [themeSS setUserInteractionEnabled:YES];
            [themeSS setTag:page];
            themeSS.frame = CGRectMake((kViewFrameWidth*page)+40,0,240,360);
            [themeSS setClipsToBounds:NO];
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showActionsheet)];
            [themeSS addGestureRecognizer:tap];
            [tap release];
            
            
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
-(void)scrollToFirstPage{
    currentPage = 0;
    [self.scrollView setContentOffset:CGPointMake(0,0) animated:YES];
}

#pragma mark INIT
- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code
        //scrollView = [[UIScrollView alloc] initWithFrame:frame];
        qup = [uploadThemesController new];
        helper = [helpers new];
        currentPage = 0;
        CGRect scrollFrame;
        scrollFrame.origin.x = 0;
        scrollFrame.origin.y = 0; 
        scrollFrame.size.width = kViewFrameWidth;
        scrollFrame.size.height = kViewFrameHeight;
        
        self.scrollView = [[UIScrollView alloc] initWithFrame:scrollFrame];
        self.scrollView.bounces = YES;
        self.scrollView.pagingEnabled = YES;
        self.scrollView.backgroundColor = [UIColor clearColor];
        [self.scrollView setCanCancelContentTouches:YES];
        [self.scrollView setDelegate:self];
        
        UIImageView *bg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
        [bg setImage:[UIImage imageNamed:@"fadedBG.JPG"]];
        [self.view addSubview:bg];
        [bg release];
        
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
        
        UIButton *titleLabel = [UIButton buttonWithType:UIButtonTypeCustom];
        [titleLabel setTitle:@"My Themes" forState:UIControlStateNormal];
        titleLabel.frame = CGRectMake(0, 0, 150, 44);
        titleLabel.titleLabel.font = [UIFont boldSystemFontOfSize:18];
        [[titleLabel titleLabel] setAdjustsFontSizeToFitWidth:YES];
        [titleLabel addTarget:self action:@selector(scrollToFirstPage) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.titleView = titleLabel;
        
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

- (void)dealloc
{
    //[self.scrollView release];
    [helper release];
    [super dealloc];
}
-(void) viewDidUnload{
    [super viewDidUnload];
    [themesArray release];
    [self.scrollView release];
    [self.piece release];
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




// animate back to the default anchor point and transform
- (void)removePiece
{
    NSString *dir = [self getPathForTheme:currentPage];    
    NSLog(@"dir: %@",dir);
    NSFileManager *fManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *files = [fManager contentsOfDirectoryAtPath:dir error:&error];
    for (NSString *file in files) {
        [fManager removeItemAtPath: [dir stringByAppendingPathComponent:file] error:&error];
    }
    //remove directory
    if([fManager removeItemAtPath:dir error:&error])
    {  
        for(UIView *view in [self.scrollView subviews])
        {
            if([view class]==[themeScreenshotView class] && view.tag == currentPage)
            {
                [UIView animateWithDuration:.4
                                 animations:^{
                                     view.alpha = 0.0;
                                     view.transform = CGAffineTransformTranslate(view.transform, 0, -40);
                                     
                                 }
                                 completion:^(BOOL finished){                   
                                     [view removeFromSuperview];
                                     NSLog(@"current page: %i | themesArray count: %i", currentPage, [themesArray count]);
                                     if(currentPage==[themesArray count]-1){
                                         [themesArray removeObjectAtIndex:currentPage];  
                                         currentPage--;
                                         [self.scrollView setContentOffset:CGPointMake(kViewFrameWidth*currentPage, 0) animated:YES];
                                     }
                                     else
                                     {
                                         [themesArray removeObjectAtIndex:currentPage];  
                                         for(UIView *subv in [self.scrollView subviews])
                                         {
                                             if([subv class]==[themeScreenshotView class] && subv.tag > currentPage)
                                             {
                                                 [UIView animateWithDuration:.4 
                                                                  animations:^(void) {
                                                                     subv.transform = CGAffineTransformTranslate(subv.transform, -kViewFrameWidth, 0);
                                                                 }
                                                                  completion:^(BOOL finished) {
                                                                      NSInteger pages = MAX(0, [themesArray count]);
                                                                      [self.scrollView setContentSize:CGSizeMake(kViewFrameWidth * pages, 0)]; 
                                                                      NSLog(@"current page: %i | themesArray count: %i", currentPage, pages);
                                                     
                                                 }];
                                                 [subv setTag:subv.tag-1];
                                             }
                                         }
                                         [activateThemeButton setTitle:[themesArray objectAtIndex:currentPage] forState:UIControlStateNormal];
                                     }
                                     
                                 }];
                break;
            }
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)sv {
    currentPage = sv.contentOffset.x / kViewFrameWidth;    
    if([themesArray count]>0 ){
        NSString *title = [NSString stringWithFormat:@"%@",[themesArray objectAtIndex:currentPage]];
        [activateThemeButton setTitle:title forState:UIControlStateNormal];    
    }
}


-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    NSInteger pages = MAX(0, [themesArray count]);
    [self.scrollView setContentSize:CGSizeMake(kViewFrameWidth * pages, 0)]; 
    if(currentPage<0){
        [self renderScrollview];
    }
    else
        [activateThemeButton setTitle:[themesArray objectAtIndex:currentPage] forState:UIControlStateNormal];
    NSLog(@"scroll anim end");
}
-(void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark Actions

-(void)showActionsheet
{
    themeConverter *th = [themeConverter new];
    UIActionSheet *actionButtonSheet;
    if([th checkIfJB])
    {
        
        actionButtonSheet = [[UIActionSheet alloc] initWithTitle:@"Theme Actions"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:@"Delete Theme"
                                                    otherButtonTitles:@"Activate Theme", @"Rename Theme",@"Upload",@"Set as Lockscreen", nil];
    }
    else
    {
        actionButtonSheet = [[UIActionSheet alloc] initWithTitle:@"Theme Actions"
                                                        delegate:self
                                               cancelButtonTitle:@"Cancel"
                                          destructiveButtonTitle:@"Delete Theme"
                                               otherButtonTitles:@"Activate Theme", @"Rename Theme", @"Upload", nil];
    }
    
    [actionButtonSheet setBounds:CGRectMake(0,0,320, 408)];
    [actionButtonSheet showInView:[self.view superview]];
    [actionButtonSheet release];
    [th release];
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// the user clicked one of the OK/Cancel buttons
    //[self.actionButtonSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if([title isEqualToString:@"Delete Theme"])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirm" message:@"Are you sure you want to delete this theme?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
        [alert show];
        [alert release];
    }
    if([title isEqualToString:@"Activate Theme"])
    {
        [self makeThemeActive];
    }
    if([title isEqualToString:@"Rename Theme"])
    {
        [self performSelector:@selector(showAlertToSaveTheme)];
    }
    if([title isEqualToString:@"Upload"])
    {    
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
        dispatch_async(queue, ^{
            
            if([helper isConnectionWifi]){  
                [self performSelector:@selector(saveToCloud)];
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [helper alertWithString:@"Could not detect internet connection. Unable to share online."];
                });
            }
        });
    }
    if([title isEqualToString:@"Set as Lockscreen"])
    {
        [self saveToLockscreen];
    }
}


#pragma mark Save Methods

- (void) saveToCloud
{
    
    NSString *UDID = [UIDevice currentDevice].uniqueIdentifier;
    NSString *blocked = @"blocked";
    NSString *URL = [NSString stringWithFormat:@"http://clockbuilder.gmtaz.com/blockList.php?udid=%@",UDID];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        NSString *isBlocked = [NSString stringWithContentsOfURL:[NSURL URLWithString:URL] encoding:NSUTF8StringEncoding error:nil];
        if(![blocked isEqualToString:isBlocked])
        {
            //[ASICloudFilesRequest setUsername:@"dcinzona"];
            //[ASICloudFilesRequest setApiKey:[[[[NSUserDefaults standardUserDefaults]objectForKey:@"settings"]objectForKey:@"cloud"]objectForKey:@"APIKey"] ];
            //[ASICloudFilesRequest authenticate];
            ASICloudFilesObjectRequest *request = 
            [ASICloudFilesObjectRequest listRequestWithContainer:@"clockBuilderThemes"];//@"clockBuilderThemes"];
            [request setDelegate:self];
            [request setShouldContinueWhenAppEntersBackground:YES];
            [request startAsynchronous];
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *blackListed = [[UIAlertView alloc] initWithTitle:@"Error" message:@"It appears your device has been blacklisted. You cannot upload themes." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [blackListed show];
                [blackListed release];
                
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            });
        }
    });
    
}

- (void)requestFinished:(ASICloudFilesObjectRequest *)request
{
    // Use when fetching text data
    //NSString *responseString = [request responseString];
    
    // Use when fetching binary data
    //NSData *responseData = [request responseData];
    NSString *themeName = [themesArray objectAtIndex:currentPage];
    
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
        [themeNamesIncloud release];
        return;
    }
    
    NSString *themeDir = [self getPathForTheme:currentPage];
    
    [qup saveThemeToCloud:themeName themePath:themeDir];
    [themeNamesIncloud release];
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
    
	if([title isEqualToString:@"Delete"])
	{
        [self performSelector:@selector(removePiece)];
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


@end
