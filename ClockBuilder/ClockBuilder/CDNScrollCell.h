//
//  CDNScrollCell.h
//  ClockBuilder
//
//  Created by gtadmin on 4/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "themeScreenshotViewCDN.h"
#import "JScrollingRowCell.h"

@interface CDNScrollCell : JScrollingRowCell {
    themeScreenshotViewCDN *themeSS;
    UIButton *themeName;
}
-(void)updateSS:(NSString *)name;

@property (nonatomic, retain) themeScreenshotViewCDN *themeSS;
@property (nonatomic, retain) UIButton *themeName;

@end

@implementation CDNScrollCell
@synthesize themeSS;
@synthesize themeName;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString*)reuseIdentifier
{
    if((self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]))
    {
        // Initialization code    
        [self setBackgroundColor:[UIColor clearColor]];
        CGRect frame = CGRectMake(40, 0, 240, 360);
        themeSS = [[themeScreenshotViewCDN alloc] initWithFrame:frame];
        themeName = [[UIButton alloc] init];
        themeName.frame = CGRectMake(60, 330, 200, 20);
        
        [themeName setTitle:@"" forState:UIControlStateNormal];
        //[btn setTitle:@"Set As Active" forState:UIControlEventTouchDown];
        [themeName setAlpha:.8];
        [themeName setExclusiveTouch:YES];
        [[themeName titleLabel] setFont:[UIFont fontWithName:@"Helvetica" size:10]];
        [themeName.titleLabel setShadowColor:[UIColor whiteColor]];
        [themeName.titleLabel setShadowOffset:CGSizeMake(1, 1)];
        
        [themeName setReversesTitleShadowWhenHighlighted:YES];
        
        [[themeName layer]setCornerRadius:10];
        [themeName.layer setMasksToBounds:YES];
        [themeName.layer setBorderWidth:1];
        [themeName setBackgroundColor:[UIColor colorWithRed:.1 green:.1 blue:.1 alpha:.3]];
        [themeName.layer setBorderColor:[[UIColor colorWithRed:.1 green:.1 blue:.1 alpha:.5] CGColor]];
    }
    return self;
}

- (void)layoutSubviews
{
    
    // Drawing code
    
    [self.contentView addSubview:themeSS];
    [self.contentView addSubview:themeName];
    // manipulate the frames of any dynamically placed/sized objects.
}


-(void)updateSS:(NSString *)name
{
    [themeSS loadImage:name];
    [themeName setTitle:name forState:UIControlStateNormal];
}

- (void)dealloc
{
    [themeSS release];
    [themeName release];
    [super dealloc];
}

@end
