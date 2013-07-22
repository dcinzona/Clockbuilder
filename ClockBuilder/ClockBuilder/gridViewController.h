//
//  gridViewController.h
//  ClockBuilder
//
//  Created by Gustavo Tandeciarz on 4/16/12.
//  Copyright (c) 2012 GMTAZ.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GMGridView.h"
#import "CoreTheme.h"
#import "CoreThemeiPad.h"
#import "CoreDataController.h"
#import <CoreData/CoreData.h>

@protocol gridViewControllerDelegate;

@interface gridViewController : UIViewController <GMGridViewDataSource, GMGridViewActionDelegate, UIPickerViewDelegate, UIActionSheetDelegate>
{
    
}
@property (nonatomic, assign) id <gridViewControllerDelegate> delegate;
@property (nonatomic, strong) CoreTheme *theme;

@end


@protocol gridViewControllerDelegate

- (NSManagedObjectContext *)getManagedObjectContext;
- (void)gridViewController:(gridViewController *)controller didFinishWithSave:(BOOL)save;

@end

