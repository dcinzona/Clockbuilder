//
//  DataSingleton.m
//  ClockBuilder
//
//  Created by Gustavo Tandeciarz on 7/25/13.
//
//

#import "DataSingleton.h"

@implementation DataSingleton

static DataSingleton *sharedInstance = nil;
static dispatch_queue_t serialQueue;

+ (id)allocWithZone:(NSZone *)zone {
    static dispatch_once_t onceQueue;
    
    dispatch_once(&onceQueue, ^{
        serialQueue = dispatch_queue_create(kSaveSettingsQueue, NULL);
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
        }
    });
    
    return sharedInstance;
}
+ (DataSingleton*)sharedInstance;
{
    static dispatch_once_t onceQueue;
    
    dispatch_once(&onceQueue, ^{
        sharedInstance = [[DataSingleton alloc] init];
    });
    
    return sharedInstance;
}
- (id)init {
    id __block obj;
    
    dispatch_sync(serialQueue, ^{
        obj = [super init];
        if (obj) {
            self.settings = [self getSettings];
        }
    });
    self = obj;
    return self;
}
-(void) saveSettingsToDefaults{
    dispatch_async(serialQueue, ^{
        @synchronized([DataSingleton sharedInstance]){
            [[NSUserDefaults standardUserDefaults] setObject:self.settings forKey:@"settings"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    });
}
-(void)saveWidgetsListToSettings:(NSMutableArray *)list{
    if(self && self.settings){
        [self.settings setObject:list forKey:@"widgetsList"];
    }
}
-(NSMutableArray *)getWidgetsListFromSettings{
    if([self.settings objectForKey:@"widgetsList"]){
        return [NSMutableArray arrayWithArray:[self.settings objectForKey:@"widgetsList"]];
    }
    else{
        NSMutableArray *newArray = [NSMutableArray new];
        [self.settings setObject:newArray forKey:@"widgetsList"];
        return newArray;
    }
}
-(NSMutableDictionary *)getSettings{
    if(self.settings)
        return self.settings;
    [self setSettingsFromDefaults];
    return self.settings;
}
-(void) setSettingsFromDefaults{
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"settings"]){
        self.settings = [[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"] mutableCopy];
    }
    else{
        NSString *settingsPath = [[NSBundle mainBundle] pathForResource:@"settings" ofType:@"plist"];
        self.settings = [NSMutableDictionary dictionaryWithContentsOfFile:settingsPath];
    }
}

//pulling from widgetHelper
-(void)saveList:(NSMutableArray *)list
{
    [self saveWidgetsListToSettings:list];
}
-(void)setWidgetsListArray:(NSMutableArray *)List
{
    [self saveList:[NSMutableArray arrayWithArray:List]];
}
-(void)setWidgetData:(NSInteger)index withData:(NSMutableDictionary *)widgetData
{
    NSMutableArray *widgetsArray = [self getWidgetsListFromSettings];
    if([widgetsArray count]>0){
        [widgetsArray replaceObjectAtIndex:index withObject:widgetData];
    }
    [self saveList:widgetsArray];
}
-(void)addWidgetToList:(NSMutableDictionary *)dict
{
    NSMutableArray *widgetsArray = [self getWidgetsListFromSettings];
    if(dict){
        [widgetsArray addObject:dict];
        [self saveList:widgetsArray];
    }
}
-(void)removeWidgetAtIndex:(NSInteger) index
{
    NSMutableArray *widgetsArray = [self getWidgetsListFromSettings];
    [widgetsArray removeObjectAtIndex:index];
    [self saveList:widgetsArray];
}
-(NSObject *)getWidgetDataFromIndex:(NSInteger)index FromKey:(NSString *)keyName
{
    return [[[self getWidgetsListFromSettings] objectAtIndex:index] objectForKey:keyName];
}
-(NSMutableDictionary *)getWidgetDataFromIndex:(NSInteger)index
{
    return [[[self getWidgetsListFromSettings] objectAtIndex:index] mutableCopy];
}




@end