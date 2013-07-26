//
//  GMTHelper.m
//  ClockBuilder
//
//  Created by Gustavo Tandeciarz on 4/28/12.
//  Copyright (c) 2012 GMTAZ.com. All rights reserved.
//

#import "GMTHelper.h"
#import <QuartzCore/QuartzCore.h>
#import "CBThemeHelper.h"
#import "CoreTheme.h"
#import "CoreThemeiPad.h"

@interface CustomAlert : UIAlertView


@end

@implementation CustomAlert

- (void)layoutSubviews
{
	for (UIView *subview in self.subviews){ //Fast Enumeration
		//NSLog(@"subview class :%@",[subview class]); //Get Class Description of Each Subview
		//NSLog(@"subview.tag %i",subview.tag); //Get Button Tags
		
		if ([subview isMemberOfClass:[UIImageView class]]) { //Find UIImageView Containing Blue Background
			subview.hidden = YES; //Hide UIImageView Containing Blue Background
            // [subview removeFromSuperview]; Also Works
		}
        
		if ([subview isMemberOfClass:[UILabel class]]) { //Point to UILabels To Change Text
			UILabel *label = (UILabel*)subview;	//Cast From UIView to UILabel
			label.textColor = [UIColor colorWithRed:210.0f/255.0f green:210.0f/255.0f blue:210.0f/255.0f alpha:1.0f];
			label.shadowColor = [UIColor blackColor];
			label.shadowOffset = CGSizeMake(0.0f, 1.0f);
            [label setAdjustsFontSizeToFitWidth:YES];
		}
	}
}

- (void)drawRect:(CGRect)rect 
{
	//////////////GET REFERENCE TO CURRENT GRAPHICS CONTEXT
	CGContextRef context = UIGraphicsGetCurrentContext();
	
    //////////////CREATE BASE SHAPE WITH ROUNDED CORNERS FROM BOUNDS
	CGRect activeBounds = self.bounds;
	CGFloat cornerRadius = 10.0f;	
	CGFloat inset = 6.5f;	
	CGFloat originX = activeBounds.origin.x + inset;
	CGFloat originY = activeBounds.origin.y + inset;
	CGFloat width = activeBounds.size.width - (inset*2.0f);
	CGFloat height = activeBounds.size.height - (inset*2.0f);
    
	CGRect bPathFrame = CGRectMake(originX, originY, width, height);
    CGPathRef path = [UIBezierPath bezierPathWithRoundedRect:bPathFrame cornerRadius:cornerRadius].CGPath;
	
	//////////////CREATE BASE SHAPE WITH FILL AND SHADOW
	CGContextAddPath(context, path);
	CGContextSetFillColorWithColor(context, [UIColor colorWithRed:210.0f/255.0f green:210.0f/255.0f blue:210.0f/255.0f alpha:1.0f].CGColor);
	CGContextSetShadowWithColor(context, CGSizeMake(0.0f, 1.0f), 6.0f, [UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:1.0f].CGColor);
    CGContextDrawPath(context, kCGPathFill);
	
	//////////////CLIP STATE
	CGContextSaveGState(context); //Save Context State Before Clipping To "path"
	CGContextAddPath(context, path);
	CGContextClip(context);
	
	//////////////DRAW GRADIENT
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	size_t count = 3;
	CGFloat locations[3] = {0.0f, 0.57f, 1.0f}; 
	CGFloat components[12] = 
	{	70.0f/255.0f, 70.0f/255.0f, 70.0f/255.0f, 1.0f,     //1
		55.0f/255.0f, 55.0f/255.0f, 55.0f/255.0f, 1.0f,     //2
		40.0f/255.0f, 40.0f/255.0f, 40.0f/255.0f, 1.0f};	//3
	CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, count);
    
	CGPoint startPoint = CGPointMake(activeBounds.size.width * 0.5f, 0.0f);
	CGPoint endPoint = CGPointMake(activeBounds.size.width * 0.5f, activeBounds.size.height);
    
	CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
	CGColorSpaceRelease(colorSpace);
	CGGradientRelease(gradient);
	
	//////////////HATCHED BACKGROUND
    CGFloat buttonOffset = activeBounds.size.height-65.5f;//92.5f; //Offset buttonOffset by half point for crisp lines
	CGContextSaveGState(context); //Save Context State Before Clipping "hatchPath"
	CGRect hatchFrame = CGRectMake(0.0f, buttonOffset, activeBounds.size.width, (activeBounds.size.height - buttonOffset+1.0f));
	CGContextClipToRect(context, hatchFrame);
	
	CGFloat spacer = 4.0f;
	int rows = (activeBounds.size.width + activeBounds.size.height/spacer);
	CGFloat padding = 0.0f;
	CGMutablePathRef hatchPath = CGPathCreateMutable();
	for(int i=1; i<=rows; i++) {
		CGPathMoveToPoint(hatchPath, NULL, spacer * i, padding);
		CGPathAddLineToPoint(hatchPath, NULL, padding, spacer * i);
	}
	CGContextAddPath(context, hatchPath);
	CGPathRelease(hatchPath);
	CGContextSetLineWidth(context, 1.0f);
	CGContextSetLineCap(context, kCGLineCapRound);
	CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:0.15f].CGColor);
	CGContextDrawPath(context, kCGPathStroke);
	CGContextRestoreGState(context); //Restore Last Context State Before Clipping "hatchPath"
	
	//////////////DRAW LINE
	CGMutablePathRef linePath = CGPathCreateMutable(); 
	CGFloat linePathY = (buttonOffset - 1.0f);
	CGPathMoveToPoint(linePath, NULL, 0.0f, linePathY);
	CGPathAddLineToPoint(linePath, NULL, activeBounds.size.width, linePathY);
	CGContextAddPath(context, linePath);
	CGPathRelease(linePath);
	CGContextSetLineWidth(context, 1.0f);
	CGContextSaveGState(context); //Save Context State Before Drawing "linePath" Shadow
	CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:0.6f].CGColor);
	CGContextSetShadowWithColor(context, CGSizeMake(0.0f, 1.0f), 0.0f, [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.2f].CGColor);
	CGContextDrawPath(context, kCGPathStroke);
	CGContextRestoreGState(context); //Restore Context State After Drawing "linePath" Shadow
    
	
	//////////////STROKE PATH FOR INNER SHADOW
	CGContextAddPath(context, path);
	CGContextSetLineWidth(context, 3.0f);
	CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:210.0f/255.0f green:210.0f/255.0f blue:210.0f/255.0f alpha:1.0f].CGColor);
	CGContextSetShadowWithColor(context, CGSizeMake(0.0f, 0.0f), 6.0f, [UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:1.0f].CGColor);
	CGContextDrawPath(context, kCGPathStroke);
    
	//////////////STROKE PATH TO COVER UP PIXILATION ON CORNERS FROM CLIPPING
    CGContextRestoreGState(context); //Restore First Context State Before Clipping "path"
	CGContextAddPath(context, path);
	CGContextSetLineWidth(context, 3.0f);
	CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:210.0f/255.0f green:210.0f/255.0f blue:210.0f/255.0f alpha:1.0f].CGColor);
	CGContextSetShadowWithColor(context, CGSizeMake(0.0f, 0.0f), 0.0f, [UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:0.1f].CGColor);
	CGContextDrawPath(context, kCGPathStroke);
	
}

@end






@interface GMTHelper ()
{
    
    int alertType;
    //theme processors
    NSURL *cbThemeURL;
    BOOL overwrite;
    BOOL _alertToSaveShowing;
    
}
- (void)processThemeFile;
- (NSDictionary *)downloadPlist:(NSString *)url;
- (NSData *)downloadImageFrom:(NSString *)url;
@end

@implementation GMTHelper

static GMTHelper *sharedInstance = nil;
static dispatch_queue_t serialQueue;

+ (id)allocWithZone:(NSZone *)zone {
    static dispatch_once_t onceQueue;    
    
    dispatch_once(&onceQueue, ^{
        serialQueue = dispatch_queue_create("com.gmtaz.Clockbuilder.GMTHelper.SerialQueue", NULL);        
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
        }
    });
    
    return sharedInstance; 
}


+ (GMTHelper*)sharedInstance;
{
    static dispatch_once_t onceQueue;    
    
    dispatch_once(&onceQueue, ^{
        sharedInstance = [[GMTHelper alloc] init];
    });
    
    return sharedInstance;
}
- (id)init {
    id __block obj;
    
    dispatch_sync(serialQueue, ^{
        obj = [super init];
        if (obj) {
            //Set variables here
            
        }
    });
    
    self = obj;
    return self;
}

-(int)iOSMajorVersion{
    NSArray *versionCompatibility = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    return [[versionCompatibility objectAtIndex:0] intValue];
}

-(BOOL)checkIfJB
{
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *cydiaDirPath = @"/Applications/Cydia.app";
    BOOL exists = [fm fileExistsAtPath:cydiaDirPath];
    if(exists)
    {
        //[TestFlight passCheckpoint:@"Checkpoint 1: fileexistsatpath"];
    }
    else {
        NSError *err;
        NSArray *contents = [fm contentsOfDirectoryAtPath:@"/Applications" error:&err];
        if(contents){
            //TFLog(@"Applications: %@",contents);
            for (NSString *fileName in contents) {
                if([fileName isEqualToString:@"Cydia.app"]){
                    exists = YES;
                    //[TestFlight passCheckpoint:@"Checkpoint 2: /Applications/[Contents]"];
                    break;
                }
            }
        }
        else {
            //TFLog(@"Error checking Checkpoint1/2: %@", err);
        }
    }
    return exists;
}
-(NSString *)getGMTSyncVersion{
    return @"1.1-3";
}

//////////////////////////////////////////////////////////////////////////////////////
#pragma mark inet methods
//////////////////////////////////////////////////////////////////////////////////////
-(BOOL)deviceIsConnectedToInet
{
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSString *hostName = @"clockbuilder.gmtaz.com";
    
    NSURLResponse *response;
    NSError *error;
    
    NSString *urlString = [NSString stringWithFormat:@"http://%@", hostName];
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:8.0];
    
    [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&response error:&error];
    
    if(response != nil)
    {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        return YES;
    }
    else
    {
        NSLog(@"SNNetworkController.isHostAvailable %@ %@", response, error);
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        return NO;
    }   
    
    //check for IP
    
    
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, [hostName cStringUsingEncoding:NSASCIIStringEncoding]);
    SCNetworkReachabilityFlags flags;
    BOOL success = SCNetworkReachabilityGetFlags(reachability, &flags);
    if(reachability)
        CFRelease(reachability);
    
    if( (success && (flags & kSCNetworkFlagsReachable) && !(flags & kSCNetworkFlagsConnectionRequired) ) == NO){
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        return NO;
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    return YES;
    
}

-(BOOL)isConnectionWifi
{    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSString *hostName = @"clockbuilder.gmtaz.com";
    
    NSURLResponse *response;
    NSError *error;
    
    NSString *urlString = [NSString stringWithFormat:@"http://%@", hostName];
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:8.0];
    
    [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&response error:&error];
    
    if(response != nil)
    {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
    else
    {
        NSLog(@"SNNetworkController.isHostAvailable %@ %@", response, error);
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        return NO;
    }   
    Reachability *wifiReach = [Reachability reachabilityForInternetConnection];
    NetworkStatus netStatus = [wifiReach currentReachabilityStatus];
    
    switch (netStatus)
    {
        case NotReachable:
        {
            return false;
            break;
        }
        case ReachableViaWWAN:
        {
            return false;
            break;
        }
        case ReachableViaWiFi:
        {
            return true;
            break;
        } 
    }
    return false;
    
}

//////////////////////////////////////////////////////////////////////////////////////
#pragma mark alert methods
//////////////////////////////////////////////////////////////////////////////////////

-(void)alertWithString:(NSString *)string{
    CustomAlert *alert = [[CustomAlert alloc] initWithTitle:@"Warning" message:string delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    _alertToSaveShowing = NO;
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    NSLog(@"title: %@", title);
    if(alertType !=1){
        if([title isEqualToString:@"Ok"]){
            
        }
        /*
        else if([title isEqualToString:@"Get it"]){
            NSString *url = [[NSUserDefaults standardUserDefaults] objectForKey:@"lssyncurl"];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString: url]];
        }
        else if([title isEqualToString:@"Got it"]){
            [[NSUserDefaults standardUserDefaults] setObject:@"no" forKey:@"showTetheredFixAlert"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        else{}*/
    }
    if(alertType == 1){
        if([title isEqualToString:@"Save"])
        {
            dispatch_sync(serialQueue, ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[GMTHelper sharedInstance] notifyToShowGlobalHudWithSpinner:@"Saving..." andHide:YES withDelay:10 andDim:YES];
                });
                
                NSMutableDictionary *themeDict = [NSMutableDictionary dictionaryWithDictionary:[NSKeyedUnarchiver unarchiveObjectWithFile:cbThemeURL.path]];
                if(themeDict.count > 0){
                    //check if theme with same name already exists    
                    [CBThemeHelper saveThemeToCoreDataFromEmailWithDict:themeDict];
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSLog(@"error getting theme contents");
                        [[GMTHelper sharedInstance] notifyToShowGlobalHudWithSpinner:@"Error" andHide:YES withDelay:3 andDim:NO];
                    });
                }
                
                NSError *deleteImportedFileError;
                if(![[NSFileManager defaultManager] removeItemAtURL:cbThemeURL error:&deleteImportedFileError])
                {
                    NSLog(@"failed to delete inbox file with error: %@",deleteImportedFileError.localizedDescription);
                }
                cbThemeURL = nil;
                
            });
        }
        else
        {
            cbThemeURL = nil;
        }
    }
}


-(void)alertNotConnected
{
    CustomAlertView *alert = [[CustomAlertView alloc] initWithTitle:@"Warning" message:@"An internet connection is required for this application to function properly" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

//////////////////////////////////////////////////////////////////////////////////////
#pragma mark version methods
//////////////////////////////////////////////////////////////////////////////////////
-(BOOL)checkAppVersionNoAlert
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey];
    NSString *versionCheck = [NSString stringWithFormat:@"http://clockbuilder.gmtaz.com/versioncheck.php?v=%@", version]; 
    NSURL *vurl = [NSURL URLWithString:versionCheck];
    NSError *err;
    NSString *versionResponse = [NSString stringWithContentsOfURL:vurl encoding:NSUTF8StringEncoding error:&err];
    if(versionResponse == nil){
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        NSLog(@"error checking app version: %@", err);
        return YES;
    }
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    if([versionResponse isEqualToString:@"OK"])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}
-(BOOL)checkAppVersion
{
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey];
    NSString *versionCheck = [NSString stringWithFormat:@"http://clockbuilder.gmtaz.com/versioncheck.php?v=%@", version]; 
    NSURL *vurl = [NSURL URLWithString:versionCheck];
    NSString *versionResponse = [NSString stringWithContentsOfURL:vurl encoding:NSUTF8StringEncoding error:nil];
    if([versionResponse isEqualToString:@"OK"])
    {
        return YES;
    }
    else
    {
        //dispatch_sync(dispatch_get_main_queue(), ^(void) {  
        [self performSelectorOnMainThread:@selector(alertWithString:) withObject:versionResponse waitUntilDone:YES];
        //});
        return NO;
    }
}


//////////////////////////////////////////////////////////////////////////////////////
#pragma mark HUD methods
//////////////////////////////////////////////////////////////////////////////////////

-(void)showOverlay:(NSString *)message iconImage:(UIImage*)image{
    
    [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];

    UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"doneCheck.png"]];
    if (image) {
        [iv setImage:image];
    }
    [self notifyToShowGlobalHudWithDict:[self buildDictForHUDWithLabelText:message andImage:iv andHide:YES withDelay:.8 andDim:NO]];
}


//////////////////////////////////////////////////////////////////////////////////////
#pragma mark File Processing methods
//////////////////////////////////////////////////////////////////////////////////////

- (void)processThemeFile
{
    BOOL renameTheme = NO;
    _alertToSaveShowing = NO;
    if(cbThemeURL){
        
        NSString *themesPath = [CBThemeHelper getThemesPath].path;
        NSFileManager *fM = [NSFileManager defaultManager];
        NSArray *fileList = [fM contentsOfDirectoryAtPath:themesPath error:nil];
        for(NSString *file in fileList) {
            NSLog(@"Dir Folder: %@",file);
            NSString *path = [themesPath stringByAppendingPathComponent:file];
            BOOL isDir;
            [fM fileExistsAtPath:path isDirectory:(&isDir)];
            if(!isDir) {
                if([file isEqualToString:[CBThemeHelper getFileNameFromURL:cbThemeURL]])
                {
                    renameTheme = YES;
                    break;
                }
            }
        }
        
        if(!renameTheme || overwrite)
        {
            
            //if(!overwrite){
            dispatch_sync(serialQueue, ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[GMTHelper sharedInstance] notifyToShowGlobalHudWithSpinner:@"Saving..." andHide:YES withDelay:10 andDim:YES];
                });
                NSDictionary *themeDict = [NSKeyedUnarchiver unarchiveObjectWithFile:cbThemeURL.path];
                //NSLog(@"themeDict for saving: %@",themeDict);
                //BACKWARDS COMPATIBILITY CHECK
               // NSLog(@"themeDict class: %@", themeDict.class);
                
                if([themeDict class] == [NSFileWrapper class]){
                    //open nsfilewrapper
                    NSFileWrapper *legacyTheme = [NSKeyedUnarchiver unarchiveObjectWithFile:cbThemeURL.path];
                    //NSLog(@"filewrappers: %@",[legacyTheme fileWrappers]);
                    NSFileWrapper *widgets = [[legacyTheme fileWrappers] objectForKey:@"widgetsList.plist"];
                    //NSLog(@"widgets class: %@", [[widgets regularFileContents]class]);
                    //testing
                    
                    NSString *tempDir = NSTemporaryDirectory();
                    NSLog(@"%@",tempDir);
                    [[widgets regularFileContents] writeToFile:[tempDir stringByAppendingPathComponent:@"testing.plist"] atomically:NO];
                    NSArray *widgetsListArray = [NSArray arrayWithContentsOfFile:[tempDir stringByAppendingPathComponent:@"testing.plist"]];                    
                    NSMutableDictionary *tempDict = [NSMutableDictionary new];
                    [tempDict setObject:widgetsListArray forKey:@"widgetsList.plist"];
                    //NSLog(@"tempDict: %@", tempDict);
                    [tempDict setObject:[[[legacyTheme fileWrappers] objectForKey:@"themeScreenshot.jpg"]regularFileContents] forKey:@"themeScreenshot.jpg"];
                    [tempDict setObject:[[[legacyTheme fileWrappers] objectForKey:@"LockBackground.png"]regularFileContents] forKey:@"LockBackground.png"];
                    
                    //NSLog(@"tempDict: %@", tempDict);
                    
                    themeDict = [NSDictionary dictionaryWithDictionary:tempDict];
                    //try background and screenshot
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [CBThemeHelper saveThemeNamed:[[CBThemeHelper getFileNameFromURL:cbThemeURL] stringByReplacingOccurrencesOfString:@".cbTheme" withString:@""] withDict:themeDict];
                        //[[GMTHelper sharedInstance] notifyToHideGlobalHud];
                        NSError *deleteImportedFileError;
                        if(![fM removeItemAtURL:cbThemeURL error:&deleteImportedFileError])
                        {
                            NSLog(@"failed to delete inbox file with error: %@",deleteImportedFileError.localizedDescription);
                        }
                        cbThemeURL = nil;
                    });
                    
                }
                else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [CBThemeHelper saveThemeNamed:[[CBThemeHelper getFileNameFromURL:cbThemeURL] stringByReplacingOccurrencesOfString:@".cbTheme" withString:@""] withDict:themeDict];
                        NSError *deleteImportedFileError;
                        if(![fM removeItemAtURL:cbThemeURL error:&deleteImportedFileError])
                        {
                            NSLog(@"failed to delete inbox file with error: %@",deleteImportedFileError.localizedDescription);
                        }
                        cbThemeURL = nil;
                        //[[GMTHelper sharedInstance] notifyToHideGlobalHud];
                    });
                }
                
                //}
            });
            
            
        }
        else
        {
            alertType = 1;
            
            CustomAlert *alert = [[CustomAlert alloc] initWithTitle:@"Overwrite?" message:@"A theme with this name already exists.  Would you like to overwrite this theme?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Overwrite",nil];
            [alert show];
        }
    }
}
- (void)processIncomingFileURL:(NSURL *)url
{
    if(!_alertToSaveShowing){
        alertType = 1;
        _alertToSaveShowing = YES;
        cbThemeURL = url;
               
        CustomAlert *tp = [[CustomAlert alloc] initWithTitle:@"Theme Importer" 
                                                             message:@"Would you like to save this theme?" 
                                                            delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
        
        [tp show];
        
    }
}


//////////////////////////////////////////////////////////////////////////////////////
#pragma mark Settings methods
//////////////////////////////////////////////////////////////////////////////////////

-(BOOL)prefers24Hour
{    
    BOOL mt = [[[NSUserDefaults standardUserDefaults] objectForKey:@"militaryTime"] boolValue];
    return mt;
}

-(BOOL)parallaxEnabled
{    
    BOOL mt = [[[NSUserDefaults standardUserDefaults] objectForKey:@"parallaxEnabled"] boolValue];
    return mt;
}
-(BOOL)shadowAdjust
{    
    BOOL mt = [[[NSUserDefaults standardUserDefaults] objectForKey:@"adjustShadowForStatusBar"] boolValue];
    return mt;
}
-(BOOL)setWallpaper
{
    BOOL mt = [[[NSUserDefaults standardUserDefaults] objectForKey:@"setWallpaper"] boolValue];
    return mt;
}
-(BOOL)rotateWallpaper
{
    BOOL mt = [[[NSUserDefaults standardUserDefaults] objectForKey:@"rotateWallpaper"] boolValue];
    return mt;
}

//////////////////////////////////////////////////////////////////////////////////////
#pragma mark Update Local Resources methods
//////////////////////////////////////////////////////////////////////////////////////
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
	return val;
}
- (NSArray *) objectWithUrl:(NSURL *)url
{
    SBJsonParser *jsonParser = [SBJsonParser new];
	NSString *jsonString = [self stringWithUrl:url];
    NSArray *json = (NSArray *)[jsonParser objectWithString:jsonString];
	return json;
}

-(NSArray *)updateCategoriesArrayFromOnline{
    
    NSMutableSet *catArray;
    if ([self deviceIsConnectedToInet]) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        NSString *catURL = @"http://clockbuilder.gmtaz.com/getCategories.php?api=SDFB52f4vw9230V45gdfg"; 
        catArray = [NSMutableSet setWithArray:[NSArray arrayWithArray:[self objectWithUrl:[NSURL URLWithString:catURL]]]];

        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    }
    else {
        //[self alertNotConnected];
        NSMutableDictionary * settingsD = [kDataSingleton getSettings];
        catArray = [NSMutableSet setWithArray:[NSArray arrayWithArray:[settingsD objectForKey:@"categoriesArray"]]];
    }
#ifdef DEBUG
    [catArray addObject:@"Flagged"];
#endif
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"description" ascending:YES];
    NSArray *sortedArray = [catArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
    NSMutableDictionary * settingsD = [kDataSingleton getSettings];
    [settingsD setObject:sortedArray forKey:@"categoriesArray"];
    return sortedArray;
}
-(NSArray *)getCategoriesArray{
    
    NSMutableSet *catArray;
    NSMutableDictionary * settingsD = [kDataSingleton getSettings];
    catArray = [NSMutableSet setWithArray:[NSArray arrayWithArray:[settingsD objectForKey:@"categoriesArray"]]];
    if(catArray==nil || catArray.count <6){
        return [self updateCategoriesArrayFromOnline];
    }
    else {
#ifdef DEBUG
        [catArray addObject:@"-Flagged"];
        [catArray addObject:@"-New Themes"];
#endif
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"description" ascending:YES];
        NSArray *sortedArray = [catArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
        
        return sortedArray;
    }
}


//////////////////////////////////////////////////////////////////////////////////////
#pragma mark Theme Downloading methods
//////////////////////////////////////////////////////////////////////////////////////


- (NSDictionary *)downloadPlist:(NSString *)url {
    NSMutableURLRequest *request  = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10]; 
    NSURLResponse *resp = nil;
    NSError *err = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&resp error:&err];
    
    if (!err) {
        NSString *errorDescription = nil;
        NSPropertyListFormat format;
        NSDictionary *samplePlist = [NSPropertyListSerialization propertyListFromData:responseData mutabilityOption:NSPropertyListImmutable format:&format errorDescription:&errorDescription];
        
        if (!errorDescription)
            return samplePlist;
        
    }
    
    return nil;
}
- (NSData *)downloadImageFrom:(NSString *)url {
    NSMutableURLRequest *request  = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10]; 
    NSURLResponse *resp = nil;
    NSError *err = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&resp error:&err];
    
    if (!err) {
        return responseData;
    }
    
    return nil;
}

-(void)downloadThemeNamed:(NSString *)themeNameToDownload withName:(NSString *)inputString{
        
    NSString *themeURLString = [NSString stringWithFormat:@"http://clockbuilder.gmtaz.com/resources/themes/%@/",themeNameToDownload];
    NSString *saveAsName = inputString;
    //FILES: LockBackground.png - themeScreenshot.jpg - widgetsList.plist
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: YES];
        [[GMTHelper sharedInstance] notifyToShowGlobalHudWithDict:[[GMTHelper sharedInstance] buildDictForHUDWithLabelText:@"Download Started..." andImage:nil andHide:YES withDelay:0.5 andDim:NO]];
    });
    dispatch_async(dispatch_queue_create("com.gmtaz.Clockbuilder.DownloadingTheme", NULL), ^{
        NSData *lockbackgroundData = [self downloadImageFrom:[themeURLString stringByAppendingString:@"LockBackground.png"]];
        NSData *themeScreenshotData = [self downloadImageFrom:[themeURLString stringByAppendingString:@"themeScreenshot.jpg"]];
        NSDictionary *widgetList = [self downloadPlist:[themeURLString stringByAppendingString:@"widgetsList.plist"]];
        //save data
        if(widgetList!=nil && themeScreenshotData!=nil && lockbackgroundData!=nil){
            NSMutableDictionary *wListMutable = [widgetList mutableCopy];  
            NSMutableDictionary *themeDict = [[NSMutableDictionary alloc] init];
            [themeDict setObject:lockbackgroundData forKey:@"LockBackground.png"];
            [themeDict setObject:themeScreenshotData forKey:@"themeScreenshot.jpg"];
            [themeDict setObject:wListMutable forKey:@"widgetsList"];
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [CBThemeHelper saveThemeNamed:saveAsName withDict:themeDict];
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
            });     
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                NSDictionary *errorDict  =[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Theme Download Error", themeNameToDownload, nil] forKeys:[NSArray arrayWithObjects:@"errorType", @"errorText", nil]];
                [[GMTHelper sharedInstance] reportError:errorDict];
                [[GMTHelper sharedInstance] alertWithString:@"There was an error downloading the theme. Support has been notified."];
                
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
            });     
        }
    });
}



//////////////////////////////////////////////////////////////////////////////////////
#pragma mark Error Reporting methods
//////////////////////////////////////////////////////////////////////////////////////
-(void)reportError:(NSDictionary *)errorDict{
    /*
    NSString *errorType = [errorDict objectForKey:@"errorType"];
    NSString *errorText = [errorDict objectForKey:@"errorText"];
    PFObject *testObject = [PFObject objectWithClassName:@"ErrorReports"];
    [testObject setObject:errorType forKey:@"ErrorType"];
    [testObject setObject:errorText forKey:@"ErrorText"];
    [testObject save];
     */
}

-(void)notifyToShowGlobalHudWithDict:(NSDictionary *)userInfo{
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowGlobalHud object:nil userInfo:userInfo];
}
-(void)notifyToHideGlobalHud{
    [[NSNotificationCenter defaultCenter] postNotificationName:kHideGlobalHud object:nil];
}
-(void)notifyToShowGlobalHudWithSpinner:(NSString *)labelText andHide:(BOOL)hide withDelay:(float)delay andDim:(BOOL)dim{
    
    NSMutableDictionary *dict = [NSMutableDictionary new];
    if(labelText)
        [dict setObject:labelText forKey:@"labelText"];
    if(hide)
        [dict setObject:@"YES" forKey:@"hide"];
    if(delay)
        [dict setObject:[NSString stringWithFormat:@"%f",delay] forKey:@"delay"];
    if(dim)
        [dict setObject:@"YES" forKey:@"dim"];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithDictionary:dict];
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowGlobalHudWithSpinner object:nil userInfo:userInfo];
}
-(NSDictionary *)buildDictForHUDWithLabelText:(NSString *)labelText andImage:(UIImageView *)imageView andHide:(BOOL)hide withDelay:(float)delay andDim:(BOOL)dim{
    
    NSMutableDictionary *dict = [NSMutableDictionary new];
    if(labelText)
        [dict setObject:labelText forKey:@"labelText"];
    if(imageView)
        [dict setObject:imageView forKey:@"imageView"];
    if(hide)
        [dict setObject:@"YES" forKey:@"hide"];
    if(delay)
        [dict setObject:[NSString stringWithFormat:@"%f",delay] forKey:@"delay"];
    if(dim)
        [dict setObject:@"YES" forKey:@"dim"];
    
    NSDictionary *retDict = [NSDictionary dictionaryWithDictionary:dict];
    return retDict;
    
}

UIImage * resizeImageTo1xHelper(UIImage * img, CGSize newSize){
    UIGraphicsBeginImageContext(newSize);
    
    //or other CGInterpolationQuality value
    CGContextSetInterpolationQuality(UIGraphicsGetCurrentContext(), kCGInterpolationDefault);
    
    [img drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
-(CGSize)getTargetSizeForImageAtScale:(int)scale{
    
    float width = [UIScreen mainScreen].bounds.size.width *scale;
    float height = [UIScreen mainScreen].bounds.size.height *scale;
    if(kIsIpad){
        width = 1024 *scale;
        height = 1024 *scale;
    }
    NSLog(@"target size: %f x %f", width, height);
    return CGSizeMake( width,
                      height);
    
}
-(UIImage *)resizeImageForSync:(UIImage *)image{
    if (image != nil) {
        // the path to write file
		
		UIImage *sourceImage = image;
		UIImage *newImage = nil;
		CGSize imageSize = sourceImage.size;
                
		CGSize targetSize = [self getTargetSizeForImageAtScale:1];
        if(kIsIpad){
            targetSize = [self getTargetSizeForImageAtScale:2]; //always save hi-res for retina iPad - down convert if non-retina when activating
        }
        else{
            if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
                if ((NSInteger)[[UIScreen mainScreen] scale] == 2) {
                    targetSize = [self getTargetSizeForImageAtScale:2];
                }
            }
        }
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
		
        return newImage;
        
	}
    return nil;
    
    
}
-(BOOL)resizeImageToWallpaper:(UIImage *)image
{
    // NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    //problems here (memory leaks)
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	if (image != nil) {
        // the path to write file
		
		UIImage *sourceImage = image;
		UIImage *newImage = nil;
		newImage = [self resizeImageForSync:sourceImage];
		if(newImage == nil)
			NSLog(@"could not scale image");
		else {
			[self saveWallpaperThumb:newImage];
			//pop the context to get back to the default
			UIGraphicsEndImageContext();
			//UIImage *bg = [newImage resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:croppedSize interpolationQuality:1.0];
            NSData *newImageData;
            
            
            NSString *appFilePNG = [documentsDirectory stringByAppendingPathComponent:@"Wallpaper.png"];
            
            if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
                if ((NSInteger)[[UIScreen mainScreen] scale] == 2) {
                    newImageData =  UIImageJPEGRepresentation(newImage, 80);
                }
                else{
                    if(kIsIpad)
                        newImageData = UIImageJPEGRepresentation(resizeImageTo1xHelper(newImage, [self getTargetSizeForImageAtScale:1]),80);
                    else{
                        newImageData = UIImageJPEGRepresentation(newImage,80);
                    }
                }
            }
            else{
                newImageData = UIImageJPEGRepresentation(newImage,80);
            }
            
            
            if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
                if ((NSInteger)[[UIScreen mainScreen] scale] == 2) {
                    NSString *appFilePNG2x = [documentsDirectory stringByAppendingPathComponent:@"Wallpaper@2x.png"];
                    if([newImageData writeToFile:appFilePNG2x atomically:YES]){
                    }
                }
            }
            
            if([newImageData writeToFile:appFilePNG atomically:NO])
            {
            }
		}
        
	}
    return YES;
}
-(BOOL)resizeImageToBackground:(UIImage *)image
{
    // NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    //problems here (memory leaks)
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	if (image != nil) {
        // the path to write file
		
		UIImage *sourceImage = image;
		UIImage *newImage = nil;		
		newImage = [self resizeImageForSync:sourceImage];
		if(newImage == nil)
			NSLog(@"could not scale image");
		else {
			[self saveImageThumb:newImage];
			//pop the context to get back to the default
			UIGraphicsEndImageContext();
			//UIImage *bg = [newImage resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:croppedSize interpolationQuality:1.0];
            NSData *newImageData;
            
            
            NSString *appFilePNG = [documentsDirectory stringByAppendingPathComponent:@"LockBackground.png"];
            
            if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
                if ((NSInteger)[[UIScreen mainScreen] scale] == 2) {
                    newImageData =  UIImageJPEGRepresentation(newImage, 80);
                }
                else{
                    if(kIsIpad)
                        newImageData = UIImageJPEGRepresentation(resizeImageTo1xHelper(newImage, [self getTargetSizeForImageAtScale:1]),80);
                    else{
                        newImageData = UIImageJPEGRepresentation(newImage,80);
                    }
                }
            }
            else{
                newImageData = UIImageJPEGRepresentation(newImage,80);
            }
            
            
            
            if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
                if ((NSInteger)[[UIScreen mainScreen] scale] == 2) {
                    NSString *appFilePNG2x = [documentsDirectory stringByAppendingPathComponent:@"LockBackground@2x.png"];
                    if([newImageData writeToFile:appFilePNG2x atomically:YES]){
                        if(kIsIpad)
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshBG" object:nil];
                    }
                }
            }
            
            if([newImageData writeToFile:appFilePNG atomically:NO])
            {
                if(kIsIpad){
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshBG" object:nil];
                }
            }
		}
        
	}
    return YES;
}

-(void)saveImageThumb:(UIImage *)image
{
    //NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	if (image != nil) {
        // the path to write file
		
		UIImage *sourceImage = image;
		UIImage *newImage = nil;
		CGSize imageSize = sourceImage.size;
		CGSize targetSize = CGSizeMake(50, 50);
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
            if ((NSInteger)[[UIScreen mainScreen] scale] == 2) {
                targetSize = CGSizeMake(100, 100);
            }
        }
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
            }
            if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
                if ((NSInteger)[[UIScreen mainScreen] scale] == 2) {
                    appFilePNG = [documentsDirectory stringByAppendingPathComponent:@"LockBackgroundThumb@2x.png"];
                    if([newImageData writeToFile:appFilePNG atomically:YES])
                    {
                    }
                }
            }
		}
    }
    //[pool release];
}

-(void)saveWallpaperThumb:(UIImage *)image
{
    //NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	if (image != nil) {
        // the path to write file
		
		UIImage *sourceImage = image;
		UIImage *newImage = nil;
		CGSize imageSize = sourceImage.size;
		CGSize targetSize = CGSizeMake(50, 50);
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
            if ((NSInteger)[[UIScreen mainScreen] scale] == 2) {
                targetSize = CGSizeMake(100, 100);
            }
        }
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
            NSString *appFilePNG = [documentsDirectory stringByAppendingPathComponent:@"WallpaperThumb.png"];
            if([newImageData writeToFile:appFilePNG atomically:YES])
            {
            }
            if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
                if ((NSInteger)[[UIScreen mainScreen] scale] == 2) {
                    appFilePNG = [documentsDirectory stringByAppendingPathComponent:@"WallpaperThumb@2x.png"];
                    if([newImageData writeToFile:appFilePNG atomically:YES])
                    {
                    }
                }
            }
		}
    }
    //[pool release];
}




@end
