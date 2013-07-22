//
//  slideshowSettingsTV.h
//  ClockBuilder
//
//  Created by gtadmin on 5/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


@interface slideshowSettingsTV : UITableViewController {
    NSInteger slidesCount;
    UISwitch *onOff;
    BOOL flipWasON;
    UIView *loadingOverlay;
    NSOperationQueue *queue;
}


-(void)showLoadingOverlay:(NSString *)message;
- (NSArray *)getSlidesArray;

@end
