//
//  sliderSelectorCell.m
//  ClockBuilder
//
//  Created by gtadmin on 6/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "sliderSelectorCell.h"
#import "UIImageView+WebCache.h"
#import "SDImageCache.h"
#import <QuartzCore/QuartzCore.h>


@implementation sliderSelectorCell
@synthesize sliderImage;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        sliderImage = [[UIImageView alloc] initWithFrame:CGRectMake(105, 12, 110, 39)];
        [sliderImage setContentMode:UIViewContentModeScaleAspectFit];
        [self addSubview:sliderImage];
        if (!kIsiOS7 && NO) {
            UIImageView *bg = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"tvCellBG.png"]];
            UIImageView *bgSelected = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"tvCellBGselected.png"]];
            [self setFrame:CGRectMake(0, 0, self.window.screen.scale*320, self.window.screen.scale*64)];
            [self setBackgroundView:bg];
            [self setSelectedBackgroundView:bgSelected];
        }
        else{
            [sliderImage setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:.4]];
            [sliderImage setFrame:CGRectMake(0, sliderImage.frame.origin.y, self.frame.size.width, sliderImage.frame.size.height)];
        }
    }
    return self;
}

-(void)loadImage:(NSString *)url
{
    [sliderImage setImageWithURL:[NSURL URLWithString:url]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
