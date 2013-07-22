//
//  appManagementTableView.h
//  ClockBuilder
//
//  Created by gtadmin on 3/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "manageWidgetsTableView.h"
#import "manageGeneralSettings.h"
#import "mySavedThemes.h"


@interface appManagementTableView : UITableViewController {
    
}

@property (nonatomic,retain) manageWidgetsTableView *manageWidgets;
@property (nonatomic,retain) manageGeneralSettings *manageGeneral;
@property (nonatomic,retain) mySavedThemes *savedThemes;

@end
