//
//  RRSGlowLabel.h
//  Typophone Clock
//
//  Created by gtadmin on 10/29/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RRSGlowLabel : UILabel {
    
    CGSize glowOffset;
    UIColor *glowColor;
    CGFloat glowAmount;
}

@property (nonatomic, assign) CGSize glowOffset;
@property (nonatomic, assign) CGFloat glowAmount;
@property (nonatomic, retain) UIColor *glowColor;

@end
