//
//  CoreDataController2.h
//  ClockBuilder
//
//  Created by Gustavo Tandeciarz on 7/24/12.
//  Copyright (c) 2012 GMTAZ.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoreDataController2 : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
