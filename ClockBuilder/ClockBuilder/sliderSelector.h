//
//  sliderSelector.h
//  ClockBuilder
//
//  Created by gtadmin on 6/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface sliderSelector : UITableViewController {
    BOOL _valid;
    BOOL _showRefreshed; 
    BOOL Done1x;
    BOOL Done2x;
    int selectedSlider;
    NSArray *themesArray;
}

@end
