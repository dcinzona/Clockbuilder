//
//  singleColumnPickerActionSheet.h
//  ClockBuilder
//
//  Created by gtadmin on 5/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
@class singleColumnPickerActionSheet;

@protocol singleColumnPickerActionSheetDelegate <NSObject>

- (void)singleColumnPickerActionSheet:(singleColumnPickerActionSheet *)pickerActionSheet didSelectItem:(NSString *)selectedItem;

@end
*/
@interface singleColumnPickerActionSheet : UIView <UIPickerViewDelegate,UIPickerViewDataSource,UIActionSheetDelegate>{
    //id<singleColumnPickerActionSheetDelegate> delegate;
    NSArray *pickerItems;
    NSString *pickerType;
    UIPickerView *pickerView;    
    CancelBlock _cancelBlock;
    CloseBlock _closeBlock;
}

-(void)showPickerWithTitle:(NSString *)title inView:(UIView *)view withPickerList:(NSArray *)pickerList onPicked:(CloseBlock)pickedItemBlock onCancelBlock:(CancelBlock)cancelPicking;


@property (nonatomic, copy) CancelBlock cancelBlock;
@property (nonatomic, copy) CloseBlock closeBlock;
@property (nonatomic, strong) NSArray *pickerItems;
@property (nonatomic, strong) NSString *pickerType;
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) UIActionSheet *pickerAS;

@end
