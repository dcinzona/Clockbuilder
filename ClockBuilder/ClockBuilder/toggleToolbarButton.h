//
//  toggleToolbarButton.h
//  ClockBuilder
//
//  Created by gtadmin on 7/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface toggleToolbarButton : UIButton {
    
    UIImageView *alignmentIcon;
    BOOL toolbarHidden;
}

@property (nonatomic, strong) UIImageView *alignmentIcon;

-(void)build;

@end
