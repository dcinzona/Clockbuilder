//
//  CBTheme.m
//  ClockBuilder
//
//  Created by Gustavo Tandeciarz on 3/14/12.
//  Copyright (c) 2012 GMTAZ.com. All rights reserved.
//

#import "CBTheme.h"

@implementation CBTheme

@synthesize themeDictData;

-(id)contentsForType:(NSString *)typeName 
               error:(NSError *__autoreleasing *)outError
{
    //NSLog(@"contentsForType: %@",typeName);
    NSMutableData *data = [NSMutableData new];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:self.themeDictData  forKey:@"themeData"];
    [archiver finishEncoding];
    
    return data;
    
} 
-(BOOL) loadFromContents:(id)contents 
                  ofType:(NSString *)typeName 
                   error:(NSError *__autoreleasing *)outError
{
    if ( [contents length] > 0) {
        
        NSMutableData *data = [[NSMutableData alloc] initWithData:contents];
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        self.themeDictData = [unarchiver decodeObjectForKey:@"themeData"];
        [unarchiver finishDecoding];
        
    } else {
        self.themeDictData = [NSMutableDictionary new];
    }
    return YES;
} 

@end
