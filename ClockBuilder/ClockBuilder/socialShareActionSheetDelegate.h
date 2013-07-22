//
//  socialShareActionSheetDelegate.h
//  ClockBuilder
//
//  Created by Gustavo Tandeciarz on 4/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface socialShareActionSheetDelegate : NSObject <UIActionSheetDelegate>{
    UIImage *image;
}
@property (nonatomic,retain) UIImage *image;
-(void)setImageToShare:(UIImage *)_image;
@end
