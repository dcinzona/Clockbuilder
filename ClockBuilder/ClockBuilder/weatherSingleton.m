//
//  weatherSingleton.m
//  ClockBuilder
//
//  Created by Gustavo Tandeciarz on 4/29/12.
//  Copyright (c) 2012 GMTAZ.com. All rights reserved.
//

#import "weatherSingleton.h"
/*
#if TARGET_IPHONE_SIMULATOR 
@interface CLLocationManager (Simulator)
@end

@implementation CLLocationManager (Simulator)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
-(void)startUpdatingLocation {
    CLLocation *simLocation = [[CLLocation alloc] initWithLatitude:37.3317 longitude:-122.0307];
    [self.delegate locationManager:self
               didUpdateToLocation:simLocation
                      fromLocation:simLocation];
    
}

@end
#pragma clang diagnostic pop

#endif // TARGET_IPHONE_SIMULATOR
*/

@interface weatherSingleton ()
{
        
    NSDictionary *weatherDataDictionary;
    NSMutableDictionary *weatherData;
    NSString *tempLocation;
    NSString *locationString;
    NSString *currentLocationName;
	CLLocationManager* locationManager;
	CLLocation* location;
    CLPlacemark *placemark;
    
    //XMLPARSER
    NSXMLParser * rssParser;
    NSData *xmlData;
    NSString *postalString;//for cleaning location name
	NSString * currentElement;
    NSMutableArray *placeNames;
    NSMutableArray *placeWOEIDS;
    NSMutableArray *arrayOfPlacesAsDict;
    
    //UIActionsheetPicker
    BOOL _pickerVisible;
    UIActionSheet *pickerAS;
    UIView *viewForPicker;
    NSInteger selectedPickerRow;
    NSTimer *timoutTimer;
    BOOL isUpdatingFromLocation;
    SBJsonParser *jsonParser;
}

@property (nonatomic,strong)NSDictionary *weatherDataDictionary;
@property (nonatomic,strong)NSMutableDictionary *weatherData;
@property (nonatomic,strong)NSString *locationString;
@property (nonatomic,strong)NSString *currentLocationName;
@property (nonatomic,strong)CLLocationManager* locationManager;
@property (nonatomic,strong)CLLocation* cllocation;
//@property (nonatomic,strong)MKReverseGeocoder *reverseGeocoder;
@property (nonatomic,strong)NSTimer *timer;


-(void) getLocationFromPlacemark;
-(void) addToolbarToPicker:(NSString *)title;

@end

@implementation weatherSingleton

@synthesize timer,weatherDataDictionary, weatherData, locationString, currentLocationName, locationManager, cllocation;

static weatherSingleton *sharedInstance = nil;
static dispatch_queue_t serialQueue;

+ (id)allocWithZone:(NSZone *)zone {
    static dispatch_once_t onceQueue;    
    
    dispatch_once(&onceQueue, ^{
        serialQueue = dispatch_queue_create("com.gmtaz.Clockbuilder.weatherSingleton.SerialQueue", NULL);        
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
        }
    });
    
    return sharedInstance; 
}


+ (weatherSingleton*)sharedInstance;
{
    static dispatch_once_t onceQueue;    
    
    dispatch_once(&onceQueue, ^{
        sharedInstance = [[weatherSingleton alloc] init];
    });
    
    return sharedInstance;
}
- (id)init {
    id __block obj;
    
    dispatch_sync(serialQueue, ^{
        obj = [super init];
        if (obj) {
            //Set variables here
            weatherData = [NSMutableDictionary dictionaryWithDictionary:[[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"] objectForKey:@"weatherData"] ];
            locationString = [weatherData objectForKey:@"location"];
            currentLocationName = [weatherData objectForKey:@"locationName"];
            locationManager = [[CLLocationManager alloc] init];
            locationManager.delegate = self;
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
            placeNames = [[NSMutableArray alloc] init];
            placeWOEIDS = [[NSMutableArray alloc] init];
            arrayOfPlacesAsDict = [[NSMutableArray alloc] init];
            _pickerVisible = NO;
            selectedPickerRow = 0;
        }
    });
    
    self = obj;
    return self;
}
- (NSString *)currentLocation {
    NSString /*__block*/ *cs;
    
    //dispatch_sync(serialQueue, ^{
        cs = locationString;
    //});
    
    return cs;
}
- (NSString *)currentLocationName {
    NSString /*__block*/ *cs;
    
    //dispatch_sync(serialQueue, ^{
        cs = currentLocationName;
    //});
    
    return cs;
}


-(void)setLocation:(NSString *)loc{
    //dispatch_sync(serialQueue, ^{
    tempLocation = loc;
        if([loc isEqualToString:@"Current Location"]){
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *ver = [[UIDevice currentDevice] systemVersion];
                float ver_float = [ver floatValue];
                if (ver_float < 4.3) {
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"cantGeoLocate" object:nil];
                    
                }
                else {
                    [locationManager setDelegate:[weatherSingleton sharedInstance]];
                    [locationManager startUpdatingLocation];
                }
                
            });
        }
        else {
            if (postalString != loc) {
                postalString = loc;
                [self parseLocation:postalString];
            }
        }
    //});    
}

-(NSDictionary *)currentWeatherData{
    
    NSDictionary __block *cs;
    
    dispatch_sync(serialQueue, ^{
        cs = weatherDataDictionary;
    });
    
    return cs;
}
-(NSMutableDictionary *)getWeatherData{
    
    NSMutableDictionary __block *cs;
    
    dispatch_sync(serialQueue, ^{
        cs = weatherData;
    });
    
    return cs;
}
-(NSString *)getWeatherIconSet{
    return [weatherData objectForKey:@"weatherIconSet"];
}
-(BOOL)isClimacon{
    return [[[self getWeatherIconSet] lowercaseString] isEqualToString:@"climacons"];
}
-(void)saveWeatherData{
    
    [weatherData setObject:locationString forKey:@"location"];  
    [weatherData setObject:currentLocationName forKey:@"locationName"];  
    if(weatherDataDictionary)
        [weatherData setObject:weatherDataDictionary forKey:@"data"];  
    NSMutableDictionary *sets = [[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"] mutableCopy];
    [sets setObject:weatherData forKey:@"weatherData"];
    [[NSUserDefaults standardUserDefaults] setObject:sets forKey:@"settings"];    
    [[NSUserDefaults standardUserDefaults] synchronize];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"weatherConfigurationSaved" 
                                                            object:nil 
                                                          userInfo:[NSDictionary dictionaryWithObject:weatherData forKey:@"weatherData"]
         ];
    });
    
}
-(void)saveWeatherDataWithDictionary:(NSMutableDictionary*)data{
    
    weatherData = data;
    currentLocationName = [data objectForKey:@"locationName"];
    locationString = [data objectForKey:@"location"];
    [self saveWeatherData];
    
}

-(BOOL)isThereAWeatherWidget
{
    NSArray *widgetsList = [[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"] objectForKey:@"widgetsList"];
    for(NSDictionary* widget in widgetsList)
    {
        if([[widget objectForKey:@"subClass"]isEqualToString:@"weather"])
            return true;
    }
    return false;
}
-(void)updateWeatherData{
    if([self isThereAWeatherWidget]){
        if(locationString == nil || [locationString isEqualToString:@""] || [locationString isEqualToString:@"Current Location"]){
            
            isUpdatingFromLocation = NO;
            NSString *ver = [[UIDevice currentDevice] systemVersion];
            float ver_float = [ver floatValue];
            if (ver_float < 4.3) {
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"cantGeoLocate" object:nil];
                
            }
            else {
                [locationManager setDelegate:[weatherSingleton sharedInstance]];
                [locationManager startUpdatingLocation];
            }
        }
        else {
            NSDictionary *wd = [self getWeatherForLocation:locationString];       
            wd = nil;
        }
        
        if(timer){
            [timer invalidate];
        }
        NSDictionary *intDict = [NSDictionary dictionaryWithDictionary:[[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"] objectForKey:@"weatherData"] ];
        int interval = [[intDict objectForKey:@"interval"] intValue];
        if(interval >= 60){
            timer = [NSTimer scheduledTimerWithTimeInterval:interval target:[weatherSingleton sharedInstance] selector:@selector(updateWeatherData) userInfo:nil repeats:NO];
        }
    }
}

-(void)didUpdateWeatherData{
    
    //dispatch_sync(serialQueue, ^{
        [weatherData setObject:locationString forKey:@"location"];  
        [weatherData setObject:currentLocationName forKey:@"locationName"];  
        [weatherData setObject:weatherDataDictionary forKey:@"data"];  
        
        NSMutableDictionary *sets = [[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"] mutableCopy];
        [sets setObject:weatherData forKey:@"weatherData"];
        [[NSUserDefaults standardUserDefaults] setObject:sets forKey:@"settings"];    
        [[NSUserDefaults standardUserDefaults] synchronize];
        sets = nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"weatherDataChanged" 
                                                                object:nil 
                                                              userInfo:[NSDictionary 
                                                                        dictionaryWithObjects:[NSArray arrayWithObjects:@"location", @"weatherData", nil] 
                                                                        forKeys:[NSArray arrayWithObjects:[self currentLocation],[self currentWeatherData], nil]
                                                                        ]
             ];
        });
    //NSLog(@"weather data: %@", weatherData);
        //});
    //});
    
}


//////////////////////////////////////////////////////////////////////////////////////
#pragma mark CORE LOCATION methods
//////////////////////////////////////////////////////////////////////////////////////
- (void)locationManager:(CLLocationManager*)manager
	didUpdateToLocation:(CLLocation*)newLocation
		   fromLocation:(CLLocation*)oldLocation
{
    [locationManager stopUpdatingLocation];
    cllocation = newLocation;
    //reverseGeo location
    if(!isUpdatingFromLocation){
        [self getReverseGeoCode:newLocation];
        isUpdatingFromLocation = YES;
    };
    
}

- (void)locationManager:(CLLocationManager*)manager
	   didFailWithError:(NSError*)error
{
    [locationManager stopUpdatingLocation];    
    isUpdatingFromLocation = NO;
    //alert that location failed
}


//////////////////////////////////////////////////////////////////////////////////////
#pragma mark MK_REVERSE_GEOCODER methods
//////////////////////////////////////////////////////////////////////////////////////


    - (void) getReverseGeoCode:(CLLocation *)newLocation
    {
            
        NSString *fetchURL = [NSString stringWithFormat:@"http://maps.google.com/maps/geo?q=%@,%@&amp;output=json&amp;sensor=true", [NSString     stringWithFormat:@"%f",newLocation.coordinate.latitude], [NSString stringWithFormat:@"%f",newLocation.coordinate.longitude]];
        NSURL *url = [NSURL URLWithString:fetchURL];
        NSError *Err;
        NSString *htmlData = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&Err];
        
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSDictionary *json = [parser objectWithString:htmlData];
        NSArray *array = [json objectForKey:@"Placemark"];
        
        isUpdatingFromLocation = NO;
        if(array.count > 0){
            NSDictionary *addressDetails = [[array objectAtIndex:0] objectForKey:@"AddressDetails"];
            if(addressDetails == nil){
                [[NSNotificationCenter defaultCenter] postNotificationName:@"cantGeoLocate" object:nil];
                return;
            }
            NSDictionary *country = [addressDetails objectForKey:@"Country"];
            if (country == nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"cantGeoLocate" object:nil];
                });
                return;
            }
            NSDictionary *adminArea = [country objectForKey:@"AdministrativeArea"];
            if(adminArea ==nil){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"cantGeoLocate" object:nil];
                });
                return;
            }
            NSDictionary *locality = [adminArea objectForKey:@"Locality"];
            if(locality ==nil){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"cantGeoLocate" object:nil];
                });
                return;
            }
            NSDictionary *postal = [locality objectForKey:@"PostalCode"];
            if (postal !=nil) {
                postalString = [postal objectForKey:@"PostalCodeNumber"];
                [self parseLocation:postalString];
            }
            else {
                if([locality objectForKey:@"LocalityName"]!=nil && [adminArea objectForKey:@"AdministrativeAreaName"]!=nil){
                    NSString *ls = [NSString stringWithFormat:@"%@ %@",
                                    [locality objectForKey:@"LocalityName"],
                                    [adminArea objectForKey:@"AdministrativeAreaName"]];
                    [self parseLocation:ls];
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"cantGeoLocate" object:nil];
                    });
                }
            }         
        
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"cantGeoLocate" object:nil];
            });
        }
    }


//////////////////////////////////////////////////////////////////////////////////////
#pragma mark Placemark Locator methods
//////////////////////////////////////////////////////////////////////////////////////

-(void)parseLocation:(NSString *)str{
    
    //dispatch_sync(serialQueue, ^{
        NSString *urlStr = [NSString stringWithFormat:@"http://xoap.weather.com/search/search?where=%@",[str stringByReplacingOccurrencesOfString:@" " withString:@"+"]];
        NSURL *xmlURL = [NSURL URLWithString:[urlStr stringByReplacingOccurrencesOfString:@" " withString:@"+"]];
        [[NSURLCache sharedURLCache] setMemoryCapacity:0];
        [[NSURLCache sharedURLCache] setDiskCapacity:0];
        NSURLRequest *request = [NSURLRequest requestWithURL:xmlURL];
        xmlData = [ NSURLConnection sendSynchronousRequest:request returningResponse: nil error: nil ];
        NSXMLParser *parser = [[NSXMLParser alloc]initWithData:xmlData];
        [parser setDelegate:sharedInstance];
        [placeNames removeAllObjects];
        [placeWOEIDS removeAllObjects];
        [parser parse];
        
    //});
    
}

-(void)getLocationFromPlacemark{
    
    if (placemark.postalCode!=nil && ![placemark.postalCode isEqualToString:@""]) {
        postalString  = placemark.postalCode;
        [self parseLocation:placemark.postalCode];
    }
    else {
        
        NSDictionary *addr = placemark.addressDictionary;
        //NSString *state = [placemark.addressDictionary objectForKey:@"State"];
        
        if([addr objectForKey:@"City"]!=nil && [addr objectForKey:@"State"]!=nil){
            NSString *ls = [NSString stringWithFormat:@"%@ %@",[addr objectForKey:@"City"],[addr objectForKey:@"State"]];
            [self parseLocation:ls];
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"cantGeoLocate" object:nil];
            });
        }
    }
}

//////////////////////////////////////////////////////////////////////////////////////
#pragma mark NSXMLParser Delegate methods
//////////////////////////////////////////////////////////////////////////////////////

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	//NSString * errorString = [NSString stringWithFormat:@"Unable to locate the location entered. (Error code %i )", [parseError code]];
	
	CustomAlertView * errorAlert = [[CustomAlertView alloc] initWithTitle:@"Error Verifying Location" message:@"Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[errorAlert show];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{		
    
	currentElement = [elementName copy];
	if ([elementName isEqualToString:@"loc"]) {
        if(placeWOEIDS !=nil){
            [placeWOEIDS addObject:[attributeDict valueForKey:@"id"]];
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
            if(placeNames != nil){
                if([string length] > 3){
                    if([string rangeOfString:[NSString stringWithFormat:@"(%@)",postalString]].location != NSNotFound){
                        string = [string stringByReplacingOccurrencesOfString:postalString withString:@""];
                        string = [string stringByReplacingOccurrencesOfString:@"()" withString:@""];
                    }
                    [placeNames addObject:string];
                }
                else {
                    @try {
                        [placeWOEIDS removeLastObject];
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
    //dispatch_async(dispatch_get_main_queue(), ^{
    if(placeNames !=nil && placeWOEIDS != nil && placeNames.count >0 && placeNames.count == placeWOEIDS.count){

        if(placeWOEIDS.count >1){
            NSArray *singleArray = [NSArray arrayWithArray:0];
            singleArray = [self getSingleArrayOfPlaces];
            if(singleArray.count>1){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showLocationPicker:singleArray];
                });
            }
            else{
                if(arrayOfPlacesAsDict.count==0){
                    //places were returned but locations not contain weather data
                    
                    [[GMTHelper sharedInstance] alertWithString:@"Yahoo! does not currently have weather for the location entered. Please try a different location."];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"weatherDataChanged"
                                                                        object:nil
                                                                      userInfo:nil];
                    
                }
                if(arrayOfPlacesAsDict.count==1){
                    //pick that one place
                    [placeWOEIDS removeAllObjects];
                    [placeNames removeAllObjects];
                    NSDictionary *dict = [arrayOfPlacesAsDict objectAtIndex:0];
                    [placeNames addObject:[dict objectForKey:@"locationName"]];
                    [placeWOEIDS addObject:[dict objectForKey:@"location"]];
                    
                    if(![tempLocation isEqualToString:@"Current Location"])
                        locationString = [placeWOEIDS objectAtIndex:0];
                    else {
                        locationString = @"Current Location";
                    }
                    currentLocationName = [placeNames objectAtIndex:0];
                    [self getWeatherForLocation:[placeWOEIDS objectAtIndex:0]];
                    
                }
            
            }
        }
        else {
            //locationString = @"Current Location";
            if(![tempLocation isEqualToString:@"Current Location"])
                locationString = [placeWOEIDS objectAtIndex:0];
            else {
                locationString = @"Current Location";
            }
            currentLocationName = [placeNames objectAtIndex:0];
            [self getWeatherForLocation:[placeWOEIDS objectAtIndex:0]];
        }
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"cantGeoLocate" object:nil];
        });
    }
}
    //});
-(NSArray *)getSingleArrayOfPlaces{
    NSArray /*__block*/ *retArray;
    //dispatch_sync(serialQueue, ^{
        [arrayOfPlacesAsDict removeAllObjects];
        for(int x = 0; x<[placeWOEIDS count]; x++){
            if(x<placeNames.count && x<placeWOEIDS.count){
                if([self shouldListLocation:[placeWOEIDS objectAtIndex:x]]){
                    NSMutableDictionary *place = [[NSMutableDictionary alloc] init];
                    [place setObject:[placeNames objectAtIndex:x] forKey:@"locationName"];
                    [place setObject:[placeWOEIDS objectAtIndex:x] forKey:@"location"];
                    NSLog(@"place: %@", place);
                    [arrayOfPlacesAsDict addObject:place];
                }
            }
        }
        retArray = [NSArray arrayWithArray:arrayOfPlacesAsDict];        
    //});
    return retArray;
}


- (NSString *)stringWithUrl:(NSURL *)url
{
    NSString /*__block*/ *retString;
    //dispatch_sync(serialQueue, ^{
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url
                                                    cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                timeoutInterval:30];
        // Fetch the JSON response
        NSData *urlData;
        NSURLResponse *response;
        NSError *error;
        // Make synchronous request
        urlData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
        
        // Construct a String around the Data from the response
        NSString *ret = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
        NSString *val = [NSString stringWithString:ret];
        retString = val;
    //});
	return retString;
}
- (NSDictionary *) weatherDictDataWithUrl:(NSURL *)url
{
    NSDictionary /*__block*/ *retDict;
    //dispatch_sync(serialQueue, ^{
    if(!jsonParser){
        jsonParser = [SBJsonParser new];
    }
        NSString *jsonString = [self stringWithUrl:url];
        NSDictionary *json = (NSDictionary *)[jsonParser objectWithString:jsonString];
        retDict = json;
    //});
	return retDict;
}

-(BOOL)shouldListLocation:(NSString *)WOEID{
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@%@%@",@"http://query.yahooapis.com/v1/public/yql?format=json&diagnostics=true&env=store://datatables.org/alltableswithkeys&q=select%20*%20from%20weather.forecast%20where%20location%20in%20%28%22",WOEID,@"%22%29%20and%20u=%22",@"f",@"%22"];
    
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                cachePolicy:NSURLRequestReloadIgnoringCacheData
                                            timeoutInterval:5];
    // Fetch the JSON response
    NSData *urlData;
    NSURLResponse *response;
    NSError *error;
    // Make synchronous request
    urlData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
    
    // Construct a String around the Data from the response
    NSString *ret = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
    NSString *jsonString = [NSString stringWithString:ret];
    if(!jsonParser){
        jsonParser = [SBJsonParser new];
    }
    NSDictionary *json = (NSDictionary *)[jsonParser objectWithString:jsonString];
    NSDictionary *data = [NSDictionary dictionaryWithDictionary:json];
    if(data!=nil){
        NSDictionary *query = [data objectForKey:@"query"];
        if(query){
            NSDictionary *results = [query objectForKey:@"results"];
            NSString *resultsToString = [NSString stringWithFormat:@"%@",results];
            if(![resultsToString isEqualToString:@"<null>"]){
                weatherDataDictionary = [results objectForKey:@"channel"];
                NSString *desc = [weatherDataDictionary objectForKey:@"description"];
                NSRange range = [desc rangeOfString:@"Error"];
                if(!(range.length > 0)){
                    NSLog(@"should list WOEID: %@",WOEID);
                    return YES;
                }
                else
                {
                    NSLog(@"should NOT list: %@", WOEID);
                    return NO;
                    
                }
            }
        }
    }
    return NO;
    
}

-(NSDictionary*)getWeatherForLocation:(NSString*)WOEID{
    
    [[NSUserDefaults standardUserDefaults] setObject:WOEID forKey:@"currentLocation"];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSDictionary /*__block*/ *retDict;
    
    //dispatch_sync(serialQueue, ^{
        NSString *temp = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"]objectForKey:@"weatherData"] objectForKey:@"units"];
        NSString *urlString = [NSString stringWithFormat:@"%@%@%@%@%@",@"http://query.yahooapis.com/v1/public/yql?format=json&diagnostics=true&env=store://datatables.org/alltableswithkeys&q=select%20*%20from%20weather.forecast%20where%20location%20in%20%28%22",WOEID,@"%22%29%20and%20u=%22",temp,@"%22"];
        NSDictionary *data = [self weatherDictDataWithUrl:[NSURL URLWithString:urlString]];
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if(data!=nil){
            NSDictionary *query = [data objectForKey:@"query"];
            if(query){
                NSDictionary *results = [query objectForKey:@"results"];
                NSString *resultsToString = [NSString stringWithFormat:@"%@",results];
                if(![resultsToString isEqualToString:@"<null>"]){
                    weatherDataDictionary = [results objectForKey:@"channel"];
                                        
                    NSString *desc = [weatherDataDictionary objectForKey:@"description"];
                    NSRange range = [desc rangeOfString:@"Error"];
                    if(!(range.length > 0)){
                        tryLocationName=NO;
                        [weatherData setObject:weatherDataDictionary forKey:@"data"];
                        [self didUpdateWeatherData];
                        retDict = weatherDataDictionary;
                    }
                    else{
                        //alert error
                        //dispatch_async(dispatch_get_main_queue(), ^{
                        NSString *alertString = [NSString stringWithFormat:@"Could not find weather from Yahoo! for location: %@", [self currentLocationName]];
                        [[GMTHelper sharedInstance]alertWithString:alertString];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"weatherDataChanged"
                                                                            object:nil
                                                                          userInfo:nil];
                    }
                }
            }
            
        }
    //});
    
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    return retDict;
}


//////////////////////////////////////////////////////////////////////////////////////
#pragma mark PickerView methods
//////////////////////////////////////////////////////////////////////////////////////
-(void)setViewForPicker:(UIView *)theView{
    viewForPicker = theView;
}

- (void) showLocationPicker:(NSArray *)places
{
    if(!_pickerVisible){
        _pickerVisible = YES;
        if(places.count>0){
            [placeNames removeAllObjects];
            [placeWOEIDS removeAllObjects];
            for (NSDictionary *place in places) {
                [placeNames addObject:[place objectForKey:@"locationName"]];
                [placeWOEIDS addObject:[place objectForKey:@"location"]];
            }
        }
        
        NSString *title = @"Select Location";
        if(!pickerAS){
            if (kIsIpad) {
                
                pickerAS = [[UIActionSheet alloc] initWithTitle:@"\n\n\n\n\n\n\n\n\n" delegate:self cancelButtonTitle:@"cancel" destructiveButtonTitle:nil otherButtonTitles:nil];
            }
            else{
                
                pickerAS = [[UIActionSheet alloc] initWithTitle:@"\n\n\n\n\n\n\n\n\n" delegate:self cancelButtonTitle:@"cancel" destructiveButtonTitle:nil otherButtonTitles:nil];
                //pickerAS = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"cancel" destructiveButtonTitle:nil otherButtonTitles:nil];
            }
        }
        [self addToolbarToPicker:title];
    }
}

-(void) addToolbarToPicker:(NSString *)title
{
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    if(!kIsIpad)
        [toolbar sizeToFit];
    [CBThemeHelper setBackgroundImage:nil forToolbar:toolbar];
    NSMutableArray *barItems = [[NSMutableArray alloc] init];
    UIBarButtonItem *cancelBtn = [CBThemeHelper createDarkButtonItemWithTitle:@"Cancel" target:self action:@selector(dismissActionSheet)];
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];  
    UIBarButtonItem *doneBtn = [CBThemeHelper createBlueButtonItemWithTitle:@"Done" target:self action:@selector(saveActionSheet)];
    UILabel *titleLabel = [[UILabel alloc] init];
    [titleLabel setText:title];
    [titleLabel setShadowColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:.5]];
    [titleLabel setShadowOffset:CGSizeMake(0, -1.0)];
    [titleLabel setFrame:CGRectMake(0, 0, 150, 22)];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    UIBarButtonItem *titleItem = [[UIBarButtonItem alloc] initWithCustomView:titleLabel];
    [titleItem setStyle:UIBarButtonItemStylePlain];
    [barItems addObject:cancelBtn];
    [barItems addObject:flexSpace];  
    [barItems addObject:titleItem];
    [barItems addObject:flexSpace];
    [barItems addObject:doneBtn];
    [toolbar setItems:barItems animated:YES];
    //build picker
    UIPickerView *picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 44, 320, 400)];
    picker.delegate = self;
    picker.dataSource = self;
    picker.showsSelectionIndicator = YES;
    [pickerAS addSubview:picker];
    [pickerAS addSubview:toolbar];
    //[pickerAS setBounds:CGRectMake(0,0,320, 408)];
    
    if(kIsIpad){
        [pickerAS setBounds:CGRectMake(0,13,320, 408)];
        [pickerAS showInView:[AppDelegate.viewController.pop.contentViewController.view superview]];
    }
    else{
        [pickerAS setBounds:CGRectMake(0,6,320, 408)];
        [pickerAS showInView:AppDelegate.window];//[[[UIApplication sharedApplication] delegate] window]];
    }
    
}
-(void)actionSheetCancel:(UIActionSheet *)actionSheet{
    
    [pickerAS dismissWithClickedButtonIndex:0 animated:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"weatherDataChanged"
                                                        object:nil
                                                      userInfo:nil];
    _pickerVisible = NO;
    pickerAS = nil;
}
-(void)dismissActionSheet{
    [pickerAS dismissWithClickedButtonIndex:0 animated:YES];
    _pickerVisible = NO;
    pickerAS = nil;
}
-(void)saveActionSheet{
    [pickerAS dismissWithClickedButtonIndex:1 animated:YES];
    _pickerVisible = NO;
    
    if(selectedPickerRow<arrayOfPlacesAsDict.count){
        NSDictionary *dict = [arrayOfPlacesAsDict objectAtIndex:selectedPickerRow];    
        locationString = [NSString stringWithFormat:@"%@", [dict objectForKey:@"location"]];
        [weatherData setObject:locationString forKey:@"location"];
        currentLocationName = [NSString stringWithFormat:@"%@", [dict objectForKey:@"locationName"]];
        [weatherData setObject:currentLocationName forKey:@"locationName"];
        [self getWeatherForLocation:locationString];
        //[self saveWeatherData];
        //[self getWeatherForLocation:locationString];
    }
    else{
        NSLog(@"arrayofplaces count did not match picker list: %@", arrayOfPlacesAsDict);
        
    }
    
    selectedPickerRow = 0;
    pickerAS = nil;
}

- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    return [arrayOfPlacesAsDict count];
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    return [[[arrayOfPlacesAsDict objectAtIndex:row] objectForKey:@"locationName"] capitalizedString];
}

- (UIView *)pickerView:(UIPickerView *)pv viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label = (UILabel*) view;
    if (label == nil)
    {
        label = [[UILabel alloc] init];
    }
    [label setText:[[[arrayOfPlacesAsDict objectAtIndex:row] objectForKey:@"locationName"] capitalizedString]];
    [label setShadowColor:[UIColor whiteColor]];
    [label setShadowOffset:CGSizeMake(1, 1)];
    
    // This part just colorizes everything, since you asked about that.
    [label setTextColor:[UIColor blackColor]];
    
    //if([pickerType isEqualToString:@"locations"] && row == 0)
    //   [label setTextColor:[UIColor colorWithRed:.3 green:.3 blue:1.0 alpha:1.0]];
    
    [label setBackgroundColor:[UIColor clearColor]];
    CGSize rowSize = [pv rowSizeForComponent:component];
    CGRect labelRect = CGRectMake (10, 0, rowSize.width-20, rowSize.height);
    [label setFrame:labelRect];
    
    return label;
}
- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    selectedPickerRow = row;
    
}




@end
