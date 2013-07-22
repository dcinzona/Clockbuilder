//
//  globalTextSettings.h
//  ClockBuilder
//
//  Created by gtadmin on 4/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ColorPickerViewController.h"
#import "WidgetPickerViewController.h"
#import "temperatureSettingsPicker.h"


@interface globalTextSettings : UITableViewController <ColorPickerViewControllerDelegate, UIActionSheetDelegate, UITextFieldDelegate> {
    NSIndexPath * SelectedCell;
    NSMutableDictionary * settings;
}
- (void) addToolbarToPicker:(NSString *)title;

@property (strong, nonatomic) UIActionSheet *pickerAS;
@property (strong, nonatomic) NSIndexPath *SelectedCell;
@property (strong, nonatomic) NSMutableDictionary *settings;
@property (strong, nonatomic) NSMutableDictionary *widgetData;
@property (strong, nonatomic) NSDictionary *weatherData;
@property (strong, nonatomic) NSMutableArray *widgetsList;
@property (strong, nonatomic) UISlider *slider;
@property (strong, nonatomic) WidgetPickerViewController *picker;
@property (strong, nonatomic) temperatureSettingsPicker *tempPicker;
@property (strong, nonatomic) UITextField *textField ;
@property (strong, nonatomic) NSString *pickerASType;

@end
