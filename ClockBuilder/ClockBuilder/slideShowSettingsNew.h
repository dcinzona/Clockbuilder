//
//  slideShowSettingsNew.h
//  ClockBuilder
//
//  Created by Gustavo Tandeciarz on 5/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>



@interface slideShowSettingsNew : UITableViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    
    
    UISwitch *onOff;
	NSMutableArray *arry;
    UIImagePickerController *imagePicker;
    UIView *loadingOverlay;
    
}

- (IBAction) EditTable:(id)sender;
- (NSArray *)getSlidesArray;
@end
