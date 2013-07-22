//
//  deleteThemeOnline.h
//  ClockBuilder
//
//  Created by gtadmin on 4/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ASINetworkQueue;



@interface deleteThemeOnline : NSObject {
    NSString *localPath;
}

- (NSString *)deleteThemeFromCloud:(NSDictionary *)theme;
- (NSString *)deleteThemeAndBlock:(NSDictionary *)theme;


@end
