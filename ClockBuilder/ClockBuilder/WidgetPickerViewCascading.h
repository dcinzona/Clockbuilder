//
//  UIPickerView.h
//  ClockBuilder
//
//  Created by gtadmin on 3/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WidgetPickerViewCascading : NSObject <UIPickerViewDelegate,UIPickerViewDataSource> {

    NSArray * pickerItems;
    NSString * pickerType;
    UIPickerView * pickerView;
}

@property (strong, nonatomic) NSArray *pickerItems;
@property (strong, nonatomic) NSString *pickerType;
@property (strong, nonatomic) UIPickerView *pickerView;
@property (strong, nonatomic) NSArray *pickerComponentItems;

-(id) initWithPickerItems: (NSArray *)listOfArrays pickerType:(NSString *)ptype;

@end
