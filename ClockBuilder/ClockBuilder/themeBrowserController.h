//
//  themeBrowserController.h
//  ClockBuilder
//
//  Created by gtadmin on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "helpers.h"
#import "deleteThemeOnline.h"
#import "JScrollingRow.h"
#import "themeScreenshotViewCDN.h"


@interface themeBrowserController : UIViewController <JScrollingRowDelegate,JScrollingRowDataSource,UIScrollViewDelegate, UIGestureRecognizerDelegate, UIAlertViewDelegate, UIActionSheetDelegate>{
    NSInteger currentPage;
    UIImageView *noThemes;
    UIActivityIndicatorView *activityIndicator;
    BOOL _valid;
    BOOL _downloadAndActive;
}

@property (nonatomic, retain) JScrollingRow *scrollView;
@property (nonatomic, retain) themeScreenshotViewCDN* thss;
@property (nonatomic,retain) UIView *piece;
@property (nonatomic,retain) NSMutableArray *themesArray;
@property (nonatomic, retain) UIButton *activateThemeButton;
@property (nonatomic, retain) UITextField *editField;
@property (nonatomic, retain) helpers *hconn;
@property (nonatomic, retain) deleteThemeOnline *deleteControl;

@end
