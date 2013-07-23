//
//  languageItemCell.m
//  ClockBuilder
//
//  Created by Gustavo Tandeciarz on 8/10/12.
//
//

#import "languageItemCell.h"

@implementation languageItemCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [_entryField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [_entryField setReturnKeyType:UIReturnKeyDone];
        if(!kIsiOS7){
            [_entryField setTextColor:[UIColor whiteColor]];
            [_entryField setPlaceholderTextColor:[UIColor colorWithRed:.6 green:.6 blue:.6 alpha:.6]];
        }
        else{
            //[_entryField setTextEdgeInsets:UIEdgeInsetsMake(10, 0, 10, 0)];
            //[_entryField setFont:[UIFont boldSystemFontOfSize:20]];
        }
        [_entryField setReturnKeyType:UIReturnKeyDone];
        [_entryField setKeyboardType:UIKeyboardTypeNamePhonePad];
    }
    return self;
}

-(UILabel *)getCellLabel{
    UILabel *label = _cellLabel;
    return label;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
