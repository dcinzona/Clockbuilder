//
//  weatherIconPickerTool.h
//  ClockBuilder
//
//  Created by gtadmin on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WidgetPickerViewController.h"

@interface weatherIconPickerTool : NSObject <UIActionSheetDelegate> {
    WidgetPickerViewController *picker;
    UIActionSheet *pickerAS;
    UIViewController *showView;
    NSDictionary *data;
}
- (void) showForecastPicker;
-(void)setShowView:(UIViewController *)v;
-(void)setWidgetData:(NSDictionary *)wd;
@end
