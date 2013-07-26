//
//  widgetHelperClass.m
//  ClockBuilder
//
//  Created by Gustavo Tandeciarz on 4/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "widgetHelperClass.h"


@implementation widgetHelperClass

-(id)init
{
    if(self == [super init])
    {
    }    
    return self;
}

-(void)saveList:(NSMutableArray *)list
{
    [[DataSingleton sharedInstance] saveWidgetsListToSettings:list];
}
-(void)setWidgetsListArray:(NSArray *)List
{    
    [self saveList:[NSMutableArray arrayWithArray:List]];
}
-(void)setWidgetData:(NSInteger)index withData:(NSDictionary *)widgetData
{
    NSMutableArray *widgetsArray = [NSMutableArray arrayWithArray:[self getWidgetsList]];
    if([widgetsArray count]>0){
        [widgetsArray replaceObjectAtIndex:index withObject:widgetData];
    }
    [self saveList:widgetsArray];
}
-(void)addWidgetToList:(NSDictionary *)dict
{
    NSMutableArray *widgetsArray = [NSMutableArray arrayWithArray:[self getWidgetsList]];
    if(dict){
        [widgetsArray addObject:dict];
        [self saveList:widgetsArray];
    }
}
-(void)removeWidgetAtIndex:(NSInteger) index
{
    NSMutableArray *widgetsArray = [NSMutableArray arrayWithArray:[self getWidgetsList]];
    [widgetsArray removeObjectAtIndex:index];
    [self saveList:widgetsArray];
}
-(NSArray *)getWidgetsList
{
    return [kDataSingleton getWidgetsListFromSettings];//[NSArray arrayWithArray:widgetsList];
}
-(NSObject *)getWidgetDataFromIndex:(NSInteger)index FromKey:(NSString *)keyName
{
    return [[[self getWidgetsList] objectAtIndex:index] objectForKey:keyName];
}
-(NSDictionary *)getWidgetDataFromIndex:(NSInteger)index
{
    return [[self getWidgetsList] objectAtIndex:index];
}



@end
