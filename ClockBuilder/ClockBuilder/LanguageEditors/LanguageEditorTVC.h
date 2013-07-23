//
//  LanguageEditorTVC.h
//  ClockBuilder
//
//  Created by Gustavo Tandeciarz on 8/10/12.
//
//

#import <UIKit/UIKit.h>
#import "languageItemCell.h"
@interface LanguageEditorTVC : UITableViewController <UITextFieldDelegate>
{
    //languageItemCell *selectedCell;
    NSIndexPath *selectedIndexPath;
}
@property (nonatomic, assign) languageItemCell *selectedCell;
@property (strong, nonatomic) IBOutlet languageItemCell *languageCell;
@end
