//
//  textBasedWidget.m
//  ClockBuilder
//
//  Created by gtadmin on 3/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "textBasedWidget.h"
#import "widgetHelperClass.h"
#import "ClockBuilderAppDelegate.h"


@implementation textBasedWidget
@synthesize textLabel;
@synthesize widgetData;
@synthesize indexInList;
@synthesize weatherData;
@synthesize timer;

-(NSNumber *) getIndexInList
{
    return self.indexInList;
}

- (void) setFontSizeForPiece:(NSInteger)i fontSize:(NSInteger)fontSize{
    
    if(i<[[[[NSUserDefaults standardUserDefaults]objectForKey:@"settings"]objectForKey:@"widgetsList"]count]){
        //NSArray *list = [[[NSUserDefaults standardUserDefaults]objectForKey:@"settings"] objectForKey:@"widgetsList"] ;
        NSMutableDictionary *widget = self.widgetData;//[[list objectAtIndex:i] mutableCopy];
        
        NSInteger origFontSize = [[widget objectForKey:@"fontSize"] intValue];
        NSString *index = [NSString stringWithFormat:@"%i",i];
        [widget setObject:[NSString stringWithFormat:@"%i", fontSize] forKey:@"fontSize"];
        
        if(origFontSize != fontSize)
        {
            [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"forceRedraw"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
        }
        //NSLog(@"widget data being saved: %@",widget);
        [[[UIApplication sharedApplication] delegate] performSelector:@selector(saveWidgetSettings:widgetDataDictionary:) withObject:index withObject:widget];
    }
}

-(id) initWithFrame:(CGRect)frame widgetData:(NSDictionary *)widgetDataDict indexValue:(NSNumber*)index;{
	self = [super initWithFrame:frame];
	//self.dateFormatter = [[NSDateFormatter alloc] init];    
    self.weatherData = [[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"]objectForKey:@"weatherData"];
    self.indexInList = index;
    [self setClipsToBounds:NO];
    [self.layer setMasksToBounds:NO];

    
    self.widgetData = [NSMutableDictionary dictionaryWithDictionary:widgetDataDict];
	[self setBackgroundColor: [UIColor clearColor]];
    NSString *digitsFont = [self.widgetData objectForKey:@"fontFamily"];
    NSData *colorData = [self.widgetData objectForKey:@"fontColor"];
    UIColor *fontColor = (UIColor *)[NSKeyedUnarchiver unarchiveObjectWithData:colorData];
    NSInteger digitFont = self.frame.size.height*.8;//.33
    
    if(!fontColor){
        fontColor = [UIColor whiteColor];
        //[self.widgetData setObject:fontColor forKey:@"fontColor"];
    }
    if([[self.widgetData objectForKey:@"subClass"]isEqualToString:@"weather"]){
        
        isClimacon = ([[weatherSingleton sharedInstance] isClimacon] && [[self.widgetData objectForKey:@"className"] isEqualToString:@"Weather Icon"]);
        if(isClimacon){
            digitsFont = @"Climacons";
            digitFont = self.frame.size.height*.8;
            [self.widgetData setObject:digitsFont forKey:@"fontFamily"];
        }
        
    }
    
    //set these based on frame
    //NSLog(@"widget Frame: %@", NSStringFromCGRect(frame));
    
    [self.textLabel setMinimumScaleFactor:2.0];
    self.textLabel = [[RRSGlowLabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [self.textLabel setTextColor:fontColor];    
    [self.textLabel setFont:[UIFont fontWithName:digitsFont size:digitFont]];
    [self.textLabel setAdjustsFontSizeToFitWidth:YES];
    
    [self.textLabel setBackgroundColor:[UIColor clearColor]];
    [self.textLabel setGlowColor:[self getGlowColor]];
    [self.textLabel setGlowOffset:CGSizeMake(0, 0)];
    if([self.widgetData objectForKey:@"glowAmount"]==nil)
        [self.textLabel setGlowAmount:digitFont*.10];
    else
        [self.textLabel setGlowAmount:[[self.widgetData objectForKey:@"glowAmount"] floatValue]];
    [self.textLabel setTextAlignment:[self setTextAlignment]];
    [self.textLabel setClipsToBounds:NO];
        
    [self performSelector:@selector(setOpacity)];
    
    [self addSubview:self.textLabel];
    
    if([[self.widgetData objectForKey:@"subClass"]isEqualToString:@"datetime"])
    {
        //NSString *dateFormat = [self.widgetData objectForKey:@"dateFormatOverride"];
        //[self.dateFormatter setDateFormat:dateFormat];
        [self performSelector:@selector(setTimer)];
    }
    if([[self.widgetData objectForKey:@"subClass"]isEqualToString:@"text"])
    {
        [NSThread detachNewThreadSelector:@selector(setText:) toTarget:self.textLabel withObject:[self transformGivenText:[self.widgetData objectForKey:@"text"]]];
        //[self.textLabel setText:[self.widgetData objectForKey:@"text"]];
        [self setFontSizeForPiece:[self.indexInList integerValue] fontSize:self.textLabel.font.pointSize];
    }
    if([[self.widgetData objectForKey:@"subClass"]isEqualToString:@"weather"])
    {
        isWeather = YES;
        [self updateViewWeather];
    }
    
    //[self.textLabel release];
    if([[self.widgetData objectForKey:@"didRotate"]boolValue])
        [self performSelector:@selector(rotateInnerContent)];
    
    if(isClimacon){
        [[[UIApplication sharedApplication] delegate] performSelector:@selector(saveWidgetSettings:widgetDataDictionary:) withObject:index withObject:self.widgetData];
    }
    NSLog(@"index integervalue: %i", [index integerValue]);
    [self setFontSizeForPiece:[index integerValue] fontSize:self.textLabel.font.pointSize];
    
	return self;
}

-(NSMutableDictionary *)getWidgetData{
    return self.widgetData;
}


- (void)rotateInnerContent
{
    /*
    float rotation = [[self.widgetData objectForKey:@"rotateAmount"] floatValue];
    if (rotation !=0 ) {
        //rotate text label
        self.textLabel.transform = CGAffineTransformRotate([self.textLabel transform], rotation);
    }
     */
}

-(NSString*)getConditionsTextForCode:(int)code{
    
    /*
     
     Code	Description
     0	tornado
     1	tropical storm
     2	hurricane
     3	severe thunderstorms
     4	thunderstorms
     5	mixed rain and snow
     6	mixed rain and sleet
     7	mixed snow and sleet
     8	freezing drizzle
     9	drizzle
     10	freezing rain
     11	showers
     12	showers
     13	snow flurries
     14	light snow showers
     15	blowing snow
     16	snow
     17	hail
     18	sleet
     19	dust
     20	foggy
     21	haze
     22	smoky
     23	blustery
     24	windy
     25	cold
     26	cloudy
     27	mostly cloudy (night)
     28	mostly cloudy (day)
     29	partly cloudy (night)
     30	partly cloudy (day)
     31	clear (night)
     32	sunny
     33	fair (night)
     34	fair (day)
     35	mixed rain and hail
     36	hot
     37	isolated thunderstorms
     38	scattered thunderstorms
     39	scattered thunderstorms
     40	scattered showers
     41	heavy snow
     42	scattered snow showers
     43	heavy snow
     44	partly cloudy
     45	thundershowers
     46	snow showers
     47	isolated thundershowers
     3200	not available
     
     */
    
    NSArray *conditions = [NSArray arrayWithObjects:
                           @"tornado",
                           @"tropical storm",
                           @"hurricane",
                           @"severe thunderstorms",
                           @"thunderstorms",
                           @"mixed rain and snow",
                           @"mixed rain and sleet",
                           @"mixed snow and sleet",
                           @"freezing drizzle",
                           @"drizzle",
                           @"freezing rain",
                           @"showers",
                           @"showers",
                           @"snow flurries",
                           @"light snow showers",
                           @"blowing snow",
                           @"snow",
                           @"hail",
                           @"sleet",
                           @"dust",
                           @"foggy",
                           @"haze",
                           @"smoky",
                           @"blustery",
                           @"windy",
                           @"cold",
                           @"cloudy",
                           @"mostly cloudy",
                           @"mostly cloudy",
                           @"partly cloudy",
                           @"partly cloudy",
                           @"clear",
                           @"sunny",
                           @"fair",
                           @"fair",
                           @"mixed rain and hail",
                           @"hot",
                           @"isolated thunderstorms",
                           @"scattered thunderstorms",
                           @"scattered thunderstorms",
                           @"scattered showers",
                           @"heavy snow",
                           @"scattered snow showers",
                           @"heavy snow",
                           @"partly cloudy",
                           @"thundershowers",
                           @"snow showers",
                           @"isolated thundershowers",
                           @"not available",
                           nil];
    if(!(code < conditions.count))
        code = conditions.count - 1;
    
    NSString *condition = [conditions objectAtIndex:code];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dict = [defaults objectForKey:@"customConditions"];
    
    if(dict){
        NSLog(@"dict: %@", dict);
        NSString *customCondition = [dict objectForKey:[condition capitalizedString]];
        if(customCondition)
            condition = customCondition;
    }
    
    
    //convert to language
    NSLog(@"condition string: %@ for code %i",condition, code);
    
    return [condition capitalizedString];

}

-(NSString *)getClimaconString{
    
    NSDictionary *forecastData = [[self.weatherData objectForKey:@"data"] objectForKey:@"item"];
    NSDictionary *item = nil;
    NSString *forecast = [[self.widgetData objectForKey:@"forecast"] lowercaseString];
    //set forecastData based on forecast value
    NSString *dn = [self isDayOrNight];
    item = [forecastData objectForKey:@"condition"];
    NSString *code = [item objectForKey:@"code"];
    
    NSArray *dayArray = [NSArray arrayWithObjects:@"(",
                         @"z",
                         @"k",
                         @"z",
                         @"z",
                         @"r",
                         @"r",
                         @"r",
                         @"u",
                         @"7",
                         @"u",
                         @"9",
                         @"9",
                         @"p",
                         @"p",
                         @"\\",
                         @"\\",
                         @"y",
                         @"y",
                         @"d",
                         @"d",
                         @"d",
                         @"d",
                         @";",
                         @";",
                         @"-",
                         @"`",
                         @"1",
                         @"1",
                         @"1",
                         @"1",
                         @"v",
                         @"v",
                         @"v",
                         @"v",
                         @"u",
                         @"e",
                         @"x",
                         @"x",
                         @"x",
                         @"0",
                         @"]",
                         @"\\",
                         @"]",
                         @"1",
                         @"z",
                         @"r",
                         @"x",
                         @"|",
                         nil];
    NSArray *nightArray = [NSArray arrayWithObjects:@"(",
                           @"z",
                           @"k",
                           @"z",
                           @"z",
                           @"t",
                           @"t",
                           @"t",
                           @"i",
                           @"8",
                           @"i",
                           @"9",
                           @"9",
                           @"[",
                           @"[",
                           @"a",
                           @"a",
                           @"y",
                           @"y",
                           @"f",
                           @"f",
                           @"f",
                           @"f",
                           @"'",
                           @"'",
                           @"-",
                           @"`",
                           @"2",
                           @"2",
                           @"2",
                           @"2",
                           @"/",
                           @"v",
                           @"/",
                           @"/",
                           @"i",
                           @"e",
                           @"c",
                           @"c",
                           @"c",
                           @"-",
                           @"]",
                           @"a",
                           @"]",
                           @"2",
                           @"z",
                           @"t",
                           @"c",
                           @"|",
                           nil];
    
    if([forecast isEqualToString:@"current"])
    {
        item = [forecastData objectForKey:@"condition"];
        code = [item objectForKey:@"code"];
    }
    if([forecast isEqualToString:@"today"])
    {
        item = [[forecastData objectForKey:@"forecast"] objectAtIndex:0];
        code = [item objectForKey:@"code"];
        dn = @"d";
    }
    if([forecast isEqualToString:@"tomorrow"])
    {
        item = [[forecastData objectForKey:@"forecast"] objectAtIndex:1];
        code = [item objectForKey:@"code"];
        dn = @"d";
    }
    
    NSLog(@"code for %@:%@",forecast,code);
    
    int codeInt = [code intValue];
    
    if(codeInt<dayArray.count){
        if([dn isEqualToString:@"n"])
            return [nightArray objectAtIndex:codeInt];
        else
            return [dayArray objectAtIndex:codeInt];
            
    }
    else
        return @"|";
        //map here
    
    return @"v";
}

-(NSString *)isDayOrNight{
    NSString* ret = @"d";
    NSDictionary *astronomy = [[self.weatherData objectForKey:@"data"] objectForKey:@"astronomy"];
    
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"h:mm a"];
    NSString *sunriseString = [astronomy objectForKey:@"sunrise"];// uppercaseString];
    NSString *sunsetString = [astronomy objectForKey:@"sunset"];// uppercaseString];
    NSString *nowString = [dateFormat stringFromDate:[NSDate date]];
    NSDate *sunrise = [dateFormat dateFromString:sunriseString];
    NSDate *sunset = [dateFormat dateFromString:sunsetString];
    NSLog(@"sunrise: %@",sunrise);
    NSLog(@"sunset: %@",sunset);
    NSDate *now = [dateFormat dateFromString:nowString];
    switch ([now compare:sunrise]){
        case NSOrderedAscending:
            //before sunrise
            ret = @"n";
            break;
        case NSOrderedSame:
            ret = @"d";
            break;
        case NSOrderedDescending:
            //After sunrise
            if([now compare:sunset]==NSOrderedAscending)
            {
                ret = @"d";
            }
            else
            {
                ret = @"n";
            }
            break;
    }
    NSLog(@"ret: %@",ret);
    return ret;
}

- (void) updateViewWeather
{
    NSLog(@"update view weather: %@",[self.widgetData objectForKey:@"subClass"]);
    NSDictionary *data = [weatherData objectForKey:@"data"];
    
    NSDictionary *item = [data objectForKey:@"item"];
    NSString *textItemType = [self.widgetData objectForKey:@"textItemType"];
    NSString *degree = [weatherData objectForKey:@"degreeSymbol"];
    NSString *string = @"";
    if(isClimacon){
        
        string = [self getClimaconString];
    }
    
    if(![[weatherData objectForKey:@"showDegreeSymbol"] boolValue])
        degree = @"";
    if([textItemType isEqualToString:@"Location"])
    {
        if([[self.widgetData objectForKey:@"text"]isEqualToString:@""])
            //[self.textLabel setText:[weatherData objectForKey:@"locationName"]];
            string = [weatherData objectForKey:@"locationName"];
        else
            //[self.textLabel setText:[self.widgetData objectForKey:@"text"]];
            string  = [weatherData objectForKey:@"text"];
    }
    else
    {
        if([[self.widgetData objectForKey:@"forecast"]isEqualToString:@"current"])
        {
            
            NSDictionary *forecast = [item objectForKey:@"condition"];
            if([textItemType isEqualToString:@"Temperature"]){
                
                NSString *_text = [NSString stringWithFormat:@"%@%@",[forecast objectForKey:@"temp"],degree];
                //[self.textLabel setText:_text];
                if([[weatherData objectForKey:@"useWindChill"] boolValue])
                {
                    _text = [NSString stringWithFormat:@"%@%@",[[data objectForKey:@"wind"] objectForKey:@"chill"],degree];
                    //[self.textLabel setText:_text];
                }
                string = _text;
            }
            if([textItemType isEqualToString:@"Conditions"]){
                string = [self getConditionsTextForCode:[[forecast objectForKey:@"code"] integerValue]];//[forecast objectForKey:@"text"];
            }
            
        }
        if([[self.widgetData objectForKey:@"forecast"]isEqualToString:@"today"])
        {
            NSArray *forecastArray = [item objectForKey:@"forecast"];
            NSDictionary *forecast = [forecastArray objectAtIndex:0];
            if([textItemType isEqualToString:@"High"]){
                NSString *_text = [NSString stringWithFormat:@"%@%@",[forecast objectForKey:@"high"],degree];
                string = _text;
                //[self.textLabel setText:_text];
            }
            if([textItemType isEqualToString:@"Low"]){
                NSString *_text = [NSString stringWithFormat:@"%@%@",[forecast objectForKey:@"low"],degree];
                string = _text;
                //[self.textLabel setText:_text];
            }
            if([textItemType isEqualToString:@"Conditions"]){
                string = [self getConditionsTextForCode:[[forecast objectForKey:@"code"] integerValue]];//[forecast objectForKey:@"text"];
            }
            
            
        }
        if([[self.widgetData objectForKey:@"forecast"]isEqualToString:@"tomorrow"])
        {
            NSArray *forecastArray = [item objectForKey:@"forecast"];
            NSDictionary *forecast = [forecastArray objectAtIndex:1];
            if([textItemType isEqualToString:@"High"]){
                NSString *_text = [NSString stringWithFormat:@"%@%@",[forecast objectForKey:@"high"],degree];
                
                string = _text;
                //[self.textLabel setText:_text];
            }
            if([textItemType isEqualToString:@"Low"]){
                NSString *_text = [NSString stringWithFormat:@"%@%@",[forecast objectForKey:@"low"],degree];
                
                string = _text;
                //[self.textLabel setText:_text];
            }
            if([textItemType isEqualToString:@"Conditions"]){
                
                string = [self getConditionsTextForCode:[[forecast objectForKey:@"code"] integerValue]];//[forecast objectForKey:@"text"];
            }
        }
        
    }
    [NSThread detachNewThreadSelector:@selector(setText:) toTarget:self.textLabel withObject:[self transformGivenText:string]];
    if(self && self.textLabel && self.indexInList)
        [self setFontSizeForPiece:[self.indexInList integerValue] fontSize:self.textLabel.font.pointSize];
}

- (void) refreshWithNewWeatherData
{
    @autoreleasepool {
        self.weatherData = [[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"]objectForKey:@"weatherData"];    
    }
    NSLog(@"refresh with new weather data");
    [self updateViewWeather];
}

- (NSString *)transformGivenText:(NSString *)str
{
    if([[self.widgetData objectForKey:@"textTransform"]isEqualToString:@"uppercase"])
    {        
        return [str uppercaseString];
    }
    if([[self.widgetData objectForKey:@"textTransform"]isEqualToString:@"lowercase"])
    {
        return [str lowercaseString];
    }
    return str;
}

- (UIColor*) getGlowColor
{
 
    NSData *colorData =[self.widgetData objectForKey:@"glowColor"];
    if(colorData != nil)
    {
        return (UIColor *)[NSKeyedUnarchiver unarchiveObjectWithData:colorData];
    }
    
    return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
}

-(UITextAlignment)setTextAlignment
{
    if([self.widgetData objectForKey:@"textalignment"]!=nil)
    {
        NSString *align = [self.widgetData objectForKey:@"textalignment"];
        if ([align isEqualToString:@"left"]) {
            return NSTextAlignmentLeft;
        }
        if ([align isEqualToString:@"center"]) {
            return NSTextAlignmentCenter;
        }
        if ([align isEqualToString:@"right"]) {
            return NSTextAlignmentRight;
        }
    }
    else{
    }
    if (isClimacon) {
        return NSTextAlignmentCenter;
    }
    return NSTextAlignmentLeft;
}

-(void)updateAlpha:(NSString *)alphaVal
{
    [self setAlpha:[alphaVal floatValue]];
    [self setFontSizeForPiece:[self.indexInList integerValue] fontSize:self.textLabel.font.pointSize];
}
- (void)setOpacity
{
    CGFloat opacity= 1;
    NSString *alpha = [self.widgetData objectForKey:@"opacity"];
    if(alpha!=nil && [alpha floatValue]>0)
    {
        opacity = [alpha floatValue];
    }
    [self setAlpha:opacity];
}
- (void)updateView
{
    //dispatch_async(dispatch_get_main_queue(), ^{    
    
    //if(self.window.rootViewController.modalViewController == nil){
    
    
        if(isWeather)//[[self.widgetData objectForKey:@"subClass"]isEqualToString:@"weather"])
        {
            //[self performSelector:@selector(updateViewWeather)];
        }
        else{
            if([[self.widgetData objectForKey:@"subClass"]isEqualToString:@"datetime"])
            {
                //NSLog(@"1234567");
                NSDateFormatter *dateFormat = [NSDateFormatter new];
                [dateFormat setDateFormat:[self.widgetData objectForKey:@"dateFormatOverride"]];
                [NSThread detachNewThreadSelector:@selector(setText:) toTarget:self.textLabel withObject:[self transformGivenText:[dateFormat stringFromDate:[NSDate date]]]];
            }    
            if([[self.widgetData objectForKey:@"subClass"]isEqualToString:@"text"])
            {
                [NSThread detachNewThreadSelector:@selector(setText:) toTarget:self.textLabel withObject:[self transformGivenText:[self.widgetData objectForKey:@"text"]]];
            }
    
            //[self setFontSizeForPiece:[self.indexInList integerValue] fontSize:self.textLabel.font.pointSize];
        }
    //}
    //});
}
-(void) setTimer 
{
    [self updateView];
    //[[[UIApplication sharedApplication] delegate] performSelector:@selector(setScreenVisible:) withObject:@"YES"];
    //shouldUpdate = YES;
    
}

#pragma mark updaters

-(NSInteger)updateFontForText:(NSString *)fontFamily
{
    if(isClimacon){
        fontFamily = @"Climacons";
    }
    NSInteger digitFont = self.frame.size.height*.8;//.33
    [self.textLabel setFont:[UIFont fontWithName:fontFamily size:digitFont]];
    [self.textLabel setAdjustsFontSizeToFitWidth:YES];
    [self setFontSizeForPiece:[self.indexInList integerValue] fontSize:self.textLabel.font.pointSize];
    return self.textLabel.font.pointSize;
}

-(void)setTextAlignmentTo:(NSString *)align
{
    if ([align isEqualToString:@"left"]) {
        [self.textLabel setTextAlignment:NSTextAlignmentLeft];
    }
    if ([align isEqualToString:@"center"]) {
        [self.textLabel setTextAlignment: NSTextAlignmentCenter];
    }
    if ([align isEqualToString:@"right"]) {
        [self.textLabel setTextAlignment: NSTextAlignmentRight];
    }
}

-(void)setTextTransformTo:(NSString *)trans
{
    if ([trans isEqualToString:@"uppercase"]) {
        [self.textLabel setText:[self.textLabel.text uppercaseString]];
    }
    if ([trans isEqualToString:@"lowercase"]) {
        [self.textLabel setText:[self.textLabel.text lowercaseString]];
    }
    if ([trans isEqualToString:@""]) {
        //[self.textLabel setText:self.textLabel.text];
        if(isWeather)
            [self updateViewWeather];
        else
            [self updateView];
    }
    widgetHelperClass *wh = [widgetHelperClass new];
    self.widgetData = [NSMutableDictionary dictionaryWithDictionary:[[wh getWidgetsList] objectAtIndex:[self.indexInList intValue]]];
}

-(void)setNewTextColor:(UIColor *)newColor
{
    [self.textLabel setTextColor:newColor];
}
-(void)setNewGlowColor:(UIColor *)newColor intensity:(NSString *)intensity
{
    [self.textLabel setGlowColor:newColor];
    [self.textLabel setGlowAmount:[intensity floatValue]];
    [self.textLabel setNeedsDisplay];
}

-(void)setNewWidgetData:(NSDictionary *)wd
{
    self.widgetData = [NSMutableDictionary dictionaryWithDictionary:wd];
    if (isWeather) {
        [self updateViewWeather];
    }
    else
        [self updateView];
}

- (void)dealloc
{
    self.textLabel = nil;
    self.widgetData = nil;
    self.indexInList = nil;
    self.weatherData = nil;
    [self.timer invalidate];
    self.timer = nil;
}

@end
