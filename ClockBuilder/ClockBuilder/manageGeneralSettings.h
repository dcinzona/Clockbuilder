//
//  manageGeneralSettings.h
//  ClockBuilder
//
//  Created by gtadmin on 3/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImagePickerView.h"

@interface manageGeneralSettings : UITableViewController <UIAlertViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    
    UISwitch *showStatusBar;
    UISwitch *disablePaging;
    UISwitch *militaryTime;
    UISwitch *iCloudSwitch;
    UIPopoverController *pop;
    UIButton *dbSyncButton;
    UIButton *saveBGButton;
    UIButton *clearBGButton;
    UISwitch *parallaxSwitch;
    UISwitch *backgroundSwitch;
    ImagePickerView *imagepicker;
}

@end
