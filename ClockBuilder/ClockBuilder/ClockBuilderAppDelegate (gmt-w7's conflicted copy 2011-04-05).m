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

@implementation ClockBuilderAppDelegate


@synthesize window=_window;

@synthesize viewController=_viewController;

@synthesize widgetsAdded,settings, gr;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];    
    [self performSelector:@selector(setDefaults)];
    application.idleTimerDisabled = YES;
    self.window.rootViewController = self.viewController;
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.window makeKeyAndVisible];
    [[NSUserDefaults standardUserDefaults]setObject:@"NO" forKey:@"forceRedraw"];    
    [[NSUserDefaults standardUserDefaults] synchronize];
    gr = [[getWeatherData alloc] init];
    gr.delegate = self;
    

    
    
    return YES;
}

-(void)forceWeatherStart
{
    [gr stop];
    [gr start];
}

#pragma mark modifying widgets
- (void) saveWeatherSettings:(NSDictionary *)weatherData
{
    NSMutableDictionary *sets = [[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"] mutableCopy];
    [sets setObject:weatherData forKey:@"weatherData"];
    [[NSUserDefaults standardUserDefaults] setObject:sets forKey:@"settings"];    
    [[NSUserDefaults standardUserDefaults] synchronize];
    [sets release];
    [self forceWeatherStart];
    [self setMonitoringInBG];
}

- (UIView *)getWidgetToRedraw:(NSString *)widgetIndexString
{
    
   // NSNumber *index = [NSNumber numberWithInteger:[widgetIndexString integerValue]];
    NSInteger modIndex = [widgetIndexString integerValue]+2;
    UIView *v1 = [_viewController.view.subviews objectAtIndex:modIndex];
    return v1;
    /*
    for(int x =0;x<widgetIndexString+2;x++)
     {
        UIView *v1 = [_viewController.view.subviews objectAtIndex:x];
        if(v1.tag>999 && [v1 respondsToSelector:@selector(getIndexInList)])
        {
            NSNumber *vIndex = [v1 performSelector:@selector(getIndexInList)];
            if([vIndex integerValue]==[index integerValue])
            {
                return v1;
            }
        }
    }
     */
    return nil;
}

-(void) activateTheme:(NSArray *)widgetsArray
{
    helpers *help = [[helpers alloc] init];
    [help showOverlay:@"Activated" iconImage:nil];
    [help release];
    NSMutableDictionary *sets = [[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"] mutableCopy];
    [sets setObject:widgetsArray forKey:@"widgetsList"];
    [[NSUserDefaults standardUserDefaults]setObject:sets forKey:@"settings"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    [sets release];
    
    if([self isThereAWeatherWidget])
    {
        //[self performSelectorInBackground:@selector(forceWeatherStart) withObject:nil];
        [self forceWeatherStart];
    }
    
    [_viewController performSelector:@selector(resetToolbar)];
    [_viewController performSelectorInBackground:@selector(refreshViews) withObject:nil];
}

- (void) saveWidgetSettings:(NSString *)widgetIndexString widgetDataDictionary:(NSDictionary *)widgetData
{
    //NSLog(@"widgetData: %@", widgetData);
    NSMutableDictionary *sets = [[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"] mutableCopy];
    NSMutableArray *widgetsArray = [[sets objectForKey:@"widgetsList"] mutableCopy];
    if([widgetsArray count]>0){
        NSInteger widgetIndex = [widgetIndexString integerValue];
        [widgetsArray removeObjectAtIndex:widgetIndex];
        [widgetsArray insertObject:widgetData atIndex:widgetIndex];    
    }
    [sets setObject:widgetsArray forKey:@"widgetsList"];
    [[NSUserDefaults standardUserDefaults] setObject:sets forKey:@"settings"];    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [widgetsArray release];
    [sets release];
    
    BOOL redraw = [[[NSUserDefaults standardUserDefaults] objectForKey:@"forceRedraw"] boolValue];
        
    if(redraw){
        [_viewController forceWidgetRedraw:[self getWidgetToRedraw:widgetIndexString]];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"forceRedraw"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}
- (void) addWidgetToArray:(NSDictionary *)widgetData
{
    
    [self setDefaults];
    NSMutableDictionary *sets = [[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"] mutableCopy];
    NSMutableArray *widgetsArray = [[sets objectForKey:@"widgetsList"] mutableCopy];
    
    [widgetsArray addObject:widgetData];    
    
    [sets setObject:widgetsArray forKey:@"widgetsList"];
    [[NSUserDefaults standardUserDefaults] setObject:sets forKey:@"settings"];    
    [[NSUserDefaults standardUserDefaults] synchronize];
    [_viewController performSelectorInBackground:@selector(refreshViews) withObject:nil];
    
    widgetsAdded = widgetsArray;
    [sets release];
    [widgetsArray release];
}

- (void) refreshBG
{
    [_viewController performSelector:@selector(drawBackground)];
}

- (void) resetTheme{
    [self setDefaults];
    NSMutableDictionary *sets = [[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"] mutableCopy];
    NSMutableArray *widgetsArray = [[sets objectForKey:@"widgetsList"] mutableCopy];
    [widgetsArray removeAllObjects];
    [sets setObject:widgetsArray forKey:@"widgetsList"];
    [[NSUserDefaults standardUserDefaults] setObject:sets forKey:@"settings"];    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    widgetsAdded = widgetsArray;
    [sets release];
    [widgetsArray release];
    [_viewController performSelector:@selector(resetToolbar)];
    [_viewController performSelectorInBackground:@selector(refreshViews) withObject:nil];
}
- (void) removeWidgetAtIndex:(NSString *)widgetI{
    [self setDefaults];
    NSMutableDictionary *sets = [[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"] mutableCopy];
    NSMutableArray *widgetsArray = [[sets objectForKey:@"widgetsList"] mutableCopy];
    NSInteger widgetIndex = [widgetI integerValue];    
    [widgetsArray removeObjectAtIndex:widgetIndex];
    [sets setObject:widgetsArray forKey:@"widgetsList"];
    [[NSUserDefaults standardUserDefaults] setObject:sets forKey:@"settings"];    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    widgetsAdded = widgetsArray;
    [sets release];
    [widgetsArray release];
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
    
    [_viewController dismissModalViewControllerAnimated:YES];
    [_viewController performSelector:@selector(resetToolbar)];
    //[_viewController performSelectorInBackground:@selector(refreshViews) withObject:nil];
}
- (void) setDefaults
{
    //create themes folder   
    
    NSString *settingsPath = [[NSBundle mainBundle] pathForResource:@"settings" ofType:@"plist"];
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"settings"]==nil){
        settings = [NSMutableDictionary dictionaryWithContentsOfFile:settingsPath];
        [[NSUserDefaults standardUserDefaults] setObject:settings forKey:@"settings"];
    }
    else
    {
        NSMutableArray *widgetList = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"] objectForKey:@"widgetsList"]mutableCopy];
        widgetsAdded = widgetList;
        settings = [NSMutableDictionary dictionaryWithContentsOfFile:settingsPath];
        [settings setObject:widgetList forKey:@"widgetsList"];
        NSMutableDictionary *weatherData = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"] objectForKey:@"weatherData"]mutableCopy];
        if(weatherData!=nil)
        {
            [settings setObject:weatherData forKey:@"weatherData"];
        }
        [[NSUserDefaults standardUserDefaults] setObject:settings forKey:@"settings"];
        [widgetList release];
        [weatherData release];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self showHideToolbar];
}

- (void) updateThemeWeather
{
    themeConverter *th = [[themeConverter alloc] init];
    if([th checkIfThemeInstalled]){
        //[th run:YES];    
        [th performSelectorInBackground:@selector(run:) withObject:@"YES"];
    }
    [th release];
}

- (void) refreshWithNewWeatherData
{
    [self updateThemeWeather];
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

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    //[gr stop]; 
    application.idleTimerDisabled = NO;
    
    [self setMonitoringInBG];
    
        
}


- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    //application.idleTimerDisabled = YES;
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
    NSLog(@"APP TERMINATING");
    application.idleTimerDisabled = NO;
    [gr stop];
    //[gr.gr.CLController.locMgr stopMonitoringSignificantLocationChanges];
}

- (void)dealloc
{
    [gr release];
    [settings release];
    [widgetsAdded release];
    [_window release];
    [_viewController release];
    [super dealloc];
}

@end
