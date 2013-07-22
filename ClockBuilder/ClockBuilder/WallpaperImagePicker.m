//
//  WallpaperImagePicker.m
//  ClockBuilder
//
//  Created by Gustavo Tandeciarz on 7/2/13.
//
//


#import "WallpaperImagePicker.h"
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@implementation WallpaperImagePicker

@synthesize imagePickerController;
@synthesize loadingOverlay;
@synthesize bgData;
@synthesize popover;

- (id)init {
	self = [super init];
	
	if(self != nil) {
        imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [imagePickerController setAllowsEditing:YES];
        [imagePickerController shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationPortrait];
        [imagePickerController.navigationBar setBarStyle:UIBarStyleBlackOpaque];
	}
	
	return self;
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	// add ok and cancel buttons to controller
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"No Image"
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(selectBlackBG)];
	viewController.navigationItem.leftBarButtonItem = doneButton;
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]
                                     initWithTitle:@"Cancel"
                                     style:UIBarButtonItemStylePlain
                                     target:self
                                     action:@selector(imagePickerControllerDidCancel:)];
	viewController.navigationItem.rightBarButtonItem = cancelButton;
    
    /*
     [navigationController setToolbarHidden:NO animated:NO];
     // customize controller size to make room for selected pics
     navigationController.toolbar.frame = CGRectMake(0,400,320,80);
     navigationController.toolbar.tintColor = [UIColor grayColor];*/
}
- (void)selectBlackBG
{
    
    UIImage *black = [UIImage imageNamed:@"LockBackground.png"];
    
    [self saveImageAsynchUsingImage:black];
    [self dismissModalViewControllerAnimated:YES];
}
-(void)removeLoadingOverlay
{
    [[GMTHelper sharedInstance] notifyToHideGlobalHud];
    if([self.parentViewController respondsToSelector:@selector(viewWillAppear:)])
        [self.parentViewController performSelector:@selector(viewWillAppear:) withObject:nil];
    [self dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    [[GMTHelper sharedInstance] notifyToShowGlobalHudWithSpinner:@"Scaling Image" andHide:YES withDelay:20 andDim:YES];
    NSOperationQueue *q = [NSOperationQueue new];
    NSInvocationOperation *save = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(saveImageAsynchUsingImage:) object:image];
    [q addOperation:save];
}

-(void)saveImageThumb:(UIImage *)image
{
    //NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	if (image != nil) {
        // the path to write file
		
		UIImage *sourceImage = image;
		UIImage *newImage = nil;
		CGSize imageSize = sourceImage.size;
		CGSize targetSize = CGSizeMake(50, 50);
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
            if ((NSInteger)[[UIScreen mainScreen] scale] == 2) {
                targetSize = CGSizeMake(100, 100);
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
			//UIImage *bg = [newImage resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:croppedSize interpolationQuality:1.0];
			NSData *newImageData =  UIImagePNGRepresentation(newImage);
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *appFilePNG = [documentsDirectory stringByAppendingPathComponent:@"LockBackgroundThumb.png"];
            if([newImageData writeToFile:appFilePNG atomically:YES])
            {
            }
            if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
                if ((NSInteger)[[UIScreen mainScreen] scale] == 2) {
                    appFilePNG = [documentsDirectory stringByAppendingPathComponent:@"LockBackgroundThumb@2x.png"];
                    if([newImageData writeToFile:appFilePNG atomically:YES])
                    {
                    }
                }
            }
		}
    }
    //[pool release];
}

UIImage * resizeImageTo1x(UIImage * img, CGSize newSize){
    UIGraphicsBeginImageContext(newSize);
    
    //or other CGInterpolationQuality value
    CGContextSetInterpolationQuality(UIGraphicsGetCurrentContext(), kCGInterpolationDefault);
    
    [img drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
-(void)saveImageAsynchUsingImage:(UIImage *)image
{
    if([[GMTHelper sharedInstance] resizeImageToBackground:image]){
        
    }
    [self performSelector:@selector(removeLoadingOverlay)  onThread:[NSThread mainThread] withObject:nil waitUntilDone:YES];
    if(kIsIpad)
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshBG" object:nil];
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	// Dismiss the image selection and close the program
    
	[self dismissModalViewControllerAnimated:YES];
	//exit(0);
}

-(void)dismissModalViewControllerAnimated:(BOOL)animated{
    if(kIsIpad)
    {
        [popover dismissPopoverAnimated:YES];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshBG" object:nil];
    [super dismissModalViewControllerAnimated:animated];
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */


@end
