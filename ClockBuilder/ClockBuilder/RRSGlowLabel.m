//
//  RRSGlowLabel.m
//  Typophone Clock
//
//  Created by gtadmin on 10/29/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "RRSGlowLabel.h"


@implementation RRSGlowLabel

@synthesize glowColor, glowOffset, glowAmount;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self != nil) {
        self.glowOffset = CGSizeMake(0.0, 0.0);
        self.glowAmount = 6.0;
        self.glowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
        self.backgroundColor = [UIColor clearColor];
        self.textColor = [UIColor whiteColor];
        [self setClipsToBounds:NO];
        [self.layer setMasksToBounds:NO];
    }
    return self;
}

- (void)drawTextInRect:(CGRect)rect {
    
    
    if(kIsiOS7){
        self.layer.shadowColor = self.glowColor.CGColor;
        self.layer.shadowRadius = self.glowAmount;
        self.layer.shadowOffset =self.glowOffset;
        self.layer.shadowOpacity = 1;
        @try {
            [super drawTextInRect:rect];
        }
        @catch (NSException *exception) {
            NSLog(@"RSSGlowLabel failed drawinrect");
        }
        @finally {
            
        }
    }
    else{
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSaveGState(context);
        
        CGContextSetShadow(context, self.glowOffset, self.glowAmount);
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        
        CGColorRef color = CGColorCreate(colorSpace, CGColorGetComponents(self.glowColor.CGColor));
        CGContextSetShadowWithColor(context, self.glowOffset, self.glowAmount, color);
        
        @try {
            [super drawTextInRect:rect];
        }
        @catch (NSException *exception) {
            NSLog(@"RSSGlowLabel failed drawinrect");
        }
        @finally {
            
        }
        
        CGColorRelease(color);
        CGColorSpaceRelease(colorSpace);
        CGContextRestoreGState(context);
    }
}




@end
