//
//  themeBrowserTVC.m
//  ClockBuilder
//
//  Created by Gustavo Tandeciarz on 4/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "themeBrowserTVCmine.h"
#import "ASICloudFilesRequest.h"
#import "ASICloudFilesObjectRequest.h"
#import "ASICloudFilesObject.h"
#import "UIImageView+WebCache.h"
#import "SDImageCache.h"
#import "JSON.h"



@implementation themeBrowserTVCmine

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        
        UIImageView *bg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
        [bg setImage:[UIImage imageNamed:@"fadedBG.JPG"]];
        [self.tableView setBackgroundColor:[UIColor clearColor]];
        [self.tableView setSeparatorColor:[UIColor clearColor]];
        [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self.tableView setBackgroundView:bg];
                
        [bg release];
        themesArray = [NSMutableArray new];
        themesAsDicts = [NSMutableArray new];
        
        [self.tableView setPagingEnabled:[[[NSUserDefaults standardUserDefaults] objectForKey:@"pagingEnabled"] boolValue]];
        [self.tableView setBounces:YES];
        
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"  style:UIBarButtonItemStyleBordered target:self action:@selector(exitModal)];
        self.navigationItem.leftBarButtonItem = doneButton;
        [doneButton release];
        
        UIBarButtonItem *actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(getThemesListInBG)];
        self.navigationItem.rightBarButtonItem = actionButton;
        [actionButton release];
        
        [self setTitle:@"My Uploads"];
    }
    return self;
}
- (void)dealloc
{
    [themesAsDicts release], themesAsDicts = nil;
    themesArray = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
    
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache clearMemory];
    [imageCache clearDisk];
    [imageCache cleanDisk];
    
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    hconn = [helpers new];
    deleteControl = [deleteThemeOnline new];
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicator.center = CGPointMake(self.view.center.x, self.view.center.y-80); 
    [self.view addSubview:activityIndicator];
    [activityIndicator startAnimating];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    hconn = nil;
    deleteControl = nil;
    activityIndicator = nil;
    selectedThemeName = nil;
    selectedCellIndex = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _showRefreshed = NO;
    _valid = YES;
    [self getThemesList];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    _valid = NO;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}
-(void) exitModal
{
    [[[UIApplication sharedApplication]delegate]performSelector:@selector(goBackToRootView)];
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
    return [themesArray count];
}
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    
    //if(searching)
      //  return nil;
    NSString *indexTitle = @"";
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    for(NSString *s in themesArray)
    {
        NSString *ssub = [[s substringToIndex:1] uppercaseString];
        if(![ssub isEqualToString:indexTitle]){
            indexTitle = ssub;
            [tempArray addObject:indexTitle];
        }
    }
    NSArray *retAr = [NSArray arrayWithArray:tempArray];
    [tempArray release];
    return retAr;
}
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    
   // if(searching)
   //     return -1;
    
    NSUInteger ind = 0;
    for(NSString *s in themesArray)
    {
        if([[[s uppercaseString] substringToIndex:1] isEqualToString:title])
        {
            if(ind==0)
                [self.tableView scrollRectToVisible:[[self.tableView tableHeaderView] bounds] animated:YES];
            else
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:ind inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
        else
            ind++;
    }
    
    return index;// % 2;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 372;//self.view.window.screen.bounds.size.height;//self.view.window.screen.scale * 64;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    themeBrowserCell *cell = (themeBrowserCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[themeBrowserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    // Configure the cell...
    
    [cell setCellData:[themesArray objectAtIndex:indexPath.row]];   
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedCellIndex = nil;
    selectedCellIndex = [indexPath retain];
    selectedThemeName = [themesArray objectAtIndex:selectedCellIndex.row];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [self performSelector:@selector(showActionMenu)];
}



#pragma mark - Themes Methods

-(void)getThemesListInBG
{
    
    [[UIApplication sharedApplication].delegate performSelector:@selector(playclicksoft)];
    _showRefreshed = YES;
    [self performSelector:@selector(getThemesList) withObject:nil];
    
}

- (NSString *)stringWithUrl:(NSURL *)url
{
    
	NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url
                                                cachePolicy:NSURLRequestReloadIgnoringCacheData
                                            timeoutInterval:30];
    // Fetch the JSON response
	NSData *urlData;
	NSURLResponse *response;
	NSError *error;
    // Make synchronous request
	urlData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
    
 	// Construct a String around the Data from the response
    NSString *ret = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
    NSString *val = [NSString stringWithString:ret];
    [ret release];
	return val;
}
- (NSArray *) objectWithUrl:(NSURL *)url
{
    SBJsonParser *jsonParser = [SBJsonParser new];
	NSString *jsonString = [self stringWithUrl:url];
    NSArray *json = (NSArray *)[jsonParser objectWithString:jsonString];
    [jsonParser release];
	return json;
}

-(void)finishedThemesListUpdate
{
    dispatch_sync(dispatch_get_main_queue(), ^(void) {    
        [self.tableView reloadData];
        [activityIndicator stopAnimating];
        [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];                    
        selectedThemeName = @"";
        if(_showRefreshed)
            [hconn showOverlay:@"Refreshed" iconImage:nil];
        [hconn unblockUI];     
        _themesListRefreshing = NO; 
    });
}

-(NSInteger)getThemesList
{    
    
    if(!_themesListRefreshing){
        _themesListRefreshing = YES;
        NSString *UDID = [UIDevice currentDevice].uniqueIdentifier;
        NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey];
        NSString *urlString = [NSString stringWithFormat:@"http://clockbuilder.gmtaz.com/getMyThemes.php?udid=%@&device=iPhone&api=SDFB52f4vw9230V45gdfg&v=%@",UDID, version];                   
        [hconn blockUIwithText:@"" showLoader:NO];
        [activityIndicator startAnimating];
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
        dispatch_async(queue, ^{
            if([hconn deviceIsConnectedToInet])
            {
                if(_valid){
                    
                    if([hconn checkAppVersion]){
                        [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:YES];   
                        NSURL *gmtaz = [NSURL URLWithString:urlString];
                        NSArray *themes = [NSArray arrayWithArray:[self objectWithUrl:gmtaz]];
                        [themesArray removeAllObjects];
                        [themesAsDicts removeAllObjects];          
                        for(NSDictionary *theme in themes)
                        {
                            [themesAsDicts addObject:theme];
                            [themesArray addObject:[theme objectForKey:@"themeName"]];
                        }                
                    }
                    else
                    {
                        [themesArray removeAllObjects];
                        [themesAsDicts removeAllObjects];       
                    }
                    [self finishedThemesListUpdate];
                    
                }
                
            }
            else{
                    dispatch_sync(dispatch_get_main_queue(), ^(void) { 
                    [hconn unblockUI];
                    if(_valid){ 
                        [hconn alertWithString:@"Internet connection not detected. Could not get online themes."];  
                        [activityIndicator stopAnimating];
                    }
                });
            }
            _themesListRefreshing = NO;
        });        
    }
    return  [themesArray count];
}

#pragma mark - Action Sheet

-(void)showActionMenu
{
    
    [[UIApplication sharedApplication].delegate performSelector:@selector(playclicksoft)];

    UIActionSheet *actionButtonSheet;
        actionButtonSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:@"Download", @"Download and Activate",@"Set Category", nil]; 
    [actionButtonSheet setBounds:CGRectMake(0,0,320, 408)];
    [actionButtonSheet showInView:[self.parentViewController.view superview]];
    [actionButtonSheet release];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [[UIApplication sharedApplication].delegate performSelector:@selector(playclicksoft)];

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
        if([title isEqualToString:@"Set Category"])
        {
            _downloadAndActive = FALSE;
            picker = [singleColumnPickerActionSheet new];
            [picker setDelegate:self];
            NSArray *cats = [NSArray arrayWithArray:[[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"] objectForKey:@"categoriesArray"]];
            [picker showWithTitle:@"Theme Category" andPickerList:cats];
        }
}

-(void)removeTheme:(NSString *)themeName
{
    NSString *retVal = [deleteControl deleteThemeFromCloud:[themesAsDicts objectAtIndex:selectedCellIndex.row]];
    if([retVal isEqualToString:@"Deleted"])
    {
        if(_valid)
        [hconn showOverlay:@"Deleted" iconImage:nil];
    }
    [themesArray removeObjectAtIndex:selectedCellIndex.row];
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:selectedCellIndex] withRowAnimation:UITableViewRowAnimationLeft];
    [self.tableView endUpdates];
    [self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.4];
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

-(void)saveThemeToLocal
{
    [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:YES];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(queue, ^{
    NSString *origName = selectedThemeName;
    NSString *localFolderName = origName;
    NSString *rackspace = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"] objectForKey:@"cloud"] objectForKey:@"themes"];
    NSString *thumbURL = [NSString stringWithFormat:@"%@/%@/themeScreenshot.jpg",rackspace,[origName lowercaseString]];
    NSString *plistURL = [NSString stringWithFormat:@"%@/%@/widgetsList.plist",rackspace,[origName lowercaseString]];
    NSString *bgURL = [NSString stringWithFormat:@"%@/%@/LockBackground.png",rackspace,[origName lowercaseString]];
        NSLog(@"thumb url: %@", thumbURL);
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
    
        
        dispatch_sync(dispatch_get_main_queue(), ^(void) {        
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
            if(_valid)
                [hconn showOverlay:@"Activated" iconImage:nil];
        }
        else if(_valid)
            [hconn showOverlay:@"Downloaded" iconImage:nil];
        });
    });
    
    
}

-(void)downloadTheme: (id)sender
{
    [sender setBackgroundColor:[UIColor colorWithRed:.1 green:.1 blue:.1 alpha:.3]];
    NSString *themeName = selectedThemeName;
    
    if([self performSelector:@selector(folderExists:) withObject:themeName])
    {
        [self performSelector:@selector(showAlertToSaveTheme)];
    }
    else
    {
        [self performSelector:@selector(saveThemeToLocal)];
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

#pragma mark - AlertView delegate

-(void) showAlertWithTextFieldAndTitle:(NSString *)alertTitle andMessage:(NSString *)message andConfirmButtonText:(NSString *)confirmText
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSString *alertMSG = [NSString stringWithFormat:@"%@\n\n\n" , message];
        UITextField *ef = [[UITextField alloc] initWithFrame:CGRectMake(16, 83, 252, 25)];
        if([message length]>34)
            [ef setFrame:CGRectMake(16, 100, 252, 25)];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:alertTitle
                                                       message:alertMSG
                                                      delegate:self
                                             cancelButtonTitle:@"Cancel"
                                             otherButtonTitles:confirmText,nil] ;
        // tagField.
        ef.backgroundColor = [UIColor whiteColor];
        ef.tag = 10;
        ef.borderStyle = UITextBorderStyleRoundedRect;
        ef.keyboardType = UIKeyboardTypeNamePhonePad;
        //[self.alert addTextFieldWithValue:@"" label:@"City Name or Zip"];
        [ef becomeFirstResponder];
        [ef setDelegate:self];
        [alert addSubview:ef];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 4.0) {
            CGAffineTransform moveUp = CGAffineTransformMakeTranslation(0, 90);
            [alert setTransform:moveUp];
        }
        [alert setTag:5];
        [alert show];
        [ef release];
        [alert release];
    });
    
}
-(void)saveThemeToLocalWithName:(NSString *)localFolderName
{    
    
    if([self performSelector:@selector(folderExists:) withObject:localFolderName])
    {
        [self performSelector:@selector(showAlertToSaveTheme)];
    }
    else
    {
        [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:YES];
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        dispatch_async(queue, ^{
            NSString *origName = selectedThemeName;
            NSString *rackspace = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"] objectForKey:@"cloud"] objectForKey:@"themes"];
            NSString *thumbURL = [NSString stringWithFormat:@"%@/%@/themeScreenshot.jpg",rackspace,[origName lowercaseString]];
            NSString *plistURL = [NSString stringWithFormat:@"%@/%@/widgetsList.plist",rackspace,[origName lowercaseString]];
            NSString *bgURL = [NSString stringWithFormat:@"%@/%@/LockBackground.png",rackspace,[origName lowercaseString]];
            NSLog(@"thumb url: %@", thumbURL);
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
            
            
            dispatch_sync(dispatch_get_main_queue(), ^(void) {        
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
                    if(_valid)
                        [hconn showOverlay:@"Activated" iconImage:nil];
                }
                else if(_valid)
                    [hconn showOverlay:@"Downloaded" iconImage:nil];
            });
        });
        
    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
	if([title isEqualToString:@"Delete"])
	{
        NSString *themeName = selectedThemeName;
        // if([hconn isConnectionWifi]){
        NSString *UDID = [UIDevice currentDevice].uniqueIdentifier;
        NSLog(@"%@",[themesAsDicts objectAtIndex:selectedCellIndex.row ]);
        NSLog(@"selected index %i", selectedCellIndex.row);
        NSLog(@"sim udid: %@ | %@", UDID, [[themesAsDicts objectAtIndex:selectedCellIndex.row ] objectForKey:@"udid"]);        
        NSString *SuperUDID = [[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"] objectForKey:@"gmtUDID"];
        if([UDID isEqualToString:[[themesAsDicts objectAtIndex:selectedCellIndex.row ] objectForKey:@"udid"]] ||
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
	}
    
    if([title isEqualToString:@"Delete & block"])
    {       
        if([hconn isConnectionWifi]){            
            NSString *retVal = [deleteControl deleteThemeAndBlock:[themesAsDicts objectAtIndex:selectedCellIndex.row]];
            if([retVal isEqualToString:@"Device Blacklisted"])
            {
                [hconn showOverlay:@"Device Blacklisted" iconImage:nil];
            }
        }
        else
            [hconn alertWithString:@"Wifi connection required"];
    }
    
	if([title isEqualToString:@"Overwrite"])
	{
		[self performSelector:@selector(saveThemeToLocal) ];
	}
    else if([title isEqualToString:@"Rename"])
    {
        
        [self showAlertWithTextFieldAndTitle:@"Save As" andMessage:@"Please enter a new name" andConfirmButtonText:@"OK"];   
    }
    
	else if([title isEqualToString:@"OK"])
	{
        NSString *textFieldString = @"";
        for(UIView *subview in [alertView subviews])
        {
            if([subview class]==[UITextField class])
            {
                textFieldString = [(UITextField*)subview text];                                            
            }
        }
        
        NSString *fieldVal = textFieldString;
        if(fieldVal != nil && ![fieldVal isEqualToString:@""]) {
            [self performSelector:@selector(saveThemeToLocalWithName:) withObject:fieldVal];
        }
        else
        {
            [self showAlertWithTextFieldAndTitle:@"Error" andMessage:@"The name cannot be blank" andConfirmButtonText:@"OK"];            
        }
	}
}

// You can add/tailor the acceptable values here...
#define CHARACTERS          @" ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-_1234567890"

/*---------------------------------------------------
 * Called whenever user enters/deletes character
 *--------------------------------------------------*/
- (BOOL)textField:(UITextField *)textField 
shouldChangeCharactersInRange:(NSRange)range 
replacementString:(NSString *)string
{
    // These are the characters that are ~not~ acceptable
    NSCharacterSet *unacceptedInput =
    [[NSCharacterSet characterSetWithCharactersInString:CHARACTERS] invertedSet];
    
    // Create array of strings from incoming string using the unacceptable
    // characters as the trigger of where to split the string.
    // If array has more than one entry, there was at least one unacceptable character
    if ([[string componentsSeparatedByCharactersInSet:unacceptedInput] count] > 1)
        return NO;
    else 
        return YES;
}
#pragma mark - Cloud Actions

- (void) setCategory:(NSString *)cat forTheme:(NSString *)themeName
{
    NSString *urlString = [NSString stringWithFormat:@"http://clockbuilder.gmtaz.com/updateCategory.php?device=iPhone&api=SDFB52f4vw9230V45gdfg&themeName=%@&cat=%@", themeName,cat];                   
    [hconn blockUIwithText:@"" showLoader:NO];
    [activityIndicator startAnimating];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        if([hconn deviceIsConnectedToInet])
        {
            if(_valid){
                [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:YES];   
                NSURL *gmtaz = [NSURL URLWithString:urlString];
                NSString *response = [self stringWithUrl:gmtaz];
                
                dispatch_sync(dispatch_get_main_queue(), ^(void) { 
                    [activityIndicator stopAnimating];
                    [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];   
                    if([response isEqualToString:@"success"])
                        [hconn showOverlay:@"Category Set" iconImage:nil];
                    else
                        [hconn showOverlay:@"Error" iconImage:[UIImage imageNamed:@"errorX.png"]];
                    [hconn unblockUI];
                });
                
            }
            
        }
        else{
            [hconn unblockUI];
            if(_valid){ 
                [hconn alertWithString:@"Internet connection not detected. Could not get online themes."];  
                [activityIndicator stopAnimating];
            }
        }
    });
}

- (void)singleColumnPickerActionSheet:(singleColumnPickerActionSheet *)pickerActionSheet didSelectItem:(NSString *)selectedItem
{
    [self setCategory:selectedItem forTheme:selectedThemeName];
    [picker release], picker = nil;
}


@end
