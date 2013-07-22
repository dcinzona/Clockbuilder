//
//  ImagePickerView.h
//  ClockBuilder
//
//  Created by gtadmin on 3/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UIImagePickerViewDelegate <NSObject>

-(void)refreshData;

@end

@interface ImagePickerView : UIImagePickerController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>{
    UIImagePickerController* imagePickerController;
    UIView *loadingOverlay;
}

@property (nonatomic, strong) UIImagePickerController* imagePickerController;
@property (nonatomic, strong) UIView *loadingOverlay;
@property (strong, nonatomic) NSData *bgData;
@property (nonatomic, assign) UIPopoverController *popover;
@end
