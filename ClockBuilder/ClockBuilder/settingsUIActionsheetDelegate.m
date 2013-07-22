//
//  settingsUIActionsheetDelegate.m
//  ClockBuilder
//
//  Created by Gustavo Tandeciarz on 4/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "settingsUIActionsheetDelegate.h"


@implementation settingsUIActionsheetDelegate

-(id)init
{
    if(self == [super init])
    {
        self = (settingsUIActionsheetDelegate*)[[UIActionSheet alloc] initWithTitle:@"Options" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Set Background",@"Weather Options", @"Change All Text", nil];
        [self setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    }
    return self;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// the user clicked one of the OK/Cancel buttons
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    UIWindow *window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    
    if([title isEqualToString:@"Set Background"])
    {        
        ImagePickerView *imagepicker = [[ImagePickerView alloc] init] ;
        imagepicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [imagepicker setDelegate:imagepicker];
        [window.rootViewController presentViewController:imagepicker animated:YES completion:nil];
    }
    if([title isEqualToString:@"Weather Options"])
    {        
        weatherSettingsIndex *wSettings = [[weatherSettingsIndex alloc] initWithStyle:UITableViewStylePlain];
        [window.rootViewController presentViewController:wSettings animated:YES completion:nil];
    }
}


@end
