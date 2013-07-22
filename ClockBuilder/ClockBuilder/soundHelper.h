//
//  soundHelper.h
//  ClockBuilder
//
//  Created by Gustavo Tandeciarz on 4/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface soundHelper : NSObject <AVAudioPlayerDelegate> {
    
}
-(void)playclick;
-(void)playclicksoft;

@end
