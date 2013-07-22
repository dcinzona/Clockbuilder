//
//  globalFontChooser.h
//  ClockBuilder
//
//  Created by gtadmin on 4/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface globalFontChooser : UITableViewController {
    
    NSIndexPath *selectedFont;
    
}
@property (strong, nonatomic) NSMutableDictionary *settings;
@property (nonatomic) NSArray *AllFonts;
@property (strong, nonatomic) NSMutableArray *widgetList;
- (void) checkFonts;
- (void) refreshData;
@end
