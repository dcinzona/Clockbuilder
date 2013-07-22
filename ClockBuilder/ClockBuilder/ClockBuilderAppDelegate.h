//
//  ClockBuilderAppDelegate.h
//  ClockBuilder
//
//  Created by Gustavo Tandeciarz on 3/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "getWeatherData.h"
#import "widgetHelperClass.h"
#import "themeConverter.h"
//#import "SHKClockbuilderConfiguration.h"
#import "ThemeUploader.h"
#import "ClockBuilderViewController.h"
#import "CoreDataController.h"
#import "CoreDataController2.h"
#import "CoreTheme.h"
#import "CoreThemeiPad.h"
//#import "TICoreDataSync.h"

#define ApplicationDelegate ((ClockBuilderAppDelegate *)[UIApplication sharedApplication].delegate)
#define RootController ((ClockBuilderViewController*)ApplicationDelegate.rootViewController
#define kActiveThemeCoreDataIDKey @"currentlyActiveThemeID"
#define kFinishedDeduping @"finishedDedupingCoreData"
#define kApplicationDidBecomeActiveNotification @"application did become active"

@class ClockBuilderViewController;

@interface ClockBuilderAppDelegate : NSObject <UIApplicationDelegate, UIAlertViewDelegate> {
    NSMutableArray * widgetsAdded;
    NSMutableDictionary * settings;
    BOOL redrawWidget;
    BOOL ScreenVisible;
    themeConverter *th;
    BOOL _hudVisible;
    BOOL _updateAlertVisible;
    BOOL _runningUpdateCheckOnStart;
    //TICDSDocumentSyncManager *_documentSyncManager;
    BOOL _downloadStoreAfterRegistering;
    
    NSUInteger _activity;
}
- (void) setDefaults;
- (void) setScreenVisible:(NSString *)val;
-(BOOL)getScreenVisible;
- (void) addWidgetToArray:(NSDictionary *)widgetData;
- (void) saveWidgetSettings:(NSString *)widgetIndexString widgetDataDictionary:(NSDictionary *)widgetData;
- (void) saveWeatherSettings:(NSDictionary *)weatherData;
-(void) activateTheme:(NSArray *)widgetsArray;
-(BOOL)isThereAWeatherWidget;
-(void)forceWeatherStart;
- (UIViewController *)getRootViewController;
- (BOOL)latestVersion;
- (BOOL) connectedToNetwork;
- (NSMutableArray *)ls;
-(void)saveContext;
//-(BOOL)isDropboxSyncing;

@property (nonatomic, strong) MBProgressHUD *globalHUD;
@property (nonatomic, strong) ThemeUploader *engine;
@property (nonatomic, strong) themeConverter *th;
//@property (nonatomic) getWeatherData *getWeather;
@property (retain, nonatomic) IBOutlet UIWindow *window;
@property (retain, nonatomic) NSMutableArray *widgetsAdded;
@property (retain, nonatomic) IBOutlet ClockBuilderViewController *viewController;
@property (nonatomic, strong) widgetHelperClass *widgetHelper;


@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;


//- (IBAction)beginSynchronizing:(id)sender;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

//@property (retain) TICDSDocumentSyncManager *documentSyncManager;
//@property (nonatomic, assign, getter = shouldDownloadStoreAfterRegistering) BOOL downloadStoreAfterRegistering;



@end
