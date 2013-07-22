//
//  UIPickerView.h
//  ClockBuilder
//
//  Created by gtadmin on 3/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface temperatureSettingsPicker : NSObject <UIPickerViewDelegate,UIPickerViewDataSource> {

    NSString * temperatureValue;
    NSString * forecastType;
    
}

@property (strong, nonatomic) UIPickerView *pickerView;
@property (strong, nonatomic) NSArray *forecastTypesArray;
@property (strong, nonatomic) NSArray *highLow;
@property (strong, nonatomic) NSArray *selectedTypeItems;
@property (strong, nonatomic) NSString *temperatureValue;
@property (strong, nonatomic) NSString *forecastType;


@end
