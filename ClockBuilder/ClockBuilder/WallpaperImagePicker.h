//
//  WallpaperImagePicker.h
//  ClockBuilder
//
//  Created by Gustavo Tandeciarz on 7/2/13.
//
//

#import <UIKit/UIKit.h>


@interface WallpaperImagePicker : UIImagePickerController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>{
    UIImagePickerController* imagePickerController;
    UIView *loadingOverlay;
}

@property (nonatomic, strong) UIImagePickerController* imagePickerController;
@property (nonatomic, strong) UIView *loadingOverlay;
@property (strong, nonatomic) NSData *bgData;
@property (nonatomic, assign) UIPopoverController *popover;
@end
