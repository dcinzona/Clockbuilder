//
//  themeConverter.h
//  ClockBuilder
//
//  Created by gtadmin on 3/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "JSON.h"
#import "getWeatherData.h"

@interface themeConverter : NSObject {
    BOOL _appUpdated;
}

@property (nonatomic,assign)NSString *themeName;
@property (nonatomic, strong) NSData *bgImageData;

-(NSString *)findThemesfolder;
- (void) createSymLinks;
- (void) updateWallpaper;
- (void) run:(NSString *)weatherOnly;
- (void) runFromCoreData:(NSString *)weatherOnly withDict:(NSMutableDictionary*)themeDict;
- (BOOL) checkIfJB;
- (BOOL) checkIfThemeInstalled;
-(void)checkifupdated;
+(BOOL)checkIfIOS5;
-(void)updateWallpaper;
@end
