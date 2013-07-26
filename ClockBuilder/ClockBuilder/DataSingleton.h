//
//  DataSingleton.h
//  ClockBuilder
//
//  Created by Gustavo Tandeciarz on 7/25/13.
//
//

#import <Foundation/Foundation.h>

@interface DataSingleton : NSObject {
    
}

@property (nonatomic,strong) NSMutableDictionary *settings;

+(DataSingleton*)sharedInstance;
-(void) updateSettings:(NSMutableDictionary *)sets;
-(void) saveSettingsToDefaults;
-(NSMutableArray *)getWidgetsListFromSettings;
-(void)saveWidgetsListToSettings:(NSMutableArray *)list;
-(NSMutableDictionary *)getSettings;
//from widgetHelper
-(void)saveList:(NSMutableArray *)list;
-(void)setWidgetsListArray:(NSMutableArray *)List;
-(void)setWidgetData:(NSInteger)index withData:(NSMutableDictionary *)widgetData;
-(void)addWidgetToList:(NSMutableDictionary *)dict;
-(void)removeWidgetAtIndex:(NSInteger) index;
-(NSObject *)getWidgetDataFromIndex:(NSInteger)index FromKey:(NSString *)keyName;
-(NSMutableDictionary *)getWidgetDataFromIndex:(NSInteger)index;



@end
