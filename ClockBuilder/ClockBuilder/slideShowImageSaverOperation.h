//
//  slideShowImageSaverOperation.h
//  ClockBuilder
//
//  Created by gtadmin on 5/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface slideShowImageSaverOperation : NSOperation {
    UIImage *image;
    NSString *path;
}

@property(retain) UIImage *image;


- (id)initWithImage:(UIImage*)_image filePath:(NSString *)_path;

@end