//
//  themeBrowserCell.m
//  ClockBuilder
//
//  Created by Gustavo Tandeciarz on 4/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "themeBrowserCell.h"
#import <QuartzCore/QuartzCore.h>


@implementation themeBrowserCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor clearColor]];
        CGRect frame = CGRectMake(40, 0, 240, 360);
        thumb = [[themeScreenshotViewCDN alloc] initWithFrame:frame];
        themeLabel = [[UIButton alloc] init];
        themeLabel.frame = CGRectMake(60, 330, 200, 20);
        
        [themeLabel setTitle:@"" forState:UIControlStateNormal];
        //[btn setTitle:@"Set As Active" forState:UIControlEventTouchDown];
        [themeLabel setAlpha:.8];
        [themeLabel setExclusiveTouch:YES];
        [[themeLabel titleLabel] setFont:[UIFont fontWithName:@"Helvetica" size:10]];
        [themeLabel.titleLabel setShadowColor:[UIColor whiteColor]];
        [themeLabel.titleLabel setShadowOffset:CGSizeMake(1, 1)];
        
        [themeLabel setReversesTitleShadowWhenHighlighted:YES];
        
        [[themeLabel layer]setCornerRadius:10];
        [themeLabel.layer setMasksToBounds:YES];
        [themeLabel.layer setBorderWidth:1];
        [themeLabel setBackgroundColor:[UIColor colorWithRed:.1 green:.1 blue:.1 alpha:.3]];
        [themeLabel.layer setBorderColor:[[UIColor colorWithRed:.1 green:.1 blue:.1 alpha:.5] CGColor]];
        
        [self.contentView addSubview:thumb];
        [self.contentView addSubview:themeLabel];
        
    }
    return self;
}

-(void)setCellData:(NSString *)themeName
{
    [themeLabel setTitle:themeName forState:UIControlStateNormal];
    [thumb loadImage:themeName];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc
{
    [themeLabel release];
    [thumb release];
    [super dealloc];
}

@end
