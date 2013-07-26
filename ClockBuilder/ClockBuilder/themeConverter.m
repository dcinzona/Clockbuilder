//
//  themeConverter.m
//  ClockBuilder
//
//  Created by gtadmin on 3/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "themeConverter.h"
#import "RegexKitLite.h"

#import <dlfcn.h>
#import <mach-o/dyld.h>
#import <TargetConditionals.h>

#import "CBThemeHelper.h"


@implementation themeConverter

@synthesize themeName;
@synthesize bgImageData;

-(BOOL)isRunningInSimulator{
    
#if TARGET_IPHONE_SIMULATOR
    //return YES;
#endif
    
#ifdef DEBUG
    return YES;
#endif
    return NO;
}

-(BOOL)checkIfJB
{
    if([self isRunningInSimulator])
        return [self isRunningInSimulator];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *cydiaDirPath = @"/Applications/Cydia.app";
    BOOL exists = [fm fileExistsAtPath:cydiaDirPath];    
    if(exists)
    {
        //[TestFlight passCheckpoint:@"Checkpoint 1: fileexistsatpath"];
    }
    else {
        NSError *err;
        NSArray *contents = [fm contentsOfDirectoryAtPath:@"/Applications" error:&err];
        if(contents){
            //TFLog(@"Applications: %@",contents);
            for (NSString *fileName in contents) {
                if([fileName isEqualToString:@"Cydia.app"]){
                    exists = YES;
                    //[TestFlight passCheckpoint:@"Checkpoint 2: /Applications/[Contents]"];
                    break;
                }
            }
        }
        else {
            //TFLog(@"Error checking Checkpoint1/2: %@", err);
        }
    }
    return exists;
}
-(BOOL)checkIfThemeInstalled
{
    if([self isRunningInSimulator])
        return [self isRunningInSimulator];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *themeDirPath = @"/Library/Themes/TypoClockBuilder.theme";
    BOOL exists = [fm fileExistsAtPath:themeDirPath];
    return exists;
}


-(void)checkifupdated
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        if([[GMTHelper sharedInstance] deviceIsConnectedToInet]){
            _appUpdated = [[GMTHelper sharedInstance] checkAppVersionNoAlert];
            if(_appUpdated == YES || _appUpdated == NO)
            [[NSUserDefaults standardUserDefaults] setBool:_appUpdated forKey:@"appUpdated"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        //NSLog(@"app updated: %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"appUpdated"]);
    });
}


-(NSString *) getColorAsString:(UIColor*)color
{
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    if(color == nil){
        float white[4] = {1.0, 1.0, 1.0, 1.0};
        components = white;
    }
    if(color == [UIColor whiteColor])
    {
        float white[4] = {1.0, 1.0, 1.0, 1.0};
        components = white;
    }
    if(color == [UIColor blackColor])
    {
        float white[4] = {0.0, 0.0, 0.0, 1.0};
        components = white;
    }
    NSString *colorAsString = [NSString stringWithFormat:@"%f,%f,%f,%f", components[0], components[1], components[2], components[3]];
    
    return colorAsString;
}

-(NSMutableArray *)processWidgetsList:(NSMutableArray *)widgetsList{
    NSMutableArray *array = [NSMutableArray arrayWithArray:0];
    for(NSMutableDictionary* widget in widgetsList)
    {
        NSMutableDictionary *data = [widget mutableCopy];
        if(![[widget objectForKey:@"type"]isEqualToString:@"imageWidget"]||[[weatherSingleton sharedInstance] isClimacon]){
            UIColor *fontColor;
            if([data objectForKey:@"fontColor"]){
             fontColor = [NSKeyedUnarchiver unarchiveObjectWithData:[data objectForKey:@"fontColor"]];
            }
            if(!fontColor)
                fontColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
            NSString *colorAsString = [self getColorAsString:fontColor];
            [data setObject:colorAsString forKey:@"fontColor"];
            if([[widget objectForKey:@"type"]isEqualToString:@"imageWidget"]){
                [data setObject:@"Climacons" forKey:@"fontFamily"];
                [data setObject:@"Climacons" forKey:@"iconSet"];
                [data setObject:@"center" forKey:@"textalignment"];
            }
        }
        else{
            if([[widget objectForKey:@"type"]isEqualToString:@"imageWidget"]){
                UIColor *fontColor;
                if([data objectForKey:@"fontColor"]){
                    fontColor = [NSKeyedUnarchiver unarchiveObjectWithData:[data objectForKey:@"fontColor"]];
                }
                if(!fontColor)
                    fontColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
                NSString *colorAsString = [self getColorAsString:fontColor];
                [data setObject:colorAsString forKey:@"fontColor"];
            }
        }
        UIColor *glowColor = (UIColor *)[NSKeyedUnarchiver unarchiveObjectWithData:[data objectForKey:@"glowColor"]];
        if(!glowColor){
            glowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
        }
        
        NSString *glowAsString = [self getColorAsString:glowColor];
        [data setObject:glowAsString forKey:@"glowColor"];
        [array addObject:data];
    }
    //NSLog(@"loaded array: %@", widgetsList);
    //NSLog(@"lockscreen data array: %@", array);
    NSArray *returnedArray = [NSArray arrayWithArray:array];
    return [returnedArray mutableCopy];
}

- (NSArray *)getWidgetList
{
    NSMutableArray *widgetsList = [kDataSingleton getWidgetsListFromSettings];

    if(themeName!=nil && ![themeName isEqualToString:@""])
    {
        widgetsList = [CBThemeHelper getWidgetsListFromFile:themeName];
    }
    return [self processWidgetsList:widgetsList];
}

-(NSString *)updateLanguages:(NSString *)buildJS{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *weatherJS = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"weather" ofType:@"js"] encoding:NSUTF8StringEncoding error:nil] ;
    NSString *weatherJSTarget = [documentsDirectory stringByAppendingPathComponent:@"/tethered/weather.js"];
    NSString *buildJSTarget = [documentsDirectory stringByAppendingPathComponent:@"/tethered/build.js"];
    
    NSString *languageItemsPath = [[NSBundle mainBundle] pathForResource:@"languageItems" ofType:@"plist"];
    NSMutableDictionary *languageItemsDict = [NSMutableDictionary dictionaryWithContentsOfFile:languageItemsPath];
    if (languageItemsDict) {
        //NSLog(@"%@",languageItemsDict);
        NSArray *weekdayKeys = [languageItemsDict objectForKey:@"days"];
        NSArray *monthKeys = [languageItemsDict objectForKey:@"months"];
        NSArray *conditionsKeys = [languageItemsDict objectForKey:@"conditions"];
        
        //Arrays of Dicts [ "Monday" : "Lunes" ]
        NSDictionary *customWeekdays = [NSDictionary dictionaryWithDictionary:[defaults objectForKey:@"customDays"]];
        NSDictionary *customMonths = [NSDictionary dictionaryWithDictionary:[defaults objectForKey:@"customMonths"]];
        NSDictionary *customConditions = [NSDictionary dictionaryWithDictionary:[defaults objectForKey:@"customConditions"]];
        
        //days
        if(customWeekdays.count > 0){
            for (int x=0; x < customWeekdays.count; x++) {
                //look through keys to get values
                for(NSString *str in weekdayKeys){
                    NSString *rep = [customWeekdays objectForKey:str];
                    if(rep){
                        NSString *orig = [NSString stringWithFormat:@"\"%@\"", [str capitalizedString]];
                        NSString *orig3 = [NSString stringWithFormat:@"\"%@\"",[[str substringToIndex:3] capitalizedString]];
                        //do replace
                        NSString *repWithQuotes = [NSString stringWithFormat:@"\"%@\"", rep];
                        NSString *repWithQuotes3 = repWithQuotes;
                        if (rep.length > 3) {
                            [NSString stringWithFormat:@"\"%@\"", [rep substringToIndex:3]];
                        }
                        //Replace in build
                        buildJS = [buildJS stringByReplacingOccurrencesOfString:orig withString:repWithQuotes];
                        buildJS = [buildJS stringByReplacingOccurrencesOfString:orig3 withString:repWithQuotes3];
                        
                    }
                }
            }
        }
        //months
        if(customMonths.count > 0){
            for (int x=0; x < customMonths.count; x++) {
                //look through keys to get values
                for(NSString *str in monthKeys){
                    NSString *rep = [customMonths objectForKey:str];
                    if(rep){
                        NSString *orig = [NSString stringWithFormat:@"\"%@\"", [str capitalizedString]];
                        NSString *orig3 = [NSString stringWithFormat:@"\"%@\"",[[str substringToIndex:3] capitalizedString]];
                        //do replace
                        NSString *repWithQuotes = [NSString stringWithFormat:@"\"%@\"",rep];
                        NSString *repWithQuotes3 = repWithQuotes;
                        if (rep.length > 3) {
                            [NSString stringWithFormat:@"\"%@\"", [rep substringToIndex:3]];
                        }
                        //Replace in build
                        buildJS = [buildJS stringByReplacingOccurrencesOfString:orig withString:repWithQuotes];
                        buildJS = [buildJS stringByReplacingOccurrencesOfString:orig3 withString:repWithQuotes3];
                        
                    }
                }
            }
        }
        //conditions
        if(customConditions.count > 0){
            for (int x=0; x < customConditions.count; x++) {
                //look through keys to get values
                for(NSString *str in conditionsKeys){
                    NSString *rep = [customConditions objectForKey:[str capitalizedString]];
                    NSLog(@"str:%@",str);
                    if(rep){
                        NSString *orig = [NSString stringWithFormat:@"\"%@\"", [str lowercaseString]];
                        //do replace
                        NSString *repWithQuotes = [NSString stringWithFormat:@"\"%@\"", rep];
                        //Replace in build
                        buildJS = [buildJS stringByReplacingOccurrencesOfString:orig withString:repWithQuotes];
                        
                    }
                }
            }
        }
    }
    
    NSError *blderr;
    if(![buildJS writeToFile:buildJSTarget atomically:NO encoding:NSUTF8StringEncoding error:&blderr])
    {
        NSLog(@"did not save build.js: %@", [blderr localizedDescription]);
    }
    
    NSDictionary *weatherData = [NSDictionary dictionaryWithDictionary:[[weatherSingleton sharedInstance] getWeatherData]];
    if(weatherData.count>0 && [weatherData objectForKey:@"interval"]){
        int timeout = [[weatherData objectForKey:@"interval"] intValue]; //60 seconds = 1 minute > get from settings
        //change timeout for weather to match app
        NSString *getWeatherTimeout = [NSString stringWithFormat:@"('getWeather()', %i)",timeout*1000];
        NSLog(@"getWeatheTimeout: %@", getWeatherTimeout);
        weatherJS = [weatherJS stringByReplacingOccurrencesOfString:@"('getWeather()', 600000)" withString:getWeatherTimeout];
    }
    [weatherJS writeToFile:weatherJSTarget atomically:NO encoding:NSUTF8StringEncoding error:nil];
    
    return buildJS;
}

-(void)writeToLocalWithStyle:(NSString*)style andHTML:(NSString*)html andbuildJS:(NSString*)buildJS {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    
    NSString *styleTarget = [documentsDirectory stringByAppendingPathComponent:@"/tethered/style.css"];
    NSString *htmlTarget = [documentsDirectory stringByAppendingPathComponent:@"/tethered/LockBackground.html"];
    NSString *backgroundTarget = [documentsDirectory stringByAppendingPathComponent:@"/tethered/LockBackground.png"];
    
    NSData *bgImage;
    if(self.bgImageData){
        bgImage = [NSData dataWithData:self.bgImageData];
    }
    else{
        bgImage = [NSData dataWithContentsOfFile:[documentsDirectory stringByAppendingPathComponent:@"/LockBackground.png"]];
    }
    if(bgImage!=nil){
        NSError *bgerr;
        if(![bgImage writeToFile:backgroundTarget options:NSDataWritingFileProtectionNone error:&bgerr])
        {
            NSLog(@"did not save image: %@", [bgerr localizedDescription]);
        }
    }
    NSError *csserr;
    if(![style writeToFile:styleTarget atomically:NO encoding:NSUTF8StringEncoding error:&csserr])
    {
        NSLog(@"did not save style.css: %@", [csserr localizedDescription]);
    }
    NSError *htmlerr;
    buildJS = [self updateLanguages:buildJS];
    
    NSString *replacementBuildString = [NSString stringWithFormat:@"<script type=\"text/javascript\">%@</script>",buildJS];
    
    //NSLog(@"replacementBuildString: %@",replacementBuildString);
    
    html = [html stringByReplacingOccurrencesOfString:@"<script></script>" withString:replacementBuildString];
    
    if(![html writeToFile:htmlTarget atomically:YES encoding:NSUTF8StringEncoding error:&htmlerr])
    {
        NSLog(@"did not save LockBackground.html: %@", htmlerr);
    }
    //NSLog(@"HTML: %@", html);
    
    [self updateWallpaper];
    
    GMTThemeSync *gmt = [GMTThemeSync new];
    if([gmt syncFilesFromPath:[documentsDirectory stringByAppendingPathComponent:@"/tethered/"] toPath:[self findThemesfolder]]){
        NSLog(@"files synced using hook");
    }
    else {
        NSLog(@"hook didn't run");
    }
    if(![[[NSUserDefaults standardUserDefaults] objectForKey:@"useSlideshow"] boolValue]){
        
    }
}
-(NSString *)widthForCSSWithPX{
    
    int width = [UIScreen mainScreen].bounds.size.width;
    if(kIsIpad){
        width = [UIScreen mainScreen].bounds.size.height;
    }
    NSLog(@"device width: %i", width);
    return [NSString stringWithFormat:@"%ipx",width];
    
}
-(NSString *)heightForCSSWithPX{
    
    int height = [UIScreen mainScreen].bounds.size.height;
    NSLog(@"device height: %i", height);
    
    return [NSString stringWithFormat:@"%ipx",height];
    
}
-(NSString *)heightForCSSWithPXMinusStatusBar{
    
    int height = [UIScreen mainScreen].bounds.size.height - 20;
    
    return [NSString stringWithFormat:@"%ipx",height];
    
}
- (void) updateHTMLandCSS:(NSString *)data weatherData:(NSString *)weatherData weatherOnly:(NSString *)weatherOnly
{
    [self createSymLinks];
    
    NSInteger i = [[NSDate date] timeIntervalSince1970];
    NSString *nowTimestamp = [NSString stringWithFormat:@"%i", i ]; 
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *styleCSSTarget = [documentsDirectory stringByAppendingPathComponent:@"/lockscreen/style.css"];
    NSString *styleCSSTargetTethered = [documentsDirectory stringByAppendingPathComponent:@"/tethered/style.css"];
    NSString *html = [documentsDirectory stringByAppendingPathComponent:@"/lockscreen/LockBackground.html"];
    
    html = [[NSBundle mainBundle] pathForResource:@"LockBackground" ofType:@"html"];
    
    NSString *cssStringOrig = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"style" ofType:@"css"] encoding:NSUTF8StringEncoding error:nil] ;
    
    NSString *htmlStringOrig = [NSString stringWithContentsOfFile:html encoding:NSUTF8StringEncoding error:nil];
        
    NSString *htmlToWrite = [(NSString *)htmlStringOrig stringByReplacingOccurrencesOfString:@"style.css\"" withString:[NSString stringWithFormat:@"style.css?%@\"",nowTimestamp]];
    htmlToWrite = [htmlToWrite stringByReplacingOccurrencesOfRegex:@"style.css\\?[0-9]+\"" withString:[NSString stringWithFormat:@"style.css?%@\"",nowTimestamp]];
    htmlToWrite = [htmlToWrite stringByReplacingOccurrencesOfRegex:@"build.js\\?[0-9]+\"" withString:[NSString stringWithFormat:@"build.js?%@\"",nowTimestamp]];
        
    //weather data
    htmlToWrite = [htmlToWrite stringByReplacingOccurrencesOfRegex:@"<script class=\"weatherDataScript\" type=\"text/javascript\">.+</script>" withString:[NSString stringWithFormat:@"<script class=\"weatherDataScript\" type=\"text/javascript\">%@</script>", weatherData]];
    
    //widget data
    htmlToWrite = [htmlToWrite stringByReplacingOccurrencesOfRegex:@"<script class=\"dataScript\" type=\"text/javascript\">.+</script>" withString:[NSString stringWithFormat:@"<script class=\"dataScript\" type=\"text/javascript\">%@</script>", data]];
    
    
    //css
    NSString *cssToWrite = cssStringOrig;
    
    cssToWrite = [cssToWrite stringByReplacingOccurrencesOfString:@"LockBackground.png?1306767707" withString:[NSString stringWithFormat:@"LockBackground.png?%@",nowTimestamp]];
    
    cssToWrite = [cssToWrite stringByReplacingOccurrencesOfString:@"WallpaperBG.png?1372730710" withString:[NSString stringWithFormat:@"WallpaperBG.png?%@",nowTimestamp]];
    
    cssToWrite = [cssToWrite stringByReplacingOccurrencesOfString:@"320px" withString:[self widthForCSSWithPX]];
    cssToWrite = [cssToWrite stringByReplacingOccurrencesOfString:@"480px" withString:[self heightForCSSWithPX]];
    
    
    //build.js
    NSString *buildJS = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"build" ofType:@"js"] encoding:NSUTF8StringEncoding error:nil] ;
    //if(![[[NSUserDefaults standardUserDefaults] objectForKey:@"useSlideshow"] boolValue])
    buildJS = [buildJS stringByReplacingOccurrencesOfString:@"var shouldShowSlideShow = true;" withString:@"var shouldShowSlideShow = false;"];
    if([[GMTHelper sharedInstance] prefers24Hour])
        buildJS = [buildJS stringByReplacingOccurrencesOfString:@"var militaryTime = false;" withString:@"var militaryTime = true;"];
    if([[GMTHelper sharedInstance] parallaxEnabled]){
        buildJS = [buildJS stringByReplacingOccurrencesOfString:@"var parallaxEnabled = false;" withString:@"var parallaxEnabled = true;"];
        
        if(kIsIpad){
            cssToWrite = [cssToWrite stringByReplacingOccurrencesOfString:@"translateZ(5px)" withString:@"translateZ(2px)"];
        }
        else{
            cssToWrite = [cssToWrite stringByReplacingOccurrencesOfString:@"translateZ(5px)" withString:@"translateZ(3px)"];
        }
        
    }
    else{
        //hide shadow
        cssToWrite = [cssToWrite stringByReplacingOccurrencesOfString:@"#boxShadow{//" withString:@"#boxShadow{display:none!important; "];
        cssToWrite = [cssToWrite stringByReplacingOccurrencesOfString:@"-10px);" withString:@"0px);"];
        cssToWrite = [cssToWrite stringByReplacingOccurrencesOfString:@"translateZ(3px)" withString:@"translateZ(0px)"];
        
    }
    if(![[GMTHelper sharedInstance] rotateWallpaper])
        buildJS = [buildJS stringByReplacingOccurrencesOfString:@"var allowWallpaperRotation = true;" withString:@"var allowWallpaperRotation = false;"];
    
    //BG Image
    NSData *bgImage;
    if(self.bgImageData){
        //resize for i5?
        UIImage *image = [UIImage imageWithData:self.bgImageData];
        NSLog(@"bgImageData dimensions: %f x %f",image.size.width, image
              .size.height);
        
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        if(!kIsIpad){
            if (screenSize.height > 480 && (image.size.height==480 || image.size.height==960)) {
                //resize image for BG
                UIImage *newImage = [[GMTHelper sharedInstance]resizeImageForSync:image];
                NSData *newImageData;
                newImageData = UIImagePNGRepresentation(newImage);
                self.bgImageData = newImageData;
            }
        }
        
        bgImage = self.bgImageData;//[NSData dataWithData:self.bgImageData];
    }
    else{
        bgImage = [NSData dataWithContentsOfFile:[documentsDirectory stringByAppendingPathComponent:@"/LockBackground.png"]];
    }
    if(bgImage!=nil){
        NSError *bgerr;
        if(![bgImage writeToFile:[documentsDirectory stringByAppendingPathComponent:@"/lockscreen/LockBackground.png"] options:NSDataWritingFileProtectionNone error:&bgerr])
        {
            NSLog(@"did not save image to lockscreen folder: %@", [bgerr localizedDescription]);
            //[TestFlight passCheckpoint:[NSString stringWithFormat:@"Failed to save image to lockscreen folder:  %@", [bgerr localizedDescription]]];
        }
    }
    
    [cssToWrite writeToFile:styleCSSTarget atomically:NO encoding:NSUTF8StringEncoding error:nil];
    [cssToWrite writeToFile:styleCSSTargetTethered atomically:NO encoding:NSUTF8StringEncoding error:nil];
    [self writeToLocalWithStyle:cssToWrite andHTML:htmlToWrite andbuildJS:buildJS];
    
}
-(void)updateWallpaper{
    NSLog(@"updateWallpaper");
    if([[GMTHelper sharedInstance] setWallpaper]){
        NSInteger i = [[NSDate date] timeIntervalSince1970];
        NSString *nowTimestamp = [NSString stringWithFormat:@"%i", i ];
        
        NSString *wallpaperHtml = [[NSBundle mainBundle] pathForResource:@"Wallpaper" ofType:@"html"];
        
        NSString *wphtmlStringOrig = [NSString stringWithContentsOfFile:wallpaperHtml encoding:NSUTF8StringEncoding error:nil];
        
        NSString *wphtmlToWrite = [(NSString *)wphtmlStringOrig stringByReplacingOccurrencesOfString:@"style.css\"" withString:[NSString stringWithFormat:@"style.css?%@\"",nowTimestamp]];
        wphtmlToWrite = [wphtmlToWrite stringByReplacingOccurrencesOfRegex:@"style.css\\?[0-9]+\"" withString:[NSString stringWithFormat:@"style.css?%@\"",nowTimestamp]];
        wphtmlToWrite = [wphtmlToWrite stringByReplacingOccurrencesOfRegex:@"build.js\\?[0-9]+\"" withString:[NSString stringWithFormat:@"build.js?%@\"",nowTimestamp]];
        [self writeWallpaperHtmlAndBG:wphtmlToWrite];
    }
    else{
        [self writeWallpaperHtmlAndBG:@""];
    }
}

-(void) writeWallpaperHtmlAndBG: (NSString *)wpHtml
{
    NSLog(@"writeWallpaperHtmlAndBG");
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *wpBGSource = [documentsDirectory stringByAppendingPathComponent:@"Wallpaper.png"];    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        if ((NSInteger)[[UIScreen mainScreen] scale] == 2) {
            wpBGSource = [documentsDirectory stringByAppendingPathComponent:@"Wallpaper@2x.png"];
        }
    }
    
    NSString *wpBGTarget = [documentsDirectory stringByAppendingPathComponent:@"/tethered/WallpaperBG.png"];
    NSString *wphtmlTarget = [documentsDirectory stringByAppendingPathComponent:@"/tethered/Wallpaper.html"];
    
    NSError *htmlerr;
    GMTThemeSync *gmt = [GMTThemeSync new];
    if([wpHtml length] > 100){
        //Grab wallpaper.png and copy to tethered
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:wpBGSource];
        if(fileExists){            
            NSData *wpData = [NSData dataWithContentsOfFile:wpBGSource];
            if(wpData){
                if(![wpData writeToFile:wpBGTarget atomically:YES]){
                    NSLog(@"did not save wallpaper.png");
                }
                else{
                    NSLog(@"wallpaper saved: %@", wpBGTarget);
                }
            }            
            if(![wpHtml writeToFile:wphtmlTarget atomically:NO encoding:NSUTF8StringEncoding error:&htmlerr])
            {
                NSLog(@"did not save Wallpaper.html: %@", htmlerr);
            }
        }
    }
    else{
        NSString *targetPath = [[self findThemesfolder] stringByAppendingString:@"/Wallpaper.html"];
        NSString *targetImagePath = [[self findThemesfolder] stringByAppendingString:@"/WallpaperBG.png"];
        NSString *targetImagePathOld = [[self findThemesfolder] stringByAppendingString:@"/Wallpaper.png"];
        [gmt deleteFileAtPath:targetPath];
        [gmt deleteFileAtPath:targetImagePath];
        [gmt deleteFileAtPath:targetImagePathOld];
    }
}

- (void) saveData:(NSString *)data weatherDataJS:(NSString *)weatherDataJS weatherOnly:(NSString *)weatherOnly
{    
    [self updateHTMLandCSS:data weatherData:weatherDataJS weatherOnly:weatherOnly];
    if(![weatherOnly boolValue])
    {
        [[GMTHelper sharedInstance] showOverlay:@"Theme Files Set" iconImage:nil];
        if([themeConverter checkIfIOS5]){
        }
        
    }
}


-(NSString *)findThemesfolder
{
    NSString *ret = @"/Library/Themes/TypoClockBuilder.theme";
    return ret;
}
-(NSString *)createDestination:(NSString *)filename{
    NSString *themePath = [self findThemesfolder];
    NSString *destination = [themePath stringByAppendingPathComponent:filename];
    //NSLog(@"destination: %@",destination);
    return destination;
}
+(BOOL)checkIfIOS5{
    
    
    BOOL isIOS5 = [[[UIDevice currentDevice] systemVersion] floatValue] >= 5;
    return isIOS5;
    
}
- (void)createSymLinks
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *lockscreenFolder = [documentsDirectory stringByAppendingPathComponent:@"lockscreen"];
    //NSString *themeFolder = [documentsDirectory stringByAppendingPathComponent:@"/TypoClockBuilder.theme"];
    
    //[TestFlight passCheckpoint:[NSString stringWithFormat:@"Creating Symlinks"]];
    if([fm fileExistsAtPath:[documentsDirectory stringByAppendingPathComponent:@"tethered"]]){
        [fm removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:@"tethered"] error:nil];
    }
    NSError *tetherr;
    if(![fm createDirectoryAtPath:[documentsDirectory stringByAppendingPathComponent:@"tethered"] withIntermediateDirectories:YES attributes:nil error:&tetherr]){
        //[TestFlight passCheckpoint:[NSString stringWithFormat:@"cannot create tethered folder: %@", tetherr.localizedDescription]];
    }

    NSError *remError;
    if([fm fileExistsAtPath:lockscreenFolder]){
       if(![fm removeItemAtPath:lockscreenFolder error:&remError]){
           //[TestFlight passCheckpoint:[NSString stringWithFormat:@"remove error: %@", remError]];
       }
    }
    
    NSError *error;
    if(![fm createDirectoryAtPath:lockscreenFolder withIntermediateDirectories:YES attributes:nil error:&error]){
        //[TestFlight passCheckpoint:[NSString stringWithFormat:@"cannot create LS dir: %@", error]];
    }
    NSArray *fileLinks = [[kDataSingleton getSettings] objectForKey:@"fileLinks"];
    
        for(NSString *file in fileLinks)
        {
            //NSError *error;
            NSString *target = [documentsDirectory stringByAppendingFormat:@"/lockscreen/%@", file];
            [fm removeItemAtPath:target error:nil];
            if(![fm createSymbolicLinkAtPath:target withDestinationPath:[self createDestination:file] error:&error]){
                //[TestFlight passCheckpoint:[NSString stringWithFormat:@"Error creating symlink: %@", error]];
            }
            else{}
            
                //NSLog(@"symlink created for: %@", file);
        }
        
        NSString *jbThemes = [self findThemesfolder];
        NSString *sliderTarget2x = [NSString stringWithFormat:@"%@/Bundles/com.apple.TelephonyUI/bottombarknobgray@2x.png",jbThemes];
        NSString *sliderTarget = [NSString stringWithFormat:@"%@/Bundles/com.apple.TelephonyUI/bottombarknobgray.png",jbThemes];
        [fm removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:@"/lockscreen/slider@2x.png"] error:nil];
        [fm removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:@"/lockscreen/slider.png"] error:nil];
        [fm createSymbolicLinkAtPath:[documentsDirectory stringByAppendingPathComponent:@"/lockscreen/slider.png"] withDestinationPath:sliderTarget error:nil];
        [fm createSymbolicLinkAtPath:[documentsDirectory stringByAppendingPathComponent:@"/lockscreen/slider@2x.png"] withDestinationPath:sliderTarget2x error:nil];
        
        for(int x = 1; x<30 ; x++)
        {
            NSString *imageName =[NSString stringWithFormat:@"slide%i.jpg",x];
            if(x<10)
            {
                imageName = [NSString stringWithFormat:@"slide0%i.jpg",x];
            }
            if([fm fileExistsAtPath:[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/lockscreen/%@",imageName]]])
            {
                [fm removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/lockscreen/%@",imageName]] error:nil];
            }  
            /*
            NSError *slideSymError;
            if(![fm createSymbolicLinkAtPath:[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/lockscreen/%@",imageName]] withDestinationPath:[NSString stringWithFormat:@"%@/slides/%@",[self findThemesfolder],imageName] error:&slideSymError])
                NSLog(@"error creating symlink:%@",slideSymError.localizedDescription);
            else
            {}//NSLog(@"symlink created for: %@", imageName);
             */
            
        }
        
}

- (void) run:(NSString *)weatherOnly
{
    self.bgImageData = nil;
    if([self checkIfThemeInstalled] )
    {        
        if(_appUpdated || YES){
            NSArray *wlist = [self getWidgetList];
            NSString *j1 = [wlist JSONRepresentation];//[jsonWriter stringWithObject:wlist];
            NSString *json = [j1 stringByReplacingOccurrencesOfString:@"\"class\"" withString:@"\"widgetClass\""];
            NSString *data = [NSString stringWithFormat:@"var data = %@;",json];
            NSDictionary *weatherData = [[kDataSingleton getSettings] objectForKey:@"weatherData"];
            
            NSString *loc = [weatherData objectForKey:@"location"];    
            if([loc isEqualToString:@"Current Location"])
                loc = [[NSUserDefaults standardUserDefaults] objectForKey:@"currentLocation"];
            
            
            NSString *windChill = ([[weatherData objectForKey:@"useWindchill"] boolValue]) ? @"YES" : @"NO";
            NSString *degreeSymbol = ([[weatherData objectForKey:@"showDegreeSymbol"] boolValue]) ? @"YES" : @"NO";
            //var weatherDataSettings = {};
            NSString *weatherDataJS = [NSString stringWithFormat:@"weatherDataSettings = { \"weatherIconSet\" : \"%@\", \"units\" : \"%@\" , \"locationName\" : \"%@\" , \"location\" : \"%@\" , \"windChill\" : \"%@\" , \"showDegreeSymbol\" : \"%@\" }", 
                                       [weatherData objectForKey:@"weatherIconSet"],
                                       [weatherData objectForKey:@"units"], 
                                       [weatherData objectForKey:@"locationName"], 
                                       loc,
                                       windChill,
                                       degreeSymbol
                                       ];

            [self saveData:data weatherDataJS:weatherDataJS weatherOnly:weatherOnly];
        }
        else
        {
            dispatch_sync(dispatch_get_main_queue(), ^(void) {  
                [[GMTHelper sharedInstance] alertWithString:@"You must update to the latest version to enable updating the lockscreen"];
            });
        }
    }
}

- (void) runFromCoreData:(NSString *)weatherOnly withDict:(NSMutableDictionary*)themeDict
{
    if([self checkIfThemeInstalled] )
    {
        if(_appUpdated || YES){
            
            
            NSMutableArray *wlist = [NSMutableArray arrayWithArray:0];
            
            if(themeDict!=nil && themeDict.count>2)
            {
                wlist = [[themeDict objectForKey:@"widgetsList"] mutableCopy];
                self.bgImageData = [themeDict objectForKey:@"LockBackground.png"];
            }
            else{
                wlist = [kDataSingleton getWidgetsListFromSettings];
                self.bgImageData = nil;
            }
            
            if(wlist)
            {
                wlist = [self processWidgetsList:wlist];
            }
            
            
            NSString *j1 = [wlist JSONRepresentation];
            NSString *json = [j1 stringByReplacingOccurrencesOfString:@"\"class\"" withString:@"\"widgetClass\""];
            NSString *data = [NSString stringWithFormat:@"var data = %@;",json];
            
            NSDictionary *weatherData = [[kDataSingleton getSettings] objectForKey:@"weatherData"];
            
            NSString *loc = [weatherData objectForKey:@"location"];    
            if([loc isEqualToString:@"Current Location"])
                loc = [[NSUserDefaults standardUserDefaults] objectForKey:@"currentLocation"];
            
            
            NSString *windChill = ([[weatherData objectForKey:@"useWindchill"] boolValue]) ? @"YES" : @"NO";
            NSString *degreeSymbol = ([[weatherData objectForKey:@"showDegreeSymbol"] boolValue]) ? @"YES" : @"NO";
            //var weatherDataSettings = {};
            NSString *weatherDataJS = [NSString stringWithFormat:@"weatherDataSettings = { \"weatherIconSet\" : \"%@\", \"units\" : \"%@\" , \"locationName\" : \"%@\" , \"location\" : \"%@\" , \"windChill\" : \"%@\" , \"showDegreeSymbol\" : \"%@\" }", 
                                       [weatherData objectForKey:@"weatherIconSet"],
                                       [weatherData objectForKey:@"units"], 
                                       [weatherData objectForKey:@"locationName"], 
                                       loc,
                                       windChill,
                                       degreeSymbol
                                       ];
            
            
            [self saveData:data weatherDataJS:weatherDataJS weatherOnly:weatherOnly];
            //ALSO SAVE BACKGROUND
            
            
            
        }
        else
        {
            dispatch_sync(dispatch_get_main_queue(), ^(void) {  
                //[TestFlight passCheckpoint:[NSString stringWithFormat:@"Run: theme is NOT installed - WeatherOnly: %@", weatherOnly]];
                [[GMTHelper sharedInstance] alertWithString:@"You must update to the latest version to enable updating the lockscreen"];
            });
        }
    }
    else{
        dispatch_sync(dispatch_get_main_queue(), ^(void) {
            //[TestFlight passCheckpoint:[NSString stringWithFormat:@"Run: theme is NOT installed - WeatherOnly: %@", weatherOnly]];
            [[GMTHelper sharedInstance] alertWithString:@"TypoClock Builder was not found.  Please install from Cydia."];
        });
    }
}


-(id)init
{
    if(self == [super init])
    {
        
    }
    return self;
}


@end
