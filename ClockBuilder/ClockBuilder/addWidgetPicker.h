//
//  UIPickerView.h
//  ClockBuilder
//
//  Created by gtadmin on 3/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface addWidgetPicker : NSObject <UIPickerViewDelegate,UIPickerViewDataSource> {

    
}

@property (strong, nonatomic) UIPickerView *pickerView;
@property (strong, nonatomic) NSArray *widgetTypesArray;
@property (strong, nonatomic) NSArray *dateTimeItems;
@property (strong, nonatomic) NSArray *weatherItems;
@property (strong, nonatomic) NSArray *selectedTypeItems;
@property (strong, nonatomic) NSString *widgetClass;
@property (strong, nonatomic) NSString *widgetType;
-(id)initWithFrame:(CGRect)pickerFrame;

@end
