//
//  fontPicker.h
//  ClockBuilder
//
//  Created by gtadmin on 4/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface fontPicker : NSObject <UIPickerViewDelegate,UIPickerViewDataSource> {
    
    NSArray * pickerItems;
    NSString * pickerType;
    UIPickerView * pickerView;
}

@property (strong, readwrite, nonatomic) NSArray *pickerItems;
@property (strong, readwrite, nonatomic) NSString *pickerType;
@property (strong, readwrite, nonatomic) UIPickerView *pickerView;

-(id) initWithPickerItems: (NSArray *)list pickerType:(NSString *)pickerType;

@end