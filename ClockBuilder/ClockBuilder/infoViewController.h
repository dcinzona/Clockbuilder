//
//  infoViewController.h
//  ClockBuilder
//
//  Created by Gustavo Tandeciarz on 4/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface infoViewController : UIViewController < UIWebViewDelegate, MFMailComposeViewControllerDelegate> {
    IBOutlet UIImageView * iconView;
    IBOutlet UILabel * appNameVer;
}
-(IBAction)clearCache;
@property (strong, nonatomic) UIImageView *iconView;
@property (strong, nonatomic) UILabel *appNameVer;
@property (unsafe_unretained, nonatomic) IBOutlet UIWebView *infoWebView;
@property (strong, nonatomic) IBOutlet UIImageView *bgView;

@end
