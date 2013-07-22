//
//  gridViewController.m
//  ClockBuilder
//
//  Created by Gustavo Tandeciarz on 4/16/12.
//  Copyright (c) 2012 GMTAZ.com. All rights reserved.
//

#import "gridViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UILazyImageView.h"
#import "UIImageView+WebCache.h"
#import "SDImageCache.h"
#import "JSONKit.h"
#import "MKEntryPanel.h"
#import "ClockBuilderAppDelegate.h"

@interface gridViewController ()
{
    BOOL isLoading;
    GMGridView *_gmGridView;
    
    UIView *_loadingView;
    
    
    NSMutableArray *_data;
    NSMutableArray *_currentData;
    
    UIImageView *thumbnailView;
    
    NSString *selectedCategory;
    NSArray *categories;
    
    UIPickerView *catPicker;
    
    BOOL _pickerVisible;
    
    NSString* themeNameToDownload;
    NSInteger selectedIndex;
    
#ifdef DEBUG
    NSDateFormatter *dateformatter;
#endif
    
}
-(void)getThemesFromOnline;
-(void)showThemePicker;

@end

@implementation gridViewController

@synthesize delegate;
@synthesize theme;

-(NSArray *)getCategoriesArray{
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        categories = [[GMTHelper sharedInstance] getCategoriesArray];
        if(selectedCategory==nil){
            if(categories && categories.count > 0){
                selectedCategory = [categories objectAtIndex:0];
            }
        }
    });
    return categories;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        /*
         UIImageView *bg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
         [bg setImage:[UIImage imageNamed:@"fadedBG.JPG"]];
         [self.view addSubview:bg];
         
         bg.layer.masksToBounds = NO;
         bg.layer.cornerRadius = 0;
         [bg.layer setShadowColor:[UIColor blackColor].CGColor];
         bg.layer.shadowOffset = CGSizeMake(0,0);
         bg.layer.shadowRadius = 10;
         bg.layer.shadowOpacity = 1;
         bg.layer.shadowPath = [UIBezierPath bezierPathWithRect:bg.bounds].CGPath;
         */
        if(!kIsiOS7){
            UIImageView *bg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, [UIScreen mainScreen].bounds.size.height)];
            [bg setImage:[UIImage imageNamed:@"tableGradient"]];
            [bg setContentMode:UIViewContentModeTop];
            UIView *bgView = [[UIView alloc] initWithFrame:bg.frame];
            [self.view addSubview:bgView];
            [bgView addSubview:bg];
            UIColor *tableBGColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"office"]];
            [bgView setBackgroundColor:tableBGColor];
        }
        // Custom initialization
        _gmGridView = [[GMGridView alloc] initWithFrame:self.view.bounds];
        _gmGridView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _gmGridView.backgroundColor = [UIColor clearColor];
        if(kIsiOS7){
            [_gmGridView setBackgroundColor:[UIColor whiteColor]];
            [self.view setBackgroundColor:[UIColor whiteColor]];
        }
        [_gmGridView setClipsToBounds:YES];
        [self.view addSubview:_gmGridView];
        
        _gmGridView.style = GMGridViewStyleSwap;
        _gmGridView.itemSpacing = 10;
        _gmGridView.minEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        _gmGridView.centerGrid = YES;
        _gmGridView.actionDelegate = self;
        //_gmGridView.transformDelegate = self;
        _gmGridView.dataSource = self;
        
        
        if(kIsIpad){
            UIBarButtonItem *search = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"NavigationSearchButton.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(showThemePicker)];
            self.navigationItem.rightBarButtonItem = search;
            self.navigationItem.leftBarButtonItem = self.navigationItem.backBarButtonItem;
        }
        else{
            if(kIsiOS7){
                self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(showThemePicker)];
            }
            else{
                UIBarButtonItem *searchButton = [CBThemeHelper createButtonItemWithImage:[UIImage imageNamed:@"NavigationSearchButton.png"]
                                                                         andPressedImage:[UIImage imageNamed:@"NavigationSearchButton.png"]
                                                                                  target:self action:@selector(showThemePicker)
                                                 ];
                self.navigationItem.rightBarButtonItem = searchButton;
            }
            UIBarButtonItem *backButton = [CBThemeHelper createBackButtonItemWithTitle:@"Saved" target:self.navigationController action:@selector(popViewControllerAnimated:)];
            [self.navigationItem setLeftBarButtonItem: backButton];
        }
        
        _data =[NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"onlineThemesArray"]];
        selectedCategory = [[NSUserDefaults standardUserDefaults] objectForKey:@"onlineThemesArrayCategory"];
        //if(selectedCategory==nil){
        [self getCategoriesArray];
        //}
        if(!_data)
            [self getThemesFromOnline];
        else {
            _currentData = _data;
            [_gmGridView reloadData];
        }
#ifdef DEBUG
        dateformatter = [NSDateFormatter new];
#endif
        
    }
    return self;
}


- (BOOL)isSimulator {
	static NSString *simulatorModel = @"iPhone Simulator";
	return [[[UIDevice currentDevice] model] isEqualToString:simulatorModel];
}



-(void)getThemesFromOnline{
    
    JSONDecoder *decoder = [[JSONDecoder alloc] init];
    //getJSON
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        if(!isLoading){
            if(selectedCategory==nil || selectedCategory.length<2){
                selectedCategory = @"Automotive";
            }
            else {
                //try updating categories
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    isLoading = NO;
                    [self getCategoriesArray];
                });
            }
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                NSDictionary *dict = [[GMTHelper sharedInstance] buildDictForHUDWithLabelText:nil andImage:nil andHide:YES withDelay:10 andDim:YES];
                [[GMTHelper sharedInstance] notifyToShowGlobalHudWithDict:dict];
            });
            if([[GMTHelper sharedInstance] deviceIsConnectedToInet]){
                isLoading = YES;
                NSString *URL = [NSString stringWithFormat:@"http://clockbuilder.gmtaz.com/getThemes2.php?api=SDFB52f4vw9230V45gdfg&v=1.5.1&category=%@",[selectedCategory stringByReplacingOccurrencesOfString:@"-" withString:@""]];
                if (kIsIpad) {
                    URL = [NSString stringWithFormat:@"http://clockbuilder.gmtaz.com/getThemes-ipad.php?api=SDFB52f4vw9230V45gdfg&v=1.5.1&category=%@",[selectedCategory stringByReplacingOccurrencesOfString:@"-" withString:@""]];
                }
                
#ifdef DEBUG
                if([[selectedCategory stringByReplacingOccurrencesOfString:@"-" withString:@""] isEqualToString:@"New Themes"]){
                    
                    NSString *lastChecked = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastCheckedForNewThemes"];
                    if(!lastChecked){
                        lastChecked = @"09/3/12";
                    }
                    
                    URL = [NSString stringWithFormat:@"http://clockbuilder.gmtaz.com/getNewThemes.php?api=SDFB52f4vw9230V45gdfg&time=%@",lastChecked];
                    if (kIsIpad) {
                        URL = [NSString stringWithFormat:@"http://clockbuilder.gmtaz.com/getNewThemes-ipad.php?api=SDFB52f4vw9230V45gdfg&time=%@",lastChecked];
                    }
                    
                    //update last checked to Today
                    if(!dateformatter)
                        dateformatter = [NSDateFormatter new];
                    [dateformatter setDateFormat:@"yyyy-MM-dd"];
                    lastChecked = [dateformatter stringFromDate:[NSDate date]];
                    [[NSUserDefaults standardUserDefaults] setObject:lastChecked forKey:@"lastCheckedForNewThemes"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    NSLog(@"last checked: %@",lastChecked);
                    
                }
#endif
                
                NSString *jsonString = [NSString stringWithContentsOfURL:[NSURL URLWithString:URL] encoding:NSUTF8StringEncoding error:nil];
                NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
                NSArray *tempArray = [decoder objectWithData:data];
                _data = [[NSMutableArray alloc]initWithArray:tempArray];
                _currentData = _data;
                [[NSUserDefaults standardUserDefaults] setObject:selectedCategory forKey:@"onlineThemesArrayCategory"];
                [[NSUserDefaults standardUserDefaults] setObject:_data forKey:@"onlineThemesArray"];
                [[NSUserDefaults standardUserDefaults]synchronize];
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    isLoading = NO;
                    [[GMTHelper sharedInstance] notifyToHideGlobalHud];
                    [_gmGridView scrollToObjectAtIndex:0 atScrollPosition:GMGridViewScrollPositionTop animated:NO];
                    [self.navigationController.navigationBar.topItem setTitle:[selectedCategory stringByReplacingOccurrencesOfString:@"-" withString:@""]];
                    [_gmGridView reloadData];
                });
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    isLoading = NO;
                    [[GMTHelper sharedInstance] notifyToHideGlobalHud];
                    
                    [[GMTHelper sharedInstance]alertNotConnected];
                });
            }
        }
    });
}

//////////////////////////////////////////////////////
#pragma mark NOTIFICATION CENTER STUFF
//////////////////////////////////////////////////////
-(void)completedUploadingTheme:(NSNotification*)notification{
    
    MBProgressHUD *HUD = ApplicationDelegate.globalHUD;
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"doneCheck.png"]];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.labelText = @"Theme Uploaded!";
    [HUD show:YES];
    [HUD hide:YES afterDelay:1];
    
    NSString *category = [[notification userInfo] objectForKey:@"category"];
    if([category isEqualToString:selectedCategory]){
        [self refreshThemes];
    }
    
}
-(void)refreshThemes{
    [[SDImageCache sharedImageCache] clearMemory];
    [self getThemesFromOnline];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (kIsIpad) {
        self.contentSizeForViewInPopover = kPopoverSize;
    }
	// Do any additional setup after loading the view.
    _gmGridView.mainSuperView = self.navigationController.view;
    [_gmGridView reloadData];
}
-(void)viewDidAppear:(BOOL)animated{
    [self.navigationController.navigationBar.topItem setTitle:[selectedCategory stringByReplacingOccurrencesOfString:@"-" withString:@""]];
    
    if(kIsIpad){
        UIBarButtonItem *search = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"NavigationSearchButton.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(showThemePicker)];
        self.navigationItem.rightBarButtonItem = search;
        self.navigationItem.leftBarButtonItem = self.navigationItem.backBarButtonItem;
    }
    else{
        
        if(kIsiOS7){
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(showThemePicker)];
        }
        else{
            UIBarButtonItem *searchButton = [CBThemeHelper createButtonItemWithImage:[UIImage imageNamed:@"NavigationSearchButton.png"]
                                                                     andPressedImage:[UIImage imageNamed:@"NavigationSearchButton.png"]
                                                                              target:self action:@selector(showThemePicker)
                                             ];
            self.navigationItem.rightBarButtonItem = searchButton;
        }
        UIBarButtonItem *backButton = [CBThemeHelper createBackButtonItemWithTitle:@"Saved" target:self.navigationController action:@selector(popViewControllerAnimated:)];
        [self.navigationItem setLeftBarButtonItem: backButton];
    }
}
-(void)viewWillAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(completedUploadingTheme:)
                                                 name:@"completedUploadingTheme"
                                               object:nil];
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"completedUploadingTheme" object:nil];
}
-(void)viewDidDisappear:(BOOL)animated{
    
    [self viewDidUnload];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    [[SDImageCache sharedImageCache] clearMemory];
    // Release any retained subviews of the main view.
    
    _currentData = nil;
    _gmGridView = nil;
    _data = nil;
    _loadingView = nil;
    thumbnailView = nil;
}


//////////////////////////////////////////////////////////////
#pragma mark GMGridViewDataSource
//////////////////////////////////////////////////////////////

#define kiPadThumbSizeWidth 90
#define kiPadThumbSizeHeight kiPadThumbSizeWidth * 1.25
#define kiPhoneThumbSizeHeight 129
#define kiPhoneThumbSizeWidth 90

- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView
{
    return [_currentData count];
}

- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    
    if(kIsIpad){
        return CGSizeMake(kiPadThumbSizeWidth, kiPadThumbSizeHeight);
    }
    
    return CGSizeMake(kiPhoneThumbSizeWidth, kiPhoneThumbSizeHeight);
}

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index
{
    //NSLog(@"Creating view indx %d", index);
    
    CGSize size = [self GMGridView:gridView sizeForItemsInInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    
    GMGridViewCell *cell = [gridView dequeueReusableCell];
    
    if (!cell)
    {
        cell = [[GMGridViewCell alloc] init];
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        if(!kIsiOS7){
            view.backgroundColor = [UIColor blackColor];
            view.layer.masksToBounds = NO;
            view.layer.cornerRadius = 0;
            [view.layer setShadowColor:[UIColor blackColor].CGColor];
            view.layer.shadowOffset = CGSizeMake(0,5);
            view.layer.shadowRadius = 5;
            view.layer.shadowOpacity = 1;
            view.layer.shadowPath = [UIBezierPath bezierPathWithRect:view.bounds].CGPath;
        }
        cell.contentView = view;
        
        CGRect frame = CGRectMake(0, 0, kiPhoneThumbSizeWidth, kiPhoneThumbSizeHeight);
        if(kIsIpad){
            frame = CGRectMake(0, 0, kiPadThumbSizeWidth, kiPadThumbSizeHeight);
        }
        
        UIImageView *thmb = [[UIImageView alloc] initWithFrame:frame];
        thmb.tag = 200;
        
        [cell.contentView addSubview:thmb];
    }
    
    //http://clockbuilder.gmtaz.com/resources/themes/1/themeScreenshot.jpg
    //[[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSDictionary *dict = (NSDictionary *)[_currentData objectAtIndex:index];
    NSString *themeName = (NSString *)[dict objectForKey:@"themeName"];
    NSURL *screenshotURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://clockbuilder.gmtaz.com/resources/themes/%@/themeScreenshot.jpg",themeName]];
    for (UIView *s in cell.contentView.subviews) {
        if (s.tag == 200) {
            UIImageView *thmb = (UIImageView*)s;
            [thmb setImageWithURL:screenshotURL success:^(UIImage *image) {
                
            } failure:^(NSError *error) {
                
            }];
        }
    }
    dict = nil;
    themeName = nil;
    screenshotURL = nil;
    [[SDImageCache sharedImageCache] clearMemory];
    return cell;
}


- (BOOL)GMGridView:(GMGridView *)gridView canDeleteItemAtIndex:(NSInteger)index
{
#ifdef DEBUG
    return YES; //index % 2 == 0;
#else
    return NO; //index % 2 == 0;
#endif
}

//////////////////////////////////////////////////////////////
#pragma mark GMGridViewActionDelegate
//////////////////////////////////////////////////////////////

-(BOOL)cancelCategoryPicker{
    if(_pickerVisible){
        //hide picker
        if(kIsIpad){
            
            UIBarButtonItem *search = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"NavigationSearchButton.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(showThemePicker)];
            self.navigationItem.rightBarButtonItem = search;
            
            self.navigationItem.leftBarButtonItem = self.navigationItem.backBarButtonItem;
        }
        else{
            
            if(kIsiOS7){
                self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(showThemePicker)];
            }
            else{
                UIBarButtonItem *searchButton = [CBThemeHelper createButtonItemWithImage:[UIImage imageNamed:@"NavigationSearchButton.png"]
                                                                         andPressedImage:[UIImage imageNamed:@"NavigationSearchButton.png"]
                                                                                  target:self action:@selector(showThemePicker)
                                                 ];
                self.navigationItem.rightBarButtonItem = searchButton;
            }
            
            UIBarButtonItem *backButton = [CBThemeHelper createBackButtonItemWithTitle:@"Saved" target:self.navigationController action:@selector(popViewControllerAnimated:)];
            //[self.navigationItem setBackBarButtonItem:backButton];
            [self.navigationItem setLeftBarButtonItem: backButton];
        }
        
        CGRect slidDown = CGRectMake(0, 0, _gmGridView.frame.size.width, _gmGridView.frame.size.height);
        UIView *bottomView = [self.view.subviews objectAtIndex:1];
        
        [UIView animateWithDuration:0.3
                              delay:0
                            options: UIViewAnimationCurveEaseOut
                         animations:^{
                             [bottomView setFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, 320, 180)];
                             [_gmGridView setFrame:slidDown];
                             [_gmGridView setAlpha:1];
                         }
                         completion:^(BOOL finished){
                             [catPicker removeFromSuperview],catPicker = nil;
                             
                         }];
        selectedCategory = self.navigationController.navigationBar.topItem.title;
        _pickerVisible = NO;
        return true;
    }
    else {
        //picker was not visible
        _pickerVisible = NO;
        return false;
    }
}

#define kInappropriate @"Flag as Inappropriate"

#define kLargeThumbFrameIphone CGRectMake(70, -700, 180, 258)
#define kLargeThumbHeight 258
#define kLargeThumbWidth kLargeThumbHeight-(kLargeThumbHeight*.25)
#define kLargeThumbFrameIpad CGRectMake(66, -700, kLargeThumbWidth, kLargeThumbHeight)

- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position
{
    if(![self cancelCategoryPicker]){
        themeNameToDownload = [[_currentData objectAtIndex:position] objectForKey:@"themeName"];
        selectedIndex = position;
        UIActionSheet *themeActions;
#ifdef DEBUG
        if([self isSimulator] && ![[selectedCategory stringByReplacingOccurrencesOfString:@"-" withString:@""] isEqualToString:@"Flagged"]){
            themeActions = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Download", kInappropriate, nil];
        }
        else{
            themeActions = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:@"Download", nil];
        }
#else
        themeActions = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Download", kInappropriate, nil];
#endif
        
        [themeActions setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
        [themeActions showInView:self.view];
        CGRect cellRect = [_gmGridView cellForItemAtIndex:position].frame;
        UIImageView *thmb = [[UIImageView alloc] initWithFrame:cellRect];
        for (UIView *v in [[_gmGridView cellForItemAtIndex:position].contentView subviews]){
            if([NSStringFromClass(v.class) isEqualToString:NSStringFromClass(UIImageView.class)]){
                UIImageView *view = (UIImageView*)v;
                thmb.image = view.image;
            }
        }
        CGRect frame = kLargeThumbFrameIphone;
        
        if(kIsIpad){
            frame = kLargeThumbFrameIpad;
        }
        
        [thmb setFrame:frame];
        [thmb setTag:999];
        thmb.layer.masksToBounds = NO;
        thmb.layer.cornerRadius = 0;
        [thmb.layer setShadowColor:[UIColor blackColor].CGColor];
        thmb.layer.shadowOffset = CGSizeMake(0,5);
        thmb.layer.shadowRadius = 15;
        thmb.layer.shadowOpacity = .8;
        thmb.layer.shadowPath = [UIBezierPath bezierPathWithRect:thmb.bounds].CGPath;
        
        [themeActions addSubview:thmb];
        [UIView animateWithDuration:.2 animations:^{
            [thmb setFrame:CGRectMake(thmb.frame.origin.x, -264, thmb.frame.size.width, thmb.frame.size.height)];
        } completion:^(BOOL finished) {
            
        }];
        
        
    }
    else {
        
    }
}
-(void)GMGridView:(GMGridView *)gridView processDeleteActionForItemAtIndex:(NSInteger)index{
    
}
- (void)GMGridViewDidTapOnEmptySpace:(GMGridView *)gridView{
    [self cancelCategoryPicker];
}

//////////////////////////////////////////////////////////////
#pragma mark ActionsheetDelegate
//////////////////////////////////////////////////////////////

- (NSDictionary *)downloadPlist:(NSString *)url {
    NSMutableURLRequest *request  = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
    NSURLResponse *resp = nil;
    NSError *err = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&resp error:&err];
    
    if (!err) {
        NSString *errorDescription = nil;
        NSPropertyListFormat format;
        NSDictionary *samplePlist = [NSPropertyListSerialization propertyListFromData:responseData mutabilityOption:NSPropertyListImmutable format:&format errorDescription:&errorDescription];
        
        if (!errorDescription)
            return samplePlist;
        
    }
    
    return nil;
}
- (NSData *)downloadImageFrom:(NSString *)url {
    NSMutableURLRequest *request  = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
    NSURLResponse *resp = nil;
    NSError *err = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&resp error:&err];
    
    if (!err) {
        return responseData;
    }
    
    return nil;
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    UIImageView *thmb;
    for (UIView *v in [actionSheet subviews]){
        if(v.tag == 999){
            thmb = (UIImageView*)v;
        }
    }
    
    if([buttonTitle isEqualToString:@"Cancel"]){
        //hide up
        [UIView animateWithDuration:.3 animations:^{
            [thmb setFrame:CGRectMake(thmb.frame.origin.x, -1000, thmb.frame.size.width, thmb.frame.size.height)];
            [thmb setAlpha:0];
        } completion:^(BOOL finished) {
            [thmb removeFromSuperview];
        }];
    }
    
    if([buttonTitle isEqualToString:kInappropriate]){
        //hide up
        [UIView animateWithDuration:.3 animations:^{
            [thmb setFrame:CGRectMake(thmb.frame.origin.x, -1000, thmb.frame.size.width, thmb.frame.size.height)];
            [thmb setAlpha:0];
        } completion:^(BOOL finished) {
            [thmb removeFromSuperview];
        }];
        
        //flag code here
        NSString *themeNameToFlag = themeNameToDownload;
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://clockbuilder.gmtaz.com/flagTheme.php?api=thisisasecretapikeygmt2745694&themeName=%@",themeNameToFlag]];
        
        UIView *mainView = [[[[UIApplication sharedApplication] delegate]window]rootViewController].view;
        UIViewController* modalPresent = ([[[[UIApplication sharedApplication] delegate]window]rootViewController].modalViewController);
        if(modalPresent!=nil){
            mainView = [[[[UIApplication sharedApplication] delegate]window]rootViewController].modalViewController.view;
        }
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:mainView animated:YES];
        hud.labelText = @"Flagging...";
        
        
        dispatch_async(dispatch_queue_create("com.gmtaz.Clockbuilder.FlagTheme", NULL), ^{
            NSError *error;
            NSString *successString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if(!successString){
                    [hud hide:YES afterDelay:0];
                    NSLog(@"error flagging: %@", error);
                    CustomAlertView *alert = [[CustomAlertView alloc] initWithTitle:@"Error" message:@"There was an error flagging this theme.  Please try again later." delegate:nil cancelButtonTitle:@"Will do" otherButtonTitles: nil];
                    [alert show];
                }
                else {
                    if([successString isEqualToString:@"flagged!"]){
                        
                        hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"doneCheck.png"]];
                        hud.mode = MBProgressHUDModeCustomView;
                        hud.labelText = @"Flagged!";
                        [hud hide:YES afterDelay:1];
                        
                    }
                    else {
                        [hud hide:YES afterDelay:0];
                        CustomAlertView *alert = [[CustomAlertView alloc] initWithTitle:@"Error" message:@"There was an error flagging this theme.  Please try again later." delegate:nil cancelButtonTitle:@"Will do" otherButtonTitles: nil];
                        [alert show];
                        NSLog(@"error flagging theme %@:%@",themeNameToFlag, successString);
                    }
                }
            });
            
        });
    }
    
    
    if([buttonTitle isEqualToString:@"Delete"]){
        //fade out
        [UIView animateWithDuration:.3 animations:^{
            thmb.transform = CGAffineTransformScale(thmb.transform, 2, 2);
            [thmb setAlpha:0];
        } completion:^(BOOL finished) {
            [thmb removeFromSuperview];
        }];
        if(themeNameToDownload && selectedIndex>=0){
            
            UIView *mainView = [[[[UIApplication sharedApplication] delegate]window]rootViewController].view;
            UIViewController* modalPresent = ([[[[UIApplication sharedApplication] delegate]window]rootViewController].modalViewController);
            if(modalPresent!=nil){
                mainView = [[[[UIApplication sharedApplication] delegate]window]rootViewController].modalViewController.view;
            }
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:mainView animated:YES];
            hud.labelText = @"Deleting...";
            dispatch_async(dispatch_queue_create("com.gmtaz.Clockbuilder.DeleteTheme", NULL), ^{
                
                NSString *url = [NSString stringWithFormat:@"http://clockbuilder.gmtaz.com/deleteTheme2.php?api=thisisasecretapikeygmt2745694&themeName=%@",themeNameToDownload];
                NSString *successString = [NSString stringWithContentsOfURL:[NSURL URLWithString:url] encoding:NSUTF8StringEncoding error:nil];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if([successString isEqualToString:@"deleted!"]){
                        if(selectedIndex >=0){
                            [_gmGridView removeObjectAtIndex:selectedIndex withAnimation:GMGridViewItemAnimationFade];
                            [_currentData removeObjectAtIndex:selectedIndex];
                            
                            [[NSUserDefaults standardUserDefaults] setObject:_currentData forKey:@"onlineThemesArray"];
                            [[NSUserDefaults standardUserDefaults]synchronize];
                            //[_gmGridView reloadData];
                            selectedIndex = -1;
                            UIView *mainView = [[[[UIApplication sharedApplication] delegate]window]rootViewController].view;
                            UIViewController* modalPresent = ([[[[UIApplication sharedApplication] delegate]window]rootViewController].modalViewController);
                            if(modalPresent!=nil){
                                mainView = [[[[UIApplication sharedApplication] delegate]window]rootViewController].modalViewController.view;
                            }
                            
                            hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"doneCheck.png"]];
                            hud.mode = MBProgressHUDModeCustomView;
                            hud.labelText = @"Deleted!";
                            [hud hide:YES afterDelay:1];
                            
                        }
                        else {
                            NSLog(@"SuccessString: %@ for themeName: %@",successString, themeNameToDownload);
                        }
                    }
                    else {
                        CustomAlertView *alert = [[CustomAlertView alloc] initWithTitle:@"Error" message:successString delegate:nil cancelButtonTitle:@"Crap" otherButtonTitles: nil];
                        [alert show];
                        NSLog(@"error deleting theme %@:%@",themeNameToDownload, successString);
                        [hud hide:YES];
                    }
                });
            });
        }
        else {
            NSLog(@"did not try to delete:%@ index:%i", themeNameToDownload, selectedIndex);
        }
        
    }
    
    
    if([buttonTitle isEqualToString:@"Download"]){
        //hide up
        [self.view addSubview:thmb];
        CGRect frame = CGRectMake(70, -12, thmb.frame.size.width, thmb.frame.size.height);
        if(kIsIpad){
            frame = CGRectMake(66, 18, thmb.frame.size.width, thmb.frame.size.height);
        }
        [thmb setFrame:frame];
        [UIView animateWithDuration:.4 animations:^{
            [thmb setFrame:CGRectMake(-200, thmb.frame.origin.y,thmb.frame.size.width, thmb.frame.size.height)];
            [thmb setAlpha:0];
        } completion:^(BOOL finished) {
            [thmb removeFromSuperview];
        }];
        if(themeNameToDownload){
            NSString *themeURLString = [NSString stringWithFormat:@"http://clockbuilder.gmtaz.com/resources/themes/%@/",themeNameToDownload];
            //FILES: LockBackground.png - themeScreenshot.jpg - widgetsList.plist
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: YES];
                [[GMTHelper sharedInstance] notifyToShowGlobalHudWithDict:[[GMTHelper sharedInstance] buildDictForHUDWithLabelText:@"Download Started..." andImage:nil andHide:YES withDelay:0.5 andDim:NO]];
            });
            dispatch_async(dispatch_queue_create("com.gmtaz.Clockbuilder.DownloadingTheme", NULL), ^{
                NSData *lockbackgroundData = [self downloadImageFrom:[themeURLString stringByAppendingString:@"LockBackground.png"]];
                NSData *themeScreenshotData = [self downloadImageFrom:[themeURLString stringByAppendingString:@"themeScreenshot.jpg"]];
                NSDictionary *widgetList = [self downloadPlist:[themeURLString stringByAppendingString:@"widgetsList.plist"]];
                //save data
                if(widgetList!=nil && themeScreenshotData!=nil && lockbackgroundData!=nil){
                    NSMutableDictionary *wListMutable = [widgetList mutableCopy];
                    NSMutableDictionary *themeDict = [[NSMutableDictionary alloc] init];
                    [themeDict setObject:lockbackgroundData forKey:@"LockBackground.png"];
                    [themeDict setObject:themeScreenshotData forKey:@"themeScreenshot.jpg"];
                    [themeDict setObject:wListMutable forKey:@"widgetsList"];
                    
                    NSManagedObjectContext *addingContext = [delegate getManagedObjectContext];
                    CoreTheme *cTheme = (CoreTheme *)[NSEntityDescription insertNewObjectForEntityForName:@"CoreTheme"
                                                                                   inManagedObjectContext:addingContext];
                    [addingContext obtainPermanentIDsForObjects:[NSArray arrayWithObject:cTheme] error:nil];
                    cTheme.themeDictData = themeDict;
                    cTheme.saveDate = [NSDate date];//[NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
                    
                    NSTimeInterval  today = [[NSDate date] timeIntervalSince1970];
                    NSString *intervalString = [NSString stringWithFormat:@"%f", today];
                    NSString *recordUUID = intervalString;
                    cTheme.recordUUID = recordUUID;//[[[cTheme objectID] URIRepresentation] absoluteString];
                    NSError __block *error;
                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                        [addingContext save:&error];
                        if(!error){
                            [delegate gridViewController:self didFinishWithSave:YES];
                        }
                        else {
                            NSLog(@"error downloading theme: %@", error);
                        }
                        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
                    });
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                        NSDictionary *errorDict  =[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Theme Download Error", themeNameToDownload, nil] forKeys:[NSArray arrayWithObjects:@"errorType", @"errorText", nil]];
                        [[GMTHelper sharedInstance] reportError:errorDict];
                        [[GMTHelper sharedInstance] alertWithString:@"There was an error downloading the theme. Support has been notified."];
                        
                        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
                    });
                }
            });
        }
    }
}



//////////////////////////////////////////////////////////////
#pragma mark PickerViewDelegate
//////////////////////////////////////////////////////////////


#define kPickerVertDisplace [UIScreen mainScreen].bounds.size.height - 244
-(void)donePicking{
    _pickerVisible = NO;
    
    if(kIsIpad){
        UIBarButtonItem *search = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"NavigationSearchButton.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(showThemePicker)];
        self.navigationItem.rightBarButtonItem = search;
        self.navigationItem.leftBarButtonItem = self.navigationItem.backBarButtonItem;
    }
    else{
        
        
        if(kIsiOS7){
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(showThemePicker)];
        }
        else{
            UIBarButtonItem *searchButton = [CBThemeHelper createButtonItemWithImage:[UIImage imageNamed:@"NavigationSearchButton.png"]
                                                                     andPressedImage:[UIImage imageNamed:@"NavigationSearchButton.png"]
                                                                              target:self action:@selector(showThemePicker)
                                             ];
            self.navigationItem.rightBarButtonItem = searchButton;
        }
        
        UIBarButtonItem *backButton = [CBThemeHelper createBackButtonItemWithTitle:@"Saved Themes" target:self.navigationController action:@selector(popViewControllerAnimated:)];
        [self.navigationItem setLeftBarButtonItem: backButton];
    }
    CGRect slidDown = CGRectMake(0, 0, _gmGridView.frame.size.width, _gmGridView.frame.size.height);
    UIView *pickerView = [self.view.subviews objectAtIndex:1];
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         [pickerView setFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, 320, 180)];
                         [_gmGridView setFrame:slidDown];
                         [_gmGridView setAlpha:1];
                     }
                     completion:^(BOOL finished){
                         [catPicker removeFromSuperview],catPicker = nil;
                         [self refreshThemes];
                     }];
}

-(void)showThemePicker{
    _pickerVisible = YES;
    CGRect pickerRect = CGRectMake(0, self.view.frame.size.height, 320, 180);
    if(kIsiOS7){
        //pickerRect = CGRectMake(0, 0, 320, 180);
        if(!catPicker){
            catPicker = [[UIPickerView alloc] initWithFrame:pickerRect];
        }
        [catPicker setBackgroundColor:[UIColor whiteColor]];
    }
    else{
        if(!catPicker){
            catPicker = [[UIPickerView alloc] initWithFrame:pickerRect];
        }
    }
    catPicker.delegate = self;
    catPicker.showsSelectionIndicator = YES;
    selectedCategory = self.navigationController.navigationBar.topItem.title;
    
    if(kIsIpad){
        
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Select" style:UIBarButtonItemStyleBordered target:self action:@selector(donePicking)];
        self.navigationItem.rightBarButtonItem = doneButton;
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelCategoryPicker)];
        self.navigationItem.leftBarButtonItem = cancelButton;
    }
    else{
        
        UIBarButtonItem *doneButton = [CBThemeHelper createBlueButtonItemWithTitle:@"Select" target:self action:@selector(donePicking)];
        self.navigationItem.rightBarButtonItem = doneButton;
        UIBarButtonItem *cancelButton = [CBThemeHelper createDoneButtonItemWithTitle:@"Cancel" target:self action:@selector(cancelCategoryPicker)];
        self.navigationItem.leftBarButtonItem = cancelButton;
    }
    [_gmGridView setAlpha:.3];
    [self.view insertSubview:catPicker aboveSubview:[self.view.subviews objectAtIndex:0]];
    
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         if(kIsIpad){
                             [catPicker setFrame:CGRectMake(0, self.view.frame.size.height - 180, 320, 180)];
                         }
                         else{
                             [catPicker setFrame:CGRectMake(0, self.view.frame.size.height - 180, 320, 180)];
                         }
                         if(!kIsiOS7){
                             [_gmGridView setFrame:CGRectMake(0, -180, _gmGridView.frame.size.width, _gmGridView.frame.size.height)];
                         }else{
                             [_gmGridView setAlpha:.2];
                         }
                     }
                     completion:^(BOOL finished){
                         NSString *title = self.navigationController.navigationBar.topItem.title;
#ifdef DEBUG
                         if ([title isEqualToString:@"New Themes"] || [title isEqualToString:@"Flagged"]) {
                             title = [@"-" stringByAppendingString:title];
                         }
#endif
                         
                         NSInteger index = [[self getCategoriesArray] indexOfObject:title];
                         if(index != NSNotFound && index>=0 && index <[self getCategoriesArray].count)
                             [catPicker selectRow:index inComponent:0 animated:YES];
                         
                     }];
    
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component {
    // Handle the selection
    selectedCategory = [[self getCategoriesArray] objectAtIndex:row];
}

// tell the picker how many rows are available for a given component
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    NSUInteger numRows = [self getCategoriesArray].count;
    return numRows;
}

// tell the picker how many components it will have
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// tell the picker the title for a given component
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    NSString *title;
    title = [[self getCategoriesArray] objectAtIndex:row];
    return title;
}

// tell the picker the width of each row for a given component
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    int sectionWidth = 300;
    return sectionWidth;
}



-(void)didReceiveMemoryWarning{
    
    [super didReceiveMemoryWarning];
    NSLog(@"did receive memory warning (GRID VIEW)");
    [[SDImageCache sharedImageCache] clearMemory];
    
}


@end
