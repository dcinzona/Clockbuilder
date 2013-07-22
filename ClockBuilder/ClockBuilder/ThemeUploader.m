//
//  ThemeUploader.m
//  ClockBuilder
//
//  Created by Gustavo Tandeciarz on 4/22/12.
//  Copyright (c) 2012 GMTAZ.com. All rights reserved.
//

#import "ThemeUploader.h"
#import "ClockBuilderAppDelegate.h"
#include "OpenUDID.h"

@implementation ThemeUploader
-(MKNetworkOperation*)uploadThemeDict:(NSMutableDictionary *)themeDict forCategory:(NSString *)category onCompletionBlock:(CloseBlock)cb andOnError:(CloseBlock)errorBlock{
    
    NSLog(@"CategorySelected: %@", category);
    NSData *themeSSData = [themeDict objectForKey:@"themeScreenshot.jpg"];
    NSData *themeBGData = [themeDict objectForKey:@"LockBackground.png"];
    NSDictionary *themeWidgetsData = [themeDict objectForKey:@"widgetsList"];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *err;
    //NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //create an array and store result of our search for the documents directory in it
    NSString *documentsDirectory = NSTemporaryDirectory();//[paths objectAtIndex:0];
    NSString *uploadDir = [documentsDirectory stringByAppendingPathComponent:@"uploads"];
    if(![fm createDirectoryAtPath:uploadDir withIntermediateDirectories:YES attributes:nil error:&err]){
        NSLog(@"error creating upload directory for theme: %@", err);
    }
    else {
        
        if([themeWidgetsData writeToFile:[uploadDir stringByAppendingPathComponent:@"widgetsList.plist"] atomically:YES]){
            
            NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey];
            NSString *udid = [OpenUDID value];
            NSString *phpFile = @"upload.php";
            if(kIsIpad){
                phpFile = @"upload-ipad.php";
            }
            MKNetworkOperation *op = [self operationWithPath:phpFile
                                                      params:[NSDictionary dictionaryWithObjectsAndKeys:
                                                              version, @"v", 
                                                              @"test", @"api",
                                                              category, @"category",
                                                              udid, @"udid",
                                                              nil]
                                                  httpMethod:@"POST"];
            
            
            if(themeBGData)
                [op addData:themeBGData forKey:@"background" mimeType:@"image/png" fileName:@"LockBackground.png"];
            if(themeSSData)
                [op addData:themeSSData forKey:@"screenshot" mimeType:@"image/jpeg" fileName:@"themeScreenshot.jpg"];
            else {
                errorBlock(@"No Theme Screenshot - not going to proceed.");
                return nil;
            }
            
            NSString *widgetListPath = [uploadDir stringByAppendingPathComponent:@"widgetsList.plist"];
            if ([fm fileExistsAtPath:widgetListPath]) {
                [op addFile:widgetListPath forKey:@"plist" mimeType:@"application/x-plist"];
            }
            else {
                NSLog(@"Could not find widgetlist:");
            }
            [op setFreezable:NO];
            
            [op onCompletion:^(MKNetworkOperation* completedOperation) {
                
                NSString *xmlString = [completedOperation responseString];
                cb(xmlString);
                
            }
                     onError:^(NSError* error) {
                         
                         errorBlock(error.localizedDescription);
                     }];
            
            [self enqueueOperation:op];
            
            return op;
            
        }
        else {
            NSLog(@"unable to save widgets.plist %@",[uploadDir stringByAppendingPathComponent:@"plist"]);
        }
        
    }
    return nil;
    
}
-(MKNetworkOperation*)uploadThemeNamed:(NSString *)themeName forCategory:(NSString *)category onCompletionBlock:(CloseBlock)cb andOnError:(CloseBlock)errorBlock{
    
    NSLog(@"CategorySelected: %@", category);
    NSDictionary *themeDict = [CBThemeHelper getThemeDictFromDoc:[CBThemeHelper getThemePathForName:themeName]];
    NSData *themeSSData = [themeDict objectForKey:@"themeScreenshot.jpg"];
    NSData *themeBGData = [themeDict objectForKey:@"LockBackground.png"];
    NSDictionary *themeWidgetsData = [themeDict objectForKey:@"widgetsList"];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *err;
    //NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //create an array and store result of our search for the documents directory in it
    NSString *documentsDirectory = NSTemporaryDirectory();//[paths objectAtIndex:0];
    NSString *uploadDir = [documentsDirectory stringByAppendingPathComponent:@"uploads"];
    if(![fm createDirectoryAtPath:uploadDir withIntermediateDirectories:YES attributes:nil error:&err]){
        NSLog(@"error creating upload directory for theme: %@", err);
    }
    else {
        
        if([themeWidgetsData writeToFile:[uploadDir stringByAppendingPathComponent:@"widgetsList.plist"] atomically:YES]){
            
            NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey];
            NSString *udid = [OpenUDID value];
            MKNetworkOperation *op = [self operationWithPath:@"upload.php"
                                      params:[NSDictionary dictionaryWithObjectsAndKeys:
                                              version, @"v", 
                                              @"test", @"api",
                                              category, @"category",
                                              udid, @"udid",
                                              nil]
                                      httpMethod:@"POST"];
            
            
            if(themeBGData)
                [op addData:themeBGData forKey:@"background" mimeType:@"image/png" fileName:@"LockBackground.png"];
            if(themeSSData)
                [op addData:themeSSData forKey:@"screenshot" mimeType:@"image/jpeg" fileName:@"themeScreenshot.jpg"];
            else {
                errorBlock(@"No Theme Screenshot - not going to proceed.");
                return nil;
            }
            
            NSString *widgetListPath = [uploadDir stringByAppendingPathComponent:@"widgetsList.plist"];
            if ([fm fileExistsAtPath:widgetListPath]) {
                [op addFile:widgetListPath forKey:@"plist" mimeType:@"application/x-plist"];
            }
            else {
                NSLog(@"Could not find widgetlist:");
            }
            [op setFreezable:NO];
            
            [op onCompletion:^(MKNetworkOperation* completedOperation) {
                
                NSString *xmlString = [completedOperation responseString];
                cb(xmlString);
                
            }
                     onError:^(NSError* error) {
                         
                         errorBlock(error.localizedDescription);
                     }];
            
            [self enqueueOperation:op];

            return op;
            
        }
        else {
            NSLog(@"unable to save widgets.plist %@",[uploadDir stringByAppendingPathComponent:@"plist"]);
        }
        
    }
    return nil;
        
}


@end
