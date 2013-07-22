//
//  GMTThemeSync.h
//  ClockBuilder 2
//
//  Created by Gustavo Tandeciarz on 3/22/12.
//  Copyright (c) 2012 GMTAZ.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface GMTThemeSync : NSObject

-(BOOL)testHook;
-(NSString *)getGMTSyncVersion;
-(void)respring;
-(BOOL)syncFilesFromPath:(NSString *)sourcePath toPath:(NSString*)target;
-(BOOL)syncFilesArray:(NSArray *)fileList toFolderAtPath:(NSString *)targetFolder;
-(BOOL)syncFileAtPath:(NSString *)filePath toFolderAtPath:(NSString *)targetFolder;
-(BOOL)deleteFileAtPath:(NSString *)targetPath;
@end
