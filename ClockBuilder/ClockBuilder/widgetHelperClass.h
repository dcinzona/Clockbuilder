//
//  widgetHelper.h
//  ClockBuilder
//
//  Created by Gustavo Tandeciarz on 4/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface widgetHelperClass : NSObject {
    
}

-(void)setWidgetData:(NSInteger)index withData:(NSDictionary *)widgetData;
-(void)addWidgetToList:(NSDictionary *)dict;
-(void)removeWidgetAtIndex:(NSInteger) index;
-(void)setWidgetsListArray:(NSArray *)List;
-(NSArray *)getWidgetsList;
-(NSObject *)getWidgetDataFromIndex:(NSInteger)index FromKey:(NSString *)keyName;
-(NSDictionary *)getWidgetDataFromIndex:(NSInteger)index;



@end
