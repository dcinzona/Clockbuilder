//
//  AMPMView.h
//  ClockBuilder
//
//  Created by Gustavo Tandeciarz on 3/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RRSGlowLabel.h"

@interface AMPMView : UIView {
    
}
@property (nonatomic, retain) RRSGlowLabel* textLabel;
-(void) updateView;

@end
