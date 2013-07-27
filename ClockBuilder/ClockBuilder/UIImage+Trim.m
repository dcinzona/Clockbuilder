#import "UIImage+Alpha.h"

@implementation UIImage (Trim)

- (UIImage *) imageByTrimmingTransparentPixels {
	int rows = self.size.height;
	int cols = self.size.width;
	int bytesPerRow = cols*sizeof(uint8_t);
	
	if ( rows < 2 || cols < 2 ) {
		return self;
	}
	
	//allocate array to hold alpha channel
	uint8_t *bitmapData = calloc(rows*cols, sizeof(uint8_t));
	
	//create alpha-only bitmap context
	CGContextRef contextRef = CGBitmapContextCreate(bitmapData, cols, rows, 8, bytesPerRow, NULL, kCGImageAlphaOnly);
	
	//draw our image on that context
	CGImageRef cgImage = self.CGImage;
	CGRect rect = CGRectMake(0, 0, cols, rows);
	CGContextDrawImage(contextRef, rect, cgImage);

	//summ all non-transparent pixels in every row and every column
	uint16_t *rowSum = calloc(rows, sizeof(uint16_t));
	uint16_t *colSum = calloc(cols, sizeof(uint16_t));
	
	//enumerate through all pixels
	for ( int row = 0; row < rows; row++) {
		for ( int col = 0; col < cols; col++)
		{
			if ( bitmapData[row*bytesPerRow + col] ) { //found non-transparent pixel
				rowSum[row]++;
				colSum[col]++;
			}
		}
	}
	
	//initialize crop insets and enumerate cols/rows arrays until we find non-empty columns or row
	UIEdgeInsets crop = UIEdgeInsetsMake(0, 0, 0, 0);
	
	for ( int i = 0; i<rows; i++ ) { 		//top
		if ( rowSum[i] > 0 ) {
			crop.top = i; break;
		}
	}
	
	for ( int i = rows; i >= 0; i-- ) {		//bottom
		if ( rowSum[i] > 0 ) {
			crop.bottom = MAX(0, rows-i-1); break;
		}
	}
	
	for ( int i = 0; i<cols; i++ ) {		//left
		if ( colSum[i] > 0 ) {
			crop.left = i; break;
		}
	}
	
	for ( int i = cols; i >= 0; i-- ) {		//right
		if ( colSum[i] > 0 ) {
			crop.right = MAX(0, cols-i-1); break;
		}
	}
	
	free(bitmapData);
	free(colSum);
	free(rowSum);
	
	if ( crop.top == 0 && crop.bottom == 0 && crop.left == 0 && crop.right == 0 ) {
		//no cropping needed
		return self;
	}
	else {
		//calculate new crop bounds
		rect.origin.x += crop.left;
		rect.origin.y += crop.top;
		rect.size.width -= crop.left + crop.right;
		rect.size.height -= crop.top + crop.bottom;
		
		//crop it
		CGImageRef newImage = CGImageCreateWithImageInRect(cgImage, rect);
		
		//convert back to UIImage
		return [UIImage imageWithCGImage:newImage];
	}
}

- (CGSize) imageSizeByTrimmingTransparentPixels {
    
	int rows = self.size.height;
	int cols = self.size.width;
	int bytesPerRow = cols*sizeof(uint8_t);
	
	if ( rows < 2 || cols < 2 ) {
		return self.size;
	}
	
	//allocate array to hold alpha channel
	uint8_t *bitmapData = calloc(rows*cols, sizeof(uint8_t));
	
	//create alpha-only bitmap context
	CGContextRef contextRef = CGBitmapContextCreate(bitmapData, cols, rows, 8, bytesPerRow, NULL, kCGImageAlphaOnly);
	//CGContextSetAllowsAntialiasing(contextRef, NO);
    //CGContextSetAllowsFontSmoothing(contextRef, NO);
    //CGContextSetInterpolationQuality(contextRef, kCGInterpolationNone);
    
	//draw our image on that context
	CGImageRef cgImage = self.CGImage;
	CGRect rect = CGRectMake(0, 0, cols, rows);
	CGContextDrawImage(contextRef, rect, cgImage);
    
	//summ all non-transparent pixels in every row and every column
	uint16_t *rowSum = calloc(rows, sizeof(uint16_t));
	uint16_t *colSum = calloc(cols, sizeof(uint16_t));
	
	//enumerate through all pixels
	for ( int row = 0; row < rows; row++) {
		for ( int col = 0; col < cols; col++)
		{
			if ( bitmapData[row*bytesPerRow + col] ) { //found non-transparent pixel
				rowSum[row]++;
				colSum[col]++;
			}
		}
	}
	
	//initialize crop insets and enumerate cols/rows arrays until we find non-empty columns or row
	UIEdgeInsets crop = UIEdgeInsetsMake(0, 0, 0, 0);
	
	for ( int i = 0; i<rows; i++ ) { 		//top
		if ( rowSum[i] > 0 ) {
			crop.top = i; break;
		}
	}
	
	for ( int i = rows; i >= 0; i-- ) {		//bottom
		if ( rowSum[i] > 0 ) {
			crop.bottom = MAX(0, rows-i-1); break;
		}
	}
	
	for ( int i = 0; i<cols; i++ ) {		//left
		if ( colSum[i] > 0 ) {
			crop.left = i; break;
		}
	}
	
	for ( int i = cols; i >= 0; i-- ) {		//right
		if ( colSum[i] > 0 ) {
			crop.right = MAX(0, cols-i-1); break;
		}
	}
	
	free(bitmapData);
	free(colSum);
	free(rowSum);
	
	if ( crop.top == 0 && crop.bottom == 0 && crop.left == 0 && crop.right == 0 ) {
		//no cropping needed
		return self.size;
	}
	else {
		//calculate new crop bounds
		rect.origin.x += crop.left;
		rect.origin.y += crop.top;
		rect.size.width -= crop.left + crop.right;
		rect.size.height -= crop.top + crop.bottom;
		
        return rect.size;
	}
}

@end