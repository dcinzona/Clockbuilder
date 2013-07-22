//
//  infoViewController.m
//  ClockBuilder
//
//  Created by Gustavo Tandeciarz on 4/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "infoViewController.h"
#import "UIImageView+WebCache.h"
#import "SDImageCache.h"
#import "themeConverter.h"

@implementation infoViewController
@synthesize infoWebView;
@synthesize iconView, appNameVer;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect frameSize = [UIScreen mainScreen].bounds;
    if(!kIsiOS7){
        //adjust for navbar
        frameSize.size.height = frameSize.size.height - 44;
        
    }
    
    if (kIsIpad) {
        self.contentSizeForViewInPopover = kPopoverSize;
        [self.view setFrame:CGRectMake(0, 0,
                                       self.view.frame.size.width,
                                       kPopoverSize.height)];
        frameSize = self.view.frame;
    }
    
    UIImageView *bg2 = [[UIImageView alloc] initWithFrame:frameSize];
    [bg2 setImage:[UIImage imageNamed:@"tableGradient"]];
    UIColor *tableBGColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"office"]];
    [bg2 setContentMode:UIViewContentModeTop];
    UIView *bgViewMain = [[UIView alloc] initWithFrame:bg2.frame];
    [bgViewMain addSubview:bg2];
    [bgViewMain setBackgroundColor:tableBGColor];
    [self.view insertSubview:bgViewMain aboveSubview:_bgView];
    
    // Do any additional setup after loading the view from its nib.
    self.title = @"Clock Builder";
    [appNameVer setText:[NSString stringWithFormat:@"Clock Builder %@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]]];
    //[iconView setImage:[UIImage imageNamed:@"clockbuilder-Icon.png"]];
    
    if(kIsIpad){
        UIBarButtonItem *supportButton = [[UIBarButtonItem alloc] initWithTitle:@"Support" style:UIBarButtonItemStyleBordered target:self action:@selector(emailMe)];
        self.navigationItem.rightBarButtonItem = supportButton;
    }
    else{
        UIBarButtonItem *backButton = [CBThemeHelper createBackButtonItemWithTitle:@"Settings" target:self.navigationController action:@selector(popViewControllerAnimated:)];
        //[self.navigationItem setBackBarButtonItem:backButton];
        [self.navigationItem setLeftBarButtonItem: backButton];
        
        UIBarButtonItem *doneButton = [CBThemeHelper createDoneButtonItemWithTitle:@"Support" target:self action:@selector(emailMe)];
        self.navigationItem.rightBarButtonItem = doneButton;
    }
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    // Since the buttons can be any width we use a thin image with a stretchable center point
    UIImage *buttonImage = [[UIImage imageNamed:@"ButtonDarkGrey30px.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:5];
    UIImage *buttonPressedImage = [[UIImage imageNamed:@"ButtonDarkGrey30pxSelected.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:5];
    
    [[button titleLabel] setFont:[UIFont boldSystemFontOfSize:12.0]];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [button setTitleShadowColor:[UIColor colorWithWhite:0.0 alpha:0.7] forState:UIControlStateNormal];
    [button setTitleShadowColor:[UIColor colorWithWhite:0.0 alpha:0.7] forState:UIControlStateHighlighted];
    [[button titleLabel] setShadowOffset:CGSizeMake(0.0, -1.0)];
    
    CGRect buttonFrame = [button frame];
    buttonFrame.size.width = [@"Clear Cache" sizeWithFont:[UIFont boldSystemFontOfSize:14.0]].width + 20.0;
    buttonFrame.size.height = buttonImage.size.height;
    [button setFrame:buttonFrame];
    
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [button setBackgroundImage:buttonPressedImage forState:UIControlStateHighlighted];
    
    [button setTitle:@"Clear Cache" forState:UIControlStateNormal];
    
    [button addTarget:self action:@selector(clearCache) forControlEvents:UIControlEventTouchUpInside];

    NSLog(@"info clear cache frame height: %f", frameSize.size.height);
    NSLog(@"info clear cache frame position: %f", (frameSize.size.height-80)-button.frame.size.height);
    
    
    CGRect buttonFrame2 = CGRectMake(160-(button.frame.size.width/2),
                                    (frameSize.size.height-40)-button.frame.size.height,
                                    button.frame.size.width,
                                    button.frame.size.height);
    
    
    [button setFrame:buttonFrame2];
    [self.view addSubview:button];
    
    
    
    themeConverter *th = [[themeConverter alloc] init];
    if([infoWebView respondsToSelector:@selector(scrollView)]){
        [infoWebView.scrollView setScrollEnabled:NO];
        infoWebView.scrollView.bounces = NO;
    }
    if ([th checkIfJB]) {
        infoWebView.hidden = NO;
        
        NSString *textString = @"<html><body style=\"background-color: transparent;font-family:sans-serif;color:#c0c0c0;font-size:12px;\"><p>Having trouble setting your lockscreen? </p><p>  Try installing GMTSync from Cydia or LSSync from my repo.</p><p>To get GMTSync, just search Cydia.  </p><p>To get LSSync, add my repo: <a href=\"http://static.gmtaz.com\">http://static.gmtaz.com</a> to your Cydia sources and search for LSSync.</p><p>More info can be found on my blog at <a href=\"http://gmtaz.com/blog\">gmtaz.com/blog</a></p></body></html>";
        [infoWebView loadHTMLString:textString baseURL:nil];
        if([[GMTHelper sharedInstance] deviceIsConnectedToInet]){
            [infoWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://clockbuilder.gmtaz.com/cbinfo.html"]]];
        }
    }
    else {
        infoWebView.hidden = YES;
    }
    

    
}
-(BOOL) webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType {
    if ( inType == UIWebViewNavigationTypeLinkClicked ) {
        [[UIApplication sharedApplication] openURL:[inRequest URL]];
        return NO;
    }
    
    return YES;
}

-(void)emailMe
{

    if ([MFMailComposeViewController canSendMail]) {
        /*
        NSBundle *bundle = [NSBundle mainBundle];
        NSString* bundlePath = [bundle bundlePath];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *widget = @"Ixnmfom.pldisxt";
        NSString* path = [NSString stringWithFormat:@"%@/%@", bundlePath, [[[widget stringByReplacingOccurrencesOfString:@"x" withString:@""] stringByReplacingOccurrencesOfString:@"m" withString:@""] stringByReplacingOccurrencesOfString:@"d" withString:@""] ];
        
        NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:path error:NULL];
        
        NSNumber *fileSize;
        if (fileAttributes != nil) {
            
            if ((fileSize = [fileAttributes objectForKey:NSFileSize])) {
                NSLog(@"File size: %qi\n", [fileSize unsignedLongLongValue]);
            }           
            if([fileSize unsignedLongLongValue] != 1981){
                NSLog(@"Not the right size: %@", fileSize);
            }
        }*/
        //NSString *fileSizeS = [NSString stringWithFormat:@"%qi", [fileSize unsignedLongLongValue]];
        //NSString *iosVersion = [[UIDevice currentDevice] systemVersion];
        //NSString *dataString = [NSString stringWithFormat:@"[fileSize: %@] [ios version: %@] [Not Used: %@]",fileSizeS, iosVersion, @"Not Used"];
        
        //NSData *dataFromString = [dataString dataUsingEncoding:NSUTF8StringEncoding];
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        [mailViewController.navigationBar setBarStyle:UIBarStyleBlack];
        mailViewController.mailComposeDelegate = self;
        [mailViewController.toolbar setBarStyle:UIBarStyleBlack];
        [mailViewController setToRecipients:[NSArray arrayWithObject:@"gmt@gmtaz.com"]];
        [mailViewController setSubject:[NSString stringWithFormat:@"Support: Clock Builder %@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]]];
        [mailViewController setMessageBody:@"" isHTML:YES];
        
        //[mailViewController addAttachmentData:dataFromString mimeType:@"application/xml" fileName:[NSString stringWithFormat:@"%@", @"DEBUGDATA"]];
        [self presentModalViewController:mailViewController animated:YES];
    }
    
    else {
        
        NSLog(@"Device is unable to send email in its current state.");
        
    }

}

-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    
    [self dismissModalViewControllerAnimated:YES];
    
}

-(IBAction)clearCache
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setLabelText:@"Clearing Cache"];
    [hud hide:YES afterDelay:15];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul), ^{
        
        SDImageCache *imageCache = [SDImageCache sharedImageCache];
        [imageCache clearMemory];
        [imageCache clearDisk];
        [imageCache cleanDisk];
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        });
        
    });
    
}

- (void)viewDidUnload
{
    [self setInfoWebView:nil];
    [self setBgView:nil];
    [super viewDidUnload];    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
