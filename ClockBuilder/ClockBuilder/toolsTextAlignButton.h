//
//  toolsTextAlignButton.h
//  ClockBuilder
//
//  Created by Gustavo Tandeciarz on 4/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>


@interface toolsTextAlignButton : UIButton <UIGestureRecognizerDelegate> {

}

@property (nonatomic, retain) UIImageView *alignmentIcon;

-(void)build;

@end
