//
//  helpers.m
//  ClockBuilder
//
//  Created by gtadmin on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "helpers.h"
//#import "Reachability.h"
#import "ClockBuilderAppDelegate.h"
#import "themeProcessor.h"
#import <dlfcn.h>
#import <mach-o/dyld.h>
#import <TargetConditionals.h>
#import "CBThemeHelper.h"

@implementation helpers


/* The encryption info struct and constants are missing from the iPhoneSimulator SDK, but not from the iPhoneOS or
 * Mac OS X SDKs. Since one doesn't ever ship a Simulator binary, we'll just provide the definitions here. */

-(NSDictionary *) sendDiag
{
    NSBundle *bundle = [NSBundle mainBundle];
    NSString* bundlePath = [bundle bundlePath];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *widget = @"Ixnmfom.pldisxt";
    NSString* path = [NSString stringWithFormat:@"%@/%@", bundlePath, [[[widget stringByReplacingOccurrencesOfString:@"x" withString:@""] stringByReplacingOccurrencesOfString:@"m" withString:@""] stringByReplacingOccurrencesOfString:@"d" withString:@""] ];
    
    NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:path error:NULL];
    
    NSNumber *fileSize;
    if (fileAttributes != nil) {
        
        if ((fileSize = [fileAttributes objectForKey:NSFileSize])) {
            NSLog(@"File size: %qi\n", [fileSize unsignedLongLongValue]);
        }      
    }
    NSString *fileSizeS = [NSString stringWithFormat:@"%d", [fileSize unsignedLongLongValue]];
    NSString *iosVersion = [[UIDevice currentDevice] systemVersion];
    NSDictionary *data = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:fileSizeS,iosVersion,@"Not used", nil] 
                                                       forKeys:[NSArray arrayWithObjects:@"FileSize",@"iOSVersion",@"UDID", nil]];
    return data;
}

-(void)blockUIwithText:(NSString *)text showLoader:(BOOL)showLoader
{
    for (UIImageView *bui in [[[[UIApplication sharedApplication] windows] objectAtIndex:0] subviews]) {
        if (bui.tag == 34543) {
            [bui removeFromSuperview];
        }
    }
    for (UIActivityIndicatorView *bui in [[[[UIApplication sharedApplication] windows] objectAtIndex:0] subviews]) {
        if (bui.tag == 45453) {
            [bui stopAnimating];
            [bui removeFromSuperview];
        }
    }
    blockUI = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"roundOverlay.png"]];
    blockUI.tag = 34543;
	[blockUI setFrame:[[UIScreen mainScreen] applicationFrame]];
	blockUI.backgroundColor = [UIColor clearColor];    
    activityLoader = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityLoader.tag = 45453;
    if(showLoader){    
        CGRect loaderFrame =CGRectMake(blockUI.center.x - 22, blockUI.center.y - 70, 44, 44);
        [activityLoader setFrame:loaderFrame];
        [blockUI addSubview:activityLoader];
        [activityLoader startAnimating];
        
    }
    
    [blockUI setAlpha:0];
    [[[UIApplication sharedApplication] keyWindow] addSubview:blockUI];
    [UIView animateWithDuration:.2
                     animations:^{
                         blockUI.alpha = 1.0;                         
                     }
                     completion:^(BOOL finished){ 
                         
                         
                     }];
}

-(void)unblockUI
{
    [UIView animateWithDuration:.2
                     animations:^{
                         blockUI.alpha = 0.0;                         
                     }
                     completion:^(BOOL finished){ 
                         
                         [blockUI removeFromSuperview];
                         blockUI=nil;
                         [activityLoader stopAnimating];
                         [activityLoader removeFromSuperview];
                         activityLoader=nil;
                         
                     }];
}

-(void)showOverlay:(NSString *)message iconImage:(UIImage*)image{
    
    [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
    
	UIView * loadingOverlay = [[UIView alloc] init];
	[loadingOverlay setFrame:[[UIScreen mainScreen] applicationFrame]];
	loadingOverlay.opaque = NO;
	loadingOverlay.backgroundColor = [UIColor clearColor];
	CGRect loaderFrame =CGRectMake(loadingOverlay.center.x - 50, loadingOverlay.center.y - 70, 100, 80);
	UIView *loader = [[UIView alloc] initWithFrame:loaderFrame];
	[loader setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.7f]];
    
    loader.layer.cornerRadius = 10;
    
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, loader.frame.size.height/2+5, loader.frame.size.width, 30)];
	label.text = message;
	label.textColor = [UIColor whiteColor];
	label.backgroundColor = [UIColor clearColor];
	label.textAlignment = UITextAlignmentCenter;
	label.opaque = NO;
	[label setFont:[UIFont fontWithName:@"HelveticaNeue" size:12]];
    [label setAdjustsFontSizeToFitWidth:YES];
	[loader addSubview:label];
    loader.transform = CGAffineTransformMakeScale(.2, .2);
	[loadingOverlay addSubview:loader];
    [loader setAlpha:0.0];
    
    
    UIImage *check = [UIImage imageNamed:@"doneCheck.png"];
    if(image!=nil)
    {
        check = image;
    }
    UIImageView *checkView = [[UIImageView alloc]initWithImage:check];
    [checkView setFrame:CGRectMake(30, 10, 39, 39)];
    [loader addSubview:checkView];
    [[[UIApplication sharedApplication] keyWindow] addSubview:loadingOverlay];
    
    [UIView animateWithDuration:.4
                     animations:^{
                         loader.alpha = 1.0;
                         loader.transform = CGAffineTransformMakeScale(1.0, 1.0);
                         
                     }
                     completion:^(BOOL finished){ 
                         [UIView animateWithDuration:.4 
                                               delay:.1 
                                             options:UIViewAnimationCurveEaseOut 
                                          animations:^{
                                              
                                              loader.alpha = 0.0;
                                              loader.transform = CGAffineTransformMakeScale(1.5,1.5);
                                          } 
                                          completion:^(BOOL finished){ 
                                              [loadingOverlay removeFromSuperview];  
                                              [loader removeFromSuperview];
                                          }];                         
                         
                     }];
    /*
    MBProgressHUD *hud = [[MBProgressHUD alloc]initWithWindow:[[UIApplication sharedApplication] keyWindow] ];
    hud.animationType = MBProgressHUDAnimationZoom;
    hud.labelText = message;
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = [[[UIImageView alloc]initWithImage:image]autorelease ];
    [[[UIApplication sharedApplication] keyWindow] addSubview:hud];
    [hud hide:YES afterDelay:1 ];
     */
}

-(void)fadeOutSlideUp:(UIView *)view
{
    [UIView animateWithDuration:.4
                     animations:^{
                         view.alpha = 0.0;
                         view.transform = CGAffineTransformTranslate(view.transform, view.frame.origin.x, -40);
                         
                     }
                     completion:^(BOOL finished){                   
                         [view removeFromSuperview];
                     }];

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

-(BOOL)isAlertVisible
{
    return NO;
}


-(void)alertWithStringAndConfirm:(NSString *)string confirmString:(NSString *)confirmString
{
    if(![[[NSUserDefaults standardUserDefaults] objectForKey:@"showTetheredFixAlert"] isEqualToString:@"no"]){
    CustomAlertView *alert = [[CustomAlertView alloc] initWithTitle:@"Warning" message:string delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:confirmString, @"Got it", nil];
    if(![self isAlertVisible])
        [alert show];
    }
}


-(void)alertWithString:(NSString *)string
{
    CustomAlertView *alert = [[CustomAlertView alloc] initWithTitle:@"Warning" message:string delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    if(![self isAlertVisible])
        [alert show];
    
}
-(void)alertNotConnected
{
    CustomAlertView *alert = [[CustomAlertView alloc] initWithTitle:@"Warning" message:@"An internet connection is required for this application to function properly" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

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

-(BOOL)prefers24Hour
{
    /*
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"hh:mm a"];
    NSDate *testDate = [NSDate dateWithTimeIntervalSince1970:16000];
    NSString *testString = [formatter stringFromDate:testDate];
    [formatter release];
    BOOL is24 = [[testString substringToIndex:1] isEqualToString:@"2"];
    //NSLog(@"prefers24Hour: %i  || %@", is24, subst);
    return is24;
     */
    
    BOOL mt = [[[NSUserDefaults standardUserDefaults] objectForKey:@"militaryTime"] boolValue];
    return mt;
}


- (void)processThemeFile
{
    BOOL renameTheme = NO;
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
            
            if(!overwrite){
                NSDictionary *themeDict = [NSKeyedUnarchiver unarchiveObjectWithFile:cbThemeURL.path];
                [CBThemeHelper saveThemeNamed:[[CBThemeHelper getFileNameFromURL:cbThemeURL] stringByReplacingOccurrencesOfString:@".cbTheme" withString:@""] withDict:themeDict];
                NSError *deleteImportedFileError;
                if(![fM removeItemAtURL:cbThemeURL error:&deleteImportedFileError])
                {
                    NSLog(@"failed to delete inbox file with error: %@",deleteImportedFileError.localizedDescription);
                }
            }
            
            cbThemeURL = nil;
            
        }
        else
        {
            alertType = 1;
            
            CustomAlertView *alert = [[CustomAlertView alloc] initWithTitle:@"Overwrite?" message:@"A theme with this name already exists.  Would you like to overwrite this theme?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Overwrite",nil];
            [alert show];
        }
    }
}
- (void)processIncomingFileURL:(NSURL *)url
{
    alertType = 1;
    
    cbThemeURL = [url copy];
    
    NSString *themeName = [[CBThemeHelper getFileNameFromURL:cbThemeURL] stringByReplacingOccurrencesOfString:@".cbTheme" withString:@""];
    CustomAlertView *tp = [[CustomAlertView alloc] initWithTitle:@"Theme Importer" 
                                                 message:[NSString stringWithFormat:@"Would you like to save %@", themeName ] 
                                                delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];

    [tp show];
    
}

//Alert Types:
// 1 = Theme Processing Alerts

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    NSLog(@"title: %@", title);
    if(alertType !=1){
        if([title isEqualToString:@"Ok"]){
            
        }
        else if([title isEqualToString:@"Get it"]){
            NSString *url = [[NSUserDefaults standardUserDefaults] objectForKey:@"lssyncurl"];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString: url]];
        }
        else if([title isEqualToString:@"Got it"]){
            [[NSUserDefaults standardUserDefaults] setObject:@"no" forKey:@"showTetheredFixAlert"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        else{}
    }
    if(alertType == 1){
        if([title isEqualToString:@"Save"])
        {
            overwrite = NO;
            [self processThemeFile];
        }
        else if([title isEqualToString:@"Overwrite"])
        {
            overwrite = YES;
            [self processThemeFile];
        }
        else
        {
            cbThemeURL = nil;
        }
    }
}



@end
