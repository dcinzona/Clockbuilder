//
//  sliderSelectorCell.h
//  ClockBuilder
//
//  Created by gtadmin on 6/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface sliderSelectorCell : UITableViewCell {
    UIImageView *sliderImage;
}
@property (nonatomic) UIImageView *sliderImage;
-(void)loadImage:(NSString *)url;
@end
