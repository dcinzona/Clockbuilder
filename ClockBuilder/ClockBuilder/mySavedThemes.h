//
//  mySavedThemes.h
//  ClockBuilder
//
//  Created by gtadmin on 3/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "helpers.h"

@interface mySavedThemes : UIViewController <UIScrollViewDelegate, UIGestureRecognizerDelegate, UIAlertViewDelegate, UIActionSheetDelegate>{
    NSInteger currentPage;
    UIImageView *noThemes;
    NSMutableArray *themesArray;
}
-(void)getFullObject:(NSString *)themeName themesInCloud:(NSArray *)themesInCloud;
@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic,retain) UIView *piece;
@property (nonatomic, retain) UIButton *activateThemeButton;
@property (nonatomic, retain) UITextField *editField;
@property (nonatomic, retain) helpers *helper;
@end
