//
//  getWeatherData.m
//  ClockBuilder
//
//  Created by Gustavo Tandeciarz on 3/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "getWeatherData.h"
#import "JSON.h"
#import <AddressBook/AddressBook.h>

@implementation getWeatherData

@synthesize gr, placemark, delegate, timerInterval, parser;

- (id)init {
	self = [super init];
	
	if(self != nil) {
        NSString *ver = [[UIDevice currentDevice] systemVersion];
        float ver_float = [ver floatValue];
        if (ver_float < 5.0) {
            self.gr = [[getReverseGeoCode alloc] init];
        }
        else {
            self.gr = [[getReverseGeoCode5 alloc] init];
        }
        self.gr.delegate = self;
        parser = [[xmlWeatherParser alloc] init];
        [parser setDelegate:self];
        _valid = YES;
        
	}
	
	return self;
}

- (void)getReverseGeoCode
{
    if(placemark!=nil)
    {
        [self getLocationFromPlacemark];
    }
}


-(void) parseLocations: (NSString *)location
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    if(location!=nil && ![location isEqualToString:@""])
    {
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        dispatch_async(queue, ^{
            [parser performSelector:@selector(parseXMLFileAtURL:) withObject:location];
        });
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"cantGeoLocate" object:nil];
    }
}


-(void)getArrayOfPlaces:(NSArray*)array woeidArray:(NSArray *)woeids
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    @try {
        // Try something
        if(woeids != nil && [woeids count]>0)
        {
            //NSString *location = [woeids objectAtIndex:0];
            //NSDictionary *wdict = [self getWeatherForLocation:location];
            //if(wdict!=nil){
                //NSMutableDictionary *weatherData = [wdict mutableCopy];
                //[[NSUserDefaults standardUserDefaults] setObject:[woeids objectAtIndex:0] forKey:@"currentLocation"];
                //[[NSUserDefaults standardUserDefaults] synchronize];
                
                
                //NSString *name = [array objectAtIndex:0];            
               // [self setWeatherData:weatherData placeName:name];
                if([self.delegate respondsToSelector:@selector(getLocationsArray:woeidsArray:)]) {
                    [self.delegate getLocationsArray:array woeidsArray:woeids];
                }
            //}
        }
    }
    @catch (NSException * e) {
        NSLog(@"Weather Getter Exception - GetArrayOfPlaces: %@", e); 
    }
    @finally {
        // Added to show finally works as well
    }
}

-(NSArray *)getArrayFor:(NSString *)woeidOrplace fromArray:(NSMutableArray *)locationsArray{
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:locationsArray.count];
    
    for (NSDictionary *dict in locationsArray) {
        NSString *item = [dict objectForKey:woeidOrplace];
        if (item && ![item isEqualToString:@""]) {
            [tempArray addObject:item];
        }
    }
    return  [NSArray arrayWithArray:tempArray];
}

- (void) getLocationFromPlacemark
{    
    /*
     
     @property (nonatomic, readonly) NSString *thoroughfare; // street address, eg 1 Infinite Loop
     28	@property (nonatomic, readonly) NSString *subThoroughfare;
     29	@property (nonatomic, readonly) NSString *locality; // city, eg. Cupertino
     30	@property (nonatomic, readonly) NSString *subLocality; // neighborhood, landmark, common name, etc
     31	@property (nonatomic, readonly) NSString *administrativeArea; // state, eg. CA
     32	@property (nonatomic, readonly) NSString *subAdministrativeArea; // county, eg. Santa Clara
     33	@property (nonatomic, readonly) NSString *postalCode; // zip code, eg 95014
     34	@property (nonatomic, readonly) NSString *country; // eg. United States
     35	@property (nonatomic, readonly) NSString *countryCode; // eg. US
     
     */
     
     
     
     
    //NSLog(@"Placemark: %@, %@, %@, %@", placemark.locality, [placemark.addressDictionary objectForKey:@"State"], placemark.postalCode, placemark);
    //URL http://where.yahooapis.com/v1/places.q(Williamsburg+New+York)?format=json&appid=h_Y.CoXV34GC7oFXYSzYXjzKsMMjKOe6R.l41wcy2dU23iOB2wDBmddlNoq1aFI-
    //NSLog(@"placemark: %@",placemark.thoroughfare);
    //NSString *city = [placemark.addressDictionary objectForKey:(NSString*) kABPersonAddressCityKey];
    //NSLog(@"city: %@",city);
    if (placemark.postalCode!=nil && ![placemark.postalCode isEqualToString:@""]) {
        if ([CBThemeHelper isIOS5]) {
            weatherFinder *finder = [weatherFinder weatherFinderInitWithLocation:placemark.postalCode];
            NSMutableArray *placesAsArray = [finder getXMLLocationsArray];
            if (placesAsArray.count > 0) {
                
                NSArray *locationsArray = [self getArrayFor:@"locName" fromArray:placesAsArray];
                NSArray *woeids = [self getArrayFor:@"locID" fromArray:placesAsArray];
                
                if([self.delegate respondsToSelector:@selector(getLocationsArray:woeidsArray:)]) {
                    [self.delegate getLocationsArray:locationsArray woeidsArray:woeids];
                }
            }
            else {
                NSDictionary *addr = placemark.addressDictionary;
                //NSString *state = [placemark.addressDictionary objectForKey:@"State"];
                NSLog(@"address dict: %@", placemark.addressDictionary);
                
                
                NSString *locationString = [NSString stringWithFormat:@"%@ %@",[addr objectForKey:@"City"],[addr objectForKey:@"State"]];
                if(![[addr objectForKey:@"CountryCode"]isEqualToString:@"US"]){
                    //locationString = [locationString stringByAppendingFormat:@" %@",[addr objectForKey:@"CountryCode"]];
                    //lat/long?
                    locationString = [NSString stringWithFormat:@"%@ %@",[addr objectForKey:@"State"],[addr objectForKey:@"Country"]];
                }
                placesAsArray = [finder getXMLLocationsArrayWithLocation:locationString];
                if (placesAsArray.count > 0) {
                    
                    NSArray *locationsArray = [self getArrayFor:@"locName" fromArray:placesAsArray];
                    NSArray *woeids = [self getArrayFor:@"locID" fromArray:placesAsArray];
                    
                    if([self.delegate respondsToSelector:@selector(getLocationsArray:woeidsArray:)]) {
                        [self.delegate getLocationsArray:locationsArray woeidsArray:woeids];
                    }
                }
                else {
                    locationString = [NSString stringWithFormat:@"%@ %@",[addr objectForKey:@"City"],[addr objectForKey:@"State"]];
                    if(![[addr objectForKey:@"CountryCode"]isEqualToString:@"US"]){
                        //locationString = [locationString stringByAppendingFormat:@" %@",[addr objectForKey:@"CountryCode"]];
                        //lat/long?
                        locationString = [NSString stringWithFormat:@"%@ %@",[addr objectForKey:@"State"],[addr objectForKey:@"Country"]];
                    }
                    placesAsArray = [finder getXMLLocationsArrayWithLocation:locationString];
                    if (placesAsArray.count > 0) {
                        
                        NSArray *locationsArray = [self getArrayFor:@"locName" fromArray:placesAsArray];
                        NSArray *woeids = [self getArrayFor:@"locID" fromArray:placesAsArray];
                        
                        if([self.delegate respondsToSelector:@selector(getLocationsArray:woeidsArray:)]) {
                            [self.delegate getLocationsArray:locationsArray woeidsArray:woeids];
                        }
                    }
                    else {
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"cantGeoLocate" object:nil];
                    }
                }
            }
        }
        else {
            [self parseLocations:[NSString stringWithFormat:@"%@", placemark.postalCode]];
        }
    }
    else {
        if ([CBThemeHelper isIOS5]) {
            
            NSDictionary *addr = placemark.addressDictionary;
            //NSString *state = [placemark.addressDictionary objectForKey:@"State"];
            NSLog(@"address dict: %@", placemark.addressDictionary);
            
            
            NSString *locationString = [NSString stringWithFormat:@"%@ %@",[addr objectForKey:@"City"],[addr objectForKey:@"State"]];
            if(![[addr objectForKey:@"CountryCode"]isEqualToString:@"US"]){
                //locationString = [locationString stringByAppendingFormat:@" %@",[addr objectForKey:@"CountryCode"]];
                //lat/long?
                
            }
            
            weatherFinder *finder = [weatherFinder weatherFinderInitWithLocation:locationString];
            NSMutableArray *placesAsArray = [finder getXMLLocationsArray];
            NSLog(@"placesArray: %@",placesAsArray);
            if(placesAsArray.count>0){
                NSArray *locationsArray = [self getArrayFor:@"locName" fromArray:placesAsArray];
                NSArray *woeids = [self getArrayFor:@"locID" fromArray:placesAsArray];
                
                if([self.delegate respondsToSelector:@selector(getLocationsArray:woeidsArray:)]) {
                    [self.delegate getLocationsArray:locationsArray woeidsArray:woeids];
                }
            }
            else {
                //Cant get weather
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"cantGeoLocate" object:nil];
            }
        }
        else{
            NSDictionary *addr = placemark.addressDictionary;
            //NSString *state = [placemark.addressDictionary objectForKey:@"State"];
            NSLog(@"address dict: %@", placemark.addressDictionary);
            
            if([addr objectForKey:@"City"]!=nil && [addr objectForKey:@"State"]!=nil){
                NSString *locationString = [NSString stringWithFormat:@"%@ %@",[addr objectForKey:@"City"],[addr objectForKey:@"State"]];
                [self parseLocations:locationString];
            }
            else {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"cantGeoLocate" object:nil];
            }
        }
        
    }

}

#pragma mark Weather Getters

- (NSString *)stringWithUrl:(NSURL *)url
{
    
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
	return val;
}
- (id) objectWithUrl:(NSURL *)url
{
    SBJsonParser *jsonParser = [SBJsonParser new];
	NSString *jsonString = [self stringWithUrl:url];
    NSDictionary *json = (NSDictionary *)[jsonParser objectWithString:jsonString];
	return json;
}


-(NSDictionary*)getWeatherForLocation:(NSString*)WOEID{
    
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSString *temp = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"]objectForKey:@"weatherData"] objectForKey:@"units"];
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@%@%@",@"http://query.yahooapis.com/v1/public/yql?format=json&diagnostics=true&env=store://datatables.org/alltableswithkeys&q=select%20*%20from%20weather.forecast%20where%20location%20in%20%28%22",WOEID,@"%22%29%20and%20u=%22",temp,@"%22"];
    NSLog(@"urlsString: %@",urlString);
    NSDictionary *data = [self objectWithUrl:[NSURL URLWithString:urlString]];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if(data!=nil){
        NSLog(@"getWeatherForLocation: %@",WOEID);
        NSDictionary *query = [data objectForKey:@"query"];
        if(query){
            NSDictionary *results = [query objectForKey:@"results"];
            NSString *resultsToString = [NSString stringWithFormat:@"%@",results];
            if(![resultsToString isEqualToString:@"<null>"]){
                return [results objectForKey:@"channel"];
            }
        }
         
    }
    else {
        return nil;
    }
    return nil;
}

-(void)stop
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(start) object:nil];
}

-(void) start 
{
    dispatch_async(dispatch_queue_create("com.gmtaz.Clockbuilder.grStart", NULL), ^{
        BOOL connected = [[GMTHelper sharedInstance] deviceIsConnectedToInet];
        if(connected)
        {
            NSString *location = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"] objectForKey:@"weatherData"] objectForKey:@"location"];
            if(location != nil && [location isEqualToString:@"Current Location"])
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.gr start];                   
                    //[[NSNotificationCenter defaultCenter] postNotificationName:@"showWeatherFinder" object:nil];
                });
            }
            else
            {
                NSMutableDictionary *weatherData = [[self getWeatherForLocation:location] mutableCopy];  
                if(weatherData!=nil){
                    [self setWeatherData:weatherData];
                }
            }
            
            NSInteger interval = [[[[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"] objectForKey:@"weatherData"] objectForKey:@"interval"] integerValue];

            if(interval==0)
            {
                interval = 600;//default 10 minutes
            }
            
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(start) object:nil];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self performSelector:@selector(start) withObject:nil afterDelay:(interval)];
            });
        }
        else{
            dispatch_sync(dispatch_get_main_queue(), ^{
                if(_valid){
                    //[helper alertWithString:@"No internet connected detected.  Could not update weather data."];
                    NSLog(@"Fail silently (no inet couldn't update weather");
                }
            });

        }
    });
}

-(void) getCurrentLocationAndRefresh
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        [gr start];
        
    });
}
-(void) forceWeatherRefresh
{
    NSString *location = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"] objectForKey:@"weatherData"] objectForKey:@"location"];
    if(location != nil && [location isEqualToString:@"Current Location"])
    {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.gr start];      
            //[[NSNotificationCenter defaultCenter] postNotificationName:@"showWeatherFinder" object:nil];
        });
    }
    else
    {
        NSMutableDictionary *weatherData = [[self getWeatherForLocation:location] mutableCopy];  
        if(weatherData!=nil)
            [self setWeatherData:weatherData];
    }
}

- (void)updatePlaceMark:(MKPlacemark *)newPlacemark
{
    placemark = newPlacemark;
    //NSLog(@"location placemark: %@", placemark.location);
    [self getLocationFromPlacemark];
}

- (void) setWeatherData:(NSMutableDictionary *)weatherData
{
    if(weatherData!=nil){
        NSMutableDictionary *settings = [[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"] mutableCopy];
        NSMutableDictionary *data = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"] objectForKey:@"weatherData"] mutableCopy] ;
        if(data == nil)
            data = [NSMutableDictionary new];
        [data setObject:weatherData forKey:@"data"];
        [settings setObject:data forKey:@"weatherData"];
        [[NSUserDefaults standardUserDefaults] setObject:settings forKey:@"settings"];
        if([[NSUserDefaults standardUserDefaults] synchronize]){
            if([self.delegate respondsToSelector:@selector(refreshWithNewWeatherData)]) {
                [self.delegate refreshWithNewWeatherData];
            }
        }
    }
}
- (void) setWeatherData:(NSMutableDictionary *)weatherData placeName:(NSString *)name
{    
    NSMutableDictionary *settings = [[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"] mutableCopy];
    NSMutableDictionary *data = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"] objectForKey:@"weatherData"] mutableCopy] ;        
    if(data == nil)
        data = [NSMutableDictionary new];
    [data setObject:weatherData forKey:@"data"];
    [data setObject:name forKey:@"locationName"];
    [settings setObject:data forKey:@"weatherData"];
    [[NSUserDefaults standardUserDefaults] setObject:settings forKey:@"settings"];
    if([[NSUserDefaults standardUserDefaults] synchronize]){
        if([self.delegate respondsToSelector:@selector(refreshWithNewWeatherData)]) {
            [self.delegate refreshWithNewWeatherData];
        }
    }
}

- (void)dealloc {
    _valid = NO;
}


@end
