//
//  savedThemesTVC.h
//  ClockBuilder
//
//  Created by gtadmin on 4/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "themeConverter.h"
#import <CoreData/CoreData.h>
#import "gridViewController.h"

@interface savedThemesTVC : UITableViewController <UIAlertViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, NSFetchedResultsControllerDelegate, gridViewControllerDelegate>{
    BOOL _valid;
    UIView *syncingView;
    UIActivityIndicatorView *activityIndicator;
    NSString *selectedThemeName;
    NSIndexPath *selectedCellIndex;
    themeConverter *th;
    NSArray *pickerItems;
    NSString *pickerType;
    UIPickerView *pickerView;    
    CancelBlock _cancelBlock;
    CloseBlock _closeBlock;
    BOOL converting;
    BOOL fetching;
}

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, copy) CancelBlock cancelBlock;
@property (nonatomic, copy) CloseBlock closeBlock;
@property (nonatomic, strong) NSArray *pickerItems;
@property (nonatomic, strong) NSString *pickerType;
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) UIActionSheet *pickerAS;
@property (strong, nonatomic) MKNetworkOperation *uploadOperation;

//-(void)getThemesListAndReloadData;
-(void)showInstructions;
-(void)showCategoriesPickerWithCloseBlock:(CloseBlock)cb andCancelBlock:(CancelBlock)cancel;
@end
