//
//  themeScreenshotViewCDN.h
//  ClockBuilder
//
//  Created by gtadmin on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface themeScreenshotViewCDN : UIView {
    NSString *theme;
}
-(id)initWithFrame:(CGRect)frame;
- (void)loadImage:(NSString *)themeName;
@property (nonatomic,retain) NSString *theme;
@property (nonatomic,retain) UIImageView *imageView;

@end
