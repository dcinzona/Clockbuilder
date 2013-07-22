//
//  slideShowImageSaverOperation.m
//  ClockBuilder
//
//  Created by gtadmin on 5/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "slideShowImageSaverOperation.h"
#import "UIImage+Resize.h"


@implementation slideShowImageSaverOperation
@synthesize image;

- (id)initWithImage:(UIImage*)_image filePath:(NSString *)_path
{
    if (![super init]) return nil;
    [self setImage:_image];
    path = [_path copy];
    return self;
}

- (void)dealloc {
    path = nil;
}

-(void)saveImageThumb:(NSString *)_thumbPath
{
    //NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	if (image != nil) {
        // the path to write file
		
		UIImage *sourceImage = image;
		UIImage *newImage = nil;        
		CGSize imageSize = sourceImage.size;
		CGSize targetSize = CGSizeMake(50, 50);
		CGFloat width = imageSize.width;
		CGFloat height = imageSize.height;
		CGFloat targetWidth = targetSize.width;
		CGFloat targetHeight = targetSize.height;
		CGFloat scaleFactor = 0.0;
		CGFloat scaledWidth = targetWidth;
		CGFloat scaledHeight = targetHeight;
		CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
		
		if (CGSizeEqualToSize(imageSize, targetSize) == NO) 
        {
			CGFloat widthFactor = targetWidth / width;
			CGFloat heightFactor = targetHeight / height;
			
			if (widthFactor > heightFactor) 
                scaleFactor = widthFactor; // scale to fit height
			else
                scaleFactor = heightFactor; // scale to fit width
			scaledWidth  = width * scaleFactor;
			scaledHeight = height * scaleFactor;
			
			// center the image
			if (widthFactor > heightFactor)
			{
                thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5; 
			}
			else 
                if (widthFactor < heightFactor)
				{
					thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
				}
        }       
		
		UIGraphicsBeginImageContext(targetSize); // this will crop
		
		CGRect thumbnailRect = CGRectZero;
		thumbnailRect.origin = thumbnailPoint;
		thumbnailRect.size.width  = scaledWidth;
		thumbnailRect.size.height = scaledHeight;
		
		[sourceImage drawInRect:thumbnailRect];
		
		newImage = UIGraphicsGetImageFromCurrentImageContext();
		if(newImage == nil) 
			NSLog(@"could not scale image");
		else {
			
			//pop the context to get back to the default
			UIGraphicsEndImageContext();
			//UIImage *bg = [newImage resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:croppedSize interpolationQuality:1.0];
			NSData *newImageData =  UIImagePNGRepresentation(newImage);
            NSString *appFilePNG = [_thumbPath stringByReplacingOccurrencesOfString:@".jpg" withString:@"_th.png"];
            if([newImageData writeToFile:appFilePNG atomically:YES])
            {
            }
		}
    }
    //[pool release];
}
- (void)main {
	if (image != nil) {
        
        UIImage *newImage = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFit 
                                                        bounds:CGSizeMake(640, 960) 
                                          interpolationQuality:kCGInterpolationHigh];
        UIImage *thumb = [newImage resizedImageWithContentMode:UIViewContentModeScaleAspectFit 
                                                        bounds:CGSizeMake(50, 50) 
                                          interpolationQuality:kCGInterpolationLow];
        
        NSString *appFilePNG = path;
        NSString *thumbpath = [appFilePNG stringByReplacingOccurrencesOfString:@".jpg" withString:@"_th.png"];
        
        NSData *newImageData =  UIImageJPEGRepresentation(newImage, 80);
        
        NSData *thumbData =  UIImageJPEGRepresentation(thumb, 80);
        if([newImageData writeToFile:appFilePNG atomically:YES])
        {   
            
            NSLog(@"image %@ saved", path);
            [thumbData writeToFile:thumbpath atomically:YES];
        }
        
        // the path to write file
		//[self saveImageThumb:path];
        /*
		UIImage *sourceImage = image;
		UIImage *newImage = nil;        
		CGSize imageSize = sourceImage.size;
		CGSize targetSize = CGSizeMake(320, 480);
		if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
			if ((NSInteger)[[UIScreen mainScreen] scale] == 2) {
				targetSize = CGSizeMake(640, 960);
			}
		}
		CGFloat width = imageSize.width;
		CGFloat height = imageSize.height;
		CGFloat targetWidth = targetSize.width;
		CGFloat targetHeight = targetSize.height;
		CGFloat scaleFactor = 0.0;
		CGFloat scaledWidth = targetWidth;
		CGFloat scaledHeight = targetHeight;
		CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
		
		if (CGSizeEqualToSize(imageSize, targetSize) == NO) 
        {
			CGFloat widthFactor = targetWidth / width;
			CGFloat heightFactor = targetHeight / height;
			
			if (widthFactor > heightFactor) 
                scaleFactor = widthFactor; // scale to fit height
			else
                scaleFactor = heightFactor; // scale to fit width
			scaledWidth  = width * scaleFactor;
			scaledHeight = height * scaleFactor;
			
			// center the image
			if (widthFactor > heightFactor)
			{
                thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5; 
			}
			else 
                if (widthFactor < heightFactor)
				{
					thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
				}
        }       
		
		UIGraphicsBeginImageContext(targetSize); // this will crop
		
		CGRect thumbnailRect = CGRectZero;
		thumbnailRect.origin = thumbnailPoint;
		thumbnailRect.size.width  = scaledWidth;
		thumbnailRect.size.height = scaledHeight;
		
		[sourceImage drawInRect:thumbnailRect];
		
		newImage = UIGraphicsGetImageFromCurrentImageContext();
		if(newImage == nil) 
			NSLog(@"could not scale image");
		else {
			
			//pop the context to get back to the default
			UIGraphicsEndImageContext();
			NSData *newImageData =  UIImageJPEGRepresentation(newImage, 80);
            
            NSString *appFilePNG = path;
            if([newImageData writeToFile:appFilePNG atomically:YES])
            {   
                NSLog(@"image %@ saved", path);
                [path release];
            }
		}
        
	}*/
        

    }
}

@end