//
//  YearView.h
//  ClockBuilder
//
//  Created by gtadmin on 3/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RRSGlowLabel.h"

@interface YearView : UIView {
    
}
@property (nonatomic, retain) RRSGlowLabel* textLabel;
@property (nonatomic, retain) NSDateFormatter * dateFormatter;
@end
