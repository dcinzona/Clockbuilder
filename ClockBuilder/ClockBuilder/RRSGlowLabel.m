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
        self.shadow = [[NSShadow alloc] init];
        [self.shadow setShadowColor:self.glowColor];
        [self.shadow setShadowBlurRadius:self.glowAmount];
        [self.shadow setShadowOffset:self.glowOffset];
        [self setClipsToBounds:NO];
        [self.layer setMasksToBounds:NO];
    }
    return self;
}
-(void) setIsScalingTo:(BOOL)yesNo{
    scaling = yesNo;
}
-(BOOL) isScaling{
    return (BOOL)scaling;
}
-(void)drawTextInRect:(CGRect)rect{
    
    if(self.text){
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:self.text];
        [self.shadow setShadowColor:self.glowColor];
        [self.shadow setShadowBlurRadius:self.glowAmount];
        [self.shadow setShadowOffset:self.glowOffset];
        [attrStr addAttribute:NSFontAttributeName value:self.font range:NSMakeRange(0, self.text.length)];
        if(![self isScaling]){
            [attrStr addAttribute:NSShadowAttributeName value:self.shadow range:NSMakeRange(0, self.text.length)];
        }
        [self setAttributedText:attrStr];
        attrStr = nil;
    }
    
    
    [super drawTextInRect:rect];
}
/*
- (void)drawTextInRect:(CGRect)rect {
    
    
    if(kIsiOS7){
        if(!scaling){
            self.layer.shadowColor = self.glowColor.CGColor;
            self.layer.shadowRadius = self.glowAmount;
            self.layer.shadowOffset =self.glowOffset;
            self.layer.shadowOpacity = 1;
        }
        else{
            self.opaque = YES;
            self.layer.shadowColor = nil;
            self.layer.shadowRadius = 0;
            self.layer.shadowOffset = CGSizeZero;
            self.layer.shadowOpacity = 0;
        }
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
*/



@end
