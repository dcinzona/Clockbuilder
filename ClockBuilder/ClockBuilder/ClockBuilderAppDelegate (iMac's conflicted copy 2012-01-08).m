//
//  ClockBuilderAppDelegate.m
//  ClockBuilder
//
//  Created by Gustavo Tandeciarz on 3/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ClockBuilderAppDelegate.h"
#import "ClockBuilderViewController.h"
#import "ManageWidgetsNavigationController.h"
#import "manageWidgetsTableView.h"
#import "getWeatherData.h"
#import "textBasedWidget.h"
#import "JSON.h"
#import <SystemConfiguration/SCNetworkReachability.h>
#include <netinet/in.h>

@implementation ClockBuilderAppDelegate


@synthesize window=_window;

@synthesize viewController=_viewController;

@synthesize widgetsAdded,settings, gr, hconn, widgetHelper, qup,th;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    th = [themeConverter new];
    [self performSelector:@selector(copySlideshowHTML)];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];    
    [self performSelector:@selector(setDefaults)];
    widgetHelper = [widgetHelperClass new];
    qup = [uploadThemesController new];
    //sh = [soundHelper new];
    application.idleTimerDisabled = YES;
    self.window.rootViewController = self.viewController;
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.window makeKeyAndVisible];
    [[NSUserDefaults standardUserDefaults]setObject:@"NO" forKey:@"forceRedraw"];    
    [[NSUserDefaults standardUserDefaults] synchronize];
    gr = [[getWeatherData alloc] init];
    gr.delegate = self;
    [self forceWeatherStart];
    [self setScreenVisible:@"YES"];
    //NSLog(@"UDID: %@",[UIDevice currentDevice].uniqueIdentifier);
    hconn = [helpers new];
    //[hconn prefers24Hour];      
    [th createSymLinks];  
    if([self latestVersion]){        
        [th createSymLinks];         
    }  
    //[th run:@"NO"];
    NSURL *url = (NSURL *)[launchOptions valueForKey:UIApplicationLaunchOptionsURLKey];
    if([url isFileURL])
    {
        [self performSelector:@selector(handleThemeFile:) withObject:url];
    }
    
    
    BOOL statusBarPref = YES;
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"showStatusBar"] boolValue]==NO)
        statusBarPref = NO;
    
    [[UIApplication sharedApplication] setStatusBarHidden:!statusBarPref withAnimation:NO];
    
    //if(![hconn isOriginal]){
        
    //}
    NSString *cbfixMessage = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://static.gmtaz.com/alertMessages.php?type=cbfix"] encoding:NSUTF8StringEncoding error:nil];
    [[NSUserDefaults standardUserDefaults] setObject:cbfixMessage forKey:@"cbfixmsg"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    return YES;
}

-(void)copySlideshowHTML
{
    NSFileManager *fm = [NSFileManager new];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    if([fm fileExistsAtPath:[documentsDirectory stringByAppendingFormat:@"/slideshow.html"]])
    {
        [fm removeItemAtPath:[documentsDirectory stringByAppendingFormat:@"/slideshow.html"] error:nil];
    }
    NSString *slideshow = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] 
                                                              pathForResource:@"slideshow" ofType:@"html"]  encoding:NSUTF8StringEncoding error:nil];
    NSString *slidesList = [NSString stringWithContentsOfFile:[documentsDirectory stringByAppendingFormat:@"/lockscreen/slideindex.txt"] encoding:NSUTF8StringEncoding error:nil];
    slideshow = [[slideshow stringByReplacingOccurrencesOfString:@"[[lines]]" 
                                                      withString:[NSString stringWithFormat:@"['%@']", 
                                                                  [[slidesList stringByReplacingOccurrencesOfString:@"\n" 
                                                                                                         withString:@"','"]
                                                                   stringByReplacingOccurrencesOfString:@",''" withString:@""]
                                                                  ]] stringByReplacingOccurrencesOfString:@"'slides/slide" withString:@"'slide"];
    
    [slideshow writeToFile:[documentsDirectory stringByAppendingFormat:@"/slideshow.html"] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    if(![fm fileExistsAtPath:[documentsDirectory stringByAppendingFormat:@"/jquery.min.js"]])
    {
        [fm copyItemAtPath:[[NSBundle mainBundle] 
                            pathForResource:@"jquery.min" ofType:@"js"] 
                    toPath:[documentsDirectory stringByAppendingFormat:@"/jquery.min.js"] 
                     error:nil];
    }
    if(![fm fileExistsAtPath:[documentsDirectory stringByAppendingFormat:@"/empty.png"]])
    {
        [fm copyItemAtPath:[[NSBundle mainBundle] 
                            pathForResource:@"empty" ofType:@"png"] 
                    toPath:[documentsDirectory stringByAppendingFormat:@"/empty.png"] 
                     error:nil];
    }
    
    
    
    [fm release];
}


-(void)playclick
{
    //[sh playclick];
}
-(void)playclicksoft
{
    //[sh playclicksoft];
}

- (void) setScreenVisible:(NSString *)val
{
    ScreenVisible = [val boolValue]; 
}
-(void)forceWeatherStart
{
    [gr stop];
    [gr start];
}
-(BOOL)getScreenVisible
{ 
    return ScreenVisible;
}
-(void) refreshViewsGCD
{
    if([self getScreenVisible]){
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        dispatch_async(queue, ^{
            [_viewController performSelector:@selector(refreshViews)];
        });
    }
}

-(void)runTimer
{
    if(ScreenVisible){
        NSArray *widgetsList = [[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"] objectForKey:@"widgetsList"];        
        if([widgetsList count]>0 ){
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
            dispatch_async(queue, ^{
                NSArray *subv = [NSArray arrayWithArray:[_viewController.view subviews]];
                
                for (UIView *v in subv) {
                    if([v class] == [textBasedWidget class])
                    {
                        [v performSelector:@selector(updateView)];
                    }
                }
            });
        }
    }
}

#pragma mark modifying widgets
- (void) saveWeatherSettings:(NSDictionary *)weatherData
{
    NSMutableDictionary *sets = [[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"] mutableCopy];
    [sets setObject:weatherData forKey:@"weatherData"];
    [[NSUserDefaults standardUserDefaults] setObject:sets forKey:@"settings"];    
    [[NSUserDefaults standardUserDefaults] synchronize];
    [sets release];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        
        BOOL connected = [hconn deviceIsConnectedToInet];
        if(connected)
        {
            dispatch_sync(dispatch_get_main_queue(), ^(void) {
                [self forceWeatherStart];
            });
        }
    });
    [self setMonitoringInBG];
}

- (UIView *)getWidgetToRedraw:(NSString *)widgetIndexString
{
    
   // NSNumber *index = [NSNumber numberWithInteger:[widgetIndexString integerValue]];
    NSInteger modIndex = [widgetIndexString integerValue]+2;
    UIView *v1 = [_viewController.view.subviews objectAtIndex:modIndex];
    return v1;
}

-(void) activateTheme:(NSArray *)widgetsArray
{
    [widgetHelper setWidgetsListArray:widgetsArray];
    for(NSDictionary* widget in widgetsArray)
    {
        if([[widget objectForKey:@"subClass"]isEqualToString:@"weather"]){            
            [self forceWeatherStart];
            break;
        }
    }
    
    //[_viewController performSelector:@selector(resetToolbar)];
    [self refreshViewsGCD];
    [hconn showOverlay:@"Activated" iconImage:nil];
    
}

- (void) saveWidgetSettings:(NSString *)widgetIndexString widgetDataDictionary:(NSDictionary *)widgetData
{
    //dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    //dispatch_async(queue, ^{
    
        [widgetHelper setWidgetData:[widgetIndexString intValue] withData:widgetData];
        
        BOOL redraw = [[[NSUserDefaults standardUserDefaults] objectForKey:@"forceRedraw"] boolValue];
            
        if(redraw){
            //dispatch_sync(dispatch_get_main_queue(), ^{
                [_viewController forceWidgetRedraw:[self getWidgetToRedraw:widgetIndexString]];
            //});
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"forceRedraw"];
        [[NSUserDefaults standardUserDefaults] synchronize];        
    //});
}
- (void) addWidgetToArray:(NSDictionary *)widgetData
{
    [widgetHelper addWidgetToList:widgetData];
}

- (void) refreshBG
{
    [_viewController performSelector:@selector(drawBackground)];
}

- (void) resetTheme{
    
    NSMutableArray *ar = [[widgetHelper getWidgetsList] mutableCopy];
    [ar removeAllObjects];
    [widgetHelper setWidgetsListArray:[NSArray arrayWithArray:ar]];
    [ar release];
    
    for(UIView *v in _viewController.view.subviews)
    {
        if(v.tag>=10)
            [v removeFromSuperview];
    }
    [_viewController performSelector:@selector(resetToolbar)];
    
}
#pragma mark generic methods
- (void)showHideToolbar
{
    if([[[[NSUserDefaults standardUserDefaults]objectForKey:@"settings"] objectForKey:@"widgetsList"] count]==0){
        [_viewController.showToolbar setHidden:YES];
        [_viewController.toolbar setHidden:NO];
    }
}
- (void) goBackToRootView
{
    [self setScreenVisible:@"YES"];
    [_viewController dismissModalViewControllerAnimated:YES];
    [_viewController performSelector:@selector(resetToolbar)];
    [_viewController performSelector:@selector(selectWidget:) withObject:nil];
    [self refreshViewsGCD];
    //[sh playclick]; 
}
- (NSString *)stringWithUrl:(NSURL *)url
{
    
	NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url
                                                cachePolicy:NSURLRequestReloadIgnoringCacheData
                                            timeoutInterval:30];
    // Fetch the JSON response
	NSData *urlData;
	NSURLResponse *response;
	NSError *error;
    // Make synchronous request
	urlData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
    
 	// Construct a String around the Data from the response
    NSString *ret = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
    NSString *val = [NSString stringWithString:ret];
    [ret release];
	return val;
}
- (NSArray *) objectWithUrl:(NSURL *)url
{
    SBJsonParser *jsonParser = [SBJsonParser new];
	NSString *jsonString = [self stringWithUrl:url];
    NSArray *json = (NSArray *)[jsonParser objectWithString:jsonString];
    [jsonParser release];
	return json;
}
-(void)getCategoriesArray
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        NSString *catURL = @"http://clockbuilder.gmtaz.com/getCategories.php?api=SDFB52f4vw9230V45gdfg"; 
        NSArray *ar = [NSArray arrayWithArray:[self objectWithUrl:[NSURL URLWithString:catURL]]];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSMutableDictionary * settingsD = [[defaults objectForKey:@"settings"] mutableCopy];
        [settingsD setObject:ar forKey:@"categoriesArray"];
        [defaults setObject:settingsD forKey:@"settings"];
        [defaults synchronize];
    });
}

- (void) setDefaults
{
    //create themes folder   
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"timeFormat"]==nil)
        [[NSUserDefaults standardUserDefaults] setObject:@"24h" forKey:@"timeFormat"];
    
    NSString *settingsPath = [[NSBundle mainBundle] pathForResource:@"settings" ofType:@"plist"];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([defaults objectForKey:@"settings"]==nil){
        settings = [NSMutableDictionary dictionaryWithContentsOfFile:settingsPath];
    }
    else{
        settings = [defaults objectForKey:@"settings"];
        NSDictionary *replacementDict = [NSDictionary dictionaryWithContentsOfFile:settingsPath];
        NSArray *updates = [replacementDict objectForKey:@"updatedConstants"];
        for(NSString *str in updates)
        {
            [settings setObject:[replacementDict objectForKey:str] forKey:str];
        }
        if([settings objectForKey:@"slidesArray"]==nil)
            [settings setObject:[replacementDict objectForKey:@"slidesArray"] forKey:@"slidesArray"];
    }   
    [defaults setObject:settings forKey:@"settings"];   
    [defaults synchronize];
    [self getCategoriesArray];
    [self showHideToolbar];
}

- (void) updateThemeWeather
{
    if([th checkIfThemeInstalled]){
        //[th run:YES];    
        [th performSelector:@selector(run:) withObject:@"YES"];
    }
}

- (void) refreshWithNewWeatherData
{
    [self updateThemeWeather];
    if([self getScreenVisible]){
        if([[UIApplication sharedApplication] applicationState]==UIApplicationStateActive)
        {
            for(UIView *widget in [self.viewController.view subviews])
            {
                if([widget tag]>9)
                {
                    NSInteger index = widget.tag - 10;                    
                    NSArray *widgetsList = [[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"] objectForKey:@"widgetsList"];
                    NSString *cls = [[widgetsList objectAtIndex:index] objectForKey:@"subClass"];
                    if([cls isEqualToString:@"weather"])
                        [widget performSelectorInBackground:@selector(refreshWithNewWeatherData) withObject:nil];
                    //[widget performSelector:@selector(refreshWithNewWeatherData)];
                }
            }
        }
    }
}

-(BOOL)isThereAWeatherWidget
{
    NSArray *widgetsList = [[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"] objectForKey:@"widgetsList"];
    for(NSDictionary* widget in widgetsList)
    {
        if([[widget objectForKey:@"subClass"]isEqualToString:@"weather"])
            return true;
    }
    return false;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */

    
    

}
-(void)setMonitoringInBG
{
    if([[[[[NSUserDefaults standardUserDefaults]objectForKey:@"settings"] objectForKey:@"weatherData"] objectForKey:@"location"]isEqualToString:@"Current Location"] &&
       [[[[[NSUserDefaults standardUserDefaults]objectForKey:@"settings"] objectForKey:@"weatherData"] objectForKey:@"monitorInBackground"] boolValue])
    {
        [gr.gr.CLController.locMgr startMonitoringSignificantLocationChanges];
    }
    else
    {
        [gr.gr.CLController.locMgr stopMonitoringSignificantLocationChanges];
    }
}



- (void) uploadThemeToCloud:(NSString*)themeName themeDirectory:(NSString *)themeDir
{
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        [qup saveThemeToCloud:themeName];
    });
}

- (UIViewController *)getRootViewController
{
    return _viewController;
}

#pragma mark checking internet

- (BOOL) connectedToNetwork
{
    // Create zero addy
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
	
    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
	
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
	
    if (!didRetrieveFlags)
    {
        printf("Error. Could not recover network reachability flags\n");
        return 0;
    }
	
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
    return (isReachable && !needsConnection) ? YES : NO;
}

- (BOOL)latestVersion{
    
    if([self connectedToNetwork]){
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
        dispatch_async(queue, ^{
            NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey];
            NSError *error = NULL;
            NSString *response = [NSString stringWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://clockbuilder.gmtaz.com/versioncheck.php?v=%@",version]] encoding:NSUTF8StringEncoding error:&error];
            //NSLog(@"response: %@", response);
            if(![response isEqualToString:@"OK"]){
                [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"needsToUpdate"];      
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                dispatch_sync(dispatch_get_main_queue(), ^(void) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Update Required" message:response delegate:self cancelButtonTitle:@"Update Now" otherButtonTitles: nil];
                    [alert show];
                    [alert release];
                });                
            }
            else{
                [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"needsToUpdate"];   
                [[NSUserDefaults standardUserDefaults] synchronize]; 
            }
            
            
            
        });
    }
    
    
    
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"needsToUpdate"] boolValue];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    //[sounds playclicksoft];
    
	NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"Update Now"]){       
        
        NSURL *roloUpdate = [NSURL URLWithString:@"http://itunes.apple.com/us/app/clock-builder/id429716375?ls=1&mt=8"];
        [[UIApplication sharedApplication] openURL:roloUpdate];
    }
    
}




- (void)applicationDidEnterBackground:(UIApplication *)application
{
    application.idleTimerDisabled = NO;
    
    if([self getScreenVisible])
        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"screenWasVisible"];
    else
        [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"screenWasVisible"];
        
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self setScreenVisible:@"NO"];
    [self setMonitoringInBG];
    [gr stop]; 
}


- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    //application.idleTimerDisabled = YES;
    [self setScreenVisible:[[NSUserDefaults standardUserDefaults] objectForKey:@"screenWasVisible"]];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    [th checkifupdated];
    application.idleTimerDisabled = YES;
    [self setScreenVisible:[[NSUserDefaults standardUserDefaults] objectForKey:@"screenWasVisible"]];
    if([self isThereAWeatherWidget])
    {
        gr.timerInterval = [NSNumber numberWithInteger:[[[[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"] objectForKey:@"weatherData"] objectForKey:@"interval"] integerValue]];
        [self performSelector:@selector(forceWeatherStart) withObject:nil];
        [self setMonitoringInBG];
    }
    [self showHideToolbar];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    application.idleTimerDisabled = NO;
    [gr stop];
    [self setMonitoringInBG];
    //[gr.gr.CLController.locMgr stopMonitoringSignificantLocationChanges];
}

#pragma mark Custom File Handling

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if([url isFileURL])
    {
        [self performSelector:@selector(handleThemeFile:) withObject:url];
    }
    return YES;
}

-(void) handleThemeFile:(NSURL *)url
{
    [hconn processIncomingFileURL:url];
}


- (void)dealloc
{
    //[sh release];
    [gr release];
    [settings release];
    [widgetsAdded release];
    [_window release];
    [_viewController release];
    [hconn release];
    [widgetHelper release];
    [qup release];
    [super dealloc];
}

@end
