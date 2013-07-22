//
//  manageWidgets.h
//  ClockBuilder
//
//  Created by Gustavo Tandeciarz on 3/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "addWidgetPicker.h"

@interface manageWidgetsTableView : UITableViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate> {
    UITableView * tv;
    NSMutableArray * widgetsAdded;
}
- (void)setWidgetObjects;
- (void) editWidget:(NSInteger) index;
- (void)launchWidgetPicker;


@property (strong, nonatomic) UITextField *editField;
@property (strong, nonatomic) NSMutableArray *widgetsAdded;
@property (strong, nonatomic) NSMutableDictionary *widgetsAddedData;
@property (strong, nonatomic) UITableView *tv;
@property (strong, nonatomic) UIActionSheet *pickerAS;
@property (strong, nonatomic) addWidgetPicker *picker;
@property (strong, nonatomic) NSDictionary *widgetClasses;
@property (strong, nonatomic) NSArray *pickerList;
@property (strong, nonatomic) UIToolbar *toolbar;

@end
