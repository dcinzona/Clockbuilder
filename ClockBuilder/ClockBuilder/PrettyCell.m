//
//  PrettyCell.m
//  ClockBuilder
//
//  Created by gtadmin on 3/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PrettyCell.h"


@implementation PrettyCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setFrame:CGRectMake(0, 0, self.window.screen.scale*320, self.window.screen.scale*64)];        
        // Initialization code
        if(!kIsiOS7){
            [self setBackgroundColor:[UIColor clearColor]];
            UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tvCellBG.png"]];
            UIImageView *bgSelected = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"tvCellBGselected.png"]];
            [self setBackgroundView:bg];
            [self setSelectedBackgroundView:bgSelected];
            [[self textLabel] setShadowColor:[UIColor blackColor]];
            [[self textLabel] setShadowOffset:CGSizeMake(1, 1)];
            [[self textLabel] setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.0]];
            [[self textLabel] setTextColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:.9]];
            [[self detailTextLabel] setFont:[UIFont fontWithName:@"HelveticaNeue" size:14.0]];
            [[self detailTextLabel] setTextColor:[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:.9]];
            [[self detailTextLabel] setShadowColor:[UIColor blackColor]];
            [[self detailTextLabel] setShadowOffset:CGSizeMake(1, 1)];
            [[self textLabel] setHighlightedTextColor:[UIColor whiteColor]];
        }
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
