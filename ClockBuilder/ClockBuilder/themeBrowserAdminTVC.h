//
//  themeBrowserAdminTVC.h
//  ClockBuilder
//
//  Created by Gustavo Tandeciarz on 5/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "themeBrowserCell.h"
#import "helpers.h"
#import "deleteThemeOnline.h"
#import "singleColumnPickerActionSheet.h"


@interface themeBrowserAdminTVC : UITableViewController < UIAlertViewDelegate, UIActionSheetDelegate, singleColumnPickerActionSheetDelegate, UITextFieldDelegate>{
    singleColumnPickerActionSheet *picker;
    NSMutableArray *themesArray;
    helpers *hconn;
    BOOL _valid;
    BOOL _downloadAndActive;
    BOOL _showRefreshed;
    BOOL _themesListRefreshing;
    UIActivityIndicatorView *activityIndicator;
    deleteThemeOnline *deleteControl;
    NSString *selectedThemeName;
    NSIndexPath *selectedCellIndex;
    UITextField *editField;
    NSMutableArray* themesAsDicts;
}

-(NSInteger)getThemesList;
-(void)getThemesListInBG;
-(void)showActionMenu;

@end