//
//  instructionsForTheme.h
//  ClockBuilder
//
//  Created by gtadmin on 3/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface instructionsForTheme : UIViewController {
    IBOutlet UIBarButtonItem * doneButton;
    IBOutlet UITextView * instructions;
}

- (IBAction)CloseModal;

@property (strong, nonatomic) UIBarButtonItem *doneButton;
@property (strong, nonatomic) UITextView *instructions;

@end
