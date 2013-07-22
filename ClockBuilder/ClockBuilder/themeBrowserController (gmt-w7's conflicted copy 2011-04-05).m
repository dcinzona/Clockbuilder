//
//  themeBrowserController.m
//  ClockBuilder
//
//  Created by gtadmin on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "themeBrowserController.h"
#import "themeScreenshotViewCDN.h"
#import <QuartzCore/QuartzCore.h>
#import "ASICloudFilesRequest.h"
#import "ASICloudFilesObjectRequest.h"
#import "ASICloudFilesObject.h"
#import "uploadThemesController.h"
#import "helpers.h"
#import "UIImageView+WebCache.h"
#import "SDImageCache.h"


@implementation themeBrowserController
@synthesize scrollView;
@synthesize piece;
@synthesize themesArray;
@synthesize activateThemeButton;
@synthesize editField;

#define kViewFrameWidth  320
#define kViewFrameHeight  410// i.e. more than 320


- (void)highlightMe:(id)sender
{
    [sender setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:.6]];
}

- (void)unhighlightMe:(id)sender
{
    [sender setBackgroundColor:[UIColor colorWithRed:.1 green:.1 blue:.1 alpha:.3]];
}
- (void)createDownloadButton
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
    [activateThemeButton addTarget:self action:@selector(downloadTheme:) forControlEvents:UIControlEventTouchUpInside];
    [activateThemeButton addTarget:self action:@selector(unhighlightMe:) forControlEvents:UIControlEventTouchUpOutside];
    
    [[activateThemeButton layer]setCornerRadius:10];
    [activateThemeButton.layer setMasksToBounds:YES];
    [activateThemeButton.layer setBorderWidth:1];
    [activateThemeButton setBackgroundColor:[UIColor colorWithRed:.1 green:.1 blue:.1 alpha:.3]];
    [activateThemeButton.layer setBorderColor:[[UIColor colorWithRed:.1 green:.1 blue:.1 alpha:.5] CGColor]];
    
    [activateThemeButton setHidden:YES];
    
}

-(void)getThemesListInBG
{
    
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache clearMemory];
    [imageCache clearDisk];
    [imageCache cleanDisk];
    
    [self performSelectorInBackground:@selector(getThemesList) withObject:nil];
    
}

-(void)getThemesList
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
    [request setCompletionBlock:^(void) {
        
        NSMutableArray *themeNamesIncloud = [NSMutableArray new];
        NSArray *objects = [request objects];
        for(ASICloudFilesObject *object in objects)
        {
            if([object.contentType isEqualToString:@"application/directory"])
            {
                //NSLog(@"Object Name: %@",object.data);
                [themeNamesIncloud addObject:object.name];
            }
        }

        self.themesArray = [themeNamesIncloud copy];
        [themeNamesIncloud release];
        [self performSelector:@selector(renderScrollview)];
    }];
    
    [pool release];
}

- (void) renderScrollview
{
    
    //remove all subviews
    for (UIView * subV in [self.scrollView subviews]) {
        if([subV class]==[themeScreenshotViewCDN class])
            [subV removeFromSuperview];
    }
    
    
    
    NSArray *previews = self.themesArray;
    
    if([previews count]>0){
        NSInteger pages = [previews count];
        
        self.scrollView.bounces = YES;
        self.scrollView.pagingEnabled = YES;
        self.scrollView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
        [self.scrollView setCanCancelContentTouches:YES];
        NSInteger page = 0;
        currentPage = page;
        NSString *title = [NSString stringWithFormat:@"Download %@",[self.themesArray objectAtIndex:currentPage]];
        [activateThemeButton setTitle:title forState:UIControlStateNormal];
        for(NSString *themeName in previews)
        {
            
            CGRect frame = CGRectMake(0, 0, 240, 360);
            themeScreenshotViewCDN *themeSS = [[themeScreenshotViewCDN alloc] initWithFrame:frame themeName:themeName];
            [themeSS setUserInteractionEnabled:YES];
            [themeSS setTag:page];
            themeSS.frame = CGRectMake((kViewFrameWidth*page)+40,0,240,360);
            [themeSS setClipsToBounds:NO];
            [self.scrollView addSubview:themeSS];
            [themeSS release];
            page++;
        }
        [self.scrollView setContentSize:CGSizeMake(kViewFrameWidth * pages, 0)];
        [self.scrollView setContentOffset:CGPointMake(0, 0)];
        [activateThemeButton setHidden:NO];
        [noThemes setHidden:YES];
    }
    else
    {
        [activateThemeButton setHidden:YES];
        [noThemes setHidden:NO];
    }
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

-(void)saveThemeToLocal:(NSString *)NewName
{
    [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:YES];
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSString *origName = [self.themesArray objectAtIndex:currentPage];
    NSString *localFolderName = origName;
    if(![NewName isEqualToString:@""] && NewName !=nil)
    {
        localFolderName = NewName;
    }
    
    NSString *rackspace = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"] objectForKey:@"cloud"] objectForKey:@"themes"];
    NSString *thumbURL = [NSString stringWithFormat:@"%@/%@/themeScreenshot.jpg",rackspace,origName];
    NSString *plistURL = [NSString stringWithFormat:@"%@/%@/widgetsList.plist",rackspace,origName];
    NSString *bgURL = [NSString stringWithFormat:@"%@/%@/LockBackground.png",rackspace,origName];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *themesPath = [documentsDirectory stringByAppendingFormat:@"/myThemes/"];
    NSString *localDir = [themesPath stringByAppendingFormat:@"%@",localFolderName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createDirectoryAtPath:localDir withIntermediateDirectories:YES attributes:nil error:nil];  

    

    //download files
    
    
    NSData *thumb = [NSData dataWithContentsOfURL:[NSURL URLWithString:thumbURL]];
    [thumb writeToFile:[localDir stringByAppendingString:@"/themeScreenshot.jpg"] atomically:YES];
    
    
    NSData *plist = [NSData dataWithContentsOfURL:[NSURL URLWithString:plistURL]];
    [plist writeToFile:[localDir stringByAppendingString:@"/widgetsList.plist"] atomically:YES];
    NSData *bg = [NSData dataWithContentsOfURL:[NSURL URLWithString:bgURL]];
    [bg writeToFile:[localDir stringByAppendingString:@"/LockBackground.png"] atomically:YES];
    
    
    UIImage *imageThumb = [UIImage imageWithData:bg];
    [self saveImageThumb:imageThumb];
    
    helpers *h = [[helpers new] autorelease];
    [h showOverlay:@"Done" iconImage:nil];
    
    [pool release];
    
}

-(void)downloadTheme: (id)sender
{
    [sender setBackgroundColor:[UIColor colorWithRed:.1 green:.1 blue:.1 alpha:.3]];
    NSString *themeName = [self.themesArray objectAtIndex:currentPage];
        
    if([self performSelector:@selector(folderExists:) withObject:themeName])
    {
        [self performSelector:@selector(showAlertToSaveTheme)];
    }
    else
    {
        [self performSelectorInBackground:@selector(saveThemeToLocal:) withObject:nil];
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
	if([title isEqualToString:@"Cancel"])
	{
        
	}
	if([title isEqualToString:@"Overwrite"])
	{
		[self performSelectorInBackground:@selector(saveThemeToLocal:) withObject:nil];
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
        [editField release];
        [alert show];
        [alert release];
    }
    
	else if([title isEqualToString:@"OK"])
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
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"The name cannot be blank\n\n\n\n" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
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
    if(![self folderExists:NewName])
    {
        [self performSelectorInBackground:@selector(saveThemeToLocal:) withObject:NewName];
    }
    else
    {
        [self showAlertToSaveTheme];
    }
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)sv {
    currentPage = sv.contentOffset.x / kViewFrameWidth;
    NSString *title = [NSString stringWithFormat:@"Download %@",[themesArray objectAtIndex:currentPage]];
    [activateThemeButton setTitle:title forState:UIControlStateNormal];
    
    //NSLog(@"page: %d",currentPage);
}

-(void) exitModal
{
    [[[UIApplication sharedApplication]delegate]performSelector:@selector(goBackToRootView)];
}





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
        [self.view setBackgroundColor:[UIColor scrollViewTexturedBackgroundColor]];
        self.scrollView = [[UIScrollView alloc] initWithFrame:scrollFrame];
        [self.scrollView setDelegate:self];
        [self.view addSubview:self.scrollView];
        [self createDownloadButton];
        [self.view addSubview:activateThemeButton];
             
        
        noThemes = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NoThemes.png"]];
        noThemes.center = CGPointMake(self.view.center.x-10, self.view.center.y-80); 
        [self.view addSubview:noThemes];
        
        [self performSelectorInBackground:@selector(getThemesList) withObject:nil];
        
        
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"  style:UIBarButtonItemStyleBordered target:self action:@selector(exitModal)];
        self.navigationItem.leftBarButtonItem = doneButton;
        [doneButton release];
        UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(getThemesListInBG)];
        self.navigationItem.rightBarButtonItem = refreshButton;
        [refreshButton release];
        
        
        [self setTitle:@"Online Themes"];
        
    }
    return self;
    
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

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self.scrollView release];
    [self.piece release];
    [self.themesArray release];
    [self.editField release];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
