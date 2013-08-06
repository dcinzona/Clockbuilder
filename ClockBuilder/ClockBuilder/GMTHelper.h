//
//  GMTHelper.h
//  ClockBuilder
//
//  Created by Gustavo Tandeciarz on 4/28/12.
//  Copyright (c) 2012 GMTAZ.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GMTHelper : NSObject

+(GMTHelper*)sharedInstance;

-(int)iOSMajorVersion;

//private
-(BOOL)checkIfJB;
-(NSString *)getGMTSyncVersion;


//inet methods:
-(BOOL)deviceIsConnectedToInet;
-(BOOL)isConnectionWifi;


//alert methods
-(void)alertWithString:(NSString *)string;
-(void)alertNotConnected;

//app version check
-(BOOL)checkAppVersionNoAlert;
-(BOOL)checkAppVersion;

//HUD overlay methods
-(void)showOverlay:(NSString *)message iconImage:(UIImage*)image;

//File processing
- (void)processIncomingFileURL:(NSURL *)url;

//settings methods
-(BOOL)prefers24Hour;
-(BOOL)parallaxEnabled;
-(BOOL)shadowAdjust;
-(BOOL)setWallpaper;
-(BOOL)rotateWallpaper;

//LocalSourcesUpdateFromRemote
- (NSArray *) objectWithUrl:(NSURL *)url;
- (NSArray*) getCategoriesArray;


//Download Theme
-(void)downloadThemeNamed:(NSString *)themeNameToDownload withName:(NSString *)inputString;



//Reporting
-(void)reportError:(NSDictionary *)errorDict;

//Global HUD notification
-(void)notifyToHideGlobalHud;
-(void)notifyToShowGlobalHudWithDict:(NSDictionary *)userInfo;
-(NSDictionary *)buildDictForHUDWithLabelText:(NSString *)labelText andImage:(UIImageView *)imageView andHide:(BOOL)hide withDelay:(float)delay andDim:(BOOL)dim;
-(void)notifyToShowGlobalHudWithSpinner:(NSString *)labelText andHide:(BOOL)hide withDelay:(float)delay andDim:(BOOL)dim;


//imageResizing
-(CGSize)getTargetSizeForImageAtScale:(int)scale;
-(UIImage *)resizeImageForSync:(UIImage *)image;
-(BOOL)resizeImageToBackground:(UIImage *)image;
-(BOOL)resizeImageToWallpaper:(UIImage *)image;
-(void)saveImageThumb:(UIImage *)image;


-(NSString *)getHostIPForClockBuilder;

@end
