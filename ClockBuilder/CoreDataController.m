

#import "CoreDataController.h"
#import "ClockBuilderAppDelegate.h"
#import "CoreTheme.h"
#import "CoreThemeiPad.h"

NSString * kiCloudPersistentStoreFilename = @"iCloudStore.sqlite";
NSString * kFallbackPersistentStoreFilename = @"fallbackStore.sqlite"; //used when iCloud is not available
NSString * kSeedStoreFilename = @"seedStore.sqlite"; //holds the seed person records
NSString * kLocalStoreFilename = @"localStore.sqlite"; //holds the states information

#define SEED_ICLOUD_STORE NO
//#define FORCE_FALLBACK_STORE

static NSOperationQueue *_presentedItemOperationQueue;

@interface CoreDataController (Private)

- (BOOL)iCloudAvailable;

- (BOOL)loadLocalPersistentStore:(NSError *__autoreleasing *)error;
- (BOOL)loadFallbackStore:(NSError * __autoreleasing *)error;
- (BOOL)loadiCloudStore:(NSError * __autoreleasing *)error;
- (void)asyncLoadPersistentStores;
- (void)dropStores;
- (void)reLoadiCloudStore:(NSPersistentStore *)store readOnly:(BOOL)readOnly;

- (void)deDupe:(NSNotification *)importNotification;

- (void)addTheme:(CoreTheme *)theme toStore:(NSPersistentStore *)store withContext:(NSManagedObjectContext *)moc;
- (BOOL)seedStore:(NSPersistentStore *)store withPersistentStoreAtURL:(NSURL *)seedStoreURL error:(NSError * __autoreleasing *)error;

- (void)copyContainerToSandbox;
- (void)nukeAndPave;

- (NSURL *)iCloudStoreURL;
- (NSURL *)seedStoreURL;
- (NSURL *)fallbackStoreURL;
- (NSURL *)applicationSandboxStoresDirectory;
- (NSString *)applicationDocumentsDirectory;

@end

@implementation CoreDataController
{
    NSLock *_loadingLock;
    NSURL *_presentedItemURL;
    BOOL deduping;
}
@synthesize ubiquityURL = _ubiquityURL;
@synthesize currentUbiquityToken = _currentUbiquityToken;
@synthesize psc = _psc;
@synthesize mainThreadContext = _mainThreadContext;
@synthesize localStore = _localStore;
@synthesize fallbackStore = _fallbackStore;
@synthesize iCloudStore = _iCloudStore;
@synthesize dedupingInProgress = _dedupingInProgress;

+ (void)initialize {
    if (self == [CoreDataController class]) {
        _presentedItemOperationQueue = [[NSOperationQueue alloc] init];
    }
}

- (id)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _loadingLock = [[NSLock alloc] init];
    _ubiquityURL = nil;
    _currentUbiquityToken = nil;
    _presentedItemURL = nil;
    
    NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:nil];
    _psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    
    if([CBThemeHelper isIOS5]){    
        _mainThreadContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    }
    else {
        _mainThreadContext = [[NSManagedObjectContext alloc] init];
    }
    [_mainThreadContext setPersistentStoreCoordinator:_psc];
    
    _currentUbiquityToken = @"com.gmtaz.Clockbuilder.iCloudUbiquityCoreDataToken";//nil;
    
    _dedupingInProgress = @"NO";
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)iCloudAvailable {

    return [CBThemeHelper isIOS5] && [CBThemeHelper isCloudEnabled];
    /*
#ifdef FORCE_FALLBACK_STORE
    BOOL available = NO;
#else
    BOOL available = (_currentUbiquityToken != nil);
#endif
    return available;
     */
}


- (void)applicationResumed {
/*
    id token = [[NSFileManager defaultManager] ubiquityIdentityToken];
    if (self.currentUbiquityToken != token) {
        if (NO == [self.currentUbiquityToken isEqual:token]) {
            [self iCloudAccountChanged:nil];
        }
    }
    */
    
}

- (void)iCloudAccountChanged:(NSNotification *)notification {
    //tell the UI to clean up while we re-add the store
    [self dropStores];
    
    // update the current ubiquity token
    //id token = [[NSFileManager defaultManager] ubiquityIdentityToken];
    //_currentUbiquityToken = token;
    
    //reload persistent store
    [self loadPersistentStores];
}

#pragma mark Managing the Persistent Stores
- (void)loadPersistentStores {
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(globalQueue, ^{
        BOOL locked = NO;
        @try {
            [_loadingLock lock];
            locked = YES;
            [self asyncLoadPersistentStores];
        } @finally {
            if (locked) {
                [_loadingLock unlock];
                locked = NO;
            }
        }
    });
}

- (BOOL)loadLocalPersistentStore:(NSError *__autoreleasing *)error {
    BOOL success = YES;
    NSError *localError = nil;
    
    if (_localStore) {
        return success;
    }
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    //load the store file containing the 50 states
    NSURL *storeURL = [[self applicationSandboxStoresDirectory] URLByAppendingPathComponent:kLocalStoreFilename];
    
    if (NO == [fm fileExistsAtPath:[storeURL path]]) {
        //copy it from the bundle
        /*
        NSURL *bundleURL = [[NSBundle mainBundle] URLForResource:@"localStore" withExtension:@"sqlite"];
        if (nil == bundleURL) {
            NSLog(@"Local store not found in bundle, this is likely a build issue, make sure the store file is being copied as a bundle resource.");
            
            bundleURL = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: kLocalStoreFilename]];
            
            [_psc addPersistentStoreWithType:NSSQLiteStoreType
                               configuration:@"LocalConfig"
                                         URL:bundleURL
                                     options:nil
                                       error:&localError];
            //abort();
        }
        
        success = [fm copyItemAtURL:bundleURL toURL:storeURL error:&localError];
        if (NO == success) {
            NSLog(@"Trouble copying the local store file from the bundle: %@", localError);
            //abort();
        }
         */
    }
    NSLog(@"storeURL: %@", storeURL);
    //add the store, use the "LocalConfiguration" to make sure state entities all end up in this store and that no iCloud entities end up in it
    _localStore = [_psc addPersistentStoreWithType:NSSQLiteStoreType
                                     configuration:nil
                                               URL:storeURL
                                           options:nil
                                             error:&localError];
    success = (_localStore != nil);
    if (success == NO) {
        //ruh roh
        if (localError && (error != NULL)) {
            *error = localError;
        }
    }
    
    return success;
}

- (BOOL)loadFallbackStore:(NSError * __autoreleasing *)error {
    BOOL success = YES;
    NSError *localError = nil;
    
    if (_fallbackStore) {
        return YES;
    }
    NSURL *storeURL = [self fallbackStoreURL];
    _fallbackStore = [_psc addPersistentStoreWithType:NSSQLiteStoreType
                                        configuration:@"fallbackConfig"
                                                  URL:storeURL
                                              options:nil
                                                error:&localError];
    success = (_fallbackStore != nil);
    if (NO == success) {
        if (localError  && (error != NULL)) {
            *error = localError;
        }
    }
    
    return success;
}

-(NSURL *)BuildiCloudStoreURL{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if([defaults URLForKey:@"icloudDataURL"]){
        return [defaults URLForKey:@"icloudDataURL"];
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];        
    NSURL *iCloud;
    if([CBThemeHelper isIOS5])
        iCloud = [fileManager URLForUbiquityContainerIdentifier:nil];
    
    if(iCloud){
        NSString *dataFileName = @"ClockBuilder.sqlite";
        
        NSString *iCloudDataDirectoryName = @"Data.nosync";
        NSString *iCloudData = [[[iCloud path] 
                                 stringByAppendingPathComponent:iCloudDataDirectoryName] 
                                stringByAppendingPathComponent:dataFileName];
        
        NSURL *iCloudDataURL = [NSURL fileURLWithPath:iCloudData];
    
        return iCloudDataURL;
    }
    else {
        return nil;
    }
    
}

- (BOOL)loadiCloudStore:(NSError * __autoreleasing *)error {
    BOOL success = YES;
    
    NSError *localError = nil;
    /**/
    
    NSFileManager *fm = [[NSFileManager alloc] init];
    _ubiquityURL = [fm URLForUbiquityContainerIdentifier:nil];
    
    NSURL *iCloudStoreURL = [self iCloudStoreURL];
    NSURL *iCloudDataURL = [self.ubiquityURL URLByAppendingPathComponent:@"iCloudData"];
    NSMutableDictionary *options = [NSMutableDictionary dictionary];
    [options setObject:[NSNumber numberWithBool:YES] forKey:NSMigratePersistentStoresAutomaticallyOption];
    [options setObject:[NSNumber numberWithBool:YES] forKey:NSInferMappingModelAutomaticallyOption];
    [options setObject:@"iCloudStore"            forKey:NSPersistentStoreUbiquitousContentNameKey];
    [options setObject:iCloudDataURL             forKey:NSPersistentStoreUbiquitousContentURLKey];

    _iCloudStore = [self.psc addPersistentStoreWithType:NSSQLiteStoreType
                                          configuration:@"iCloudConfig"
                                                    URL:iCloudStoreURL
                                                options:options
                                                  error:&localError];
    success = (_iCloudStore != nil);
    if (success) {
        //set up the file presenter
        _presentedItemURL = iCloudDataURL;
        [NSFileCoordinator addFilePresenter:self];
    } else {
        if (localError  && (error != NULL)) {
            *error = localError;
        }
    }
    
    
    /**/
    /*
    // ** Note: if you adapt this code for your own use, you MUST change this variable:
    NSString *iCloudEnabledAppID = @"8AMM5A65M4.com.gmtaz.ClockBuilder";
    
    // ** Note: if you adapt this code for your own use, you should change this variable:        
    NSString *dataFileName = @"ClockBuilder.sqlite";
    
    // ** Note: For basic usage you shouldn't need to change anything else
    
    NSString *iCloudDataDirectoryName = @"Data.nosync";
    NSString *iCloudLogsDirectoryName = @"Logs";
    NSFileManager *fileManager = [NSFileManager defaultManager];        
    NSURL *iCloud;
    if([CBThemeHelper isIOS5])
        iCloud = [fileManager URLForUbiquityContainerIdentifier:nil];
    
    if (iCloud){ //&& [CBThemeHelper isCloudEnabled]) {
        
        NSLog(@"iCloud is working");
        
        NSURL *iCloudLogsPath = [NSURL fileURLWithPath:[[iCloud path] stringByAppendingPathComponent:iCloudLogsDirectoryName]];
        
        NSLog(@"iCloudEnabledAppID = %@",iCloudEnabledAppID);
        NSLog(@"dataFileName = %@", dataFileName); 
        NSLog(@"iCloudDataDirectoryName = %@", iCloudDataDirectoryName);
        NSLog(@"iCloudLogsDirectoryName = %@", iCloudLogsDirectoryName);  
        NSLog(@"iCloud = %@", iCloud);
        NSLog(@"iCloudLogsPath = %@", iCloudLogsPath);
        
        if([fileManager fileExistsAtPath:[[iCloud path] stringByAppendingPathComponent:iCloudDataDirectoryName]] == NO) {
            NSError *fileSystemError;
            [fileManager createDirectoryAtPath:[[iCloud path] stringByAppendingPathComponent:iCloudDataDirectoryName] 
                   withIntermediateDirectories:YES 
                                    attributes:nil 
                                         error:&fileSystemError];
            if(fileSystemError != nil) {
                NSLog(@"Error creating database directory %@", fileSystemError);
            }
        }
        
        NSString *iCloudData = [[[iCloud path] 
                                 stringByAppendingPathComponent:iCloudDataDirectoryName] 
                                stringByAppendingPathComponent:dataFileName];
        
        NSLog(@"iCloudData = %@", iCloudData);
        
        NSMutableDictionary *options = [NSMutableDictionary dictionary];
        [options setObject:[NSNumber numberWithBool:YES] forKey:NSMigratePersistentStoresAutomaticallyOption];
        [options setObject:[NSNumber numberWithBool:YES] forKey:NSInferMappingModelAutomaticallyOption];
        [options setObject:iCloudEnabledAppID            forKey:NSPersistentStoreUbiquitousContentNameKey];
        [options setObject:iCloudLogsPath                forKey:NSPersistentStoreUbiquitousContentURLKey];
        
        
        NSURL *iCloudDataURL = [NSURL fileURLWithPath:iCloudData];
        
        _iCloudStore = [self.psc addPersistentStoreWithType:NSSQLiteStoreType 
                          configuration:nil 
                                    URL:iCloudDataURL
                                options:options 
                                  error:&localError];
        
        success = (_iCloudStore != nil);
        if (success) {
            [[NSUserDefaults standardUserDefaults] setURL:iCloudDataURL forKey:@"icloudDataURL"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            //set up the file presenter
            _presentedItemURL = iCloudDataURL;
            [NSFileCoordinator addFilePresenter:self];
        } else {
            if (localError  && (error != NULL)) {
                *error = localError;
            }
        }
        
    }
     */
    return success;
}

- (void)asyncLoadPersistentStores {
    NSError *error = nil;
    
    //if iCloud is available, add the persistent store
    //if iCloud is not available, or the add call fails, fallback to local storage
    BOOL useFallbackStore = NO;
    if ([self iCloudAvailable]) {
        if ([self loadiCloudStore:&error]) {
            NSLog(@"Added iCloud Store");
            
            //check to see if we need to seed or migrate data from the fallback store
            BOOL seedCloud = NO;
#ifdef DEBUG
            seedCloud = YES;
#endif
            
            if(![[NSUserDefaults standardUserDefaults] boolForKey:@"seedediCloudDataForDevice"]||seedCloud){
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"seedediCloudDataForDevice"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                NSFileManager *fm = [NSFileManager defaultManager];
                if ([fm fileExistsAtPath:[[self fallbackStoreURL] path]]) {
                    //migrate data from the fallback store to the iCloud store
                    //there is no reason to do this synchronously since no other peer should have this data
                    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                    dispatch_async(globalQueue, ^{
                        NSError *blockError = nil;
                        
                        BOOL seedSuccess = [self seedStore:_iCloudStore
                                  withPersistentStoreAtURL:[self fallbackStoreURL]
                                                     error:&blockError];
                        
                        
                        if (seedSuccess) {
                            NSLog(@"Successfully seeded iCloud Store from Fallback Store");
                            //dedupe
                            self.dedupingInProgress = @"YES";
                            [self deDupe:nil];
                        } else {
                            NSLog(@"Error seeding iCloud Store from fallback store: %@", blockError);     
                            dispatch_async(dispatch_get_main_queue(), ^{      
                                self.dedupingInProgress = @"NO";          
                                [[NSNotificationCenter defaultCenter] postNotificationName:kFinishedDeduping object:nil];
                            });
                            //abort();
                        }
                    });
                }
                else {     
                    dispatch_async(dispatch_get_main_queue(), ^{      
                        self.dedupingInProgress = @"NO";          
                        [[NSNotificationCenter defaultCenter] postNotificationName:kFinishedDeduping object:nil];
                    });

                }
            }else {     
                dispatch_async(dispatch_get_main_queue(), ^{      
                    self.dedupingInProgress = @"NO";          
                    [[NSNotificationCenter defaultCenter] postNotificationName:kFinishedDeduping object:nil];
                });

            }
        } else {
            NSLog(@"Unable to add iCloud store: %@", error);                            dispatch_async(dispatch_get_main_queue(), ^{      
                self.dedupingInProgress = @"NO";          
                [[NSNotificationCenter defaultCenter] postNotificationName:kFinishedDeduping object:nil];
            });
            useFallbackStore = YES;
        }
    } else {
        useFallbackStore = YES;                            
        dispatch_async(dispatch_get_main_queue(), ^{      
            self.dedupingInProgress = @"NO";          
            [[NSNotificationCenter defaultCenter] postNotificationName:kFinishedDeduping object:nil];
        });
    }
    
    if (useFallbackStore) {
        if ([self loadFallbackStore:&error]) {
            NSLog(@"Added fallback store: %@", self.fallbackStore);
            //seed fallbackstore from icloud store
            NSFileManager *fm = [NSFileManager defaultManager];
            if ([self iCloudStoreURL] && [fm fileExistsAtPath:[[self iCloudStoreURL] path]]) {
                //migrate data from the fallback store to the iCloud store
                //there is no reason to do this synchronously since no other peer should have this data
                dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                dispatch_async(globalQueue, ^{
                    NSError *blockError = nil;
                    //clear fallback store
                    
                    BOOL shouldSeedFallback = NO;
                        
                    if(shouldSeedFallback){
                        
                        if([self wipeDataFromStoreMountedStore]){
                            NSLog(@"fallbackStore should be wiped");
                        }
                        
                        BOOL seedSuccess = [self seedStore:_fallbackStore
                                  withPersistentStoreAtURL:[self iCloudStoreURL]
                                                     error:&blockError];
                        
                        
                        if (seedSuccess) {
                            NSLog(@"Successfully seeded Fallback Store from iCloud Store");
                            //dedupe
                            self.dedupingInProgress = @"YES";
                            [self deDupe:nil];
                        } else {
                            NSLog(@"Error seeding Fallback Store from iCloud store: %@", blockError);      
                            dispatch_async(dispatch_get_main_queue(), ^{      
                                self.dedupingInProgress = @"NO";          
                                [[NSNotificationCenter defaultCenter] postNotificationName:kFinishedDeduping object:nil];
                            });
                            //abort();
                        }
                    }                            
                    dispatch_async(dispatch_get_main_queue(), ^{      
                        self.dedupingInProgress = @"NO";          
                        [[NSNotificationCenter defaultCenter] postNotificationName:kFinishedDeduping object:nil];
                    });
                     
                });
            }
            
            
            
        } else {
            NSLog(@"Unable to add fallback store: %@", error);                            
            dispatch_async(dispatch_get_main_queue(), ^{      
                self.dedupingInProgress = @"NO";          
                [[NSNotificationCenter defaultCenter] postNotificationName:kFinishedDeduping object:nil];
            });
            abort();
        }
    }
}

-(BOOL)wipeDataFromStoreMountedStore{
    
    BOOL success = YES;
    NSError *localError = nil;
    
    
    
    if(_psc){
        NSManagedObjectContext *seedMOC = [[NSManagedObjectContext alloc] init];
        [seedMOC setPersistentStoreCoordinator:_psc];
        
        NSFetchRequest *fr = [NSFetchRequest fetchRequestWithEntityName:@"CoreTheme"];
        NSUInteger batchSize = 10;
        [fr setFetchBatchSize:batchSize];
        
        NSArray *themes = [seedMOC executeFetchRequest:fr error:&localError];
        
        NSUInteger i = 10;
        for (CoreTheme *theme in themes) {
            NSLog(@"wiping theme: %@", theme.recordUUID);
            [seedMOC deleteObject:theme];            
            if (0 == (i % batchSize)) {
                success = [seedMOC save:&localError];
                if (success) {
                    /*
                     Reset the managed object context to free the memory for the inserted objects
                     The faulting array used for the fetch request will automatically free objects
                     with each batch, but inserted objects remain in the managed object context for
                     the lifecycle of the context
                     */
                    [seedMOC reset];
                } else {
                    NSLog(@"Error saving during seed: %@", localError);
                    break;
                }
            }
            
            i++;
        }
        
        //one last save
        if ([seedMOC hasChanges]) {
            success = [seedMOC save:&localError];
            [seedMOC reset];
        }
    }
    else {
        success = NO;
    }
    return success;
}


- (void)dropStores {
    NSError *error = nil;
    
    if (_fallbackStore) {
        if ([_psc removePersistentStore:_fallbackStore error:&error]) {
            NSLog(@"Removed fallback store");
            _fallbackStore = nil;
        } else {
            NSLog(@"Error removing fallback store: %@", error);
        }
    }
    
    if (_iCloudStore) {
        _presentedItemURL = nil;
        [NSFileCoordinator removeFilePresenter:self];
        if ([_psc removePersistentStore:_iCloudStore error:&error]) {
            NSLog(@"Removed iCloud Store");
            _iCloudStore = nil;
        } else {
            NSLog(@"Error removing iCloud Store: %@", error);
        }
    }
}

- (void)reLoadiCloudStore:(NSPersistentStore *)store readOnly:(BOOL)readOnly {
    NSMutableDictionary *options = [[NSMutableDictionary alloc] initWithDictionary:[store options]];
    if (readOnly) {
        [options setObject:[NSNumber numberWithBool:YES] forKey:NSReadOnlyPersistentStoreOption];
    }
    
    NSError *error = nil;
    NSURL *storeURL = [store URL];
    NSString *storeType = [store type];
    NSString *configurationName = [store configurationName];
    _iCloudStore = [_psc addPersistentStoreWithType:storeType configuration:configurationName URL:storeURL options:options error:&error];
    if (_iCloudStore) {
        NSLog(@"Added store back as read only: %@", store);
    } else {
        NSLog(@"Error adding read only store: %@", error);
    }
}

#pragma mark -
#pragma mark Application Lifecycle - Uniquing

-(BOOL)isDeduping{
    return [self.dedupingInProgress boolValue];
}

- (void)deDupe:(NSNotification *)importNotification {
    //if importNotification, scope dedupe by inserted records
    //else no search scope, prey for efficiency.
    NSLog(@"DEDUPING");
    @autoreleasepool {
        NSError *error = nil;
        NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] init];
        [moc setPersistentStoreCoordinator:_psc];

        NSFetchRequest *fr = [[NSFetchRequest alloc] initWithEntityName:@"CoreTheme"];
        [fr setIncludesPendingChanges:NO]; //distinct has to go down to the db, not implemented for in memory filtering
        [fr setFetchBatchSize:1000]; //protect thy memory
        
        NSExpression *countExpr = [NSExpression expressionWithFormat:@"count:(recordUUID)"];
        NSExpressionDescription *countExprDesc = [[NSExpressionDescription alloc] init];
        [countExprDesc setName:@"count"];
        [countExprDesc setExpression:countExpr];
        [countExprDesc setExpressionResultType:NSInteger64AttributeType];
        
        NSAttributeDescription *recordID = [[[[[_psc managedObjectModel] entitiesByName] objectForKey:@"CoreTheme"] propertiesByName] objectForKey:@"recordUUID"];
        [fr setPropertiesToFetch:[NSArray arrayWithObjects:recordID, countExprDesc, nil]];
        [fr setPropertiesToGroupBy:[NSArray arrayWithObject:recordID]];
        
        [fr setResultType:NSDictionaryResultType];
        
        NSArray *countDictionaries = [moc executeFetchRequest:fr error:&error];
        NSMutableArray *duplicateThemes = [[NSMutableArray alloc] init];
        for (NSDictionary *dict in countDictionaries) {
            NSNumber *count = [dict objectForKey:@"count"];
            if ([count integerValue] > 1) {
                [duplicateThemes addObject:[dict objectForKey:@"recordUUID"]];
            }
        }
        
        NSLog(@"themes with dupes: %@", duplicateThemes);
        
        //fetch out all the duplicate records
        fr = [NSFetchRequest fetchRequestWithEntityName:@"CoreTheme"];
        [fr setIncludesPendingChanges:NO];
        
        
        NSPredicate *p = [NSPredicate predicateWithFormat:@"recordUUID IN (%@)", duplicateThemes];
        [fr setPredicate:p];
        
        NSSortDescriptor *emailSort = [NSSortDescriptor sortDescriptorWithKey:@"saveDate" ascending:YES];
        [fr setSortDescriptors:[NSArray arrayWithObject:emailSort]];
        
        NSUInteger batchSize = 10; //can be set 100-10000 objects depending on individual object size and available device memory
        [fr setFetchBatchSize:batchSize];
        NSArray *dupes = [moc executeFetchRequest:fr error:&error];
        
        CoreTheme *prevTheme = nil;
        
        NSUInteger i = 1;
        for (CoreTheme *theme in dupes) {
            if (prevTheme) {
                NSLog(@"theme.record %@ == prevTheme.record %@", theme.recordUUID,prevTheme.recordUUID);
                if ([theme.recordUUID isEqualToString:prevTheme.recordUUID]) {
                    
                    if ([theme.saveDate compare:theme.saveDate] == NSOrderedAscending) {
                        [moc deleteObject:theme];
                    } else {
                        [moc deleteObject:prevTheme];
                        prevTheme = theme;
                    }
                    
                    //[moc deleteObject:theme];
                } else {
                    prevTheme = theme;
                }
            } else {
                prevTheme = theme;
            }
            
            if (0 == (i % batchSize)) {
                //save the changes after each batch, this helps control memory pressure by turning previously examined objects back in to faults
                if ([moc save:&error]) {
                    NSLog(@"Saved successfully after uniquing");
                } else {
                    NSLog(@"Error saving unique results: %@", error);
                }
            }
            
            i++;
        }
        
        if ([moc save:&error]) {
            NSLog(@"Saved successfully after uniquing");    
            self.dedupingInProgress = @"NO";      
            dispatch_async(dispatch_get_main_queue(), ^{           
                self.dedupingInProgress = @"NO";      
                [[NSNotificationCenter defaultCenter] postNotificationName:kFinishedDeduping object:nil];
            });
            
        } else {
            NSLog(@"Error saving unique results: %@", error);
            self.dedupingInProgress = @"NO";            
            dispatch_async(dispatch_get_main_queue(), ^{          
                self.dedupingInProgress = @"NO";    
                [[NSNotificationCenter defaultCenter] postNotificationName:kFinishedDeduping object:nil];
            });
        }
    }
    
}

#pragma mark -
#pragma mark Application Lifecycle - Seeding
- (void)addTheme:(CoreTheme *)theme toStore:(NSPersistentStore *)store withContext:(NSManagedObjectContext *)moc{
    
    
    CoreTheme *newTheme =  (CoreTheme *)[NSEntityDescription insertNewObjectForEntityForName:@"CoreTheme"
                                                                      inManagedObjectContext:moc];
    newTheme.themeDictData = theme.themeDictData;
    newTheme.saveDate = (theme.saveDate == nil) ? [NSDate date] : theme.saveDate;
    newTheme.themeName = (theme.themeName == nil) ? nil : theme.themeName;
    if(!newTheme.themeName && [theme.themeDictData objectForKey:@"themeName"]){
        newTheme.themeName = [theme.themeDictData objectForKey:@"themeName"];
    }
    //get permanent key
    NSError *errorObtaining;
    if(![moc obtainPermanentIDsForObjects:[NSArray arrayWithObject:theme] error:&errorObtaining]){
        if(errorObtaining){
            NSLog(@"error obtaining permanent ID: %@", errorObtaining);
        }
    }
    NSTimeInterval  today = [[NSDate date] timeIntervalSince1970];
    NSString *intervalString = [NSString stringWithFormat:@"%f", today];
    NSString *recordUUID = intervalString;
    newTheme.recordUUID = (theme.recordUUID == nil) ? recordUUID : theme.recordUUID;
    [moc assignObject:newTheme toPersistentStore:store];
}

- (BOOL)seedStore:(NSPersistentStore *)store withPersistentStoreAtURL:(NSURL *)seedStoreURL error:(NSError * __autoreleasing *)error {
    BOOL success = YES;
    
     NSError *localError = nil;
    NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:nil];
    NSPersistentStoreCoordinator *seedPSC = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    NSDictionary *seedStoreOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:NSReadOnlyPersistentStoreOption];// @{ NSReadOnlyPersistentStoreOption : [NSNumber numberWithBool:YES] };
    NSPersistentStore *seedStore = [seedPSC addPersistentStoreWithType:NSSQLiteStoreType
                                                         configuration:nil
                                                                   URL:seedStoreURL
                                                               options:seedStoreOptions
                                                                 error:&localError];
    if (seedStore) {
        NSManagedObjectContext *seedMOC = [[NSManagedObjectContext alloc] init];
        [seedMOC setPersistentStoreCoordinator:seedPSC];
        
        NSFetchRequest *fr = [NSFetchRequest fetchRequestWithEntityName:@"CoreTheme"];
        NSUInteger batchSize = 10;
        [fr setFetchBatchSize:batchSize];
        
        NSArray *themes = [seedMOC executeFetchRequest:fr error:&localError];
        NSLog(@"themes for seeding: %@",themes);
        NSManagedObjectContext *moc;
        if([CBThemeHelper isIOS5]){    
            moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        }
        else {
            moc = [[NSManagedObjectContext alloc] init];
        }
        [moc setPersistentStoreCoordinator:_psc];
        NSUInteger i = 10;
        for (CoreTheme *theme in themes) {
            [self addTheme:theme toStore:store withContext:moc];
            
            if (0 == (i % batchSize)) {
                success = [moc save:&localError];
                if (success) {
                    /*
                     Reset the managed object context to free the memory for the inserted objects
                     The faulting array used for the fetch request will automatically free objects
                     with each batch, but inserted objects remain in the managed object context for
                     the lifecycle of the context
                     */
                    [moc reset];
                } else {
                    NSLog(@"Error saving during seed: %@", localError);
                    break;
                }
            }
            
            i++;
        }
        
        //one last save
        if ([moc hasChanges]) {
            success = [moc save:&localError];
            [moc reset];
        }
    } else {
        success = NO;
        NSLog(@"Error adding seed store: %@", localError);
    }
    
    if (NO == success) {
        if (localError  && (error != NULL)) {
            *error = localError;
        }
    }

    return success;
}

#pragma mark -
#pragma mark Merging Changes
+ (void)mergeiCloudChangeNotification:(NSNotification *)note withManagedObjectContext:(NSManagedObjectContext *)moc {
    [moc performBlock:^{
        [moc mergeChangesFromContextDidSaveNotification:note];
    }];
}

#pragma mark -
#pragma mark Debugging Helpers
- (void)copyContainerToSandbox {
    @autoreleasepool {
        NSFileCoordinator *fc = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
        NSError *error = nil;
        NSFileManager *fm = [[NSFileManager alloc] init];
        NSString *path = [self.ubiquityURL path];
        NSString *sandboxPath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:[self.ubiquityURL lastPathComponent]];
        
        if ([fm createDirectoryAtPath:sandboxPath withIntermediateDirectories:YES attributes:nil error:&error]) {
            NSLog(@"Created container directory in sandbox: %@", sandboxPath);
        } else {
            if ([[error domain] isEqualToString:NSCocoaErrorDomain]) {
                if ([error code] == NSFileWriteFileExistsError) {
                    //delete the existing directory
                    error = nil;
                    if ([fm removeItemAtPath:sandboxPath error:&error]) {
                        NSLog(@"Removed old sandbox container copy");
                    } else {
                        NSLog(@"Error trying to remove old sandbox container copy: %@", error);
                    }
                }
            } else {
                NSLog(@"Error attempting to create sandbox container copy: %@", error);
                return;
            }
        }
        
        
        NSArray *subPaths = [fm subpathsAtPath:path];
        for (NSString *subPath in subPaths) {
            NSString *fullPath = [NSString stringWithFormat:@"%@/%@", path, subPath];
            NSString *fullSandboxPath = [NSString stringWithFormat:@"%@/%@", sandboxPath, subPath];
            BOOL isDirectory = NO;
            if ([fm fileExistsAtPath:fullPath isDirectory:&isDirectory]) {
                if (isDirectory) {
                    //create the directory
                    BOOL createSuccess = [fm createDirectoryAtPath:fullSandboxPath
                                       withIntermediateDirectories:YES
                                                        attributes:nil
                                                             error:&error];
                    if (createSuccess) {
                        //yay
                    } else {
                        NSLog(@"Error creating directory in sandbox: %@", error);
                    }
                } else {
                    //simply copy the file over
                    BOOL copySuccess = [fm copyItemAtPath:fullPath
                                                   toPath:fullSandboxPath
                                                    error:&error];
                    if (copySuccess) {
                        //yay
                    } else {
                        NSLog(@"Error copying item at path: %@\nTo path: %@\nError: %@", fullPath, fullSandboxPath, error);
                    }
                }
            } else {
                NSLog(@"Got subpath but there is no file at the full path: %@", fullPath);
            }
        }
        
        fc = nil;
    }
}

- (void)nukeAndPave {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [self asyncNukeAndPave];
    });
}

- (void)asyncNukeAndPave {
    //disconnect from the various stores
    [self dropStores];
    
    NSFileCoordinator *fc = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
    NSError *error = nil;
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *path = [self.ubiquityURL path];
    NSArray *subPaths = [fm subpathsAtPath:path];
    for (NSString *subPath in subPaths) {
        NSString *fullPath = [NSString stringWithFormat:@"%@/%@", path, subPath];
        [fc coordinateWritingItemAtURL:[NSURL fileURLWithPath:fullPath]
                               options:NSFileCoordinatorWritingForDeleting
                                 error:&error
                            byAccessor:^(NSURL *newURL) {
            NSError *blockError = nil;
            if ([fm removeItemAtURL:newURL error:&blockError]) {
                NSLog(@"Deleted file: %@", newURL);
            } else {
                NSLog(@"Error deleting file: %@\nError: %@", newURL, blockError);
            }

        }];
    }

    fc = nil;
}

#pragma mark -
#pragma mark Misc.

- (NSString *)folderForUbiquityToken:(id)token {
    NSURL *tokenURL = [[self applicationSandboxStoresDirectory] URLByAppendingPathComponent:@"TokenFoldersData"];
    NSData *tokenData = [NSData dataWithContentsOfURL:tokenURL];
    NSMutableDictionary *foldersByToken = nil;
    if (tokenData) {
        foldersByToken = [NSKeyedUnarchiver unarchiveObjectWithData:tokenData];
    } else {
        foldersByToken = [NSMutableDictionary dictionary];
    }
    NSString *storeDirectoryUUID = [foldersByToken objectForKey:token];
    if (storeDirectoryUUID == nil) {
        /*
        NSUUID *uuid = [[NSUUID alloc] init];
        storeDirectoryUUID = [uuid UUIDString];
         */
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *UUID = @"";
        
        if (![defaults valueForKey:@"UUID"])
        {
            CFUUIDRef UUIDRef = CFUUIDCreate(kCFAllocatorDefault);
            CFStringRef UUIDSRef = CFUUIDCreateString(kCFAllocatorDefault, UUIDRef);
            UUID = [NSString stringWithFormat:@"%@", UUIDSRef];
            storeDirectoryUUID = UUID;
            [defaults setObject:UUID forKey:@"UUID"];
        }
        else {
            UUID = [defaults valueForKey:@"UUID"];
            if(!storeDirectoryUUID)
                storeDirectoryUUID = UUID;
        }
        
        //[deviceInformation setObject:UUID forKey:@"UUID"];
        [foldersByToken setObject:storeDirectoryUUID forKey:token];
        tokenData = [NSKeyedArchiver archivedDataWithRootObject:foldersByToken];
        [tokenData writeToFile:[tokenURL path] atomically:YES];
    }
    return storeDirectoryUUID;
}

- (NSURL *)iCloudStoreURL {
    
    //return [self BuildiCloudStoreURL];
    
    NSURL *iCloudStoreURL = [self applicationSandboxStoresDirectory];
    
    //NSAssert1(self.currentUbiquityToken, @"No ubiquity token? Why you no use fallback store? %@", self);
    
    NSString *storeDirectoryUUID = [self folderForUbiquityToken:self.currentUbiquityToken];
    
    iCloudStoreURL = [iCloudStoreURL URLByAppendingPathComponent:storeDirectoryUUID];
    NSFileManager *fm = [[NSFileManager alloc] init];
    if (NO == [fm fileExistsAtPath:[iCloudStoreURL path]]) {
        NSError *error = nil;
        BOOL createSuccess = [fm createDirectoryAtURL:iCloudStoreURL withIntermediateDirectories:YES attributes:nil error:&error];
        if (NO == createSuccess) {
            NSLog(@"Unable to create iCloud store directory: %@", error);
        }
    }
    
    iCloudStoreURL = [iCloudStoreURL URLByAppendingPathComponent:kiCloudPersistentStoreFilename];
    return iCloudStoreURL;
}

- (NSURL *)seedStoreURL {
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSURL *bundleURL = [mainBundle URLForResource:@"seedStore" withExtension:@"sqlite"];
    return bundleURL;
}

- (NSURL *)fallbackStoreURL {
    NSURL *storeURL = [[self applicationSandboxStoresDirectory] URLByAppendingPathComponent:kFallbackPersistentStoreFilename];
    return storeURL;
}

- (NSURL *)applicationSandboxStoresDirectory {
    NSURL *storesDirectory = [NSURL fileURLWithPath:[self applicationDocumentsDirectory]];
    storesDirectory = [storesDirectory URLByAppendingPathComponent:@"SharedCoreDataStores"];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if (NO == [fm fileExistsAtPath:[storesDirectory path]]) {
        //create it
        NSError *error = nil;
        BOOL createSuccess = YES;
        if([CBThemeHelper isIOS5]){
            createSuccess = [fm createDirectoryAtURL:storesDirectory
                          withIntermediateDirectories:YES
                                           attributes:nil
                                                error:&error];
        }
        else {
            createSuccess = [fm createDirectoryAtPath:storesDirectory.path withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (createSuccess == NO) {
            NSLog(@"Unable to create application sandbox stores directory: %@\n\tError: %@", storesDirectory, error);
        }
    }
    return storesDirectory;
}

- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

#pragma mark -
#pragma mark NSFilePresenter

- (NSURL *)presentedItemURL {
    return _presentedItemURL;
}

- (NSOperationQueue *)presentedItemOperationQueue {
    return _presentedItemOperationQueue;
}

- (void)accommodatePresentedItemDeletionWithCompletionHandler:(void (^)(NSError *))completionHandler {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [self iCloudAccountChanged:nil];
    });
    completionHandler(NULL);
}

#pragma mark -

@end
