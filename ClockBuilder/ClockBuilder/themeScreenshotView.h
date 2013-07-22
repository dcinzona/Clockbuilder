//
//  themeScreenshotView.h
//  ClockBuilder
//
//  Created by gtadmin on 3/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface themeScreenshotView : UIView {
    //UIImageView *imageView;
}
-(id)initWithFrame:(CGRect)frame;
-(void)loadImage:(NSString*)themeName;
-(void)loadImageFromDict:(NSMutableDictionary*)themeDictData;
//-(NSString *)getThemeFolderPathForTheme:(NSString *)themeName;


@end
