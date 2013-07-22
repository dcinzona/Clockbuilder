//
//  weatherSettingsIndex.h
//  ClockBuilder
//
//  Created by gtadmin on 3/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WidgetPickerViewController.h"
#import "PrettyCell.h"


@interface weatherSettingsIndex : UITableViewController < UIActionSheetDelegate, UITextFieldDelegate> {
    NSIndexPath * SelectedCell;
    BOOL _valid;
    NSMutableDictionary *weatherData;
    BOOL _pickerVisible;
    BOOL isTyping;
}

- (void) addToolbarToPicker:(NSString *)title;
//- (void) showLocationPicker:(NSArray *)pickerList;
- (void) showIntervalPicker;
- (void) saveWeatherData;
- (NSString *)getFriendlyIntervalName;
- (NSString *)getFriendlyTemperatureName;
- (void) showTemperatureUnitsPicker;
@property (strong, nonatomic) UIActionSheet *pickerAS;
@property (strong, nonatomic) WidgetPickerViewController *picker;
@property (strong, nonatomic) NSIndexPath *SelectedCell;
//@property (nonatomic, retain) NSMutableDictionary *weatherData;
@property (strong, nonatomic) NSMutableArray *placesArray;
@property (strong, nonatomic) UISlider *slider;
@property (strong, nonatomic) UITextField *textField ;
@property (strong, nonatomic) UISwitch *onOff ;
@property (strong, nonatomic) UISwitch *showDegree ;
@property (strong, nonatomic) UISwitch *monitorInBG ;
@property (strong, nonatomic) UIActivityIndicatorView *loadingIndicator;


@end
