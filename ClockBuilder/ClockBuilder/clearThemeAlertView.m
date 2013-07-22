//
//  clearThemeAlertView.m
//  ClockBuilder
//
//  Created by gtadmin on 3/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "clearThemeAlertView.h"


@implementation clearThemeAlertView

- (void)drawRect:(CGRect)rect {
}

- (void) show{
    
    [super show];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if([title isEqualToString:@"Yes"])
    {
        //delete all widgets from widgets list
        [[[UIApplication sharedApplication] delegate] performSelector:@selector(resetTheme)];
    }
    
    
    
    [self performSelector:@selector(closeView)];

}

- (void) closeView{
    [self dismissWithClickedButtonIndex:0 animated:YES];
}



@end
