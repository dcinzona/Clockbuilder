//
//  GMTThemeSync.m
//  ClockBuilder 2
//
//  Created by Gustavo Tandeciarz on 3/22/12.
//  Copyright (c) 2012 GMTAZ.com. All rights reserved.
//

#import "GMTThemeSync.h"

@implementation GMTThemeSync

-(BOOL)testHook{
    
    NSLog(@"hook failed test");
    return NO;
    
}

-(NSString *)getGMTSyncVersion{
    return @"1.1-3";
}

-(void)respring{
    system("killall lsd SpringBoard");
    //[[GMTHelper sharedInstance] alertWithString:@"Respring failed.  Have you updated GMTSync?"];
}

-(BOOL)syncFilesFromPath:(NSString *)sourcePath toPath:(NSString*)target{
    
    NSLog(@"syncFilesFromPath: Not Hooked");
    return NO;
}

-(BOOL)syncFilesArray:(NSArray *)fileList toFolderAtPath:(NSString *)targetFolder{
    
    NSLog(@"syncFilesArray: Not Hooked");
    return NO;
}

-(BOOL)syncFileAtPath:(NSString *)filePath toFolderAtPath:(NSString *)targetFolder{
    
    NSLog(@"syncFileAtPath: Not Hooked");
    return NO;
}
-(BOOL)deleteFileAtPath:(NSString *)targetPath{
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:targetPath];
    if(fileExists){
        [[GMTHelper sharedInstance] alertWithString:@"Attempt to clear the wallpaper failed. Are you running the latest version of GMTSync?"];
    }
    NSLog(@"deleteFileAtPath: Not Hooked");
    return NO;
}


@end
