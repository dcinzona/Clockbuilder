//
//  toolsTextWeatherButton.h
//  ClockBuilder
//
//  Created by gtadmin on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "WidgetPickerViewController.h"
#import "temperatureSettingsPicker.h"

@interface toolsTextWeatherButton : UIButton <UIActionSheetDelegate, UITextFieldDelegate, UIPopoverControllerDelegate> {
    IBOutlet UITextField *_textField;
    IBOutlet UILabel *resultsLabel;
    IBOutlet UIView *toolsDateTimeView;
    NSDictionary *data;
    WidgetPickerViewController *picker;
    temperatureSettingsPicker *tempPicker;
    UIActionSheet *pickerAS;
    NSArray *pickerItems;
    NSString *pickerType;
    UIPickerView *pickerView;
    UIPopoverController *pop;
}

-(void)build;
-(void)setWidgetData:(NSDictionary *)wd;
- (void) showConditionsPicker;
- (void) showTemperatureSettingsPicker;

@end
