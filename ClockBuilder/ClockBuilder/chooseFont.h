//
//  chooseFont.h
//  ClockBuilder
//
//  Created by gtadmin on 3/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface chooseFont : UITableViewController {
    
    NSIndexPath *selectedFont;
    
}
@property (nonatomic) NSMutableDictionary *settings;
@property (nonatomic) NSArray *AllFonts;
@property (strong, nonatomic) NSMutableArray *widgetList;
- (void) checkFonts;
- (void) refreshData;
@end
