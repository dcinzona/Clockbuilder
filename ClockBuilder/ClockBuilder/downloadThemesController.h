//
//  downloadThemesController.h
//  ClockBuilder
//
//  Created by Gustavo Tandeciarz on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ASINetworkQueue;


@interface downloadThemesController : NSObject {
    ASINetworkQueue *networkQueue;
    NSString *localPath;
}
- (void)downloadThemeFromCloud:(NSString *)themeName localPath:(NSString *)themePath;
@property (retain) ASINetworkQueue *networkQueue;

@end
