//
//  UILazyImageView.m
//  ClockBuilder
//
//  Created by Gustavo Tandeciarz on 4/16/12.
//  Copyright (c) 2012 GMTAZ.com. All rights reserved.
//

#import "UILazyImageView.h"
#import "UIImageView+WebCache.h"

@implementation UILazyImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
- (id)initWithURL:(NSURL *)url
{
    self = [self init];
    
    if (self)
    {
	    receivedData = [[NSMutableData alloc] init];
        NSLog(@"screenshotURL: %@", url);
        [self loadWithURL:url];
    }
    
    return self;
}
- (void)loadWithURL:(NSURL *)url    
{
	self.alpha = 0;
    __block UIImageView *weakSelf = self;
    [self setImageWithURL:url placeholderImage:nil success:^(UIImage *image) {
        [UIView beginAnimations:@"fadeIn" context:NULL];
        [UIView setAnimationDuration:0.5];
        weakSelf.alpha = 1.0;
        [UIView commitAnimations];
    } failure:^(NSError *error) {
        
    }];
    /*
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:url]delegate:self];
    [connection start];
     */
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.image = [[UIImage alloc] initWithData:receivedData];
    [UIView beginAnimations:@"fadeIn" context:NULL];
    [UIView setAnimationDuration:0.5];
    self.alpha = 1.0;
    [UIView commitAnimations];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [receivedData setLength:0];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
}


@end
