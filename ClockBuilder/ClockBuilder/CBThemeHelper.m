//
//  CBThemeHelper.m
//  ClockBuilder
//
//  Created by Gustavo Tandeciarz on 3/14/12.
//  Copyright (c) 2012 GMTAZ.com. All rights reserved.
//
#import <sys/xattr.h>

#import "CBThemeHelper.h"
#import "CBTheme.h"
#import "CoreDataController.h"
#import "ClockBuilderAppDelegate.h"

//#import "MBProgressHUD.h"

@implementation CBThemeHelper

+(void)convertDocumentsToNSFileWrapper{
    
    
    
}

+(BOOL)isIOS5{
    BOOL isIOS5 = [[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0;
    return isIOS5;
}

+(void)convertThemesToDocuments{
    
        //NSLog(@"Documents Dir: %@", documentsDirectory);
    /*
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *themesPath = [documentsDirectory stringByAppendingPathComponent:@"myThemes/"];
        NSFileManager *fM = [NSFileManager defaultManager];
        NSArray *fileList = [fM contentsOfDirectoryAtPath:themesPath error:nil];
        
        NSMutableDictionary *themeDict = [[NSMutableDictionary alloc] init];
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        dispatch_async(queue, ^{
                
            BOOL foundFilesToConvert = NO;
            for(NSString *file in fileList) {
                NSString *path = [themesPath stringByAppendingPathComponent:file];
                BOOL isDir;
                [fM fileExistsAtPath:path isDirectory:(&isDir)];
                if(isDir) {
                    
                    if([CBThemeHelper isIOS5]){
                    //Convert
                    foundFilesToConvert = YES;
                    
                    NSFileManager *fManager = [NSFileManager defaultManager];
                    NSString *lockbackground = [path stringByAppendingFormat:@"/LockBackground.png"];
                    NSString *screenshot = [path stringByAppendingFormat:@"/themeScreenshot.jpg"];
                    NSString *bgThumb = [path stringByAppendingFormat:@"/LockBackgroundThumb.png"];
                    NSString *widgetsListPath = [path stringByAppendingFormat:@"/widgetsList.plist"];
                    
                    if([fManager fileExistsAtPath:lockbackground]){
                        
                        NSData *bgData = UIImagePNGRepresentation([UIImage imageWithContentsOfFile:lockbackground]);
                        if(bgData!=nil)
                            [themeDict setObject:bgData forKey:@"LockBackground.png"];
                        
                    }
                    
                    if([fManager fileExistsAtPath:screenshot]){
                        
                        NSData *bgData = UIImageJPEGRepresentation([UIImage imageWithContentsOfFile:screenshot],100);
                        if(bgData!=nil)
                            [themeDict setObject:bgData forKey:@"themeScreenshot.jpg"];
                        
                    }
                    if([fManager fileExistsAtPath:bgThumb]){
                        
                        NSData *bgData = UIImagePNGRepresentation([UIImage imageWithContentsOfFile:bgThumb]);
                        if(bgData!=nil)
                            [themeDict setObject:bgData forKey:@"LockBackgroundThumb.png"];
                        
                    }
                    if([fManager fileExistsAtPath:widgetsListPath]){
                        NSArray *list = [NSArray arrayWithContentsOfFile:widgetsListPath];
                        if (list!=nil) {
                            [themeDict setObject:list forKey:@"widgetsList"];
                        }
                    }
                    else {
                        //widgetsList
                        if ([fManager fileExistsAtPath:[path stringByAppendingFormat:@"/widgetsList"]]) {
                            NSDictionary *wdata = [NSKeyedUnarchiver unarchiveObjectWithFile:[path stringByAppendingFormat:@"/widgetsList"]];
                            if(wdata!=nil)
                                [themeDict setObject:wdata forKey:@"widgetsList"];
                        }
                    }
                        CBTheme *doc = [[CBTheme alloc] initWithFileURL:[CBThemeHelper getThemePathForName:file]];
                        doc.themeDictData = themeDict;
                        [doc saveToURL:[CBThemeHelper getThemePathForName:file] forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
                            NSError *error;
                            NSArray *files = [fManager contentsOfDirectoryAtPath:path error:&error];
                            for (NSString *file in files) {
                                [fManager removeItemAtPath: [path stringByAppendingPathComponent:file] error:&error];
                            }
                            //remove directory
                            if(![fManager removeItemAtPath:path error:&error])
                            {
                                //NSLog(@"error removing old theme: %@",error.localizedDescription);
                            }
                        }];
                    }
                        
                    }
                    else {
                        //convert to NSFILEWRAPPER??
                        
                        NSString *widgetsListPath = [path stringByAppendingFormat:@"/widgetsList.plist"];
                        if([fM fileExistsAtPath:widgetsListPath]){
                            
                            NSArray *list = [NSArray arrayWithContentsOfFile:widgetsListPath];
                            NSData *wdata = [NSKeyedArchiver archivedDataWithRootObject:list];
                            if([wdata writeToFile:[path stringByAppendingFormat:@"/widgetsList"] atomically:YES])
                                [fM removeItemAtPath:widgetsListPath error:nil];
                            
                        }
                        
                        
                    }
                
            }
            //make sure all converted
            if(foundFilesToConvert){
                BOOL remaining = NO;
                for(NSString *file in fileList) {
                    NSString *path = [themesPath stringByAppendingPathComponent:file];
                    BOOL isDir;
                    [fM fileExistsAtPath:path isDirectory:(&isDir)];
                    if(isDir) {
                        //Convert
                        remaining = YES;
                    }
                }
                if(!remaining){
                    
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"convertedAllThemes"];
                    [[NSUserDefaults standardUserDefaults]synchronize];
                    
                }
            }
        });
        */
}

+(BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    BOOL success;
    
    NSString *reqSysVer = @"5.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    if([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]){
        if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending){
            
            
            NSError *error = nil;
            success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                          forKey: NSURLIsExcludedFromBackupKey error: &error];
            if(!success){
                NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
            }
            
        }
        else {
            const char* filePath = [[URL path] fileSystemRepresentation];
            
            const char* attrName = "com.apple.MobileBackup";
            u_int8_t attrValue = 1;
            
            int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
            return result == 0;
        }
    }
    return success;
}

+(void)checkIfURLIsExcluded:(NSURL *)theURL{
    NSString *reqSysVer = @"5.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    
    if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending){
        NSString *isExcluded;
        [theURL getResourceValue:&isExcluded forKey:NSURLIsExcludedFromBackupKey error:NULL];
        NSLog(@"%@  is excluded: %@", theURL.lastPathComponent, isExcluded);
    }
}

+(BOOL)isCloudEnabled{
    
#if TARGET_IPHONE_SIMULATOR
    //return YES;
#endif
    
    
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"iCloudEnabled"];
    
}

+(NSURL *)getCloudPath{
    
    NSURL *ubiq = [[NSFileManager defaultManager]
                   URLForUbiquityContainerIdentifier:nil];
    NSURL *ubiquitousPackage = [ubiq URLByAppendingPathComponent:@"Documents/"];
    return ubiquitousPackage;
}

+(NSURL *)getLocalPath{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //create an array and store result of our search for the documents directory in it
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSURL *url = [NSURL fileURLWithPath:[documentsDirectory stringByAppendingPathComponent:@"myThemes/"]];
    return url;
}
+(NSURL*)getThemesPath{
    
    NSURL *retURL;
    if([CBThemeHelper isCloudEnabled]){
        retURL = [self getCloudPath];
    }
    else {
        
        retURL = [self getLocalPath];
    }
    //NSLog(@"returl: %@",retURL);
    return [self getLocalPath];//retURL;
    
}
+(NSURL*)getThemeCloudPathForName:(NSString *)themeName{
    NSString *fileName = themeName;
    if([themeName rangeOfString:@".cbTheme"].location==NSNotFound){
        fileName = [themeName stringByAppendingString:@".cbTheme"];
    }
    NSURL *retURL;
    retURL = [[CBThemeHelper getCloudPath] URLByAppendingPathComponent:fileName];
    //NSLog(@"cloudPath: %@",retURL);
    return retURL;
}
+(NSURL*)getThemePathForName:(NSString *)themeName{
    NSString *fileName = themeName;
    if([themeName rangeOfString:@".cbTheme"].location==NSNotFound){
        fileName = [themeName stringByAppendingString:@".cbTheme"];
    }
    NSURL *retURL;
    retURL = [[CBThemeHelper getLocalPath] URLByAppendingPathComponent:fileName];
    //NSLog(@"returl: %@",retURL);
    return retURL;
}

+(NSString*)getFileNameFromURL:(NSURL *)url{
    NSArray *parts = url.pathComponents;
    NSString *filename = [parts objectAtIndex:[parts count]-1];
    return filename;
}
+(UIImage *)getThumbForBG:(UIImage*)image{
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
			
            
		}
        return newImage;
    }
    return nil;
}
+(void)saveThemeNamed:(NSString *)themeName{
    //NSAutoreleasePool *pool = [NSAutoreleasePool new];
    
    
    dispatch_async(dispatch_queue_create("com.gmtaz.clockbuilder.saveThemeNamed", DISPATCH_QUEUE_SERIAL), ^{
            
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //create an array and store result of our search for the documents directory in it
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        NSString *themeScreen = [NSString stringWithFormat:@"%@/%@.jpg",documentsDirectory,@"themeScreenshot"];
        UIImage *imageThumb= [UIImage imageWithContentsOfFile:themeScreen];
        UIImage *bgImage = [UIImage imageWithContentsOfFile:[documentsDirectory stringByAppendingFormat:@"/LockBackground.png"]];
        UIImage *bgImageThumb = [self getThumbForBG:bgImage];

        NSData *thumbnail = UIImageJPEGRepresentation(imageThumb, 70);
        NSData *background = UIImagePNGRepresentation(bgImage);
        NSData *backgroundThumb = UIImagePNGRepresentation(bgImageThumb);
        NSMutableArray *widgetsList = [kDataSingleton getWidgetsListFromSettings];
        
        NSMutableDictionary *themeDict = [NSMutableDictionary new];
        if(thumbnail!=nil)
        [themeDict setObject:thumbnail forKey:@"themeScreenshot.jpg"];
        if(background!=nil)
        [themeDict setObject:background forKey:@"LockBackground.png"];
        if(backgroundThumb!=nil)
        [themeDict setObject:backgroundThumb forKey:@"LockBackgroundThumb.png"];
        if(widgetsList!=nil)
        [themeDict setObject:widgetsList forKey:@"widgetsList"];
        //CHECK IF IOS 5
        
        if ([self isIOS5]) {
            CBTheme *doc = [[CBTheme alloc] initWithFileURL:[CBThemeHelper getThemePathForName:themeName]];
            doc.themeDictData = themeDict;
            NSFileManager *fm = [NSFileManager defaultManager];
            
            //NSString *fileName = [themeName stringByAppendingString:@".cbTheme"];
            NSURL *url = [CBThemeHelper getThemePathForName:themeName];
            //NSLog(@"saving local theme to: %@", url);
            if([fm fileExistsAtPath:url.path]){
                [doc saveToURL:url forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
                    NSLog(@"Theme Saved");
                    
                    if(success){
                        if([self isCloudEnabled]){
                            [self addSkipBackupAttributeToItemAtURL:url];
                            CBTheme *cloudDoc = [[CBTheme alloc] initWithFileURL:[self getThemeCloudPathForName:themeName]];
                            [cloudDoc setThemeDictData:doc.themeDictData];
                            [cloudDoc saveToURL:[self getThemeCloudPathForName:themeName] forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
                                [self addSkipBackupAttributeToItemAtURL:[self getThemeCloudPathForName:themeName]];
                            }];
                        }
                        dispatch_async(dispatch_get_main_queue(), ^(void) {
                            
                            [[GMTHelper sharedInstance] notifyToShowGlobalHudWithDict:[[GMTHelper sharedInstance] 
                                                                                       buildDictForHUDWithLabelText:@"Theme Saved" 
                                                                                       andImage:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"doneCheck.png"]] 
                                                                                       andHide:YES 
                                                                                       withDelay:0.5 
                                                                                       andDim:NO]];
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshThemesList" object:nil];
                        }); 
                    }
                    else
                    {
                        dispatch_async(dispatch_get_main_queue(), ^(void) {
                            NSLog(@"Processing Complete");
                            
                            [[GMTHelper sharedInstance] notifyToShowGlobalHudWithDict:[[GMTHelper sharedInstance] 
                                                                                       buildDictForHUDWithLabelText:@"Error Saving" 
                                                                                       andImage:nil 
                                                                                       andHide:YES 
                                                                                       withDelay:0.5 
                                                                                       andDim:NO]];
                        }); 
                        
                    }

                    
                    
                }];
            }
            else {
                [doc saveToURL:url forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
                    NSLog(@"Theme Saved");
                    
                    if(success){
                        
                        if([self isCloudEnabled]){
                            [self addSkipBackupAttributeToItemAtURL:url];
                            CBTheme *cloudDoc = [[CBTheme alloc] initWithFileURL:[self getThemeCloudPathForName:themeName]];
                            [cloudDoc setThemeDictData:doc.themeDictData];
                            [cloudDoc saveToURL:[self getThemeCloudPathForName:themeName] forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
                                [self addSkipBackupAttributeToItemAtURL:[self getThemeCloudPathForName:themeName]];
                            }];
                        }
                        dispatch_async(dispatch_get_main_queue(), ^(void) {
                            
                            [[GMTHelper sharedInstance] notifyToShowGlobalHudWithDict:[[GMTHelper sharedInstance] 
                                                                                       buildDictForHUDWithLabelText:@"Theme Saved" 
                                                                                       andImage:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"doneCheck.png"]] 
                                                                                       andHide:YES 
                                                                                       withDelay:0.5 
                                                                                       andDim:NO]];
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshThemesList" object:nil];
                        }); 
                    }
                    else
                    {
                        dispatch_async(dispatch_get_main_queue(), ^(void) {
                            NSLog(@"Processing Complete");
                            [[GMTHelper sharedInstance] notifyToShowGlobalHudWithDict:[[GMTHelper sharedInstance] 
                                                                                       buildDictForHUDWithLabelText:@"Error Saving" 
                                                                                       andImage:nil 
                                                                                       andHide:YES 
                                                                                       withDelay:0.5 
                                                                                       andDim:NO]];
                        }); 
                        
                    }

                
                }];//*/
            }
            

        }
           
        else {
            //SAVE AS NSFILEWRAPPER
            NSFileWrapper *themeWrapper = [[NSFileWrapper alloc] initDirectoryWithFileWrappers:nil];
            [themeWrapper addRegularFileWithContents:thumbnail preferredFilename:@"themeScreenshot.jpg"];
            [themeWrapper addRegularFileWithContents:background preferredFilename:@"LockBackground.png"];
            [themeWrapper addRegularFileWithContents:backgroundThumb preferredFilename:@"LockBackgroundThumb.png"];
            NSData *widgetListData = [NSKeyedArchiver archivedDataWithRootObject:widgetsList];
            [themeWrapper addRegularFileWithContents:widgetListData preferredFilename:@"widgetsList"];
            NSError *err;
            if(![themeWrapper writeToURL:[CBThemeHelper getThemePathForName:themeName] options:NSFileWrapperWritingAtomic originalContentsURL:nil error:&err]){
                NSLog(@"Error Saving: %@", err);
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                        NSLog(@"Processing Complete");
                    
                    [[GMTHelper sharedInstance] notifyToShowGlobalHudWithDict:[[GMTHelper sharedInstance] 
                                                                               buildDictForHUDWithLabelText:@"Error Saving" 
                                                                               andImage:nil 
                                                                               andHide:YES 
                                                                               withDelay:0.5 
                                                                               andDim:NO]];
                    }); 
            }
            else 
            {
                NSLog(@"Theme Saved as NSFILEWRAPPER\n:%@", [CBThemeHelper getThemePathForName:themeName]);
                
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    [[GMTHelper sharedInstance] notifyToShowGlobalHudWithDict:[[GMTHelper sharedInstance] 
                                                                               buildDictForHUDWithLabelText:@"Theme Saved" 
                                                                               andImage:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"doneCheck.png"]] 
                                                                               andHide:YES 
                                                                               withDelay:0.5 
                                                                               andDim:NO]];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshThemesList" object:nil];
                }); 
            }
        }
        

        
    });
    
    
    //[pool release];
}


//////////////////////////////////////////////////////////////////////////////////////
#pragma mark Theme Conversion to Core Data
//////////////////////////////////////////////////////////////////////////////////////

#define kConvertToCoreDataQ dispatch_queue_create("com.gmtaz.clockbuilder.ConvertQueue", NULL)


+(CoreTheme *)getCoreThemeWithName:(NSString *)themeName orObjectID:(NSString *)objectID{
    NSLog(@"themeName to search for:%@", themeName);
    CoreTheme *theme;    
    NSManagedObjectContext *context = ApplicationDelegate.managedObjectContext;//ApplicationDelegate.coreDataController.mainThreadContext;

    if(themeName){
        //find theme with themename in db else return new theme
        NSEntityDescription *entityDescription = [NSEntityDescription
                                                  entityForName:@"CoreTheme" inManagedObjectContext:context];
        NSLog(@"Context: %@", context);
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(themeName == %@)", themeName];
        
        [request setPredicate:predicate];
        [request setFetchLimit:1];
        NSError *error;
        NSArray *array = [context executeFetchRequest:request error:&error];
        
        NSLog(@"fetched themes with same name: %@", array);
        
        if(!array){
            if(error){
                NSLog(@"error getting themes named (%@): %@", themeName, error);
            }
        }
        else {
            if(array.count > 0){
                //return first object
                NSLog(@"object found!");
                theme = [array objectAtIndex:0];
            }
        }
    }
    if(objectID){
        /*
        NSManagedObjectID *moID = [ApplicationDelegate.psc managedObjectIDForURIRepresentation:[NSURL URLWithString:objectID]];
        //[ApplicationDelegate.coreDataController.psc managedObjectIDForURIRepresentation:[NSURL URLWithString:objectID]];
        if(moID)
            theme = (CoreTheme*)[context objectWithID:moID];*/
        //find theme with themename in db else return new theme
        NSEntityDescription *entityDescription = [NSEntityDescription
                                                  entityForName:@"CoreTheme" inManagedObjectContext:context];
        //NSLog(@"Context: %@", context);
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(recordUUID == %@)", objectID];
        
        [request setPredicate:predicate];
        [request setFetchLimit:1];
        NSError *error;
        NSArray *array = [context executeFetchRequest:request error:&error];
        
        //NSLog(@"fetched themes with same name: %@", array);
        
        if(!array){
            if(error){
                NSLog(@"error getting theme with recordUUID (%@): %@", objectID, error);
            }
        }
        else {
            if(array.count > 0){
                //return first object
                NSLog(@"object found!");
                theme = [array objectAtIndex:0];
            }
        }
    }
    if(!theme){
        theme = (CoreTheme *)[NSEntityDescription insertNewObjectForEntityForName:@"CoreTheme"
                                                           inManagedObjectContext:context];    
        //GET PERMANENT KEY
        NSError *errorObtaining;
        if(![context obtainPermanentIDsForObjects:[NSArray arrayWithObject:theme] error:&errorObtaining]){
            if(errorObtaining){
                NSLog(@"error obtaining: %@", errorObtaining);
            }
        }

    }
    
    return theme;

}


+(void)asyncSaveThemeToCoreDatawithDict:(NSMutableDictionary *)themeDict andObjectID:(NSString *)objectID{
    
    if(!themeDict || themeDict.count == 0)
    {
        NSLog(@"theme dict to save to core data was nil or had no value");
        return;
    }
    
    NSString *themeName = [themeDict objectForKey:@"themeName"];
    
    CoreTheme *theme = [self getCoreThemeWithName:themeName orObjectID:objectID];
    if(theme){        
        if([themeDict objectForKey:@"themeName"]){
            theme.themeName = [themeDict objectForKey:@"themeName"];
            NSLog(@"Saving theme with name: %@", themeName);
        }
        
        theme.saveDate = [NSDate date];//[NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
        theme.themeDictData = themeDict;
        
        NSTimeInterval  today = [[NSDate date] timeIntervalSince1970];
        NSString *intervalString = [NSString stringWithFormat:@"%f", today];
        NSString *recordUUID = intervalString;
        //NSString *recordUUID = [[[theme objectID] URIRepresentation] absoluteString];
        NSLog(@"objectID: %@",recordUUID);
        
        theme.recordUUID = (theme.recordUUID == nil) ? recordUUID : theme.recordUUID;
        
    }
    else {
        NSLog(@"error retreiving theme for saving");
    }
    NSLog(@"save theme with count: %i", [theme.themeDictData count]);
    
    //[self saveContext:ApplicationDelegate.coreDataController.mainThreadContext];
    [[GMTHelper sharedInstance] notifyToHideGlobalHud];
    [ApplicationDelegate saveContext];
    
}

+(void)asyncSaveCurrentActiveThemeToCoreDatawithDict:(NSMutableDictionary *)themeDict andObjectID:(NSString *)objectID{
    
    if(!themeDict || themeDict.count == 0)
    {
        NSLog(@"theme dict to save to core data was nil or had no value");
        return;
    }
    
    NSString *themeName = [themeDict objectForKey:@"themeName"];
    
    CoreTheme *theme = [self getCoreThemeWithName:themeName orObjectID:objectID];
    if(theme){
        if([themeDict objectForKey:@"themeName"]){
            theme.themeName = [themeDict objectForKey:@"themeName"];
            NSLog(@"Saving theme with name: %@", themeName);
        }
        
        theme.saveDate = [NSDate date];//[NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
        theme.themeDictData = themeDict;
        
        NSTimeInterval  today = [[NSDate date] timeIntervalSince1970];
        NSString *intervalString = [NSString stringWithFormat:@"%f", today];
        NSString *recordUUID = intervalString;
        //NSString *recordUUID = [[[theme objectID] URIRepresentation] absoluteString];
        NSLog(@"objectID: %@",recordUUID);
        
        theme.recordUUID = (theme.recordUUID == nil) ? recordUUID : theme.recordUUID;
        [[NSUserDefaults standardUserDefaults] setObject:theme.recordUUID forKey:kActiveThemeCoreDataIDKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else {
        NSLog(@"error retreiving theme for saving");
    }
    NSLog(@"save theme with count: %i", [theme.themeDictData count]);
    
    //[self saveContext:ApplicationDelegate.coreDataController.mainThreadContext];
    [[GMTHelper sharedInstance] notifyToHideGlobalHud];
    [ApplicationDelegate saveContext];
    
}

+(void)saveThemeToCoreDataFromEmailWithDict:(NSMutableDictionary *)themeDictInput{
    NSMutableDictionary *themeDict = [NSMutableDictionary dictionaryWithDictionary:themeDictInput];
    dispatch_async(dispatch_queue_create("com.gmtaz.clockbuilder.saveThemeNamed", DISPATCH_QUEUE_SERIAL), ^{
        
        if(themeDict.count == 0){
            //themeDict = [[NSMutableDictionary alloc] initWithDictionary:0];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[GMTHelper sharedInstance]notifyToShowGlobalHudWithSpinner:@"Error" andHide:YES withDelay:3 andDim:NO];
            });
            
        }
        else {
            //get new theme
            CoreTheme *theme = [self getCoreThemeWithName:nil orObjectID:nil];
            if(theme){        
                if([themeDict objectForKey:@"themeName"]){
                    //theme.themeName = [themeDict objectForKey:@"themeName"];
                    //strip name from theme
                    //trust the user that they are importing a theme they want to have
                    [themeDict removeObjectForKey:@"themeName"];
                }
                
                theme.saveDate = [NSDate date];//[NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
                theme.themeDictData = themeDict;
                
                NSTimeInterval  today = [[NSDate date] timeIntervalSince1970];
                NSString *intervalString = [NSString stringWithFormat:@"%f", today];
                NSString *recordUUID = intervalString;
                //NSString *recordUUID = [[[theme objectID] URIRepresentation] absoluteString];
                NSLog(@"objectID: %@",recordUUID);
                
                theme.recordUUID = (theme.recordUUID == nil) ? recordUUID : theme.recordUUID;
                
            }
            else {
                NSLog(@"error retreiving theme for saving");
            }
            NSLog(@"save theme with count: %i", [theme.themeDictData count]);
            
            //[self saveContext:ApplicationDelegate.coreDataController.mainThreadContext];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[GMTHelper sharedInstance] notifyToHideGlobalHud];
                UIImageView *check = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"doneCheck"]];
                NSDictionary *dict = [[GMTHelper sharedInstance] buildDictForHUDWithLabelText:@"Saved" andImage:check andHide:YES withDelay:.5 andDim:NO];
                [[GMTHelper sharedInstance] notifyToShowGlobalHudWithDict:dict];
                
            });
            [ApplicationDelegate saveContext];
        }
        
        
    });
}

+(void)saveThemeToCoreDatawithDict:(NSMutableDictionary *)themeDictInput andObjectID:(NSString *)objectID{
    
    NSMutableDictionary *themeDict = [NSMutableDictionary dictionaryWithDictionary:themeDictInput];
    dispatch_async(dispatch_queue_create("com.gmtaz.clockbuilder.saveThemeNamed", DISPATCH_QUEUE_SERIAL), ^{
        
        if(themeDict.count == 0){
            
            //SAVING CURRENT THEME
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //create an array and store result of our search for the documents directory in it
            NSString *documentsDirectory = [paths objectAtIndex:0];
            
            NSString *themeScreen = [NSString stringWithFormat:@"%@/%@.jpg",documentsDirectory,@"themeScreenshot"];
            UIImage *imageThumb= [UIImage imageWithContentsOfFile:themeScreen];
            UIImage *bgImage = [UIImage imageWithContentsOfFile:[documentsDirectory stringByAppendingFormat:@"/LockBackground.png"]];
            UIImage *bgImageThumb = [self getThumbForBG:bgImage];
            
            NSData *thumbnail = UIImageJPEGRepresentation(imageThumb, 70);
            NSData *background = UIImagePNGRepresentation(bgImage);
            NSData *backgroundThumb = UIImagePNGRepresentation(bgImageThumb);
            NSMutableArray *widgetsList = [kDataSingleton getWidgetsListFromSettings];
            
            NSMutableDictionary *themeDict = [[NSMutableDictionary alloc] init];
            if(widgetsList!=nil)
                [themeDict setObject:widgetsList forKey:@"widgetsList"];
            
            
            if(thumbnail!=nil)
                [themeDict setObject:thumbnail forKey:@"themeScreenshot.jpg"];
            if(background!=nil)
                [themeDict setObject:background forKey:@"LockBackground.png"];
            if(backgroundThumb!=nil)
                [themeDict setObject:backgroundThumb forKey:@"LockBackgroundThumb.png"];
            
            
            NSLog(@"saving theme dict with count: %i", [themeDict count]);
            
            [self asyncSaveCurrentActiveThemeToCoreDatawithDict:themeDict andObjectID:objectID];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[GMTHelper sharedInstance] showOverlay:@"Theme Saved" iconImage:nil];
            });
            
        }
        else {
            [self asyncSaveThemeToCoreDatawithDict:themeDict andObjectID:objectID];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[GMTHelper sharedInstance] showOverlay:@"Theme Saved" iconImage:nil];
            });
        }
        
        
    });
    
}
+(void)saveThemeToCoreDatawithDict:(NSMutableDictionary *)themeDictInput andObjectID:(NSString *)objectID andThemeName:(NSString *)themeName{
    
    NSMutableDictionary *themeDict = [NSMutableDictionary dictionaryWithDictionary:themeDictInput];
    dispatch_async(dispatch_queue_create("com.gmtaz.clockbuilder.saveThemeNamed", DISPATCH_QUEUE_SERIAL), ^{
        
        if(themeDict.count == 0){
            //themeDict = [[NSMutableDictionary alloc] initWithDictionary:0];
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //create an array and store result of our search for the documents directory in it
            NSString *documentsDirectory = [paths objectAtIndex:0];
            
            NSString *themeScreen = [NSString stringWithFormat:@"%@/%@.jpg",documentsDirectory,@"themeScreenshot"];
            UIImage *imageThumb= [UIImage imageWithContentsOfFile:themeScreen];
            UIImage *bgImage = [UIImage imageWithContentsOfFile:[documentsDirectory stringByAppendingFormat:@"/LockBackground.png"]];
            UIImage *bgImageThumb = [self getThumbForBG:bgImage];
            
            NSData *thumbnail = UIImageJPEGRepresentation(imageThumb, 70);
            NSData *background = UIImagePNGRepresentation(bgImage);
            NSData *backgroundThumb = UIImagePNGRepresentation(bgImageThumb);
            NSMutableArray *widgetsList = [kDataSingleton getWidgetsListFromSettings];
            
            NSMutableDictionary *themeDict = [[NSMutableDictionary alloc] init];
            if(widgetsList!=nil)
                [themeDict setObject:widgetsList forKey:@"widgetsList"];
            
            
            if(thumbnail!=nil)
                [themeDict setObject:thumbnail forKey:@"themeScreenshot.jpg"];
            if(background!=nil)
                [themeDict setObject:background forKey:@"LockBackground.png"];
            if(backgroundThumb!=nil)
                [themeDict setObject:backgroundThumb forKey:@"LockBackgroundThumb.png"];            
            if(themeName)
                [themeDict setObject:themeName forKey:@"themeName"];
            [self asyncSaveThemeToCoreDatawithDict:themeDict andObjectID:objectID];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[GMTHelper sharedInstance] showOverlay:@"Theme Saved" iconImage:nil];
            });
            
        }
        else {
            if(themeName)
                [themeDict setObject:themeName forKey:@"themeName"];
            [self asyncSaveThemeToCoreDatawithDict:themeDict andObjectID:objectID];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[GMTHelper sharedInstance] showOverlay:@"Theme Saved" iconImage:nil];
            });
        }
        
        
    });
    
}
+(void)converAllThemesInDocumentsToCoreData{
    //get all themes and process
    
    //dispatch_sync(kConvertToCoreDataQ, ^{
        NSURL *url = [CBThemeHelper getThemesPath];
        NSError *error;
        NSArray *arrayOfThemeURLs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:url.path error:&error];
        NSLog(@"array of theme urls: %@", arrayOfThemeURLs);
        for(NSString *urlString in arrayOfThemeURLs){
            if([urlString rangeOfString:@".cbTheme"].location!=NSNotFound){
                NSURL *urlToPass = [self getThemePathForName:urlString];
                [self asyncConvertFileToCoreDataAtURL:urlToPass];
            }
        }
    
        //dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"finishedConvertingDocumentsToCoreData" object:nil];
        //});
    //});
}
+(void)asyncConvertFileToCoreDataAtURL:(NSURL *)url{
    NSLog(@"url:%@", url);
    //dispatch_async(kConvertToCoreDataQ, ^{
        NSFileManager *fm = [NSFileManager defaultManager];
        if(url && [fm fileExistsAtPath:url.path]){
            
            //convert document to coredata
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[CBThemeHelper getThemeDictFromDoc:url]];
            if(dict.count>0){
                
                NSString *fileName = [url lastPathComponent];
                NSString *themeName = [fileName stringByReplacingOccurrencesOfString:@".cbTheme" withString:@""];
                
                CoreTheme *theme = [self getCoreThemeWithName:themeName orObjectID:nil];
                                
                [dict setObject:themeName forKey:@"themeName"];
                
                theme.themeName = themeName;
                theme.saveDate = [NSDate date];//[NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
                theme.themeDictData = dict;
                NSTimeInterval  today = [[NSDate date] timeIntervalSince1970];
                NSString *intervalString = [NSString stringWithFormat:@"%f", today];
                NSString *recordUUID = intervalString;
                //NSString *recordUUID = [[[theme objectID] URIRepresentation] absoluteString];
                NSLog(@"objectID: %@",recordUUID);
                
                theme.recordUUID = (theme.recordUUID == nil) ? recordUUID : theme.recordUUID;
                
                NSError *errorCleaning;

                if([CBThemeHelper isIOS5] && [CBThemeHelper isCloudEnabled]){
                    NSURL *cloudPath = [CBThemeHelper getThemeCloudPathForName:themeName];
                    if([fm fileExistsAtPath:cloudPath.path]){
                        if(![fm removeItemAtURL:cloudPath error:&errorCleaning]){
                            //error deleting cloud
                            NSLog(@"error cleaning theme from cloud: %@", errorCleaning);
                        }
                    }
                }
                NSURL *localPath = [CBThemeHelper getThemePathForName:themeName];
                if([fm fileExistsAtPath:localPath.path]){
                    if(![fm removeItemAtURL:localPath error:&errorCleaning]){
                        //error deleting cloud
                        NSLog(@"error cleaning theme from local docs: %@", errorCleaning);
                    }
                }
                //[self saveContext:ApplicationDelegate.coreDataController.mainThreadContext];
                [ApplicationDelegate saveContext];
            }
        }
    //});
}



+(void)saveContext:(NSManagedObjectContext *)context{    
    
    if(!context){
        context = ApplicationDelegate.managedObjectContext;//ApplicationDelegate.coreDataController.mainThreadContext;
    }
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        //abort();
    }
}

+(void)saveThemeNamed:(NSString *)themeName withDict:(NSDictionary *)themeDict{
    
    
    dispatch_queue_t queue = dispatch_queue_create("com.gmtaz.Clockbuilder.SavingThemeWithDict", NULL);//dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        
        NSMutableDictionary *themeDictMutable = [NSMutableDictionary dictionaryWithDictionary:themeDict];
        
        UIImage *bgImage = [UIImage imageWithData:[themeDict objectForKey:@"LockBackground.png"]];
        UIImage *bgImageThumb = [self getThumbForBG:bgImage];
        NSData *thumbnail = [themeDict objectForKey:@"themeScreenshot.jpg"];
        NSData *background = UIImagePNGRepresentation(bgImage);
        NSData *backgroundThumb = UIImagePNGRepresentation(bgImageThumb);
        NSMutableArray * widgetsList = [themeDict objectForKey:@"widgetsList"];
        [themeDictMutable setObject:backgroundThumb forKey:@"LockBackgroundThumb.png"];
        
        //CHECK IF IOS 5
        if ([self isIOS5]) {
            CBTheme *doc = [[CBTheme alloc] initWithFileURL:[CBThemeHelper getThemePathForName:themeName]];
            doc.themeDictData = themeDictMutable;
            NSFileManager *fm = [NSFileManager defaultManager];
            
            //NSString *fileName = [themeName stringByAppendingString:@".cbTheme"];
            NSURL *url = [CBThemeHelper getThemePathForName:themeName];
            
            if([fm fileExistsAtPath:url.path]){
                [doc saveToURL:url forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
                    //NSLog(@"Theme Saved");
                    
                    if(success){
                        if([self isCloudEnabled]){
                            [self addSkipBackupAttributeToItemAtURL:url];
                            CBTheme *cloudDoc = [[CBTheme alloc] initWithFileURL:[self getThemeCloudPathForName:themeName]];
                            [cloudDoc setThemeDictData:doc.themeDictData];
                            [cloudDoc saveToURL:[self getThemeCloudPathForName:themeName] forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
                                [self addSkipBackupAttributeToItemAtURL:[self getThemeCloudPathForName:themeName]];
                            }];
                        }
                        dispatch_async(dispatch_get_main_queue(), ^(void) {
                            [[GMTHelper sharedInstance] notifyToShowGlobalHudWithDict:[[GMTHelper sharedInstance] 
                                                                                       buildDictForHUDWithLabelText:@"Theme Saved" 
                                                                                       andImage:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"doneCheck.png"]] 
                                                                                       andHide:YES 
                                                                                       withDelay:0.5 
                                                                                       andDim:NO]];
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshThemesList" object:nil];
                        }); 
                    }
                    else
                    {
                        dispatch_async(dispatch_get_main_queue(), ^(void) {       
                            [[GMTHelper sharedInstance] notifyToShowGlobalHudWithDict:[[GMTHelper sharedInstance] buildDictForHUDWithLabelText:@"Error Saving" andImage:nil andHide:YES withDelay:2 andDim:NO]];
                        }); 
                        
                    }
                }];
            }
            else {
                [doc saveToURL:url forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
                    //NSLog(@"Theme Saved");
                    
                    if(success){
                        if([self isCloudEnabled]){
                            [self addSkipBackupAttributeToItemAtURL:url];
                            CBTheme *cloudDoc = [[CBTheme alloc] initWithFileURL:[self getThemeCloudPathForName:themeName]];
                            [cloudDoc setThemeDictData:doc.themeDictData];
                            [cloudDoc saveToURL:[self getThemeCloudPathForName:themeName] forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
                                [self addSkipBackupAttributeToItemAtURL:[self getThemeCloudPathForName:themeName]];
                            }];
                        }
                        dispatch_async(dispatch_get_main_queue(), ^(void) {
                            
                            [[GMTHelper sharedInstance] notifyToShowGlobalHudWithDict:[[GMTHelper sharedInstance] 
                                                                                       buildDictForHUDWithLabelText:@"Theme Saved" 
                                                                                       andImage:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"doneCheck.png"]] 
                                                                                       andHide:YES 
                                                                                       withDelay:0.5 
                                                                                       andDim:NO]];
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshThemesList" object:nil];
                        }); 
                    }
                    else
                    {
                        dispatch_async(dispatch_get_main_queue(), ^(void) {
                            NSLog(@"Processing Complete");
                            [[GMTHelper sharedInstance] notifyToShowGlobalHudWithDict:[[GMTHelper sharedInstance] buildDictForHUDWithLabelText:@"Error Saving" andImage:nil andHide:YES withDelay:2 andDim:NO]];
                        }); 
                        
                    }
                }];//*/
            }
            
            
        }
        
        else {
            //SAVE AS NSFILEWRAPPER
            NSFileWrapper *themeWrapper = [[NSFileWrapper alloc] initDirectoryWithFileWrappers:nil];
            [themeWrapper addRegularFileWithContents:thumbnail preferredFilename:@"themeScreenshot.jpg"];
            [themeWrapper addRegularFileWithContents:background preferredFilename:@"LockBackground.png"];
            [themeWrapper addRegularFileWithContents:backgroundThumb preferredFilename:@"LockBackgroundThumb.png"];
            NSData *widgetListData = [NSKeyedArchiver archivedDataWithRootObject:widgetsList];
            [themeWrapper addRegularFileWithContents:widgetListData preferredFilename:@"widgetsList"];
            NSError *err;
            if(![themeWrapper writeToURL:[CBThemeHelper getThemePathForName:themeName] options:NSFileWrapperWritingAtomic originalContentsURL:nil error:&err]){
                NSLog(@"Error Saving: %@", err);
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    NSLog(@"Processing Complete");
                    
                    [[GMTHelper sharedInstance] notifyToShowGlobalHudWithDict:[[GMTHelper sharedInstance] buildDictForHUDWithLabelText:@"Error Saving" andImage:nil andHide:YES withDelay:2 andDim:NO]];
                }); 
            }
            else 
            {
                NSLog(@"Theme Saved as NSFILEWRAPPER\n:%@", [CBThemeHelper getThemePathForName:themeName]);
                
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    [[GMTHelper sharedInstance] notifyToShowGlobalHudWithDict:[[GMTHelper sharedInstance] 
                                                                               buildDictForHUDWithLabelText:@"Theme Saved" 
                                                                               andImage:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"doneCheck.png"]] 
                                                                               andHide:YES 
                                                                               withDelay:0.5 
                                                                               andDim:NO]];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshThemesList" object:nil];
                }); 
            }

        }
        
       
    });

}

+(NSDictionary *)getThemeDictFromDoc:(NSURL *)fileURL{
    
    if(fileURL!=nil){
        if ([self isIOS5]) {
            
            if([[fileURL.path pathExtension]isEqualToString:@"cbTheme"]){
                NSLog(@"fileURL: %@", fileURL);
                CBTheme *doc = [[CBTheme alloc] initWithFileURL:fileURL];
                NSError *readError;
                if([doc readFromURL:fileURL error:&readError]){
                    NSDictionary *theme = doc.themeDictData;
                    //NSLog(@"theme read: %@", theme);
                    return theme;
                }
                else{
                    NSLog(@"failed to open document with error: %@", readError);
                    return nil;
                }
                
            }
            else {
                return nil;
            }
        }
        else {
            //NSFILEWRAPPER
            //NSLog(@"getThemeDictFromDoc fileURL: %@", fileURL.path);
            NSString *path = fileURL.path;
            NSString *themeScreenshotPath = [path stringByAppendingPathComponent:@"themeScreenshot.jpg"];
            NSString *LockBackgroundPath = [path stringByAppendingPathComponent:@"LockBackground.png"];
            NSString *LockBackgroundThumbPath = [path stringByAppendingPathComponent:@"LockBackgroundThumb.png"];
            NSString *widgetsListPath = [path stringByAppendingPathComponent:@"widgetsList"];
            //DATA
            NSData *themeScreenshotData = [NSData dataWithContentsOfFile:themeScreenshotPath];
            NSData *LockBackgroundData = [NSData dataWithContentsOfFile:LockBackgroundPath];
            NSData *LockBackgroundThumbData = [NSData dataWithContentsOfFile:LockBackgroundThumbPath];
            NSArray *widgetsListData = [NSKeyedUnarchiver unarchiveObjectWithFile:widgetsListPath];
            
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            if (themeScreenshotData!=nil) {
                [dict setObject:themeScreenshotData forKey:@"themeScreenshot.jpg"];
            }
            if (LockBackgroundData!=nil) {
                [dict setObject:LockBackgroundData forKey:@"LockBackground.png"];
            }
            if (LockBackgroundThumbData!=nil) {
                [dict setObject:LockBackgroundThumbData forKey:@"LockBackgroundThumb.png"];
            }
            if (widgetsListData!=nil) {
                [dict setObject:widgetsListData forKey:@"widgetsList"];
            }
            NSMutableDictionary *retDict = [NSMutableDictionary dictionaryWithDictionary:dict];
            return retDict;
            
        }
    }
    else return nil;
    
}

+(BOOL)openTheme:(NSString *)themeName{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSDictionary *themeDict = [self getThemeDictFromDoc:[self getThemePathForName:themeName]];
    //NSLog(@"themeDict: %@",themeDict);
    NSMutableArray *list = [self getWidgetsListFromFile:themeName];
    NSMutableDictionary *sets = [kDataSingleton settings];
    [sets setObject:list forKey:@"widgetsList"];
    [kDataSingleton saveWidgetsListToSettings:list];
    
    
    //background image
    NSData *background = [themeDict objectForKey:@"LockBackground.png"];
    if(background!=nil){
        NSString *appFilePNG = [documentsDirectory stringByAppendingPathComponent:@"LockBackground.png"];
        if(![background writeToFile:appFilePNG atomically:YES]){
            return NO;
        }
    }
    //background thumb
    NSData *backgroundThumb = [themeDict objectForKey:@"LockBackgroundThumb.png"];
    if(backgroundThumb!=nil){
        NSString *appFilePNGThumb = [documentsDirectory stringByAppendingPathComponent:@"LockBackgroundThumb.png"];
        if(![backgroundThumb writeToFile:appFilePNGThumb atomically:YES]){
        }
    }
    
    return YES;
}


+(NSMutableArray *)getWidgetsListFromFile:(NSString *)themeName{
    
    NSURL *url = [CBThemeHelper getThemePathForName:themeName];
    NSDictionary *themeDict = [CBThemeHelper getThemeDictFromDoc:url];
    //NSLog(@"themeDict: %@",themeDict);
    NSMutableArray *widgetsList = [[themeDict objectForKey:@"widgetsList"] mutableCopy];
    return widgetsList;
}
+(UIImage *)getThumbnailFromFile:(NSString *)themeName{
    
    NSURL *url = [CBThemeHelper getThemePathForName:themeName];
    NSDictionary *themeDict = [CBThemeHelper getThemeDictFromDoc:url];
    NSData *ssData = [themeDict objectForKey:@"themeScreenshot.jpg"];
    UIImage *image = [UIImage imageWithData:ssData];
    return image;
}
+(UIImage *)getBackgroundFromFile:(NSString *)themeName{
    
    NSURL *url = [CBThemeHelper getThemePathForName:themeName];
    NSDictionary *themeDict = [CBThemeHelper getThemeDictFromDoc:url];
    NSData *ssData = [themeDict objectForKey:@"LockBackground.png"];
    UIImage *image = [UIImage imageWithData:ssData];
    return image;
}
+(BOOL)setWidgetsList:(NSDictionary *)list toFile:(NSString *)filePath{
    
	// Attach an image to the email
    NSURL *fileURL = [NSURL URLWithString:filePath];
    CBTheme *doc = [[CBTheme alloc] initWithFileURL:fileURL];
    NSError *readError;
    if([doc readFromURL:fileURL error:&readError]){
        NSMutableDictionary *theme = doc.themeDictData;
        [theme setObject:list forKey:@"widgetsList"];
        [doc saveToURL:fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
            [self addSkipBackupAttributeToItemAtURL:fileURL];
        }];
        return true;
    }
    else{
        NSLog(@"failed to open theme file. Creating new theme file.");
        NSLog(@"Read Error: %@",readError.localizedDescription);
        
        NSMutableDictionary *theme = doc.themeDictData;
        [theme setObject:list forKey:@"widgetsList"];
        [doc saveToURL:fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            [self addSkipBackupAttributeToItemAtURL:fileURL];
        }];
        
        return true;
    }
    
}
+(BOOL)setThumbnail:(UIImage *)image toFile:(NSString *)filePath{
    NSURL *fileURL = [NSURL URLWithString:filePath];
    NSData *list = UIImagePNGRepresentation(image);
    CBTheme *doc = [[CBTheme alloc] initWithFileURL:fileURL];
    NSError *readError;
    if([doc readFromURL:fileURL error:&readError]){
        NSMutableDictionary *theme = doc.themeDictData;
        [theme setObject:list forKey:@"themeScreenshot.jpg"];
        [doc saveToURL:fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
            
            [self addSkipBackupAttributeToItemAtURL:fileURL];
        }];
        
        return true;
    }
    else{
        NSLog(@"failed to open theme file. Creating new theme file.");
        NSLog(@"Read Error: %@",readError.localizedDescription);
        
        NSMutableDictionary *theme = doc.themeDictData;
        [theme setObject:list forKey:@"themeScreenshot.jpg"];
        [doc saveToURL:fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            
            [self addSkipBackupAttributeToItemAtURL:fileURL];
        }];
        
        return true;
    }
    
}
+(BOOL)setBackground:(UIImage *)image toFile:(NSString *)filePath{
    NSURL *fileURL = [NSURL URLWithString:filePath];
    NSData *list = UIImagePNGRepresentation(image);
    CBTheme *doc = [[CBTheme alloc] initWithFileURL:fileURL];
    NSError *readError;
    if([doc readFromURL:fileURL error:&readError]){
        NSMutableDictionary *theme = doc.themeDictData;
        [theme setObject:list forKey:@"LockBackground.png"];
        [doc saveToURL:fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
            
            [self addSkipBackupAttributeToItemAtURL:fileURL];
        }];
        
        return true;
    }
    else{
        NSLog(@"failed to open theme file. Creating new theme file.");
        NSLog(@"Read Error: %@",readError.localizedDescription);
        
        NSMutableDictionary *theme = doc.themeDictData;
        [theme setObject:list forKey:@"LockBackground.png"];
        [doc saveToURL:fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            
            [self addSkipBackupAttributeToItemAtURL:fileURL];
        }];
        
        return true;
    }
    
}

+(void)setThemeUbiquity:(BOOL)putIniCloud overwrite:(BOOL)overwrite{

    /*
    if([ApplicationDelegate.coreDataController respondsToSelector:@selector(dropStores)]){
        [ApplicationDelegate.coreDataController dropStores];
        [ApplicationDelegate.coreDataController loadPersistentStores];
    }
    */
    /*
    NSFileManager *filemgr = [NSFileManager defaultManager];
    NSError *error = nil;
    NSURL *documentsPath = nil;
    NSURL *ubiquityURL = nil;
    
    
    if(putIniCloud){
        documentsPath = [self getLocalPath];
        ubiquityURL = [self getCloudPath];
    }
    else {
        documentsPath = [self getCloudPath];
        ubiquityURL = [self getLocalPath];
    }
    NSArray *fileList = [filemgr contentsOfDirectoryAtPath:documentsPath.path error:&error];
    if(!fileList){
        NSLog(@"error getting file list: %@", error.localizedDescription);
    }
    else{
        for(NSString *file in fileList) {
            if([[file pathExtension]isEqualToString:@"cbTheme"]) {

                if(putIniCloud){
                    documentsPath = [self getLocalPath];
                    ubiquityURL = [self getCloudPath];
                }
                else {
                    documentsPath = [self getCloudPath];
                    ubiquityURL = [self getLocalPath];
                }
                NSURL *documentURL = [documentsPath URLByAppendingPathComponent:file];
                ubiquityURL = [ubiquityURL URLByAppendingPathComponent:file];
                
                //figure out what to do if file exists
                if(overwrite){
                    if([filemgr fileExistsAtPath:ubiquityURL.path isDirectory:nil] ){
                        
                        NSError *err;
                        if(![filemgr removeItemAtURL:ubiquityURL error:&err]){
                            NSLog(@"error deleting local copy: %@", err);
                        }
                    }
                    if ([filemgr copyItemAtURL:documentURL toURL:ubiquityURL error:&error] == YES)
                    {
                        [self addSkipBackupAttributeToItemAtURL:ubiquityURL];
                        NSLog(@"setUbiquitous OK");
                    }
                    else
                        NSLog(@"setUbiquitous Failed error = %@", error);
                }
                else {
                    
                    if(![filemgr fileExistsAtPath:ubiquityURL.path isDirectory:nil] ){
                        
                        if ([filemgr copyItemAtURL:documentURL toURL:ubiquityURL error:&error] == YES)
                        {
                            [self addSkipBackupAttributeToItemAtURL:ubiquityURL];
                            NSLog(@"setUbiquitous OK");
                        }
                        else
                            NSLog(@"setUbiquitous Failed error = %@", error);
                    }
                }
    
                
            }
        }
    }
*/

}
+(void)startDownloadingThemeAtURLString:(NSString *)urlString andSaveAs:(NSString *)saveName{
    
}

#define kBlueColor [UIColor colorWithRed:0.11f green:0.55f blue:0.84f alpha:1.00f]

+ (UIBarButtonItem *)createFontAwesomeBlueBarButtonItemWithIcon:(NSString *)iconCSSClass target:(id)tgt action:(SEL)a
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [[button titleLabel] setFont:[UIFont fontWithName:kFontAwesomeFamilyName size:20]];
    [[button titleLabel] setText:[NSString fontAwesomeIconStringForIconIdentifier:iconCSSClass]];
    
    [button addTarget:tgt action:a forControlEvents:UIControlEventTouchUpInside];
    //[button addTarget:tgt action:a forControlEvents:UIControlEventAllTouchEvents];
    
    
    if(!kIsiOS7 && !kIsIpad){
        UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
        // Since the buttons can be any width we use a thin image with a stretchable center point
        UIImage *buttonImage = [[UIImage imageNamed:@"ButtonBlue30px.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:5];
        UIImage *buttonPressedImage = [[UIImage imageNamed:@"ButtonBlue30pxSelected.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:5];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [button setTitleShadowColor:[UIColor colorWithWhite:0.0 alpha:0.7] forState:UIControlStateNormal];
        [button setTitleShadowColor:[UIColor colorWithWhite:0.0 alpha:0.7] forState:UIControlStateHighlighted];
        [[button titleLabel] setShadowOffset:CGSizeMake(0.0, -1.0)];
        CGRect buttonFrame = [button frame];
        buttonFrame.size.width = [[NSString fontAwesomeIconStringForIconIdentifier:iconCSSClass] sizeWithFont:[UIFont fontWithName:kFontAwesomeFamilyName size:20]].width + 10.0;
        buttonFrame.size.height = buttonImage.size.height;
        //buttonFrame.size.width = 35;
        [button setTitle:[NSString fontAwesomeIconStringForIconIdentifier:iconCSSClass]
                forState:UIControlStateNormal];
        [button setFrame:buttonFrame];
        
        
        [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
        [button setBackgroundImage:buttonPressedImage forState:UIControlStateHighlighted];
        
        return buttonItem;
    }
    else{
        UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithTitle:[NSString fontAwesomeIconStringForIconIdentifier:iconCSSClass] style:UIBarButtonItemStylePlain target:tgt action:a];
        [buttonItem setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                             [UIFont fontWithName:kFontAwesomeFamilyName size:20],UITextAttributeFont,kDefaultBlue, UITextAttributeTextColor,nil]forState:UIControlStateNormal];
        
        return buttonItem;
    }
}
+ (UIBarButtonItem *)createFontAwesomeDarkBarButtonItemWithIcon:(NSString *)iconCSSClass target:(id)tgt action:(SEL)a
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [[button titleLabel] setFont:[UIFont fontWithName:kFontAwesomeFamilyName size:20]];
    [[button titleLabel] setText:[NSString fontAwesomeIconStringForIconIdentifier:iconCSSClass]];
    
    [button addTarget:tgt action:a forControlEvents:UIControlEventTouchUpInside];
    
    if(!kIsiOS7 && !kIsIpad){
        UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
        // Since the buttons can be any width we use a thin image with a stretchable center point
        UIImage *buttonImage = [[UIImage imageNamed:@"ButtonDarkGrey30px.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:5];
        UIImage *buttonPressedImage = [[UIImage imageNamed:@"ButtonDarkGrey30pxSelected.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:5];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [button setTitleShadowColor:[UIColor colorWithWhite:0.0 alpha:0.7] forState:UIControlStateNormal];
        [button setTitleShadowColor:[UIColor colorWithWhite:0.0 alpha:0.7] forState:UIControlStateHighlighted];
        [[button titleLabel] setShadowOffset:CGSizeMake(0.0, -1.0)];
        CGRect buttonFrame = [button frame];
        buttonFrame.size.width = [[NSString fontAwesomeIconStringForIconIdentifier:iconCSSClass] sizeWithFont:[UIFont fontWithName:kFontAwesomeFamilyName size:20]].width + 5.0;
        buttonFrame.size.height = buttonImage.size.height;
        [button setFrame:buttonFrame];
        
        buttonFrame.size.width = 35;
        [button setTitle:[NSString fontAwesomeIconStringForIconIdentifier:iconCSSClass]
                forState:UIControlStateNormal];
        
        [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
        [button setBackgroundImage:buttonPressedImage forState:UIControlStateHighlighted];
        
        return buttonItem;
    }
    else{
        UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithTitle:[NSString fontAwesomeIconStringForIconIdentifier:iconCSSClass] style:UIBarButtonItemStylePlain target:tgt action:a];
        [buttonItem setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                             [UIFont fontWithName:kFontAwesomeFamilyName size:20],UITextAttributeFont,[UIColor darkGrayColor], UITextAttributeTextColor,nil]forState:UIControlStateNormal];
        
        return buttonItem;
    }
}

+ (UIBarButtonItem *)createBlueButtonItemWithTitle:(NSString *)t target:(id)tgt action:(SEL)a
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [button setTitle:t forState:UIControlStateNormal];
    
    [button addTarget:tgt action:a forControlEvents:UIControlEventTouchUpInside];
    //[button addTarget:tgt action:a forControlEvents:UIControlEventAllTouchEvents];
    
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    if(!kIsiOS7){
        // Since the buttons can be any width we use a thin image with a stretchable center point
        UIImage *buttonImage = [[UIImage imageNamed:@"ButtonBlue30px.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:5];
        UIImage *buttonPressedImage = [[UIImage imageNamed:@"ButtonBlue30pxSelected.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:5];
        
        [[button titleLabel] setFont:[UIFont boldSystemFontOfSize:12.0]];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [button setTitleShadowColor:[UIColor colorWithWhite:0.0 alpha:0.7] forState:UIControlStateNormal];
        [button setTitleShadowColor:[UIColor colorWithWhite:0.0 alpha:0.7] forState:UIControlStateHighlighted];
        [[button titleLabel] setShadowOffset:CGSizeMake(0.0, -1.0)];
        CGRect buttonFrame = [button frame];
        buttonFrame.size.width = [t sizeWithFont:[UIFont boldSystemFontOfSize:14.0]].width + 20.0;
        buttonFrame.size.height = buttonImage.size.height;
        [button setFrame:buttonFrame];
        
        
        [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
        [button setBackgroundImage:buttonPressedImage forState:UIControlStateHighlighted];
        
        return buttonItem;
    }
    else{
        CGRect buttonFrame = [button frame];
        buttonFrame.size.width = [t sizeWithFont:[UIFont boldSystemFontOfSize:14.0]].width + 20.0;
        [button setFrame:buttonFrame];
        [button setTitleColor:kDefaultBlue forState:UIControlStateNormal];
        [button setTitleColor:kDefaultBlue forState:UIControlStateHighlighted];
         UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithTitle:t style:UIBarButtonItemStylePlain target:tgt action:a];
        [buttonItem setTintColor:kDefaultBlue];
        return buttonItem;
    }
}
+ (UIBarButtonItem *)createDoneButtonItemWithTitle:(NSString *)t target:(id)tgt action:(SEL)a
{
    if(kIsIpad){
        UIBarButtonItem *buttonItem =[[UIBarButtonItem alloc] initWithTitle:t style:UIBarButtonItemStyleDone target:tgt action:a];
        [buttonItem setTintColor:kDefaultBlue];
        return buttonItem;
    }
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [button setTitle:t forState:UIControlStateNormal];
    
    [button addTarget:tgt action:a forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    if(!kIsiOS7){
        // Since the buttons can be any width we use a thin image with a stretchable center point
        UIImage *buttonImage = [[UIImage imageNamed:@"ButtonBlue30px.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:5];
        UIImage *buttonPressedImage = [[UIImage imageNamed:@"ButtonBlue30pxSelected.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:5];
        
        [[button titleLabel] setFont:[UIFont boldSystemFontOfSize:12.0]];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [button setTitleShadowColor:[UIColor colorWithWhite:0.0 alpha:0.7] forState:UIControlStateNormal];
        [button setTitleShadowColor:[UIColor colorWithWhite:0.0 alpha:0.7] forState:UIControlStateHighlighted];
        [[button titleLabel] setShadowOffset:CGSizeMake(0.0, -1.0)];
        
        CGRect buttonFrame = [button frame];
        buttonFrame.size.width = [t sizeWithFont:[UIFont boldSystemFontOfSize:14.0]].width + 20.0;
        buttonFrame.size.height = buttonImage.size.height;
        [button setFrame:buttonFrame];
        
        [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
        [button setBackgroundImage:buttonPressedImage forState:UIControlStateHighlighted];
        
        return buttonItem;
    }
    else{
        CGRect buttonFrame = [button frame];
        buttonFrame.size.width = [t sizeWithFont:[UIFont boldSystemFontOfSize:14.0]].width + 20.0;
        [button setFrame:buttonFrame];
        [button setTitleColor:kDefaultBlue forState:UIControlStateNormal];
        [button setTitleColor:kDefaultBlue forState:UIControlStateHighlighted];
        [buttonItem setTintColor:kDefaultBlue];
        UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithTitle:t style:UIBarButtonItemStylePlain target:tgt action:a];
        return buttonItem;
    }
}
+ (UIBarButtonItem *)createDarkButtonItemWithTitle:(NSString *)t target:(id)tgt action:(SEL)a
{
    if(kIsIpad){
        return [[UIBarButtonItem alloc] initWithTitle:t style:UIBarButtonItemStyleBordered target:tgt action:a];
    }
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:t forState:UIControlStateNormal];
    [button addTarget:tgt action:a forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    if(!kIsiOS7){
        // Since the buttons can be any width we use a thin image with a stretchable center point
        UIImage *buttonImage = [[UIImage imageNamed:@"ButtonDarkGrey30px.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:5];
        UIImage *buttonPressedImage = [[UIImage imageNamed:@"ButtonDarkGrey30pxSelected.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:5];
        
        [[button titleLabel] setFont:[UIFont boldSystemFontOfSize:12.0]];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [button setTitleShadowColor:[UIColor colorWithWhite:0.0 alpha:0.7] forState:UIControlStateNormal];
        [button setTitleShadowColor:[UIColor colorWithWhite:0.0 alpha:0.7] forState:UIControlStateHighlighted];
        [[button titleLabel] setShadowOffset:CGSizeMake(0.0, -1.0)];
        
        CGRect buttonFrame = [button frame];
        buttonFrame.size.width = [t sizeWithFont:[UIFont boldSystemFontOfSize:14.0]].width + 20.0;
        buttonFrame.size.height = buttonImage.size.height;
        [button setFrame:buttonFrame];
        
        [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
        [button setBackgroundImage:buttonPressedImage forState:UIControlStateHighlighted];
        
    
        return buttonItem;
    }
        else{
            
            UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithTitle:t style:UIBarButtonItemStylePlain target:tgt action:a];
            [buttonItem setTintColor:[UIColor blackColor]];
            return buttonItem;
        }
}
+ (UIBarButtonItem *)createButtonItemWithImage:(UIImage *)image andPressedImage:(UIImage*)imagePressed target:(id)tgt action:(SEL)a
{
    
    if(!kIsiOS7){
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        // Since the buttons can be any width we use a thin image with a stretchable center point
        UIImage *buttonImage = [[UIImage imageNamed:@"ButtonDarkGrey30px.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:5];
        UIImage *buttonPressedImage = [[UIImage imageNamed:@"ButtonDarkGrey30pxSelected.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:5];
        
        [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
        [button setBackgroundImage:buttonPressedImage forState:UIControlStateHighlighted];
        
        CGRect buttonFrame = [button frame];
        buttonFrame.size.width = image.size.width + 15.0;
        buttonFrame.size.height = image.size.height + 15.0;
        [button setFrame:buttonFrame];
        
        [button setImage:image forState:UIControlStateNormal];
        [button setImage:imagePressed forState:UIControlStateHighlighted];
        
        [button addTarget:tgt action:a forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
        
        return buttonItem;
    }
    else{
        
        UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:tgt action:a];
        
        return buttonItem;
    }
}
+ (UIBarButtonItem *)createBlueButtonItemWithImage:(UIImage *)image andPressedImage:(UIImage*)imagePressed target:(id)tgt action:(SEL)a
{
    
    if(!kIsiOS7){
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        // Since the buttons can be any width we use a thin image with a stretchable center point
        UIImage *buttonImage = [[UIImage imageNamed:@"ButtonBlue30px.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:5];
        UIImage *buttonPressedImage = [[UIImage imageNamed:@"ButtonBlue30pxSelected.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:5];
        
        [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
        [button setBackgroundImage:buttonPressedImage forState:UIControlStateHighlighted];
        
        CGRect buttonFrame = [button frame];
        buttonFrame.size.width = image.size.width + 15.0;
        buttonFrame.size.height = image.size.height + 15.0;
        [button setFrame:buttonFrame];
        
        [button setImage:image forState:UIControlStateNormal];
        [button setImage:imagePressed forState:UIControlStateHighlighted];
        
        [button addTarget:tgt action:a forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
        
        return buttonItem;
    }
    else{
        
        UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:tgt action:a];
        return buttonItem;
    }
}
+ (UIBarButtonItem *)createBackButtonItemWithTitle:(NSString *)t target:(id)tgt action:(SEL)a
{
    if(!kIsiOS7){
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        // Since the buttons can be any width we use a thin image with a stretchable center point
        UIImage *buttonImage = [[UIImage imageNamed:@"BarButtonItemBack.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:5];
        UIImage *buttonPressedImage = [[UIImage imageNamed:@"BarButtonItemBackSelected.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:5];
        
        [[button titleLabel] setFont:[UIFont boldSystemFontOfSize:12.0]];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [button setTitleShadowColor:[UIColor colorWithWhite:0.0 alpha:0.7] forState:UIControlStateNormal];
        [button setTitleShadowColor:[UIColor colorWithWhite:0.0 alpha:0.7] forState:UIControlStateHighlighted];
        [[button titleLabel] setShadowOffset:CGSizeMake(0.0, -1.0)];
        
        
        int clipLength = 8;
        if([t length]>clipLength)
        {
            t = [NSString stringWithFormat:@"%@...",[t substringToIndex:clipLength]];
        }
        
        
        CGRect buttonFrame = [button frame];
        buttonFrame.size.width = [t sizeWithFont:[UIFont boldSystemFontOfSize:14.0]].width + 30.0;
        
        buttonFrame.size.height = buttonImage.size.height;
        [button setFrame:buttonFrame];
        
        [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
        [button setBackgroundImage:buttonPressedImage forState:UIControlStateHighlighted];
        
        [button setTitle:t forState:UIControlStateNormal];
        
        [button addTarget:tgt action:a forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
        
        return buttonItem;
    }
    else{
        return nil;//[[UIBarButtonItem alloc] initWithTitle:t style:UIBarButtonItemStylePlain target:tgt action:a];
    }
}

+ (UIBarButtonItem *)createBorderlessButtonItemWithImage:(UIImage *)image andPressedImage:(UIImage*)imagePressed target:(id)tgt action:(SEL)a
{
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    CGRect buttonFrame = [button frame];
    buttonFrame.size.width = image.size.width + 15.0;
    buttonFrame.size.height = image.size.height + 15.0;
    [button setFrame:buttonFrame];
    
    [button setImage:image forState:UIControlStateNormal];
    [button setImage:imagePressed forState:UIControlStateHighlighted];
    
    [button addTarget:tgt action:a forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    return buttonItem;
}

+(UIButton *)createBlueUIButtonWithTitle: (NSString *)t target:(id)tgt action:(SEL)a frame:(CGRect)buttonFrame{
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    // Since the buttons can be any width we use a thin image with a stretchable center point
    UIImage *buttonImage = [[UIImage imageNamed:@"ButtonBlue30px.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:5];
    if(!kIsiOS7){
        UIImage *buttonPressedImage = [[UIImage imageNamed:@"ButtonBlue30pxSelected.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:5];
        [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
        [button setBackgroundImage:buttonPressedImage forState:UIControlStateHighlighted];
        [[button titleLabel] setFont:[UIFont boldSystemFontOfSize:12.0]];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [button setTitleShadowColor:[UIColor colorWithWhite:0.0 alpha:0.7] forState:UIControlStateNormal];
        [button setTitleShadowColor:[UIColor colorWithWhite:0.0 alpha:0.7] forState:UIControlStateHighlighted];
        [[button titleLabel] setShadowOffset:CGSizeMake(0.0, -1.0)];
        
        buttonFrame.size.width = [t sizeWithFont:[UIFont boldSystemFontOfSize:14.0]].width + 20.0;
        buttonFrame.size.height = buttonImage.size.height;
    }
    else{
        [button setTintColor:kDefaultBlue];
        [[button titleLabel]setFont:[UIFont boldSystemFontOfSize:16]];
        buttonFrame.size.width = [t sizeWithFont:[UIFont boldSystemFontOfSize:16.0]].width+5;
        [button setTitleColor:kDefaultBlue forState:UIControlStateNormal];
    }
    [button setFrame:buttonFrame];
    [button setTitle:t forState:UIControlStateNormal];
    [button addTarget:tgt action:a forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}
+(UIButton *)createGrayUIButtonWithTitle: (NSString *)t target:(id)tgt action:(SEL)a frame:(CGRect)buttonFrame{
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    // Since the buttons can be any width we use a thin image with a stretchable center point
    UIImage *buttonImage = [[UIImage imageNamed:@"ButtonDarkGrey30px.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:5];
    if(!kIsiOS7){
        UIImage *buttonPressedImage = [[UIImage imageNamed:@"ButtonDarkGrey30pxSelected.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:5];
        [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
        [button setBackgroundImage:buttonPressedImage forState:UIControlStateHighlighted];
        [[button titleLabel] setFont:[UIFont boldSystemFontOfSize:12.0]];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [button setTitleShadowColor:[UIColor colorWithWhite:0.0 alpha:0.7] forState:UIControlStateNormal];
        [button setTitleShadowColor:[UIColor colorWithWhite:0.0 alpha:0.7] forState:UIControlStateHighlighted];
        [[button titleLabel] setShadowOffset:CGSizeMake(0.0, -1.0)];
        
        buttonFrame.size.width = [t sizeWithFont:[UIFont boldSystemFontOfSize:14.0]].width + 20.0;
        buttonFrame.size.height = buttonImage.size.height;
    }
    else{
        [button setBackgroundColor:[UIColor darkGrayColor]];
    }
    [button setFrame:buttonFrame];
    [button setTitle:t forState:UIControlStateNormal];
    [button addTarget:tgt action:a forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

+(void)setTitle:(NSString *)title forCustomBarButton:(UIBarButtonItem*)button{
    //NSLog(@"button class: %@", NSStringFromClass(button.class));
    //if(!kIsiOS7 || button.class == UIButton.class){
        UIButton *b = (UIButton*)button.customView;
    if(b){
        [b setTitle:title forState:UIControlStateNormal];
        [b setTitle:title forState:UIControlStateHighlighted];
        [button setCustomView:b];
    }
    else{
        [button setTitle:title];
    }
    /*}
    else{
        [button setTitle:title];
    }*/
}
+(NSString*)getTitleCustBarButton:(UIBarButtonItem*)barButton{
    //if(!kIsiOS7 || barButton.class == UIButton.class){
    UIButton *b = (UIButton*)barButton.customView;
    if(b)
        return b.currentTitle;
    else{
        return barButton.title;
    }
    //}
    //else{
    //    return barButton.title;
    //}
}

+(void)setBackgroundImage:(UIImage*)bg forToolbar:(UIToolbar*)toolbar{

    if(!kIsiOS7){
        if(!bg){
            bg = [UIImage imageNamed:@"ToolbarBackground.png"];
        }
        if ([toolbar respondsToSelector:@selector(setBackgroundImage:forToolbarPosition:barMetrics:)]) {
            [toolbar setBackgroundImage:bg forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
        } else {
            CGRect screenBounds = [[UIScreen mainScreen] bounds];
            UIColor *bgPattern = [UIColor colorWithPatternImage:bg];
            [toolbar setBackgroundColor:bgPattern];
            UIImageView *bgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, screenBounds.size.width , toolbar.bounds.size.height)];
            [bgView setBackgroundColor:bgPattern];
            [toolbar insertSubview:bgView atIndex:0];
            //[toolbar insertSubview:[[UIImageView alloc] initWithImage:bg] atIndex:0];
        }
    }
    else{
        if([toolbar respondsToSelector:@selector(setBarTintColor:)])
            [toolbar performSelector:@selector(setBarTintColor:) withObject:[UIColor whiteColor]];
        [toolbar setTintColor:[UIColor blackColor]];
    }
}
+(void)styleTableView:(UITableView *)tableView{
    
    if(!kIsiOS7){
        UIImageView *bg2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, [UIScreen mainScreen].bounds.size.height)];
        [bg2 setImage:[UIImage imageNamed:@"tableGradient"]];
        [bg2 setContentMode:UIViewContentModeTop];
        UIView *bgView = [[UIView alloc] initWithFrame:tableView.frame];
        [tableView setBackgroundView:bgView];
        [bgView addSubview:bg2];
        UIColor *tableBGColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"office"]];
        [bgView setBackgroundColor:tableBGColor];
        [tableView setBackgroundColor:tableBGColor];
        
        UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tvFooterBG.png"]];
        [bg setContentMode:UIViewContentModeTopLeft];
        [tableView setTableFooterView:bg];
    }
    else{
        [tableView setBackgroundColor:[UIColor whiteColor]];
        [tableView.superview setBackgroundColor:[UIColor whiteColor]];
    }
    
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [tableView setSectionFooterHeight:0];
}



+(void)styleTableView:(UITableView *)tableView withBackgroundImage:(UIImage *)image{
    
}

+(void)showPicker:(UIPickerView*)pickerView aboveUITableView:(UITableView *)tableView onCompletion:(void(^)(void))callback{
    
    [tableView.superview insertSubview:pickerView aboveSubview:tableView];//[tableView.superview.subviews objectAtIndex:0]];
    [tableView setBackgroundColor:[UIColor whiteColor]];
    [tableView setBackgroundColor:[UIColor whiteColor]];
    [tableView.superview setBackgroundColor:[UIColor whiteColor]];
    [pickerView setBackgroundColor:[UIColor whiteColor]];
    
    [pickerView setFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, pickerView.frame.size.width, pickerView.frame.size.height)];

    [UIView animateWithDuration:0.3
                          delay:0
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         //[tableView.superview setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:.7]];
                         [pickerView setFrame:CGRectMake(0, tableView.frame.size.height - 180, 320, 180)];
                         [tableView setAlpha:.1];
                         [tableView setTransform:CGAffineTransformMakeScale(.9, .9)];
                     }
                     completion:^(BOOL finished){
                         tableView.userInteractionEnabled = NO;
                         callback();
                     }];
}
+(void)dismissPicker:(UIPickerView *)pickerView fromUITableView:(UITableView *)tableView onCompletion:(void(^)(void))callback{
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         //[tableView.superview setBackgroundColor:[UIColor whiteColor]];
                         [pickerView setFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, 320, 180)];
                         [tableView setAlpha:1];
                         [tableView setTransform:CGAffineTransformMakeScale(1, 1)];
                         CGRect tvFrame = tableView.frame;
                         tvFrame.origin.x = 0;
                         tvFrame.origin.y = 0;
                         [tableView setFrame:tvFrame];
                     }
                     completion:^(BOOL finished){
                         tableView.userInteractionEnabled = YES;
                         callback();
                         
                     }];
}

@end
