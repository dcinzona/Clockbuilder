//
//  UIPickerView.h
//  ClockBuilder
//
//  Created by gtadmin on 3/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WidgetPickerViewController : NSObject <UIPickerViewDelegate,UIPickerViewDataSource> {

    NSArray * pickerItems;
    NSString * pickerType;
    UIPickerView * pickerView;
}

@property (retain, nonatomic) NSArray *pickerItems;
@property (retain, nonatomic) NSString *pickerType;
@property (retain, nonatomic) UIPickerView *pickerView;

-(id) initWithPickerItems: (NSArray *)list pickerType:(NSString *)pickerType;

@end
