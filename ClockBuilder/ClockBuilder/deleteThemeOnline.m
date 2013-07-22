#import "deleteThemeOnline.h"
#import "helpers.h"


@implementation deleteThemeOnline

-(id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (NSString *)deleteThemeFromCloud:(NSDictionary *)theme
{
    NSString *themeName = [theme objectForKey:@"themeName"];
    NSString *rowID = [theme objectForKey:@"id"];
    NSString *UDID = [theme objectForKey:@"udid"];
    NSString *URL = [NSString stringWithFormat:@"http://clockbuilder.gmtaz.com/deleteTheme.php?api=SDFB52f4vw9230V45gdfg&themeName=%@&rowID=%@&device=iphone&udid=%@",themeName, rowID,UDID];
    NSString *retVal = [NSString stringWithContentsOfURL:[NSURL URLWithString:URL] encoding:NSUTF8StringEncoding error:nil];

    return retVal;
}
- (NSString *)deleteThemeAndBlock:(NSDictionary *)theme
{
    NSString *themeName = [theme objectForKey:@"themeName"];
    NSString *UDID = [theme objectForKey:@"udid"];
    NSString *rowID = [theme objectForKey:@"id"];
    NSString *URL = [NSString stringWithFormat:@"http://clockbuilder.gmtaz.com/deleteTheme.php?api=SDFB52f4vw9230V45gdfg&udid=%@&themeName=%@&rowID=%@&block=1&device=iphone",UDID,themeName, rowID];
    NSString *retVal = [NSString stringWithContentsOfURL:[NSURL URLWithString:URL] encoding:NSUTF8StringEncoding error:nil];

    return retVal;
}
- (void)dealloc
{
	[super dealloc];
}

@end

