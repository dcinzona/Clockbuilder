//
//  toolsFontButton.h
//  ClockBuilder
//
//  Created by Gustavo Tandeciarz on 4/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>


@interface toolsFontButton : UIButton <UIPickerViewDelegate,UIPickerViewDataSource,UIActionSheetDelegate>{
    UILabel * fontButtonLabel;
    NSArray *pickerItems;
    NSString *pickerType;
    UIPickerView *pickerView;
    UIPopoverController *pop;
}
@property (nonatomic, retain) UILabel * fontButtonLabel;
@property (nonatomic, retain) NSArray *pickerItems;
@property (nonatomic, retain) NSString *pickerType;
@property (nonatomic, retain) UIPickerView *pickerView;
@property (nonatomic, retain) UIActionSheet *pickerAS;

-(void)build;

@end
