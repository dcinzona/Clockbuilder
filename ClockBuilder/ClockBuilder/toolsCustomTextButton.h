//
//  toolsCustomTextButton.h
//  ClockBuilder
//
//  Created by gtadmin on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>


@interface toolsCustomTextButton : UIButton <UITextFieldDelegate, UIPopoverControllerDelegate>{
    IBOutlet UITextField *_textField;
    IBOutlet UILabel *resultsLabel;
    IBOutlet UIView *toolsDateTimeView;
    NSString *dateFormatOverride;
    NSDictionary *data;
    UIPopoverController *pop;
}

-(void)build;
-(void)setdateFormatOverride:(NSString *)df;
-(void)setWidgetData:(NSDictionary *)wd;

@end
