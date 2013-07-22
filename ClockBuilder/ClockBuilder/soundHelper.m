//
//  soundHelper.m
//  ClockBuilder
//
//  Created by Gustavo Tandeciarz on 4/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "soundHelper.h"


@implementation soundHelper
AVAudioPlayer *playClick;
AVAudioPlayer *clickSoft;

-(id)init
{
    if((self = [super init]))
    {
        [self performSelector:@selector(initPlayClick)];
        [self performSelector:@selector(initClickSoft)];
    }
    return self;
}
-(void)initPlayClick
{
    playClick = [AVAudioPlayer alloc];
    NSString* resourcePath = [[NSBundle mainBundle] resourcePath];
    resourcePath = [resourcePath stringByAppendingString:[NSString stringWithFormat:@"/%@",@"click.wav"]];  
    //NSError* err;
    
    //Initialize our player pointing to the path to our resource
    
    //[playClick initWithContentsOfURL:[NSURL fileURLWithPath:resourcePath] error:&err];
    //[playClick prepareToPlay];
}
-(void)initClickSoft
{
    clickSoft = [AVAudioPlayer alloc];
    NSString* resourcePath = [[NSBundle mainBundle] resourcePath];
    resourcePath = [resourcePath stringByAppendingString:[NSString stringWithFormat:@"/%@",@"clickSoft.wav"]];  
    //NSError* err;
    
    //Initialize our player pointing to the path to our resource
    
    //[clickSoft initWithContentsOfURL:[NSURL fileURLWithPath:resourcePath] error:&err];
    //[clickSoft prepareToPlay];
}

-(void)playclicksoft
{
    if (clickSoft) 
        [clickSoft play];
}

-(void)playclick
{   
    if(playClick)
        [playClick play];
}

-(void)dealloc
{
    NSLog(@"deallocating sounds");
    /*
    [clickSoft release];
    [playClick release];
     */
}


@end
