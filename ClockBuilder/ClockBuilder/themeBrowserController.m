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
#import "UIImageView+WebCache.h"
#import "SDImageCache.h"
#import "CDNScrollCell.h"


@implementation themeBrowserController
@synthesize scrollView;
@synthesize piece;
@synthesize themesArray;
@synthesize activateThemeButton;
@synthesize editField;
@synthesize hconn;
@synthesize deleteControl;
@synthesize thss;
#define kViewFrameWidth  320
#define kViewFrameHeight  410// i.e. more than 320



- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code
        //scrollView = [[UIScrollView alloc] initWithFrame:frame];
        //CGRect frame = CGRectMake(40, 0, 240, 360);
        //thss = [[themeScreenshotViewCDN alloc] initWithFrame:frame];
        
        UIImageView *bg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
        [bg setImage:[UIImage imageNamed:@"fadedBG.JPG"]];
        [self.view addSubview:bg];
        [bg release];
                
        _valid = YES;
        currentPage = 0;
        
        activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activityIndicator.center = CGPointMake(self.view.center.x, self.view.center.y-80); 
        [self.view addSubview:activityIndicator];
        [activityIndicator startAnimating];
        
        noThemes = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NoThemes.png"]];
        noThemes.center = CGPointMake(self.view.center.x-10, self.view.center.y-80); 
        [noThemes setHidden:YES];
        [self.view addSubview:noThemes];
        
        //[self performSelector:@selector(getThemesList) withObject:nil];
        
        
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"  style:UIBarButtonItemStyleBordered target:self action:@selector(exitModal)];
        self.navigationItem.leftBarButtonItem = doneButton;
        [doneButton release];
        
        UIBarButtonItem *actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(getThemesListInBG)];
        self.navigationItem.rightBarButtonItem = actionButton;
        [actionButton release];
        
        UIButton *titleLabel = [UIButton buttonWithType:UIButtonTypeCustom];
        [titleLabel setTitle:@"Online Themes" forState:UIControlStateNormal];
        titleLabel.frame = CGRectMake(0, 0, 150, 44);
        titleLabel.titleLabel.font = [UIFont boldSystemFontOfSize:18];
        [[titleLabel titleLabel] setAdjustsFontSizeToFitWidth:YES];
        [titleLabel addTarget:self action:@selector(scrollToFirstPage) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.titleView = titleLabel;
        
        [self setTitle:@"Online Themes"];
        
        themesArray = [NSMutableArray new];
        
        CGRect scrollFrame;
        scrollFrame.origin.x = 0;
        scrollFrame.origin.y = 0; 
        scrollFrame.size.width = kViewFrameWidth;
        scrollFrame.size.height = kViewFrameHeight;
        scrollView = [[JScrollingRow alloc] initWithFrame:scrollFrame];
        [scrollView setDataSource:self];
        [scrollView setDelegate:self];
        [self.view addSubview:scrollView]; 
        [self performSelector:@selector(getThemesListInBG)];
    }
    return self;    
}


-(void)getThemesListInBG
{
    
    [[UIApplication sharedApplication].delegate performSelector:@selector(playclicksoft)];
    
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache clearMemory];
    [imageCache clearDisk];
    [imageCache cleanDisk];
    
    [self performSelector:@selector(getThemesList) withObject:nil];
    
}

-(NSInteger)getThemesList
{    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        if([hconn deviceIsConnectedToInet])
        {
            if(_valid){
                [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:YES];
                [ASICloudFilesRequest setUsername:@"dcinzona"];
                NSString *apiKey = [[[[NSUserDefaults standardUserDefaults]objectForKey:@"settings"]objectForKey:@"cloud"]objectForKey:@"APIKey"];
                [ASICloudFilesRequest setApiKey:apiKey];
                [ASICloudFilesRequest authenticate];
                ASICloudFilesObjectRequest *request = 
                [ASICloudFilesObjectRequest listRequestWithContainer:@"clockBuilderThemes"];                
                [request setDelegate:self];
                [request setShouldContinueWhenAppEntersBackground:YES];
                [request startAsynchronous];
                [request setShouldPresentCredentialsBeforeChallenge:YES];
                [request setCompletionBlock:^(void) {
                    [themesArray removeAllObjects];
                    //[themeNamesIncloud addObject:NSNull];
                    NSArray *objects = [request objects];
                    for(ASICloudFilesObject *object in objects)
                    {
                        if([object.contentType isEqualToString:@"application/directory"])
                        {
                            [themesArray addObject:object.name];
                        }
                    }                    
                    dispatch_async(dispatch_get_main_queue(), ^(void) {                  
                        [scrollView setIndexPath:[NSIndexPath indexPathWithIndex:[themesArray count]]];
                        [self performSelector:@selector(renderScrollview)];
                    });
                }];
                [request setDidFailSelector:@selector(requestFailedToWork)];
                [request setFailedBlock:^(void) {
                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                        [activityIndicator stopAnimating];
                    });
                }];
            }
        }
        else{
            if(_valid){ 
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    [hconn alertWithString:@"Internet connection not detected. Could not get online themes."];  
                    [activityIndicator stopAnimating];
                });
            }
        }
    });
    return  [self.themesArray count];
}

-(void)requestFailedToWork
{
    NSLog(@"FAILED");
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [activityIndicator stopAnimating];
    });
}

-(NSUInteger)numberOfColumnsInRow:(JScrollingRow *)scrollingRowView atIndexPath:(NSIndexPath *)indexPath
{
    NSInteger i = [themesArray count];
    return i;
}

-(CGFloat)scrollingRowView:(JScrollingRow *)scrollingRowView widthForCellAtIndex:(NSUInteger)index
{
    return kViewFrameWidth;
}

-(JScrollingRowCell *)scrollingRowView:(JScrollingRow *)scrollingRowView cellForColumnAtIndex:(NSUInteger)index
{
    
    static NSString *cellID = @"thumbnail";
    CDNScrollCell *cell = (CDNScrollCell*)[scrollView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[[CDNScrollCell alloc] initWithFrame:CGRectMake(0, 0, kViewFrameWidth, kViewFrameHeight) reuseIdentifier:cellID] autorelease]; 
    }  
    [cell setTag:index];
    [cell updateSS:[self.themesArray objectAtIndex:index]]; 
    
    return cell;
    
}

-(void)scrollViewDidScroll:(JScrollingRow *)sv
{

}

-(void)scrollViewDidEndDragging:(JScrollingRow *)sv willDecelerate:(BOOL)decelerate
{
   // [sv layoutCells];
}

-(void)scrollingRowView:(JScrollingRow *)scrollingRowView didSelectCellAtIndex:(NSUInteger)index
{
    currentPage = index;
    [self performSelector:@selector(showActionMenu)];
}


-(void)viewWillAppear:(BOOL)animated
{
    _valid = YES;
    [super viewWillAppear:animated];
}

-(void)scrollToFirstPage{
    currentPage = 0;
    [scrollView setContentOffset:CGPointMake(0,0) animated:YES];
}

- (void) renderScrollview
{ 
    [scrollView removeFromSuperview];
    if(scrollView)
        [scrollView release];
    CGRect scrollFrame;
    scrollFrame.origin.x = 0;
    scrollFrame.origin.y = 0; 
    scrollFrame.size.width = kViewFrameWidth;
    scrollFrame.size.height = kViewFrameHeight;
    scrollView = [[JScrollingRow alloc] initWithFrame:scrollFrame];
    [scrollView setDataSource:self];
    [scrollView setDelegate:self];
    [self.view addSubview:scrollView];
    scrollView.bounces = YES;
    scrollView.pagingEnabled = YES;
    scrollView.backgroundColor = [UIColor clearColor];
    [scrollView setContentSize:CGSizeMake(kViewFrameWidth * [themesArray count], 0)];
    [scrollView setContentOffset:CGPointMake(0, 0)];
    [scrollView layoutCells];

    [activityIndicator stopAnimating];
}


- (BOOL)canBecomeFirstResponder
{
    return YES;
}

-(void)removeTheme:(NSString *)themeName
{
    
    [deleteControl deleteThemeFromCloud:themeName];
    
    //animate deleting the theme
    for(CDNScrollCell *view in [scrollView subviews])
    {
        
        NSLog(@"deletedClass: %@",[view class] );
        if([view class]==[CDNScrollCell class] && view.tag == currentPage)
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
                                     [scrollView setContentOffset:CGPointMake(kViewFrameWidth*currentPage, 0) animated:YES];
                                 }
                                 else
                                 {
                                     [themesArray removeObjectAtIndex:currentPage];  
                                     for(CDNScrollCell *subv in [scrollView subviews])
                                     {
                                         if([subv class]==[CDNScrollCell class] && subv.tag > currentPage)
                                         {
                                             [UIView animateWithDuration:.4 
                                                              animations:^(void) {
                                                                  subv.transform = CGAffineTransformTranslate(subv.transform, -kViewFrameWidth, 0);
                                                              }
                                                              completion:^(BOOL finished) {
                                                                  NSInteger pages = MAX(0, [self.themesArray count]);
                                                                  [scrollView setContentSize:CGSizeMake(kViewFrameWidth * pages, 0)]; 
                                                                  NSLog(@"current page: %i | themesArray count: %i", currentPage, pages);
                                                                  
                                                              }];
                                             [subv setTag:subv.tag-1];
                                         }
                                     }
                                 }
                                 
                             }];
            break;
        }
    }

    
    //[self renderScrollview];
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
    
    
    if(_valid)
    [hconn showOverlay:@"Done" iconImage:nil];
    
    if(_downloadAndActive)
    {
        NSString *dir = localDir;
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
    
	if([title isEqualToString:@"Delete"])
	{
        [self performSelector:@selector(deleteTheme:) withObject:[themesArray objectAtIndex:currentPage]];
	}
    
    if([title isEqualToString:@"Delete & block"])
    {       
        if([hconn isConnectionWifi]){
        NSString *themeName = [self.themesArray objectAtIndex:currentPage];
        ASICloudFilesObjectRequest *request = [ASICloudFilesObjectRequest 
                                               getObjectRequestWithContainer:@"clockBuilderThemes" 
                                               objectPath:[NSString stringWithFormat:@"%@",themeName]];
        [request setShouldPresentCredentialsBeforeChallenge:YES];
        [request setCompletionBlock:^{
            // Use when fetching text data
            ASICloudFilesObject *object = [request object];
            NSString *UDID = [object.metadata objectForKey:@"Udid"];
            NSString *key = @"086eec220c3db3edafa624a3c869315e907ef253";
            NSString *URL = [NSString stringWithFormat:@"http://clockbuilder.gmtaz.com/blockDevice.php?udid=%@&key=%@",UDID,key];
            NSString *retVal = [NSString stringWithContentsOfURL:[NSURL URLWithString:URL] encoding:NSUTF8StringEncoding error:nil];
            NSLog(@"deleted?: %@",retVal);
            [self performSelector:@selector(deleteTheme:) withObject:themeName];            
        }];
        [request setFailedBlock:^{
            NSError *error = [request error];
            NSLog(@"error: %@",[error description]);
        }];
        [request startAsynchronous];
        }
        else
            [hconn alertWithString:@"Wifi connection required"];
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
        [alertView setTag:5];
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
    
	else if([title isEqualToString:@"OK"] && alertView.tag==5)
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
/*
-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    NSInteger pages = MAX(0, [self.themesArray count]);
    [self.scrollView setContentSize:CGSizeMake(kViewFrameWidth * pages, 0)]; 
    if(currentPage<0){
        [self renderScrollview];
    }
    else
        [activateThemeButton setTitle:[self.themesArray objectAtIndex:currentPage] forState:UIControlStateNormal];
    NSLog(@"scroll anim end");
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)sv {
    currentPage = sv.contentOffset.x / kViewFrameWidth;    
    NSInteger pages = MAX(0, [self.themesArray count]);
    if(pages>0 ){
        NSString *title = [NSString stringWithFormat:@"%@",[themesArray objectAtIndex:currentPage]];
        [activateThemeButton setTitle:title forState:UIControlStateNormal];    
    }
    
    //NSLog(@"page: %d",currentPage);
}*/
-(void) exitModal
{
    [[[UIApplication sharedApplication]delegate]performSelector:@selector(goBackToRootView)];
}
-(void)deleteTheme:(NSString *)themeName
{
    
    if([hconn isConnectionWifi]){
        
        ASICloudFilesObjectRequest *request = [ASICloudFilesObjectRequest 
                                               getObjectRequestWithContainer:@"clockBuilderThemes" 
                                               objectPath:[NSString stringWithFormat:@"%@",themeName]];
        [request setShouldPresentCredentialsBeforeChallenge:YES];
        [request setCompletionBlock:^{
            // Use when fetching text data
            
            ASICloudFilesObject *object = [request object];
            
            NSLog(@"META UDID: %@", [object.metadata objectForKey:@"Udid"]);
            NSString *UDID = [UIDevice currentDevice].uniqueIdentifier;
            NSString *SuperUDID = @"086eec220c3db3edafa624a3c869315e907ef253";
            if([UDID isEqualToString:[object.metadata objectForKey:@"Udid"]] ||
               [UDID isEqualToString:SuperUDID])
            {
                [self removeTheme:themeName];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You can only delete your own themes" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                [alert release];
            }

        }];
        [request setFailedBlock:^{
            NSError *error = [request error];
            NSLog(@"error: %@",[error description]);
        }];
        [request startAsynchronous];
    }
    else
        [hconn alertWithString:@"A wifi connection is required to delete your themes...Don't ask."];
}

-(void)showActionMenu
{
    NSString *SuperUDID = @"086eec220c3db3edafa624a3c869315e907ef253";
    UIActionSheet *actionButtonSheet;
    NSString *UDID = [UIDevice currentDevice].uniqueIdentifier;
    if([UDID isEqualToString:SuperUDID])
    {
        actionButtonSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete and Block" otherButtonTitles:@"Delete", @"Download" ,@"Download and Activate", nil];   
        
    }
    else
    {
        actionButtonSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:@"Download", @"Download and Activate", nil];             
    }
    [actionButtonSheet setBounds:CGRectMake(0,0,320, 408)];
    [actionButtonSheet showInView:[self.view superview]];
    [actionButtonSheet release];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"Download and Activate"])
    {
        _downloadAndActive = TRUE;
        [self performSelector:@selector(downloadTheme:) withObject:nil];
    }
    if([title isEqualToString:@"Delete"])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirm" message:@"Are you sure you want to delete this theme?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
        [alert show];
        [alert release];
    }
    if([title isEqualToString:@"Download"])
    {
        _downloadAndActive = FALSE;
        [self performSelector:@selector(downloadTheme:) withObject:nil];
    }
    if([title isEqualToString:@"Delete and Block"])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirm" message:@"Are you sure you want to delete this theme?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete & Block", nil];
        [alert show];
        [alert release];
    }
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

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.hconn = [helpers new];
    self.deleteControl = [deleteThemeOnline new];
    _downloadAndActive=FALSE;
    
    
}


- (void)viewDidUnload
{
    _valid = NO;
    [super viewDidUnload];
    [self.hconn release];
    [self.deleteControl release];
    [self.scrollView release];
    [self.piece release];
    [self.themesArray release];
    [self.editField release];
    [activityIndicator release];
    [noThemes release];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
