//
//  manageJBSettings.h
//  ClockBuilder
//
//  Created by gtadmin on 6/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImagePickerView.h"
#import "themeConverter.h"
#import "GMTThemeSync.h"

@interface manageJBSettings : UITableViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    
    UISwitch *adjustShadowForStatusBar;
    UISwitch *rotateWallpaper;
    UIPopoverController *pop;
    themeConverter *tc;
    GMTThemeSync *gmt;
}

@end
