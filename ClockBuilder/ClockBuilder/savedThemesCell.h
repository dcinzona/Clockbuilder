//
//  savedThemesCell.h
//  ClockBuilder
//
//  Created by gtadmin on 4/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "themeScreenshotView.h"

@interface savedThemesCell : UITableViewCell {
    themeScreenshotView *thumb;
    UIButton *themeLabel;    
}

-(void)setCellData:(NSString *)themeName;
-(void)setCellDictData:(NSMutableDictionary *)themeDictData;

@end
