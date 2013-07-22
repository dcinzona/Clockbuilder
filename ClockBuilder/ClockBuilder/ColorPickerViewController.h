//
//  ColorPickerViewController.h
//  ColorPicker
//
//  Created by Gilly Dekel on 23/3/09.
//  Extended by Fabián Cañas August 2010.
//  Copyright 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ColorPickerViewController;

@protocol ColorPickerViewControllerDelegate <NSObject>

- (void)colorPickerViewController:(ColorPickerViewController *)colorPicker didSelectColor:(UIColor *)color;

@end

@interface ColorPickerViewController : UIViewController {
    id<ColorPickerViewControllerDelegate> delegate;
#ifdef IPHONE_COLOR_PICKER_SAVE_DEFAULT
    NSString *defaultsKey;
#else
    UIColor * defaultsColor;
#endif
    IBOutlet UIButton * chooseButton;
    IBOutlet UIToolbar *toolbar;
}

// Use this member to update the display after the default color value
// was changed.
// This is required when e.g. the view controller is kept in memory
// and is re-used for another color value selection
// Automatically called after construction, so no need to do it here.
-(void) moveToDefault;


@property(nonatomic,strong)	id<ColorPickerViewControllerDelegate> delegate;
#ifdef IPHONE_COLOR_PICKER_SAVE_DEFAULT
  @property(readwrite,nonatomic,retain) NSString *defaultsKey;
#else
  @property(strong, readwrite,nonatomic) UIColor *defaultsColor;
#endif
@property(strong, readwrite,nonatomic) IBOutlet UIButton *chooseButton;
@property(strong, readwrite,nonatomic) IBOutlet UIToolbar *toolbar;

- (IBAction) chooseSelectedColor;
- (IBAction) chooseClearColor;
- (IBAction) cancelColorSelection;
- (UIColor *) getSelectedColor;

@end

