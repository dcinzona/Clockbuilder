//
//  helpers.h
//  ClockBuilder
//
//  Created by gtadmin on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@interface helpers : NSObject <UIAlertViewDelegate>{
    UIImageView *blockUI;
    UIActivityIndicatorView *activityLoader;
    NSURL *cbThemeURL;
    BOOL overwrite;
    int alertType;
}
-(void)unblockUI;
-(void)blockUIwithText:(NSString *)text showLoader:(BOOL)showLoader;
-(void)showOverlay:(NSString *)message iconImage:(UIImage*)image;
-(BOOL)deviceIsConnectedToInet;
-(void)alertWithStringAndConfirm:(NSString *)string confirmString:(NSString *)confirmString;
-(void)alertWithString:(NSString *)string;
-(void)alertNotConnected;
-(BOOL)isConnectionWifi;
-(BOOL)checkAppVersionNoAlert;
-(BOOL)checkAppVersion;
-(BOOL)prefers24Hour;
-(NSDictionary *) sendDiag;
-(void)processIncomingFileURL:(NSURL *)url;
@end
