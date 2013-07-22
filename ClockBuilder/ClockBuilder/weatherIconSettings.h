//
//  weatherIconSettings.h
//  ClockBuilder
//
//  Created by gtadmin on 3/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WidgetPickerViewController.h"
#import "PrettyCell.h"


@interface weatherIconSettings : UITableViewController <UIActionSheetDelegate> {
    NSIndexPath * _SelectedCell;
    NSMutableDictionary * _settings;
}
- (void) addToolbarToPicker:(NSString *)title;

@property (strong, nonatomic) UIActionSheet *pickerAS;
@property (strong, nonatomic) NSIndexPath *SelectedCell;
@property (strong, nonatomic) NSMutableDictionary *settings;
@property (strong, nonatomic) NSMutableDictionary *widgetData;
@property (strong, nonatomic) NSMutableArray *widgetsList;
@property (strong, nonatomic) UISlider *slider;
@property (strong, nonatomic) WidgetPickerViewController *picker;


@end
