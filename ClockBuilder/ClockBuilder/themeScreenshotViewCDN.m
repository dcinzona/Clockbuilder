//
//  themeScreenshotViewCDN.m
//  ClockBuilder
//
//  Created by gtadmin on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "themeScreenshotViewCDN.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+WebCache.h"
#import "SDImageCache.h"


@implementation themeScreenshotViewCDN
@synthesize theme, imageView;

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        
        [self setClipsToBounds:NO];
        imageView = [[UIImageView alloc] init];
        [imageView setFrame:CGRectMake(20, 26, 200, 288)];
        [imageView setContentMode:UIViewContentModeScaleAspectFill];
        imageView.layer.borderColor = [UIColor colorWithRed:.85 green:.85 blue:.85 alpha:.4].CGColor;
        imageView.layer.borderWidth = 1.0;        
        [imageView setImage:[UIImage imageNamed:@"placeholderThemeThumb.png"]];
        
        UIImageView *ds = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"themeFrame.png"]];
        [ds setFrame:CGRectMake(10, 16, 220, 307)];
        [self addSubview:ds];        
        [self addSubview:imageView];
        [ds release];      
        
    }
    return self;

}

- (void)loadImage:(NSString *)themeName{
    
    //NSString *rackspace = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"] objectForKey:@"cloud"] objectForKey:@"themes"];
    NSString *rackspace = [[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"] objectForKey:@"iPhoneThemesURL"];
    NSString *URL = [NSString stringWithFormat:@"%@/%@/%@.jpg",rackspace,[themeName lowercaseString], @"themeScreenshot"];
    [imageView setImageWithURL:[NSURL URLWithString: URL] placeholderImage:[UIImage imageNamed:@"placeholderThemeThumb.png"]];
    
}

- (void)dealloc
{
    [imageView release];
    [theme release];
    [super dealloc];
}
@end
