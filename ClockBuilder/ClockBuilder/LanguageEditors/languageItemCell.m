//
//  languageItemCell.m
//  ClockBuilder
//
//  Created by Gustavo Tandeciarz on 8/10/12.
//
//

#import "languageItemCell.h"

@implementation languageItemCell
@synthesize cellLabel;
@synthesize entryField;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [entryField setReturnKeyType:UIReturnKeyDone];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
