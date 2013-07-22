//
//  CoreThemeiPad.h
//  ClockBuilder
//
//  Created by Gustavo Tandeciarz on 8/2/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CoreThemeiPad : NSManagedObject

@property (nonatomic, retain) NSData * background;
@property (nonatomic, retain) NSData * backgroundThumb;
@property (nonatomic, retain) NSString * recordUUID;
@property (nonatomic, retain) NSDate * saveDate;
@property (nonatomic, retain) NSData * screenshot;
@property (nonatomic, retain) id themeDictData;
@property (nonatomic, retain) NSString * themeName;
@property (nonatomic, retain) NSString * ticdsSyncID;

@end
