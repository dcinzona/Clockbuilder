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
    BOOL scaling;
}
-(void) setIsScalingTo:(BOOL)yesNo;
-(BOOL) isScaling;
@property (nonatomic, assign) CGSize glowOffset;
@property (nonatomic, assign) CGFloat glowAmount;
@property (nonatomic, strong) UIColor *glowColor;
@property (nonatomic, strong) NSShadow *shadow;

@end
