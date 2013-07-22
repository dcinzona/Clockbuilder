//
//  BGImageCell.m
//  ClockBuilder
//
//  Created by gtadmin on 3/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BGImageCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation BGImageCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setFrame:CGRectMake(0, 0, self.window.screen.scale*320, self.window.screen.scale*64)];
        if(!kIsiOS7){
            [self setBackgroundColor:[UIColor clearColor]];
            UIImageView *bg = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"tvCellBG.png"]];
            UIImageView *bgSelected = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"tvCellBGselected.png"]];
            [self setBackgroundView:bg];
            [[self textLabel] setShadowColor:[UIColor blackColor]];
            [[self textLabel] setShadowOffset:CGSizeMake(1, 1)];
            [[self textLabel]setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.0]];
            [[self textLabel] setTextColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:.9]];
            [self setSelectedBackgroundView:bgSelected];
            [[self textLabel] setHighlightedTextColor:[UIColor whiteColor]];
        }
        
        //UIImageView *thumb = [[UIImageView alloc] initWithImage:[self thumbnailOfSize:CGSizeMake(self.window.screen.scale*50, self.window.screen.scale*50)]];
        [[self imageView] setFrame:CGRectMake(7, 7, 50, 50)];
        [[self imageView] setContentMode:UIViewContentModeScaleToFill];
        self.imageView.center = self.imageView.center;
        self.imageView.layer.cornerRadius = 8.0;
        self.imageView.layer.masksToBounds = YES;
        self.imageView.layer.borderColor = [UIColor colorWithRed:.8 green:.8 blue:.8 alpha:.4].CGColor;
        self.imageView.layer.borderWidth = 3.0;
        [self.imageView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:.4]];
        /*
        UIView* shadowView = [[UIView alloc] init];
        shadowView.layer.cornerRadius = 8.0;
        shadowView.layer.shadowColor = [[UIColor blackColor] CGColor];
        shadowView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
        shadowView.layer.shadowOpacity = 0.7f;
        shadowView.layer.shadowRadius = 5.0f;
         */
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
