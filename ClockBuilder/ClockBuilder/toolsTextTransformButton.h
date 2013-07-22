//
//  toolsTextTransformButton.h
//  ClockBuilder
//
//  Created by Gustavo Tandeciarz on 4/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>



@interface toolsTextTransformButton : UIButton {
    UILabel *fontLabel;
}

@property (nonatomic) UILabel *fontLabel;

-(void)build;

@end
