//
//  themeProcessor.m
//  ClockBuilder
//
//  Created by gtadmin on 7/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "themeProcessor.h"

@implementation themeProcessor


- (void)processThemeFile
{
    BOOL renameTheme = NO;
    if(cbThemeURL){
    
        NSFileWrapper *wrapper =  [NSKeyedUnarchiver unarchiveObjectWithData:[NSData dataWithContentsOfURL:cbThemeURL]];
        NSString *themeName = [[wrapper preferredFilename] stringByReplacingOccurrencesOfString:@".cbTheme" withString:@""];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *themesPath = [documentsDirectory stringByAppendingFormat:@"/myThemes/"];
        NSFileManager *fM = [NSFileManager defaultManager];
        NSArray *fileList = [fM contentsOfDirectoryAtPath:themesPath error:nil];
        for(NSString *file in fileList) {
            NSString *path = [themesPath stringByAppendingPathComponent:file];
            BOOL isDir;
            [fM fileExistsAtPath:path isDirectory:(&isDir)];
            if(isDir) {
                if([file isEqualToString:themeName])
                {
                    NSLog(@"Theme already exists - rename");
                    renameTheme = YES;
                    break;
                }
            }
        }
        if(!renameTheme)
        {
            NSString *path = [themesPath stringByAppendingPathComponent:themeName];
            [fM createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
            
            NSData *wlData =  [[[wrapper fileWrappers] objectForKey:@"widgetsList.plist"] regularFileContents];
            NSString *wlPath = [path stringByAppendingString:@"/widgetsList.plist"];
            [wlData writeToFile:wlPath atomically:YES];
            NSLog(@"File - widgetsList.plist: %@", [NSString stringWithContentsOfFile:wlPath encoding:NSUTF8StringEncoding error:nil]);
            
            NSData *bgData =  [[[wrapper fileWrappers] objectForKey:@"LockBackground.png"] regularFileContents];
            NSString *bgPath = [path stringByAppendingString:@"/LockBackground.png"];
            [bgData writeToFile:bgPath atomically:YES];
            
            NSData *ssData =  [[[wrapper fileWrappers] objectForKey:@"themeScreenshot.jpg"] regularFileContents];
            NSString *ssPath = [path stringByAppendingString:@"/themeScreenshot.jpg"];
            [ssData writeToFile:ssPath atomically:YES];
            
        }
        else
        {
            CustomAlertView *alert = [[CustomAlertView alloc] initWithTitle:@"Cannot Save" message:@"A theme with this name already exists.  Please rename the saved theme." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    
    }
}
- (void)processIncomingFileURL:(NSURL *)url
{
    NSLog(@"File URL: %@",url);
    cbThemeURL = url;
    //NSFileManager *fm = [NSFileManager new];
    NSError *err;
    NSFileWrapper *themeWrapper = [[NSFileWrapper alloc] initWithURL:url options:NSFileWrapperReadingImmediate error:&err];
    
    NSString *filename = [themeWrapper filename];
    NSLog(@"Filename: %@",filename);    
    
    NSString *themeName = [[themeWrapper preferredFilename] stringByReplacingOccurrencesOfString:@".cbTheme" withString:@""];
    CustomAlertView *tp = [[CustomAlertView alloc] initWithTitle:@"Theme Importer" 
                                                 message:[NSString stringWithFormat:@"Would you like to save %@", themeName ] 
                                                delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
    [tp show];
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if([title isEqualToString:@"Save"])
    {
        //delete all widgets from widgets list
        NSLog(@"Saving Theme: %@", cbThemeURL);
        
        
    }
}




@end
