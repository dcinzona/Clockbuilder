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
//#import "getWeatherData.h"
#import "textBasedWidget.h"
//#import "JSON.h"
#import <SystemConfiguration/SCNetworkReachability.h>
#include <netinet/in.h>
#include "CBThemeHelper.h"
#include "manageGeneralSettings.h"
//#import "SHKFacebook.h"
//#import "SHKConfiguration.h"
#import "UIDevice+IdentifierAddition.h"
#import "OpenUDID.h"
//#import "TICoreDataSync.h"
//#import <DropboxSDK/DropboxSDK.h>
//#import "DropboxSettings.h"


/*
@interface ClockBuilderAppDelegate ()<DBSessionDelegate, TICDSApplicationSyncManagerDelegate, TICDSDocumentSyncManagerDelegate>
- (void)registerSyncManager;
- (void)showHUDFromNotification:(NSNotification*)note;
@end
*/

@implementation ClockBuilderAppDelegate

/*
#pragma mark -
#pragma mark Initial Sync Registration
- (void)registerSyncManager
{
    //    [TICDSLog setVerbosity:TICDSLogVerbosityEveryStep];
    
    TICDSDropboxSDKBasedApplicationSyncManager *manager = [TICDSDropboxSDKBasedApplicationSyncManager defaultApplicationSyncManager];
    
    NSString *clientUuid = [[NSUserDefaults standardUserDefaults] stringForKey:@"iOSClockbuilderAppSyncClientUUID"];
    
    if( !clientUuid ) {
        clientUuid = [TICDSUtilities uuidString];
        [[NSUserDefaults standardUserDefaults] setValue:clientUuid forKey:@"iOSClockbuilderAppSyncClientUUID"];
    }
    
    NSString *deviceDescription = [[UIDevice currentDevice] name];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(activityDidIncrease:) name:TICDSApplicationSyncManagerDidIncreaseActivityNotification object:manager];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(activityDidDecrease:) name:TICDSApplicationSyncManagerDidDecreaseActivityNotification object:manager];
    
    [manager registerWithDelegate:self
              globalAppIdentifier:kGlobalAppIdentifier
           uniqueClientIdentifier:clientUuid
                      description:deviceDescription
                         userInfo:nil];
}

#pragma mark -
#pragma mark Synchronization
- (IBAction)beginSynchronizing:(id)sender
{
    [[self documentSyncManager] initiateSynchronization];
}

- (void)activityDidIncrease:(NSNotification *)aNotification
{
    _activity++;
    NSLog(@"Activity increased to: %i", _activity);
    
    if( _activity > 0 ) {
        [[UIApplication sharedApplication]
         setNetworkActivityIndicatorVisible:YES];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DBSyncActivityChanged" object:nil];
}

- (void)activityDidDecrease:(NSNotification *)aNotification
{
    if( _activity > 0) {
        _activity--;
    }
    NSLog(@"Activity decreased to: %i", _activity);
    
    if( _activity < 1 ) {
        [[UIApplication sharedApplication]
         setNetworkActivityIndicatorVisible:NO];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"activityDecreasedToZero" object:nil];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DBSyncActivityChanged" object:nil];
}

#pragma mark -
#pragma mark Application Sync Manager Delegate
- (void)applicationSyncManagerDidPauseRegistrationToAskWhetherToUseEncryptionForFirstTimeRegistration:(TICDSApplicationSyncManager *)aSyncManager
{
    [aSyncManager continueRegisteringWithEncryptionPassword:@"password"];
}

- (void)applicationSyncManagerDidPauseRegistrationToRequestPasswordForEncryptedApplicationSyncData:(TICDSApplicationSyncManager *)aSyncManager
{
    [aSyncManager continueRegisteringWithEncryptionPassword:@"password"];
}

- (TICDSDocumentSyncManager *)applicationSyncManager:(TICDSApplicationSyncManager *)aSyncManager preConfiguredDocumentSyncManagerForDownloadedDocumentWithIdentifier:(NSString *)anIdentifier atURL:(NSURL *)aFileURL
{
    
    return nil;
}

- (void)applicationSyncManagerDidFinishRegistering:(TICDSApplicationSyncManager *)aSyncManager
{
    TICDSDropboxSDKBasedDocumentSyncManager *docSyncManager = [[TICDSDropboxSDKBasedDocumentSyncManager alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(activityDidIncrease:) name:TICDSDocumentSyncManagerDidIncreaseActivityNotification object:docSyncManager];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(activityDidDecrease:) name:TICDSDocumentSyncManagerDidDecreaseActivityNotification object:docSyncManager];
    NSString *folder = @"Clockbuilder Data";
    if (kIsIpad) {
        folder = @"Clockbuilder iPad Data";
    }
    [docSyncManager registerWithDelegate:self
                          appSyncManager:aSyncManager
                    managedObjectContext:(TICDSSynchronizedManagedObjectContext *)[self managedObjectContext]
                      documentIdentifier:folder
                             description:@"Application's data"
                                userInfo:nil];

    [self setDocumentSyncManager:docSyncManager];
}


#pragma mark -
#pragma mark Document Sync Manager Delegate

-(BOOL)documentSyncManager:(TICDSDocumentSyncManager *)aSyncManager shouldBeginSynchronizingAfterManagedObjectContextDidSave:(TICDSSynchronizedManagedObjectContext *)aMoc{
    return YES;
}

- (void)documentSyncManager:(TICDSDocumentSyncManager *)aSyncManager didPauseSynchronizationAwaitingResolutionOfSyncConflict:(id)aConflict
{
    [aSyncManager continueSynchronizationByResolvingConflictWithResolutionType:TICDSSyncConflictResolutionTypeLocalWins];
}

- (NSURL *)documentSyncManager:(TICDSDocumentSyncManager *)aSyncManager URLForWholeStoreToUploadForDocumentWithIdentifier:(NSString *)anIdentifier description:(NSString *)aDescription userInfo:(NSDictionary *)userInfo
{
    NSString *storename = kCoreDataStoreName;
    if (kIsIpad) {
        storename = kCoreDataStoreNameiPad;
    }
    
    return [[self applicationDocumentsDirectory] URLByAppendingPathComponent:storename];
}

- (void)documentSyncManager:(TICDSDocumentSyncManager *)aSyncManager didPauseRegistrationAsRemoteFileStructureDoesNotExistForDocumentWithIdentifier:(NSString *)anIdentifier description:(NSString *)aDescription userInfo:(NSDictionary *)userInfo
{
    [self setDownloadStoreAfterRegistering:NO];
    [aSyncManager continueRegistrationByCreatingRemoteFileStructure:YES];
}

- (void)documentSyncManager:(TICDSDocumentSyncManager *)aSyncManager didPauseRegistrationAsRemoteFileStructureWasDeletedForDocumentWithIdentifier:(NSString *)anIdentifier description:(NSString *)aDescription userInfo:(NSDictionary *)userInfo
{
    [self setDownloadStoreAfterRegistering:NO];
    [aSyncManager continueRegistrationByCreatingRemoteFileStructure:YES];
}

- (void)documentSyncManagerDidDetermineThatClientHadPreviouslyBeenDeletedFromSynchronizingWithDocument:(TICDSDocumentSyncManager *)aSyncManager
{
    NSLog(@"DOC WAS DELETED");
    [self setDownloadStoreAfterRegistering:YES];
}

- (void)documentSyncManagerDidFinishRegistering:(TICDSDocumentSyncManager *)aSyncManager
{
    if( [self shouldDownloadStoreAfterRegistering] ) {
        [[self documentSyncManager] initiateDownloadOfWholeStore];
    }
    
    //[self performSelector:@selector(removeAllRemoteSyncData) withObject:nil afterDelay:8.0];
    //[self performSelector:@selector(getPreviouslySynchronizedClients) withObject:nil afterDelay:8.0];
    //[self performSelector:@selector(deleteClient) withObject:nil afterDelay:8.0];
}

- (void)removeAllRemoteSyncData
{
    [[[self documentSyncManager] applicationSyncManager] removeAllSyncDataFromRemote];
}

- (void)getPreviouslySynchronizedClients
{
    [[[self documentSyncManager] applicationSyncManager] requestListOfSynchronizedClientsIncludingDocuments:YES];
}

- (void)deleteClient
{
    [[self documentSyncManager] deleteDocumentSynchronizationDataForClientWithIdentifier:@"B29A21AB-529A-4CBB-A603-332CAD8F2D33-715-000001314CB7EE5B"];
}

- (void)applicationSyncManager:(TICDSApplicationSyncManager *)aSyncManager didFinishFetchingInformationForAllRegisteredDevices:(NSDictionary *)information
{
    NSLog(@"App client info: %@", information);
}

- (BOOL)documentSyncManagerShouldUploadWholeStoreAfterDocumentRegistration:(TICDSDocumentSyncManager *)aSyncManager
{
    return [self shouldDownloadStoreAfterRegistering];
}

- (void)documentSyncManager:(TICDSDocumentSyncManager *)aSyncManager willReplaceStoreWithDownloadedStoreAtURL:(NSURL *)aStoreURL
{
    NSError *anyError = nil;
    BOOL success = [[self persistentStoreCoordinator] removePersistentStore:[[self persistentStoreCoordinator] persistentStoreForURL:aStoreURL] error:&anyError];
    
    if( !success ) {
        NSLog(@"Failed to remove persistent store at %@: %@",
              aStoreURL, anyError);
    }
}

- (void)documentSyncManager:(TICDSDocumentSyncManager *)aSyncManager didReplaceStoreWithDownloadedStoreAtURL:(NSURL *)aStoreURL
{
    NSError *anyError = nil;
    id store = [[self persistentStoreCoordinator] addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:aStoreURL options:nil error:&anyError];
    
    if( !store ) {
        NSLog(@"Failed to add persistent store at %@: %@", aStoreURL, anyError);
    }
}

- (void)documentSyncManager:(TICDSDocumentSyncManager *)aSyncManager didMakeChangesToObjectsInBackgroundContextAndSaveWithNotification:(NSNotification *)aNotification
{
    [[self managedObjectContext] mergeChangesFromContextDidSaveNotification:aNotification];
}

- (void)documentSyncManager:(TICDSDocumentSyncManager *)aSyncManager didFailToSynchronizeWithError:(NSError *)anError
{
    if( [anError code] != TICDSErrorCodeSynchronizationFailedBecauseIntegrityKeysDoNotMatch ) {
        NSLog(@"error synchronizing: %@",anError);
        //return;
    }
    
    [aSyncManager initiateDownloadOfWholeStore];
}
*/


@synthesize window=_window;

@synthesize viewController=_viewController;

@synthesize widgetsAdded, widgetHelper,th;

@synthesize engine = _engine;

@synthesize managedObjectContext=__managedObjectContext;
@synthesize managedObjectModel=__managedObjectModel;
@synthesize persistentStoreCoordinator=__persistentStoreCoordinator;
//@synthesize documentSyncManager = _documentSyncManager;
//@synthesize downloadStoreAfterRegistering = _downloadStoreAfterRegistering;

@synthesize globalHUD;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [self performSelector:@selector(setDefaults)];
    kDataSingleton;
    [GMTHelper sharedInstance];
    
    th = [themeConverter new];
    
    BOOL statusBarPref = YES;
    
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"showStatusBar"] boolValue]==NO)
        statusBarPref = NO;
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    
    widgetHelper = [widgetHelperClass new];
    application.idleTimerDisabled = YES;
    
    [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"forceRedraw"];    
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self setScreenVisible:@"YES"];
    
    
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    NSURL *url = (NSURL *)[launchOptions valueForKey:UIApplicationLaunchOptionsURLKey];
    if([url isFileURL])
    {
        [self performSelector:@selector(handleThemeFile:) withObject:url];
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(forceWeatherStart)
                                                 name:@"startGettingWeather"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshWithNewWeatherData) name:@"weatherDataChanged" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showHUDFromNotification:) name:kShowGlobalHud object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideGlobalHud) name:kHideGlobalHud object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showHUDWithSpinnerFromNotification:) name:kShowGlobalHudWithSpinner object:nil];
    _runningUpdateCheckOnStart = YES;
    
    
    [self processOnlineOnStartASYNC];
    
    return YES;
}

-(void)processOnlineOnStartASYNC{
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.engine = [[ThemeUploader alloc] initWithHostName:@"clockbuilder.gmtaz.com"];
        });
        
        BOOL deviceIsConnected = [[GMTHelper sharedInstance] deviceIsConnectedToInet];
        if(!deviceIsConnected){
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [[GMTHelper sharedInstance] alertWithString:@"This application requires an internet connection.  Running it without will lead to unexpected results."];
            });
        }
        if(deviceIsConnected){
            
            NSString *cbfixMessage = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://static.gmtaz.com/apps.php?type=cbfix"] encoding:NSUTF8StringEncoding error:nil];
            if(cbfixMessage)
                [[NSUserDefaults standardUserDefaults] setObject:cbfixMessage forKey:@"cbfixmsg"];
            NSString *lsync = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://static.gmtaz.com/apps.php?type=lssyncurl"] encoding:NSUTF8StringEncoding error:nil];
            if(lsync)
                [[NSUserDefaults standardUserDefaults] setObject:lsync forKey:@"lssyncurl"];
            [[NSUserDefaults standardUserDefaults]synchronize];
        }
        
        
        if([th checkIfJB] && [self latestVersion]){
            [th createSymLinks];
        }
        
    });
}

- (NSMutableArray *)ls {

    NSURL *url = [CBThemeHelper getThemesPath];
    //NSLog(@"url: %@", url);
    NSArray *properties = [NSArray arrayWithObjects:NSURLNameKey,nil];
    NSDirectoryEnumerator *dirEnumerator = [[NSFileManager defaultManager] enumeratorAtURL:url
                                                                includingPropertiesForKeys:properties
                                                                                   options:0
                                                                              errorHandler:^(NSURL *url, NSError *error) {
                                                                                  // Handle the error.
                                                                                  // Return YES if the enumeration should continue after the error.
                                                                                 // NSLog(@"error: %@", error);
                                                                                  return YES;
                                                                              }];
    
    // An array to store the all the enumerated file names in
    NSMutableArray *theArray=[NSMutableArray array];
    
    // Enumerate the dirEnumerator results, each value is stored in allURLs
    for (NSURL *theURL in dirEnumerator) {
        
        // Retrieve the file name. From NSURLNameKey, cached during the enumeration.
        NSString *fileName;
        [theURL getResourceValue:&fileName forKey:NSURLNameKey error:NULL];
        //NSString *isExcluded;
        /*[theURL getResourceValue:&isExcluded forKey:NSURLIsExcludedFromBackupKey error:NULL];
        if(![isExcluded boolValue]){
            NSLog(@"%@  is excluded: %@", fileName, isExcluded);
            [theArray addObject:theURL];
        }
        else {
            NSLog(@"%@  exclusion = %@", fileName, isExcluded);
        }*/
        [theArray addObject:theURL];
    }
    
    // Do something with the path URLs.
   // NSLog(@"theArray - %@",theArray);
    
    
    return theArray;
}
-(void)processForiCloud{
    
    /*
    if([CBThemeHelper isIOS5] && [CBThemeHelper isCloudEnabled]){
        
        //find all local themes in documents/mythemes and set flag
        NSMutableArray *contents = [self ls];
        for (NSURL *url in contents) {
            [CBThemeHelper addSkipBackupAttributeToItemAtURL:url];
        }
    }
    */
    
}

-(void)hideGlobalHud{
    [MBProgressHUD hideAllHUDsForView:self.window animated:YES];
}
-(void)showHUDWithSpinnerFromNotification:(NSNotification *)note{
    
    if(note.userInfo){
        NSDictionary *dict = note.userInfo;
        [globalHUD hide:YES];
        globalHUD = [MBProgressHUD showHUDAddedTo:self.window animated:YES];
        globalHUD.animationType = MBProgressHUDAnimationZoom;
        globalHUD.mode = MBProgressHUDModeIndeterminate;
        if([dict objectForKey:@"labelText"]){
            globalHUD.labelText = [dict objectForKey:@"labelText"];
        }
        if([[dict objectForKey:@"hide"]boolValue] && [dict objectForKey:@"delay"]){
            if([[dict objectForKey:@"delay"]floatValue]>0)
                [globalHUD hide:[[dict objectForKey:@"hide"] boolValue] afterDelay:[[dict objectForKey:@"delay"] floatValue]];
        }
        if([dict objectForKey:@"dim"]){
            globalHUD.dimBackground = [[dict objectForKey:@"dim"]boolValue];
            if(globalHUD.dimBackground)
                globalHUD.animationType = MBProgressHUDAnimationFade;
        }
    }
}
-(void)showHUDFromNotification:(NSNotification *)note{
    if(note.userInfo){
        
        NSDictionary *dict = note.userInfo;
        [globalHUD hide:YES];
        globalHUD = [MBProgressHUD showHUDAddedTo:self.window animated:YES];
        globalHUD.animationType = MBProgressHUDAnimationZoom;
        if([dict objectForKey:@"labelText"]){
            globalHUD.labelText = [dict objectForKey:@"labelText"];
            if(![dict objectForKey:@"imageView"])
                globalHUD.mode = MBProgressHUDModeText;
        }
        if([dict objectForKey:@"imageView"]){
            globalHUD.customView = [dict objectForKey:@"imageView"];
            globalHUD.mode = MBProgressHUDModeCustomView;
        }
        if([[dict objectForKey:@"hide"]boolValue] && [dict objectForKey:@"delay"]){
            if([[dict objectForKey:@"delay"]floatValue]>0)
                [globalHUD hide:[[dict objectForKey:@"hide"] boolValue] afterDelay:[[dict objectForKey:@"delay"] floatValue]];
        }
        if([dict objectForKey:@"dim"]){
            globalHUD.dimBackground = [[dict objectForKey:@"dim"]boolValue];
            if(globalHUD.dimBackground)
                globalHUD.animationType = MBProgressHUDAnimationFade;
        }
        
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if([title isEqualToString:@"Enable"]){
        //enable iCloud Support
        //[[GMTHelper sharedInstance] notifyToShowGlobalHudWithDict:[[GMTHelper sharedInstance] buildDictForHUDWithLabelText:@"Setting up iCloud" andImage:nil andHide:YES withDelay:10 andDim:YES]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showDownloadThemesHud) name:@"downloadThemesFromiCloud" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideAllHudsInRootView) name:@"doneSettingUpiCloud" object:nil];
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"iCloudEnabled"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [CBThemeHelper setThemeUbiquity:[[NSUserDefaults standardUserDefaults] boolForKey:@"iCloudEnabled"] overwrite:NO];
        [[self window].rootViewController performSelector:@selector(setupAndStartQuery)];
        
    }
    
    if([title isEqualToString:@"Update Now"]){       
        _updateAlertVisible = NO;
        NSURL *roloUpdate = [NSURL URLWithString:@"http://itunes.apple.com/us/app/clock-builder/id429716375?ls=1&mt=8"];
        [[UIApplication sharedApplication] openURL:roloUpdate];
    }
}
-(void)showDownloadThemesHud{
    if(!_hudVisible){
        _hudVisible = YES;
        [MBProgressHUD hideAllHUDsForView:_viewController.view animated:YES];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:_viewController.view animated:YES];
        hud.labelText = @"Downloading Themes";
        [hud hide:YES afterDelay:10];
    }
}
-(void)hideAllHudsInRootView{
    _hudVisible = NO;
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"downloadThemesFromiCloud" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"doneSettingUpiCloud" object:nil];
    [MBProgressHUD hideAllHUDsForView:_viewController.view animated:YES];
    
}
-(void)setupThemeFiles
{
    @autoreleasepool {
        BOOL isJB = [th checkIfJB];
        NSFileManager *fm = [NSFileManager defaultManager];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        BOOL isDir;
        if(isJB && ![fm fileExistsAtPath:[documentsDirectory stringByAppendingFormat:@"/tethered"] isDirectory:&isDir]){
            [fm createDirectoryAtPath:[documentsDirectory stringByAppendingFormat:@"/tethered"] withIntermediateDirectories:NO attributes:nil error:nil];
        }
        if(isJB && ![fm fileExistsAtPath:[documentsDirectory stringByAppendingFormat:@"/lockscreen"] isDirectory:&isDir]){
            [fm createDirectoryAtPath:[documentsDirectory stringByAppendingFormat:@"/lockscreen"] withIntermediateDirectories:NO attributes:nil error:nil];
        }
        
        /*
        NSError *errorCreating;
        if(![fm createDirectoryAtPath:[documentsDirectory stringByAppendingPathComponent:@"myThemes/"] withIntermediateDirectories:NO attributes:nil error:&errorCreating]){

        }
        */
        //Main file copy
        if(isJB){
            
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"useSlideshow"];
            NSString *buildJS = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"build" ofType:@"js"] encoding:NSUTF8StringEncoding error:nil] ;
            buildJS = [buildJS stringByReplacingOccurrencesOfString:@"var shouldShowSlideShow = true;" withString:@"var shouldShowSlideShow = false;"];
            
            //WEATHER JS
            NSString *weatherJS = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"weather" ofType:@"js"] encoding:NSUTF8StringEncoding error:nil] ;
            NSString *weatherJSTarget = [documentsDirectory stringByAppendingString:@"/tethered/weather.js"];
            [weatherJS writeToFile:weatherJSTarget atomically:NO encoding:NSUTF8StringEncoding error:nil];
            
            //BUILD JS
            NSString *buildJSTarget = [documentsDirectory stringByAppendingString:@"/lockscreen/build.js"];
            [buildJS writeToFile:buildJSTarget atomically:NO encoding:NSUTF8StringEncoding error:nil];
            buildJSTarget = [documentsDirectory stringByAppendingString:@"/tethered/build.js"];
            [buildJS writeToFile:buildJSTarget atomically:NO encoding:NSUTF8StringEncoding error:nil];
            
            //HTML
            NSInteger i = [[NSDate date] timeIntervalSince1970];
            NSString *html = [documentsDirectory stringByAppendingString:@"/tethered/LockBackground.html"];
            NSString *htmlls = [documentsDirectory stringByAppendingString:@"/lockscreen/LockBackground.html"];
            NSString *htmlTemplate = [NSString stringWithContentsOfFile:html encoding:NSUTF8StringEncoding error:nil];
            htmlTemplate = [htmlTemplate stringByReplacingOccurrencesOfString:@"build.js?6513543" withString:[NSString stringWithFormat:@"build.js?%i",i]];
            htmlTemplate = [htmlTemplate stringByReplacingOccurrencesOfString:@"weather.js?6521345" withString:[NSString stringWithFormat:@"weather.js?%i",i]];
            [htmlTemplate writeToFile:html atomically:NO encoding:NSUTF8StringEncoding error:nil];
            html = [documentsDirectory stringByAppendingString:@"/tethered/LockBackground.html"];
            [htmlTemplate writeToFile:html atomically:NO encoding:NSUTF8StringEncoding error:nil];
            [htmlTemplate writeToFile:htmlls atomically:NO encoding:NSUTF8StringEncoding error:nil];
            
            
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        /*
        
        if([fm fileExistsAtPath:[documentsDirectory stringByAppendingFormat:@"/slideshow.html"]])
        {
            [fm removeItemAtPath:[documentsDirectory stringByAppendingFormat:@"/slideshow.html"] error:nil];
        }
        if([fm fileExistsAtPath:[documentsDirectory stringByAppendingFormat:@"/tethered/slideshow.html"]])
        {
            [fm removeItemAtPath:[documentsDirectory stringByAppendingFormat:@"/tethered/slideshow.html"] error:nil];
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
        slidesList = [NSString stringWithContentsOfFile:[documentsDirectory stringByAppendingFormat:@"/tethered/slideindex.txt"] encoding:NSUTF8StringEncoding error:nil];
        //NSLog(@"slidesList: %@", slidesList);
        slideshow = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] 
                                                        pathForResource:@"slideshow" ofType:@"html"]  encoding:NSUTF8StringEncoding error:nil];
        slideshow = [[slideshow stringByReplacingOccurrencesOfString:@"[[lines]]" 
                                                          withString:[NSString stringWithFormat:@"['%@']", 
                                                                      [[slidesList stringByReplacingOccurrencesOfString:@"\n" 
                                                                                                             withString:@"','"]
                                                                       stringByReplacingOccurrencesOfString:@",''" withString:@""]
                                                                      ]] stringByReplacingOccurrencesOfString:@"'slides/slide" withString:@"'slide"];
        
        [slideshow writeToFile:[documentsDirectory stringByAppendingFormat:@"/slideshow.html"] atomically:YES encoding:NSUTF8StringEncoding error:nil];
        [slideshow writeToFile:[documentsDirectory stringByAppendingFormat:@"/tethered/slideshow.html"] atomically:YES encoding:NSUTF8StringEncoding error:nil];
        */
        
        if(![fm fileExistsAtPath:[documentsDirectory stringByAppendingFormat:@"/jquery.min.js"]])
        {
            [fm copyItemAtPath:[[NSBundle mainBundle] 
                                pathForResource:@"jquery.min" ofType:@"js"] 
                        toPath:[documentsDirectory stringByAppendingFormat:@"/jquery.min.js"]
                         error:nil];
            
        }
        if([fm fileExistsAtPath:[documentsDirectory stringByAppendingFormat:@"/jquery.min.js"]]){
            [CBThemeHelper addSkipBackupAttributeToItemAtURL:[NSURL URLWithString:[documentsDirectory stringByAppendingFormat:@"/jquery.min.js"] ]];
        }
        if(isJB && ![fm fileExistsAtPath:[documentsDirectory stringByAppendingFormat:@"/tethered/jquery.min.js"]])
        {
            [fm copyItemAtPath:[[NSBundle mainBundle] 
                                pathForResource:@"jquery.min" ofType:@"js"] 
                        toPath:[documentsDirectory stringByAppendingFormat:@"/tethered/jquery.min.js"] 
                         error:nil];
        }
        if(isJB && ![fm fileExistsAtPath:[documentsDirectory stringByAppendingFormat:@"/tethered/weather.js"]])
        {
            [fm copyItemAtPath:[[NSBundle mainBundle]
                                pathForResource:@"weather" ofType:@"js"]
                        toPath:[documentsDirectory stringByAppendingFormat:@"/tethered/weather.js"]
                         error:nil];
        }
        if(isJB && ![fm fileExistsAtPath:[documentsDirectory stringByAppendingFormat:@"/tethered/climacons-webfont.svg"]])
        {
            [fm copyItemAtPath:[[NSBundle mainBundle]
                                pathForResource:@"climacons-webfont" ofType:@"svg"]
                        toPath:[documentsDirectory stringByAppendingFormat:@"/tethered/climacons-webfont.svg"]
                         error:nil];
        }
        if(![fm fileExistsAtPath:[documentsDirectory stringByAppendingFormat:@"/empty.png"]])
        {
            [fm copyItemAtPath:[[NSBundle mainBundle] 
                                pathForResource:@"empty" ofType:@"png"] 
                        toPath:[documentsDirectory stringByAppendingFormat:@"/empty.png"] 
                         error:nil];
        }
        if([fm fileExistsAtPath:[documentsDirectory stringByAppendingFormat:@"/empty.png"]]){
            
            [CBThemeHelper addSkipBackupAttributeToItemAtURL:[NSURL URLWithString:[documentsDirectory stringByAppendingFormat:@"/empty.png"] ]];
        }
        
        if(isJB && ![fm fileExistsAtPath:[documentsDirectory stringByAppendingFormat:@"/tethered/empty.png"]])
        {
            [fm copyItemAtPath:[[NSBundle mainBundle] 
                                pathForResource:@"empty" ofType:@"png"] 
                        toPath:[documentsDirectory stringByAppendingFormat:@"/tethered/empty.png"] 
                         error:nil];
        }
    
    
        //delete uploads directory  
        BOOL uploadsIsDir;
        if([fm fileExistsAtPath:[documentsDirectory stringByAppendingFormat:@"/uploads"] isDirectory:&uploadsIsDir])
        {
            //NSLog(@"uploads found");
            if (uploadsIsDir) {
                NSLog(@"uploads is dir");
                NSError *errorDeleteUploads;
                if(![fm removeItemAtPath:[documentsDirectory stringByAppendingFormat:@"/uploads"] error:&errorDeleteUploads]){
                    //NSLog(@"error deleting uploads directory: %@", errorDeleteUploads);
                }
                else {
                    //NSLog(@"uploads deleted");
                }
            }
        
        }
        else {
            //NSLog(@"no uploads dir found");
        }
    }

}


- (void) setScreenVisible:(NSString *)val
{
    ScreenVisible = [val boolValue];
 //   if(ScreenVisible)
 //       [self refreshViewsGCD];
}
-(void)forceWeatherStart
{
    //NSLog(@"AppDelegate - ForceWeatherStart called, doing nothing");
    
}
-(BOOL)getScreenVisible
{ 
    return ScreenVisible;
}
-(void) refreshViewsGCD
{
    if([self getScreenVisible]||YES){
        dispatch_async(dispatch_queue_create("com.gmtaz.Clockbuilder.refreshViewsGCD", NULL), ^{
            [_viewController performSelector:@selector(refreshViews)];
        });
    }
}

-(void)runTimer
{
    //if(ScreenVisible){
        NSMutableArray *widgetsList = [kDataSingleton getWidgetsListFromSettings];
        if([widgetsList count]>0 ){
            //dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
            //dispatch_async(queue, ^{
                if (_viewController.view !=nil) {
                    NSArray *subv = [NSArray arrayWithArray:[_viewController.view subviews]];
                    
                    for (UIView *v in subv) {
                        if([v class] == [textBasedWidget class])
                        {
                            [v performSelector:@selector(updateView)];
                        }
                    }
                }
            //});
        }
    //}
}

#pragma mark modifying widgets
- (void) saveWeatherSettings:(NSDictionary *)weatherData
{
    
    //dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    //dispatch_async(queue, ^{
        
        NSMutableDictionary *sets = [kDataSingleton settings];
        [sets setObject:weatherData forKey:@"weatherData"];
        
    //});
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
    NSMutableArray *tempArray = [widgetsArray mutableCopy];
    [kDataSingleton setWidgetsListArray:tempArray];
    for(NSDictionary* widget in tempArray)
    {
        if([[widget objectForKey:@"subClass"]isEqualToString:@"weather"]){  
            //check if data already exists
            if(![[weatherSingleton sharedInstance] currentWeatherData]){
                [[weatherSingleton sharedInstance] updateWeatherData];
            }
            break;
        }
    }
    
    //[_viewController performSelector:@selector(resetToolbar)];
    if(kIsIpad)
        [self refreshViewsGCD];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
        
        if([_viewController presentedViewController] !=nil)
        {
            //[MBProgressHUD hideHUDForView:_viewController.modalViewController.view animated:YES];
        }
        else{
            //[MBProgressHUD hideHUDForView:_viewController.view animated:YES];
        }
        [[GMTHelper sharedInstance] showOverlay:@"Theme Activated" iconImage:nil];
        if(kIsIpad)
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshBG" object:nil];
    });
    
}

- (void) saveWidgetSettings:(NSString *)widgetIndexString widgetDataDictionary:(NSDictionary *)widgetData
{
    dispatch_queue_t queue = dispatch_queue_create(kSaveSettingsQueue, NULL);
    dispatch_async(queue, ^{
        
        [kDataSingleton setWidgetData:[widgetIndexString intValue]
                                             withData:[widgetData mutableCopy]];
        
        BOOL redraw = [[[NSUserDefaults standardUserDefaults] objectForKey:@"forceRedraw"] boolValue];
        
        if(redraw){
            dispatch_sync(dispatch_get_main_queue(), ^{
                [_viewController forceWidgetRedraw:[self getWidgetToRedraw:widgetIndexString]];
            });
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"forceRedraw"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        });
        
    });
}
- (void) addWidgetToArray:(NSDictionary *)widgetData
{
    [[DataSingleton sharedInstance] addWidgetToList:[widgetData mutableCopy]];
}

- (void) refreshBG
{
    [_viewController performSelector:@selector(drawBackground)];
}

- (void) resetTheme{
    
    NSMutableArray *ar = [[[DataSingleton sharedInstance] getWidgetsListFromSettings] mutableCopy];
    [ar removeAllObjects];
    [[DataSingleton sharedInstance] setWidgetsListArray:ar];
    
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
    if([[kDataSingleton getWidgetsListFromSettings] count]==0){
        [_viewController.showToolbar setHidden:YES];
        [_viewController.toolbar setHidden:NO];
    }
}
- (void) goBackToRootView
{
    [self setScreenVisible:@"YES"];
    
    if(kIsIpad){
        [_viewController.pop dismissPopoverAnimated:YES];
    }
    else{
        if([_viewController presentedViewController]!=nil)
            [_viewController dismissViewControllerAnimated:YES completion:nil];
    }
    [_viewController performSelector:@selector(resetToolbar)];
    [_viewController performSelector:@selector(selectWidget:) withObject:nil];
    [self refreshViewsGCD];
}

-(void)getCategoriesArray
{
    [[GMTHelper sharedInstance] getCategoriesArray];
}

- (void) setDefaults
{
    //create themes folder   
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"timeFormat"]==nil)
        [[NSUserDefaults standardUserDefaults] setObject:@"24h" forKey:@"timeFormat"];
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"rotateWallpaper"]==nil)
        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"rotateWallpaper"];
    
    NSMutableDictionary *sets = [kDataSingleton getSettings];
    
    NSString *settingsPath = [[NSBundle mainBundle] pathForResource:@"settings" ofType:@"plist"];
    NSDictionary *replacementDict = [NSDictionary dictionaryWithContentsOfFile:settingsPath];
    NSArray *updates = [replacementDict objectForKey:@"updatedConstants"];
    for(NSString *str in updates)
    {
        [sets setObject:[replacementDict objectForKey:str] forKey:str];
    }
    if([sets objectForKey:@"slidesArray"]==nil)
        [sets setObject:[replacementDict objectForKey:@"slidesArray"] forKey:@"slidesArray"];

    
    //NSLog(@"sets: %@", sets);
    [weatherSingleton sharedInstance];
    [self getCategoriesArray];
    [self showHideToolbar];
}

- (void) updateThemeWeather
{
    if([th checkIfThemeInstalled]){
        //[th run:YES];    
        //[th run:@"YES"];
    }
}

- (void) refreshWithNewWeatherData
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul), ^{
        [self updateThemeWeather];
    });
    if([self getScreenVisible] || kIsIpad){
    
        if([[UIApplication sharedApplication] applicationState]==UIApplicationStateActive)
        {
            for(UIView *widget in [self.viewController.view subviews])
            {
                if([widget tag]>9)
                {
                    NSInteger index = widget.tag - 10;
                    NSMutableArray *widgetsList = [kDataSingleton getWidgetsListFromSettings];
                    if(index<widgetsList.count){
                        NSString *cls = [[widgetsList objectAtIndex:index] objectForKey:@"subClass"];
                        if([cls isEqualToString:@"weather"]){
                            [widget performSelector:@selector(refreshWithNewWeatherData)];
                            if([widget respondsToSelector:@selector(updateViewWeather)])
                                [widget performSelector:@selector(updateViewWeather)];
                        }
                    }
                    //[widget performSelector:@selector(refreshWithNewWeatherData)];
                }
            }
        }
     
    }
     
}

-(BOOL)isThereAWeatherWidget
{
    NSMutableArray *widgetsList = [kDataSingleton getWidgetsListFromSettings];
    for(NSMutableDictionary* widget in widgetsList)
    {
        if([[widget objectForKey:@"subClass"]isEqualToString:@"weather"])
            return true;
    }
    return false;
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
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
    if([[GMTHelper sharedInstance] deviceIsConnectedToInet]){
        
            NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey];
            NSError *error = NULL;
            NSString *response = [NSString stringWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://clockbuilder.gmtaz.com/versioncheck.php?v=%@",version]] encoding:NSUTF8StringEncoding error:&error];
        //NSLog(@"response: %@", response);
            _runningUpdateCheckOnStart = NO;
            if(![response isEqualToString:@"OK"]){
                [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"needsToUpdate"];      
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    if(!_updateAlertVisible){
                        _updateAlertVisible = YES;
                        CustomAlertView *alert = [[CustomAlertView alloc] initWithTitle:@"Update Required" message:response delegate:self cancelButtonTitle:@"Update Now" otherButtonTitles: nil];
                        [alert show];
                    }
                });                
            }
            else{         
                [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"needsToUpdate"];   
                [[NSUserDefaults standardUserDefaults] synchronize]; 
            }
    }
    else
        _runningUpdateCheckOnStart = NO;
    });
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"needsToUpdate"] boolValue];
}



- (void)applicationDidEnterBackground:(UIApplication *)application
{
    application.idleTimerDisabled = NO;
    
    if([self getScreenVisible])
        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"screenWasVisible"];
    else
        [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"screenWasVisible"];
    
    [kDataSingleton saveSettingsToDefaults];
    
    
    //[getWeather stop]; 
}


- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [_viewController viewWillAppear:YES];
   // NSLog(@"APPLICATION WILL ENTER FOREGROUND");
    //if([[NSUserDefaults standardUserDefaults] objectForKey:@"needsToUpdate"]==nil){
    if (!_runningUpdateCheckOnStart) {
        if([self latestVersion]){
            
        }
    }
    //}
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    
    application.idleTimerDisabled = YES;
    [self showHideToolbar];
    //NSLog(@"APPLICATION DID BECOME ACTIVE");
    [[NSNotificationCenter defaultCenter] postNotificationName:kApplicationDidBecomeActiveNotification object:nil];
    
    dispatch_async(dispatch_queue_create("com.gmtaz.clockbuilder.query", NULL), ^{
        NSString *urlstr = [NSString stringWithFormat:@"http://clockbuilder.gmtaz.com/blockList.php?udid=%@",[OpenUDID value]];
        NSURL *url = [NSURL URLWithString:urlstr];
        NSString *blocked =  [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
        [[NSUserDefaults standardUserDefaults] setBool:[blocked boolValue] forKey:@"blocked"];
        if([blocked boolValue]){
            NSLog(@"blocked");
        }
        else {
            NSLog(@"not blocked");
        }
    });
    
    
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"convertedAllThemes"])
        [CBThemeHelper convertThemesToDocuments];
    
    if([[weatherSingleton sharedInstance] isThereAWeatherWidget])
        [[weatherSingleton sharedInstance] updateWeatherData];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    
    [kDataSingleton saveSettingsToDefaults];
    [_viewController viewWillDisappear:YES];
    
}
- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */ 
    [self saveContext];
    [kDataSingleton saveSettingsToDefaults];
    application.idleTimerDisabled = NO;
    //[getWeather stop];
}
#pragma mark Custom File Handling

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if([url isFileURL])
    {
        //[self performSelector:@selector(handleThemeFile:) withObject:url];
        [self handleThemeFile:url];
    }
    //NSString* scheme = [url scheme];
    /*NSString* prefix = [NSString stringWithFormat:@"fb%@", SHKCONFIG(facebookAppId)];
    if ([scheme hasPrefix:prefix])
        return [SHKFacebook handleOpenURL:url];
    */
    /*
    if ([[DBSession sharedSession] handleOpenURL:url] == YES) {
        if ([[DBSession sharedSession] isLinked]) {
            NSLog(@"%s App linked successfully!", __PRETTY_FUNCTION__);
            [self registerSyncManager];
        } else {
            NSLog(@"%s App was not linked successfully.", __PRETTY_FUNCTION__);
        }
    } else {
        NSLog(@"%s DBSession couldn't handle opening the URL %@", __PRETTY_FUNCTION__, url);
    }
     */
    
    return YES;
}

-(void) handleThemeFile:(NSURL *)url
{
    [[GMTHelper sharedInstance] processIncomingFileURL:url];
}


- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}
#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];//[[TICDSSynchronizedManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"CBModel" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    NSString *storeName = kCoreDataStoreName;
    if(kIsIpad){
        storeName = kCoreDataStoreNameiPad;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:storeName];
    
    //if( ![[NSFileManager defaultManager] fileExistsAtPath:[storeURL path]] ) {
    //    [self setDownloadStoreAfterRegistering:YES];
    //}
    NSDictionary *options = nil;//[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"persistant store coordinator error %@, %@", error, [error userInfo]);
        
        //abort();
    }
    
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}
/*
#pragma mark -
#pragma mark DBSessionDelegate methods

- (void)sessionDidReceiveAuthorizationFailure:(DBSession *)session userId:(NSString *)userId;
{
    [[DBSession sharedSession] unlinkUserId:userId];
    NSLog(@"%s Could not create DBSession for user %@", __PRETTY_FUNCTION__, userId);
}


-(BOOL)isDropboxSyncing{
    return _activity > 0;
}
 */

@end




