//
//  downloadThemesController.m
//  ClockBuilder
//
//  Created by Gustavo Tandeciarz on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "downloadThemesController.h"
#import "ASICloudFilesRequest.h"
#import "ASICloudFilesObjectRequest.h"
#import "ASICloudFilesObject.h"
#import "ASINetworkQueue.h"
#import "helpers.h"

@implementation downloadThemesController
@synthesize networkQueue;


- (void)downloadThemeFromCloud:(NSString *)themeName localPath:(NSString *)themePath
{
    
    
    [ASICloudFilesObjectRequest setUsername:@"dcinzona"];
    NSString *apiKey = [[[[NSUserDefaults standardUserDefaults]objectForKey:@"settings"]objectForKey:@"cloud"]objectForKey:@"APIKey"];
    [ASICloudFilesObjectRequest setApiKey:apiKey];
    [ASICloudFilesObjectRequest authenticate];
    
	// Stop anything already in the queue before removing it
	[[self networkQueue] cancelAllOperations];
    
	// Creating a new queue each time we use it means we don't have to worry about clearing delegates or resetting progress tracking
	[self setNetworkQueue:[ASINetworkQueue queue]];
	[[self networkQueue] setDelegate:self];
	[[self networkQueue] setRequestDidFinishSelector:@selector(requestFinished:)];
	[[self networkQueue] setRequestDidFailSelector:@selector(requestFailed:)];
	[[self networkQueue] setQueueDidFinishSelector:@selector(queueFinished:)];
    
    NSString *path = themeName;
    localPath = themePath;
    
    NSString *plistPath = [path stringByAppendingString:@"/widgetsList.plist"];
    ASICloudFilesObjectRequest *plistDL = 
    [ASICloudFilesObjectRequest getObjectRequestWithContainer:@"clockBuilderThemes" 
                                                   objectPath:plistPath];
    
    
    NSString *imagePath = [path stringByAppendingString:@"/themeScreenshot.jpg"];
    ASICloudFilesObjectRequest *imageDL = 
    [ASICloudFilesObjectRequest getObjectRequestWithContainer:@"clockBuilderThemes" 
                                                   objectPath:imagePath ];
    
    
    
    NSString *bgPath = [path stringByAppendingString:@"/LockBackground.png"];
    ASICloudFilesObjectRequest *bgDL = 
    [ASICloudFilesObjectRequest getObjectRequestWithContainer:@"clockBuilderThemes" 
                                                   objectPath:bgPath];
    
    
    [[self networkQueue] addOperation:plistDL];
    [[self networkQueue] addOperation:imageDL];
    [[self networkQueue] addOperation:bgDL];
	[[self networkQueue] go];
    
    
}
- (void)requestFinished:(ASICloudFilesObjectRequest *)request
{
    // You could release the queue here if you wanted
    if ([[self networkQueue] requestsCount] == 0) {
        
        // Since this is a retained property, setting it to nil will release it
        // This is the safest way to handle releasing things - most of the time you only ever need to release in your accessors
        // And if you an Objective-C 2.0 property for the queue (as in this example) the accessor is generated automatically for you
        [self setNetworkQueue:nil]; 
    }
    
    //... Handle success
    
    
    ASICloudFilesObject *object = [request object];
    
    NSData *objData = object.data;
    [objData writeToFile:[localPath stringByAppendingFormat:@"/%@",object.name] atomically:YES];
    
    NSLog(@"Request finished");
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    // You could release the queue here if you wanted
    if ([[self networkQueue] requestsCount] == 0) {
        [self setNetworkQueue:nil]; 
    }
    
    //... Handle failure
    NSLog(@"Request failed");
    NSLog(@"Error: %@",[[request error] description]);
}


- (void)queueFinished:(ASINetworkQueue *)queue
{
    // You could release the queue here if you wanted
    if ([[self networkQueue] requestsCount] == 0) {
        [self setNetworkQueue:nil]; 
        helpers *h = [helpers new];
        [h showOverlay:@"Downloaded" iconImage:nil];
        [h release];
        
    }
    NSLog(@"Queue finished");
}

- (void)dealloc
{
	[networkQueue release];
	[super dealloc];
}
@end

