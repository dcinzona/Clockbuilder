//
//  themeBrowserTVC.h
//  ClockBuilder
//
//  Created by Gustavo Tandeciarz on 4/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "themeBrowserCell.h"
#import "helpers.h"
#import "deleteThemeOnline.h"
#import "singleColumnPickerActionSheet.h"

@interface themeBrowserTVC : UITableViewController < UIAlertViewDelegate, UIActionSheetDelegate, UITextFieldDelegate>{
    NSMutableArray *themesArray;
    helpers *hconn;
    BOOL _valid;
    BOOL _downloadAndActive;
    BOOL _showRefreshed;
    BOOL _themesListRefreshing;
    BOOL _appCurrent;
    UIActivityIndicatorView *activityIndicator;
    deleteThemeOnline *deleteControl;
    NSString *selectedThemeName;
    NSIndexPath *selectedCellIndex;
    UITextField *editField;
    NSMutableArray* themesAsDicts;
    singleColumnPickerActionSheet *picker;
    NSString *URLString;
}

@property (nonatomic, retain) NSArray* categories;
@property (nonatomic, retain) NSString* currentCategory;

-(NSInteger)getThemesList;
-(void)getThemesListInBG;
-(void)showActionMenu;
@end
