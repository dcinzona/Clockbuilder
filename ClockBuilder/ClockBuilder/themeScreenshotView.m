//
//  themeScreenshotView.m
//  ClockBuilder
//
//  Created by gtadmin on 3/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "themeScreenshotView.h"
#import <QuartzCore/QuartzCore.h>
#import "CBThemeHelper.h"
#import "UIImageView+WebCache.h"
#import "SDImageCache.h"

@implementation themeScreenshotView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        
        [self setClipsToBounds:NO];
        UIImageView *imageView;
        imageView = [[UIImageView alloc] init];
        imageView.tag = 1000;
        CGRect frame = CGRectMake(20, 26, 200, 288);
        if(kIsIpad)
        {
            frame = CGRectMake(12, 26, 288-68, 288);
        }
        [imageView setFrame:frame];
        [imageView setContentMode:UIViewContentModeScaleAspectFill];
        imageView.layer.borderColor = [UIColor colorWithRed:.85 green:.85 blue:.85 alpha:.4].CGColor;
        imageView.layer.borderWidth = 1.0;   
        [imageView setBackgroundColor:[UIColor blackColor]];
        [imageView setAlpha:0];
        imageView.layer.masksToBounds = NO;
        imageView.layer.cornerRadius = 0;
        [imageView.layer setShadowColor:[UIColor blackColor].CGColor];
        imageView.layer.shadowOffset = CGSizeMake(0,5);
        imageView.layer.shadowRadius = 15;
        imageView.layer.shadowOpacity = .8;
        imageView.layer.shadowPath = [UIBezierPath bezierPathWithRect:imageView.bounds].CGPath;
        //[imageView setImage:[UIImage imageNamed:@"placeholderThemeThumb.png"]];
        /*
        UIImageView *ds = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"themeFrame.png"]];
        [ds setFrame:CGRectMake(10, 16, 220, 307)];
        [self addSubview:ds];   
         */
        [self addSubview:imageView];
        //[ds release];      
        
    }
    return self;
    
}

-(void)loadImageFromDict:(NSMutableDictionary*)themeDictData{
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        NSData *ssData = [themeDictData objectForKey:@"themeScreenshot.jpg"];
        UIImage *image = [UIImage imageWithData:ssData];//[CBThemeHelper getThumbnailFromFile:themeName];
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            //NSLog(@"%@",_currentData);
            UIImageView *view;
            for (UIView *iv in self.subviews) {
                if(iv.tag == 1000){
                    view = (UIImageView*)iv;
                    view.image = image;
                }
            }
            [UIView animateWithDuration:.4 animations:^{
                [view setAlpha:1];
            } completion:^(BOOL finished) {
                
            }];
        });             
    });
}


- (void)loadImage:(NSString*)themeName {
        
    //NSString *fullPath = [[self getThemeFolderPathForTheme:themeName] stringByAppendingPathComponent:@"themeScreenshot.jpg"];
    //NSURL *themeURL = [CBThemeHelper getThemePathForName:themeName];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        UIImage *image = [CBThemeHelper getThumbnailFromFile:themeName];
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            //NSLog(@"%@",_currentData);
            UIImageView *view;
            for (UIView *iv in self.subviews) {
                if(iv.tag == 1000){
                    view = (UIImageView*)iv;
                    view.image = image;
                }
            }
            [UIView animateWithDuration:.4 animations:^{
                [view setAlpha:1];
            } completion:^(BOOL finished) {
                
            }];
        });             
    });
}
/*
-(NSString *)getThemeFolderPathForTheme:(NSString *)themeName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *themesPath = [documentsDirectory stringByAppendingFormat:@"/myThemes/%@/",themeName];
    return themesPath;
}*/
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/



@end
