//
//  CoreDataController2.m
//  ClockBuilder
//
//  Created by Gustavo Tandeciarz on 7/24/12.
//  Copyright (c) 2012 GMTAZ.com. All rights reserved.
//

#import "CoreDataController2.h"

@implementation CoreDataController2


@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

/*
- (id)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:nil];
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    
    if([CBThemeHelper isIOS5]){    
        __managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    }
    else {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
    }
    [__managedObjectContext setPersistentStoreCoordinator:__persistentStoreCoordinator];
    
    
    return self;
}
*/

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
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
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
/*- (NSManagedObjectContext *)managedObjectContext
 {
 if (__managedObjectContext != nil)
 {
 return __managedObjectContext;
 }
 
 NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
 if (coordinator != nil)
 {
 __managedObjectContext = [[NSManagedObjectContext alloc] init];
 [__managedObjectContext setPersistentStoreCoordinator:coordinator];
 }
 return __managedObjectContext;
 }*/

- (NSManagedObjectContext *)managedObjectContext {
	
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    
    if (coordinator != nil) {
        NSManagedObjectContext* moc;
        if([CBThemeHelper isIOS5]){
            
            moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
            [moc performBlockAndWait:^{
                [moc setPersistentStoreCoordinator: coordinator];
                [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(mergeChangesFrom_iCloud:) name:NSPersistentStoreDidImportUbiquitousContentChangesNotification object:coordinator];
            }];
            
        }
        else {
            
            moc = [[NSManagedObjectContext alloc] init] ;
            [moc setPersistentStoreCoordinator:coordinator];
        }
        
        
        __managedObjectContext = moc;
    }
    
    return __managedObjectContext;
}

- (void)mergeChangesFrom_iCloud:(NSNotification *)notification {
    
	NSLog(@"Merging in changes from iCloud...");
    
    NSManagedObjectContext* moc = [self managedObjectContext];
    
    [moc performBlock:^{
        
        [moc mergeChangesFromContextDidSaveNotification:notification]; 
        
        NSNotification* refreshNotification = [NSNotification notificationWithName:@"SomethingChanged" 
                                                                            object:self 
                                                                          userInfo:[notification userInfo]];
        
        [[NSNotificationCenter defaultCenter] postNotification:refreshNotification];
    }];
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
    __managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];;
    return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if((__persistentStoreCoordinator != nil)) {
        return __persistentStoreCoordinator;
    }
    
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];    
    NSPersistentStoreCoordinator *psc = __persistentStoreCoordinator;
    
    // Set up iCloud in another thread:
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // ** Note: if you adapt this code for your own use, you MUST change this variable:
        NSString *iCloudEnabledAppID = @"8AMM5A65M4.com.gmtaz.ClockBuilder";
        
        // ** Note: if you adapt this code for your own use, you should change this variable:        
        NSString *dataFileName = @"ClockBuilder.sqlite";
        
        // ** Note: For basic usage you shouldn't need to change anything else
        
        NSString *iCloudDataDirectoryName = @"Data.nosync";
        NSString *iCloudLogsDirectoryName = @"Logs";
        NSFileManager *fileManager = [NSFileManager defaultManager];        
        NSURL *localStore = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:dataFileName];
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
            
            [psc lock];
            
            [psc addPersistentStoreWithType:NSSQLiteStoreType 
                              configuration:nil 
                                        URL:[NSURL fileURLWithPath:iCloudData] 
                                    options:options 
                                      error:nil];
            
            [psc unlock];
        }
        else {
            NSLog(@"iCloud is NOT working - using a local store");
            NSMutableDictionary *options = [NSMutableDictionary dictionary];
            [options setObject:[NSNumber numberWithBool:YES] forKey:NSMigratePersistentStoresAutomaticallyOption];
            [options setObject:[NSNumber numberWithBool:YES] forKey:NSInferMappingModelAutomaticallyOption];
            
            [psc lock];
            
            [psc addPersistentStoreWithType:NSSQLiteStoreType 
                              configuration:nil 
                                        URL:localStore 
                                    options:options 
                                      error:nil];
            [psc unlock];
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SomethingChanged" object:self userInfo:nil];
        });
    });
    
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



@end
