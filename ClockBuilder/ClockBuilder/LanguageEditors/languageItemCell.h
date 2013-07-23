//
//  languageItemCell.h
//  ClockBuilder
//
//  Created by Gustavo Tandeciarz on 8/10/12.
//
//

#import <UIKit/UIKit.h>


@interface languageItemCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UILabel *cellLabel;
@property (nonatomic, strong) IBOutlet SSTextField *entryField;

-(UILabel *)getCellLabel;

@end
