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


@implementation themeConverter

@synthesize themeName;
@synthesize h;


/* The encryption info struct and constants are missing from the iPhoneSimulator SDK, but not from the iPhoneOS or
 * Mac OS X SDKs. Since one doesn't ever ship a Simulator binary, we'll just provide the definitions here. */
#if TARGET_IPHONE_SIMULATOR && !defined(LC_ENCRYPTION_INFO)
#define LC_ENCRYPTION_INFO 0x21
struct encryption_info_command {
    uint32_t cmd;
    uint32_t cmdsize;
    uint32_t cryptoff;
    uint32_t cryptsize;
    uint32_t cryptid;
};
#endif

int main (int argc, char *argv[]);

static BOOL is_encrypted () {
    const struct mach_header *header;
    Dl_info dlinfo;
    
    /* Fetch the dlinfo for main() */
    if (dladdr(main, &dlinfo) == 0 || dlinfo.dli_fbase == NULL) {
        NSLog(@"Could not find main() symbol (very odd)");
        return NO;
    }
    header = dlinfo.dli_fbase;
    
    /* Compute the image size and search for a UUID */
    struct load_command *cmd = (struct load_command *) (header+1);
    
    for (uint32_t i = 0; cmd != NULL && i < header->ncmds; i++) {
        /* Encryption info segment */
        if (cmd->cmd == LC_ENCRYPTION_INFO) {
            struct encryption_info_command *crypt_cmd = (struct encryption_info_command *) cmd;
            /* Check if binary encryption is enabled */
            if (crypt_cmd->cryptid < 1) {
                /* Disabled, probably pirated */
                return NO;
            }
            
            /* Probably not pirated? */
            return YES;
        }
        
        cmd = (struct load_command *) ((uint8_t *) cmd + cmd->cmdsize);
    }
    
    /* Encryption info not found */
    return NO;
}

-(BOOL)isEncrypted{
    BOOL enc = is_encrypted();
    return enc;
}

-(void)dealloc
{
    [themeName release];
    [h release];
    [super dealloc];
}

-(BOOL)checkIfJB
{
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *cydiaDirPath = @"/Applications/Cydia.app";
    BOOL exists = [fm fileExistsAtPath:cydiaDirPath];    
    [fm release];
    return exists;
}
-(BOOL)checkIfThemeInstalled
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *themeDirPath = @"/Library/Themes/TypoClockBuilder.theme";
    BOOL exists = [fm fileExistsAtPath:themeDirPath];
    [fm release];
    return exists;
}


-(void)checkifupdated
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        if([h deviceIsConnectedToInet]){
            if( [h checkAppVersionNoAlert] ){
                [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"appUpdated"];
                _appUpdated = YES;
            }
            else
            {
                [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"appUpdated"];
                _appUpdated = NO;
            }
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

- (NSString *)getThemesDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *themesPath = [documentsDirectory stringByAppendingFormat:@"/myThemes/"];
    NSString *dir = [themesPath stringByAppendingFormat:@"%@",themeName];
    return dir;
}

- (NSArray *)getWidgetList
{
    NSArray *widgetsList = [[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"] objectForKey:@"widgetsList"];

    if(themeName!=nil && ![themeName isEqualToString:@""])
    {
    widgetsList = [NSArray arrayWithContentsOfFile:[[self getThemesDirectory] stringByAppendingFormat:@"/widgetsList.plist"]];
        
    }
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for(NSDictionary* widget in widgetsList)
    {
        NSMutableDictionary *data = [widget mutableCopy];
        if(![[widget objectForKey:@"type"]isEqualToString:@"imageWidget"]){
            NSString *colorAsString = [self getColorAsString:(UIColor *)[NSKeyedUnarchiver unarchiveObjectWithData:[data objectForKey:@"fontColor"]]];
            [data setObject:colorAsString forKey:@"fontColor"];
        }
        NSString *glowAsString = [self getColorAsString:(UIColor *)[NSKeyedUnarchiver unarchiveObjectWithData:[data objectForKey:@"glowColor"]]];
        [data setObject:glowAsString forKey:@"glowColor"];
        [array addObject:data];
        [data release];
    }
    NSArray *returnedArray = [NSArray arrayWithArray:array];
    [array release];
    return returnedArray;
}

-(void)writeToLocalWithStyle:(NSString*)style andHTML:(NSString*)html andbuildJS:(NSString*)buildJS {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *styleTarget = [documentsDirectory stringByAppendingPathComponent:@"/tethered/style.css"];
    NSString *htmlTarget = [documentsDirectory stringByAppendingPathComponent:@"/tethered/LockBackground.html"];
    NSString *buildJSTarget = [documentsDirectory stringByAppendingPathComponent:@"/tethered/build.js"];
    NSString *backgroundTarget = [documentsDirectory stringByAppendingPathComponent:@"/tethered/LockBackground.png"];
    
    NSString *themeDir = [documentsDirectory stringByAppendingFormat:@"/myThemes/%@",themeName];
    if(themeName == nil || [themeName isEqualToString:@""])
        themeDir = documentsDirectory;
    NSData *bgImage = [NSData dataWithContentsOfFile:[themeDir stringByAppendingPathComponent:@"/LockBackground.png"]];
    
    NSError *bgerr;
    if(![bgImage writeToFile:backgroundTarget options:NSDataWritingFileProtectionNone error:&bgerr])
    {
        NSLog(@"did not save image: %@", [bgerr localizedDescription]);
    }
    NSError *csserr;
    if(![style writeToFile:styleTarget atomically:YES encoding:NSUTF8StringEncoding error:&csserr])
    {
        NSLog(@"did not save style.css: %@", [csserr localizedDescription]);
    }
    NSError *htmlerr;
    if(![html writeToFile:htmlTarget atomically:YES encoding:NSUTF8StringEncoding error:&htmlerr])
    {
        NSLog(@"did not save LockBackground.html: %@", [htmlerr localizedDescription]);
    }
    NSError *blderr;
    if(![buildJS writeToFile:buildJSTarget atomically:YES encoding:NSUTF8StringEncoding error:&blderr])
    {
        NSLog(@"did not save build.js: %@", [blderr localizedDescription]);
    }
    
}

- (void) updateHTMLandCSS:(NSString *)data weatherData:(NSString *)weatherData weatherOnly:(NSString *)weatherOnly
{
    NSInteger i = [[NSDate date] timeIntervalSince1970];
    NSString *nowTimestamp = [NSString stringWithFormat:@"%i", i ]; 
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *styleCSS = [documentsDirectory stringByAppendingPathComponent:@"/lockscreen/style.css"];
    //style.css
    NSString *stylecss = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"style" ofType:@"css"] encoding:NSUTF8StringEncoding error:nil] ;
    NSString *html = [documentsDirectory stringByAppendingPathComponent:@"/lockscreen/LockBackground.html"];
    NSString *buildJSTarget = [documentsDirectory stringByAppendingPathComponent:@"/lockscreen/build.js"];
    
    NSString *htmlTemplate = [[NSBundle mainBundle] pathForResource:@"LockBackground" ofType:@"html"];
    NSString *cssStringOrig = stylecss;//[NSString stringWithContentsOfFile:stylecss encoding:NSUTF8StringEncoding error:nil];
   // if(is_encrypted() && [h isOriginal]){
        
        //NSLog(@"data: %@",data);

        if(![weatherOnly boolValue]){
            
            NSString *htmlStringOrig = [NSString stringWithContentsOfFile:htmlTemplate encoding:NSUTF8StringEncoding error:nil];
            
            NSString *htmlToWrite = [(NSString *)htmlStringOrig stringByReplacingOccurrencesOfString:@"style.css\"" withString:[NSString stringWithFormat:@"style.css?%@\"",nowTimestamp]];
            htmlToWrite = [htmlToWrite stringByReplacingOccurrencesOfRegex:@"style.css\\?[0-9]+\"" withString:[NSString stringWithFormat:@"style.css?%@\"",nowTimestamp]];
            htmlToWrite = [htmlToWrite stringByReplacingOccurrencesOfRegex:@"build.js\\?[0-9]+\"" withString:[NSString stringWithFormat:@"build.js?%@\"",nowTimestamp]];
            
            NSString *cssToWrite = [(NSString *)cssStringOrig stringByReplacingOccurrencesOfString:@"LockBackground.png'" withString:[NSString stringWithFormat:@"LockBackground.png?%@'",nowTimestamp]];
            cssToWrite = [cssToWrite stringByReplacingOccurrencesOfRegex:@"LockBackground.png\\?[0-9]+'" withString:[NSString stringWithFormat:@"LockBackground.png?%@'",nowTimestamp]];    
            
            htmlToWrite = [htmlToWrite stringByReplacingOccurrencesOfRegex:@"<script class=\"dataScript\" type=\"text/javascript\">.+</script>" withString:[NSString stringWithFormat:@"<script class=\"dataScript\" type=\"text/javascript\">%@</script>", data]];
            htmlToWrite = [htmlToWrite stringByReplacingOccurrencesOfRegex:@"<script class=\"weatherDataScript\" type=\"text/javascript\">.+</script>" withString:[NSString stringWithFormat:@"<script class=\"weatherDataScript\" type=\"text/javascript\">%@</script>", weatherData]];

            //build.js
            NSString *buildJS = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"build" ofType:@"js"] encoding:NSUTF8StringEncoding error:nil] ;
            if(![[[NSUserDefaults standardUserDefaults] objectForKey:@"useSlideshow"] boolValue])
                buildJS = [buildJS stringByReplacingOccurrencesOfString:@"var shouldShowSlideShow = true;" withString:@"var shouldShowSlideShow = false;"];
            if([h prefers24Hour])
                buildJS = [buildJS stringByReplacingOccurrencesOfString:@"var militaryTime = false;" withString:@"var militaryTime = true;"];
            
            NSError *err;
            
            
            NSError *htmlerr;
            if(![htmlToWrite writeToFile:html atomically:NO encoding:NSUTF8StringEncoding error:&htmlerr]){
                //NSLog(@"unable to write HTML /n %@", htmlerr.localizedDescription);
                [self writeToLocalWithStyle:cssToWrite andHTML:htmlToWrite andbuildJS:buildJS];
                return;
            }
            
            if(![buildJS writeToFile:buildJSTarget atomically:NO encoding:NSUTF8StringEncoding error:&err])
            {}//NSLog(@"unable to write build.js /n %@", err.localizedDescription);
            [cssToWrite writeToFile:styleCSS atomically:NO encoding:NSUTF8StringEncoding error:nil];     
            
            
            NSString *themeDir = [documentsDirectory stringByAppendingFormat:@"/myThemes/%@",themeName];
            if(themeName == nil || [themeName isEqualToString:@""])
                themeDir = documentsDirectory;
            NSData *bgImage = [NSData dataWithContentsOfFile:[themeDir stringByAppendingPathComponent:@"/LockBackground.png"]];
            
            NSError *bgerr;
            if(![bgImage writeToFile:[documentsDirectory stringByAppendingPathComponent:@"/lockscreen/LockBackground.png"] options:NSDataWritingFileProtectionNone error:&bgerr])
            {
                NSLog(@"did not save image: %@", [bgerr localizedDescription]);
            }
            
            
        }
        else
        {
            
            NSString *htmlStringOrig = [NSString stringWithContentsOfFile:html encoding:NSUTF8StringEncoding error:nil];
            
            NSString *htmlToWrite = [(NSString *)htmlStringOrig stringByReplacingOccurrencesOfString:@"style.css\"" withString:[NSString stringWithFormat:@"style.css?%@\"",nowTimestamp]];
            htmlToWrite = [htmlToWrite stringByReplacingOccurrencesOfRegex:@"style.css\\?[-0-9-]+\"" withString:[NSString stringWithFormat:@"style.css?%@\"",nowTimestamp]];
            
            
            htmlToWrite = [htmlToWrite stringByReplacingOccurrencesOfRegex:@"<script class=\"weatherDataScript\" type=\"text/javascript\">.+</script>" withString:[NSString stringWithFormat:@"<script class=\"weatherDataScript\" type=\"text/javascript\">%@</script>", weatherData]];
            [htmlToWrite writeToFile:html atomically:NO encoding:NSUTF8StringEncoding error:nil];
            NSError *htmlerr;
            if(![htmlToWrite writeToFile:html atomically:NO encoding:NSUTF8StringEncoding error:&htmlerr]){
                //NSLog(@"unable to write HTML weatherOnly /n %@", htmlerr.localizedDescription);
                NSString *htmlTarget = [documentsDirectory stringByAppendingPathComponent:@"/tethered/LockBackground.html"];
                [htmlToWrite writeToFile:htmlTarget atomically:YES encoding:NSUTF8StringEncoding error:nil];
                return;
            }
            
        }
   /* }
    else
    {
        NSString *htmls = @"Error: Unencrypted version of Clock Builder detected. Please update using Apple's App Store.";        
        [htmls writeToFile:html atomically:NO encoding:NSUTF8StringEncoding error:nil];
    }*/
    
}

- (void) saveData:(NSString *)data weatherDataJS:(NSString *)weatherDataJS weatherOnly:(NSString *)weatherOnly
{

        [self updateHTMLandCSS:data weatherData:weatherDataJS weatherOnly:weatherOnly];
        if(![weatherOnly boolValue])
        {
            //[self performSelector:@selector(createSymLinks)];
            if([[[NSUserDefaults standardUserDefaults] objectForKey:@"tethered"] isEqualToString:@"NO"])
                [h showOverlay:@"Lockscreen Set" iconImage:nil];
            else{
                [h showOverlay:@"Theme Files Set" iconImage:nil];
                NSString *confirmStr = @"Get it now";
                [h alertWithStringAndConfirm:[[NSUserDefaults standardUserDefaults]objectForKey:@"cbfixmsg"] confirmString:confirmStr];
                //[h alertWithString:];
            }
        }
}


-(NSString *)findThemesfolder
{
    NSString *themesRoot = @"/Library/Themes/";
    NSFileManager *manager = [NSFileManager defaultManager];
    //NSArray *fileList = [manager contentsOfDirectoryAtPath:themesRoot error:nil];
    //for (NSString *s in fileList){
        //if([s isMatchedByRegex:@"^Themes.+"]){
            NSString *fullString = [NSString stringWithFormat:@"%@/TypoClockBuilder.theme",themesRoot];
            if([manager fileExistsAtPath:fullString])
            {
                [manager release];
                //return fullString;
            }
        //}
    //}
    [manager release];
    NSString *ret = [@"" stringByAppendingPathComponent:@"/Library/Themes/TypoClockBuilder.theme"];
    return ret;
}
-(NSString *)createDestination:(NSString *)filename{
    NSString *themePath = [self findThemesfolder];
    NSString *destination = [themePath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",filename]];
    //NSLog(@"destination: %@",destination);
    return destination;
}
- (void)createSymLinks
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *lockscreenFolder = [documentsDirectory stringByAppendingPathComponent:@"/lockscreen"];
    NSString *themeFolder = [documentsDirectory stringByAppendingPathComponent:@"/TypoClockBuilder.theme"];
    
    
    NSError *error1;
    [fm removeItemAtPath:themeFolder error:nil];
    if(![fm createSymbolicLinkAtPath:themeFolder withDestinationPath:@"/Library/Themes/TypoClockBuilder.theme" error:&error1])
        NSLog(@"error creating themesFolder:%@ \n",error1.localizedDescription);
    NSError *err2;
    if(![@"test" writeToFile:[themeFolder stringByAppendingPathComponent:@"/test"] atomically:NO encoding:NSUTF8StringEncoding error:&err2]){
        [fm removeItemAtPath:[themeFolder stringByAppendingPathComponent:@"/TypoClockBuilder.theme"] error:nil];
        NSError *error;
        [fm createDirectoryAtPath:[documentsDirectory stringByAppendingPathComponent:@"/tethered"] withIntermediateDirectories:YES attributes:nil error:&error];
        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"tethered"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else{
        [fm removeItemAtPath:[themeFolder stringByAppendingPathComponent:@"/test"] error:nil];
        [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"tethered"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    
    NSError *error;
    [fm createDirectoryAtPath:lockscreenFolder withIntermediateDirectories:YES attributes:nil error:&error];
    NSArray *fileLinks = [[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"] objectForKey:@"fileLinks"];
    for(NSString *file in fileLinks)
    {
        NSError *error;
        NSString *target = [documentsDirectory stringByAppendingFormat:@"/lockscreen/%@", file];
        [fm removeItemAtPath:target error:nil];
        if(![fm createSymbolicLinkAtPath:target withDestinationPath:[self createDestination:file] error:&error])
            NSLog(@"error creating symlink:%@",error);
    }
    
    NSString *jbThemes = [self findThemesfolder];
    NSString *sliderTarget2x = [NSString stringWithFormat:@"%@/Bundles/com.apple.TelephonyUI/bottombarknobgray@2x.png",jbThemes];
    NSString *sliderTarget = [NSString stringWithFormat:@"%@/Bundles/com.apple.TelephonyUI/bottombarknobgray.png",jbThemes];
    [fm removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:@"/lockscreen/slider@2x.png"] error:nil];
    [fm removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:@"/lockscreen/slider.png"] error:nil];
    [fm createSymbolicLinkAtPath:[documentsDirectory stringByAppendingPathComponent:@"/lockscreen/slider.png"] withDestinationPath:sliderTarget error:nil];
    [fm createSymbolicLinkAtPath:[documentsDirectory stringByAppendingPathComponent:@"/lockscreen/slider@2x.png"] withDestinationPath:sliderTarget2x error:nil];
    /*
    NSLog(@"lockbackground --------------\n%@", 
          [NSString stringWithContentsOfFile:
           [documentsDirectory stringByAppendingPathComponent:@"/lockscreen/LockBackground.html"]                                                                    encoding:NSUTF8StringEncoding error:nil]);*/

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
        [fm createSymbolicLinkAtPath:[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/lockscreen/%@",imageName]] withDestinationPath:[NSString stringWithFormat:@"%@/slides/%@",[self findThemesfolder],imageName] error:nil];
    }
    [fm release];
}

- (void) run:(NSString *)weatherOnly
{
    if([self checkIfThemeInstalled] )//&& is_encrypted() && [h isOriginal])
    {        
        _appUpdated = [[[NSUserDefaults standardUserDefaults] objectForKey:@"appUpdated"] boolValue];
        if(_appUpdated){
            
            SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
            NSArray *wlist = [self getWidgetList];
            NSString *j1 = [jsonWriter stringWithObject:wlist];
            NSString *json = [j1 stringByReplacingOccurrencesOfString:@"\"class\"" withString:@"\"widgetClass\""];
            NSString *data = [NSString stringWithFormat:@"var data = %@;",json];
            [jsonWriter release];
            NSDictionary *weatherData = [[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"] objectForKey:@"weatherData"];
            
            
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
                [h alertWithString:@"You must update to the latest version to enable updating the lockscreen"];
            });
        }
    }
}



-(id)init
{
    if(self == [super init])
    {
        h = [helpers new];
    }
    return self;
}


@end
