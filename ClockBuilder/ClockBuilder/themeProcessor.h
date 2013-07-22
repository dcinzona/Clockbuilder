//
//  themeProcessor.h
//  ClockBuilder
//
//  Created by gtadmin on 7/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface themeProcessor : NSObject {

    NSURL *cbThemeURL;
    
}
- (void)processIncomingFileURL:(NSURL *)url;
@end
