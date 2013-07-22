//
//  xmlWeatherParser.m
//  ClockBuilder
//
//  Created by Gustavo Tandeciarz on 3/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "xmlWeatherParser.h"


@implementation xmlWeatherParser

@synthesize locationsString;
@synthesize locationsArray;
@synthesize unitString;
@synthesize validatedLocation;
@synthesize delegate;
@synthesize rssParser;

-(id )initWithLocation:(NSString *)locationStr
{
    self = [super init];
    if(self != nil)
    {     
    }
    return self;
}

- (void)parserDidStartDocument:(NSXMLParser *)parser{	
	
}

- (void)parseXMLFileAtURL:(NSString *)URL
{	
    zips = [NSMutableArray new];
    places = [NSMutableArray new];   
    _postalString = URL;
    
    NSString *urlStr = [NSString stringWithFormat:@"http://xoap.weather.com/search/search?where=%@",[URL stringByReplacingOccurrencesOfString:@" " withString:@"+"]];
    NSLog(@"Weather URL: %@", urlStr);
    //you must then convert the path to a proper NSURL or it won't work
    NSURL *xmlURL = [NSURL URLWithString:[urlStr stringByReplacingOccurrencesOfString:@" " withString:@"+"]];
    NSLog(@"XML URL: %@", xmlURL);
    // here, for some reason you have to use NSClassFromString when trying to alloc NSXMLParser, otherwise you will get an object not found error
    // this may be necessary only for the toolchain
    [[NSURLCache sharedURLCache] setMemoryCapacity:0];
    [[NSURLCache sharedURLCache] setDiskCapacity:0];
    NSURLRequest *request = [NSURLRequest requestWithURL:xmlURL];
    NSData *data = [ NSURLConnection sendSynchronousRequest:request returningResponse: nil error: nil ];
    
    if(self.rssParser){
        [self.rssParser abortParsing];
    }
        self.rssParser = [[NSXMLParser alloc] initWithData:data] ;
    
    //rssParser = [[NSXMLParser alloc] initWithContentsOfURL:xmlURL];
    // Set self as the delegate of the parser so that it will receive the parser delegate methods callbacks.
    [self.rssParser setDelegate:self];
	
    // Depending on the XML document you're parsing, you may want to enable these features of NSXMLParser.
    [self.rssParser setShouldProcessNamespaces:NO];
    [self.rssParser setShouldReportNamespacePrefixes:NO];
    [self.rssParser setShouldResolveExternalEntities:NO];
    @try {
        if(self.rssParser!=nil && self.rssParser){
            [self.rssParser parse];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"RSS Parser failed with exception: %@", exception);
    }
    @finally {
        
    }
	//[rssParser release];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	//NSString * errorString = [NSString stringWithFormat:@"Unable to locate the location entered. (Error code %i )", [parseError code]];
	
	CustomAlertView * errorAlert = [[CustomAlertView alloc] initWithTitle:@"Error Verifying Location" message:@"Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[errorAlert show];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{		
    
	currentElement = [elementName copy];
	if ([elementName isEqualToString:@"loc"]) {
        if(zips !=nil){
            NSLog(@"adding zip: %@",[attributeDict valueForKey:@"id"]);
            [zips addObject:[attributeDict valueForKey:@"id"]];
        }
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{   
    
	if ([elementName isEqualToString:@"loc"]) {
		// save values to an item, then store that item into the array...
	}
	
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
	// save the characters for the current item...
    
	if ([currentElement isEqualToString:@"loc"]) {
        NSString *filterString = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
        if([filterString length]>=1 && [filterString rangeOfString:@"\n"].location == NSNotFound)
        {
            if(places != nil){
                NSLog(@"adding place: %@",string);
                if([string length] > 3){
                    if([string rangeOfString:[NSString stringWithFormat:@"(%@)",_postalString]].location != NSNotFound){
                        string = [string stringByReplacingOccurrencesOfString:_postalString withString:@""];
                        string = [string stringByReplacingOccurrencesOfString:@"()" withString:@""];
                    }
                    [places addObject:string];
                }
                else {
                    @try {
                        [zips removeLastObject];
                    }
                    @catch (NSException *exception) {
                        NSLog(@"Exception removing last zip: %@", exception);
                    }
                    @finally {
                        
                    }
                }
            }
        }
    }
     
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
	//NSLog(@"Places: %@",zips);
    dispatch_async(dispatch_get_main_queue(), ^{
        if([self.delegate conformsToProtocol:@protocol(xmlWeatherParserDelegate)]) {
            if(places !=nil && zips != nil){                
                NSArray *placesArray = [NSArray arrayWithArray:places];
                NSArray *zipsArray = [NSArray arrayWithArray:zips];
                places = nil;
                zips = nil;
                [self.delegate getArrayOfPlaces:placesArray woeidArray:zipsArray];
            }
            else {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"cantGeoLocate" object:nil];
            }
        }
    });
}



-(void)dealloc
{
    NSLog(@"Parser dealloc");
}




@end
