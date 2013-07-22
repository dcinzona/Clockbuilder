//
//  UILazyImageView.h
//  ClockBuilder
//
//  Created by Gustavo Tandeciarz on 4/16/12.
//  Copyright (c) 2012 GMTAZ.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILazyImageView : UIImageView{
    NSMutableData *receivedData;
}
- (id)initWithURL:(NSURL *)url;
- (void)loadWithURL:(NSURL *)url;
@end
