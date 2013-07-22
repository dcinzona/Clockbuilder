//
//  ThemeUploader.h
//  ClockBuilder
//
//  Created by Gustavo Tandeciarz on 4/22/12.
//  Copyright (c) 2012 GMTAZ.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ThemeUploader : MKNetworkEngine

-(MKNetworkOperation*)uploadThemeDict:(NSMutableDictionary *)themeDict forCategory:(NSString *)category onCompletionBlock:(CloseBlock)cb andOnError:(CloseBlock)errorBlock;

-(MKNetworkOperation*)uploadThemeNamed:(NSString *)themeName forCategory:(NSString *)category onCompletionBlock:(CloseBlock)cb andOnError:(CloseBlock)errorBlock;

@end
