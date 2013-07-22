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
#import "themeConverter.h"
#import "uploadThemesController.h"
#import "textBasedWidget.h"

@implementation ClockBuilderAppDelegate


@synthesize window=_window;

@synthesize viewController=_viewController;

@synthesize widgetsAdded,settings, gr, hconn, widgetHelper;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];    
    [self performSelector:@selector(setDefaults)];
    widgetHelper = [widgetHelperClass new];
    application.idleTimerDisabled = YES;
    self.window.rootViewController = self.viewController;
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.window makeKeyAndVisible];
    [[NSUserDefaults standardUserDefaults]setObject:@"NO" forKey:@"forceRedraw"];    
    [[NSUserDefaults standardUserDefaults] synchronize];
    gr = [[getWeatherData alloc] init];
    gr.delegate = self;
    [self setScreenVisible:@"YES"];
    //NSLog(@"UDID: %@",[UIDevice currentDevice].uniqueIdentifier);
    hconn = [helpers new];
    
    return YES;
}
- (void) setScreenVisible:(NSString *)val
{
    ScreenVisible = [val boolValue];
    NSLog(@"Set Screen Visible: %@", (ScreenVisible ? @"YES" : @"NO"));    
}
-(void)forceWeatherStart
{
    [gr stop];
    [gr start];
}
-(BOOL)getScreenVisible
{
    NSLog(@"Get Screen Visible: %@", (ScreenVisible ? @"YES" : @"NO"));    
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
                for (UIView *v in [_viewController.view subviews]) {
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
    [hconn showOverlay:@"Activated" iconImage:nil];
    NSMutableArray *ma = [widgetsArray mutableCopy];
    [widgetHelper setWidgetsList:ma];
    [ma release];
    
    for(NSDictionary* widget in widgetsArray)
    {
        if([[widget objectForKey:@"subClass"]isEqualToString:@"weather"]){            
            [self forceWeatherStart];
            break;
        }
    }
    
    [_viewController performSelector:@selector(resetToolbar)];
    [self refreshViewsGCD];
    
}

- (void) saveWidgetSettings:(NSString *)widgetIndexString widgetDataDictionary:(NSDictionary *)widgetData
{
    //NSLog(@"widgetData: %@", widgetData);
    //dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    //dispatch_async(queue, ^{
        NSMutableDictionary *sets = [[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"] mutableCopy];
        NSMutableArray *widgetsArray = [[sets objectForKey:@"widgetsList"] mutableCopy];
        if([widgetsArray count]>0){
            NSInteger widgetIndex = [widgetIndexString integerValue];
            [widgetsArray removeObjectAtIndex:widgetIndex];
            [widgetsArray insertObject:widgetData atIndex:widgetIndex];    
        }
        [sets setObject:widgetsArray forKey:@"widgetsList"];
        [[NSUserDefaults standardUserDefaults] setObject:sets forKey:@"settings"];    
        
        BOOL redraw = [[[NSUserDefaults standardUserDefaults] objectForKey:@"forceRedraw"] boolValue];
            
        if(redraw){
            //dispatch_sync(dispatch_get_main_queue(), ^{
                [_viewController forceWidgetRedraw:[self getWidgetToRedraw:widgetIndexString]];
            //});
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"forceRedraw"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [widgetsArray release];
        [sets release];
        
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
    
    [_viewController performSelector:@selector(resetToolbar)];
    NSMutableArray *ar = [[widgetHelper getWidgetsList] mutableCopy];
    [ar removeAllObjects];
    [widgetHelper setWidgetsList:ar];
    [ar release];
    
    for(UIView *v in _viewController.view.subviews)
    {
        if(v.tag>=10)
            [v removeFromSuperview];
    }
    
}
- (void) removeWidgetAtIndex:(NSString *)widgetI{
    [widgetHelper removeWidgetAtIndex:[widgetI intValue]];
    [[self getWidgetToRedraw:widgetI] removeFromSuperview];
    [_viewController performSelector:@selector(initWidgetsArray)];
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
}
- (void) setDefaults
{
    //create themes folder   
    
    NSString *settingsPath = [[NSBundle mainBundle] pathForResource:@"settings" ofType:@"plist"];
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"settings"]==nil){
        settings = [NSMutableDictionary dictionaryWithContentsOfFile:settingsPath];
        [[NSUserDefaults standardUserDefaults] setObject:settings forKey:@"settings"];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self showHideToolbar];
}

- (void) updateThemeWeather
{
    themeConverter *th = [[themeConverter alloc] init];
    if([th checkIfThemeInstalled]){
        //[th run:YES];    
        [th performSelector:@selector(run:) withObject:@"YES"];
    }
    [th release];
}

- (void) refreshWithNewWeatherData
{
    [self updateThemeWeather];
    if([self getScreenVisible]){
        if([[UIApplication sharedApplication] applicationState]==UIApplicationStateActive)
        {
            for(UIView *widget in [self.viewController.view subviews])
            {
                if([widget tag]>1999)
                {
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

    //NSLog(@"application delegate: Application Will Resign Active");
    

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
        uploadThemesController *qup= [uploadThemesController new];
        [qup saveThemeToCloud:themeName themePath:themeDir];
    });
}

#pragma mark checking internet




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
    application.idleTimerDisabled = YES;
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

- (void)dealloc
{
    [gr release];
    [settings release];
    [widgetsAdded release];
    [_window release];
    [_viewController release];
    [hconn release];
    [widgetHelper release];
    [super dealloc];
}

@end
