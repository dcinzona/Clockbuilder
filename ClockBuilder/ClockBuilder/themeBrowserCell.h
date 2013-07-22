//
//  themeBrowserCell.h
//  ClockBuilder
//
//  Created by Gustavo Tandeciarz on 4/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "themeScreenshotViewCDN.h"

@interface themeBrowserCell : UITableViewCell {
    themeScreenshotViewCDN *thumb;
    UIButton *themeLabel;
}

-(void)setCellData:(NSString *)themeName;

@end
