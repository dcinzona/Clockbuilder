//
//  weatherIconView.m
//  ClockBuilder
//
//  Created by Gustavo Tandeciarz on 3/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "weatherIconView.h"
#import "UIImageView+WebCache.h"
#import "UIImage+Trim.h"
#import "SDImageCache.h"


@implementation weatherIconView

@synthesize iconID,
widgetIconSet,
widgetData,
weatherData,
icon,
indexInList;

-(NSNumber *) getIndexInList
{
    return self.indexInList;
}


- (void) refreshWithNewWeatherData
{
    dispatch_async(dispatch_queue_create("com.gmtaz.clockbuilder.GetWeatherIcon", NULL), ^{
        self.weatherData = [[kDataSingleton getSettings] objectForKey:@"weatherData"];
        self.widgetIconSet = [self.weatherData objectForKey:@"weatherIconSet"];
        if(self.widgetIconSet == nil || [self.widgetIconSet isEqualToString:@""])
        {
            self.widgetIconSet = @"Tick";
        }
        NSDictionary *forecastData = [[self.weatherData objectForKey:@"data"] objectForKey:@"item"];
        NSDictionary *item = nil;
        NSString *forecast = [[self.widgetData objectForKey:@"forecast"] lowercaseString];
        //set forecastData based on forecast value
        NSString *dn = [self isDayOrNight];
        if([forecast isEqualToString:@"current"])
        {
            item = [forecastData objectForKey:@"condition"];
            self.iconID = [item objectForKey:@"code"];
        }
        if([forecast isEqualToString:@"today"])
        {
            item = [[forecastData objectForKey:@"forecast"] objectAtIndex:0];
            self.iconID = [item objectForKey:@"code"];
            dn = @"d";
        }
        if([forecast isEqualToString:@"tomorrow"])
        {
            item = [[forecastData objectForKey:@"forecast"] objectAtIndex:1];
            self.iconID = [item objectForKey:@"code"];
            dn = @"d";
        }
        
        NSString *imageName = [NSString stringWithFormat:@"%@_%@%@",[self.widgetIconSet lowercaseString],self.iconID,dn];
        UIImage *iconImage = [UIImage imageNamed:imageName];
        CGSize originalImageSize = iconImage.size;
        UIImage *iconImageCropped = [iconImage imageByTrimmingTransparentPixels];
        CGSize croppedSize = iconImageCropped.size;
        
        float difx = originalImageSize.width - croppedSize.width;
        float dify = originalImageSize.height - croppedSize.height;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setBackgroundColor:[UIColor colorWithRed:0 green:1 blue:0 alpha:.4]];
            [self.icon setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:1 alpha:.4]];
            [self.icon setImage:iconImageCropped];
            CGRect frame = self.icon.frame;
            frame.size = iconImage.size;
            //[self.icon setFrame:frame];
            CGRect selfFrame = self.frame;
            //selfFrame.size = frame.size;
            //[self setFrame:selfFrame];
            //scale by scale value
            
            if([self.widgetData objectForKey:kIconScaleKey]){
                //[self.layer setAnchorPoint:CGPointMake(0.5, 0.5)];
                [self.icon.layer setAnchorPoint:CGPointMake(0.5, 0.5)];
                if(!CGSizeEqualToSize(self.frame.size, self.icon.frame.size)){
                    float scale = [[self.widgetData objectForKey:kIconScaleKey] floatValue];
                    self.icon.transform = CGAffineTransformScale(self.icon.transform, scale, scale);
                }
            }
            
            [self setNeedsDisplay];
        });

    });
}

-(NSString *)isDayOrNight{
    NSString* ret = @"d";
    NSDictionary *astronomy = [[self.weatherData objectForKey:@"data"] objectForKey:@"astronomy"];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"hh:mm a"];
    NSString *sunriseString = [[astronomy objectForKey:@"sunrise"] uppercaseString];
    NSString *sunsetString = [[astronomy objectForKey:@"sunset"] uppercaseString];
    NSString *nowString = [dateFormat stringFromDate:[NSDate date]];
    NSDate *sunrise = [dateFormat dateFromString:sunriseString];
    NSDate *sunset = [dateFormat dateFromString:sunsetString];
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
    return ret;
}


-(UIImage *)getIconImage
{
    UIImage *image;
    image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%@%@.png",[self.widgetIconSet lowercaseString],self.iconID, [self isDayOrNight]]];
    return image;
}

-(NSMutableDictionary *)getWidgetData{
    return self.widgetData;
}
- (id) initWithFrame:(CGRect)frame widgetData:(NSDictionary *)widgetDataDict indexValue:(NSNumber*)index {
	self = [super initWithFrame:frame];
    if (self) 
    {
        [self setClearsContextBeforeDrawing:YES];
        //[self setOpaque:YES];
        self.indexInList = index;
        self.widgetData = [widgetDataDict mutableCopy];
        self.weatherData = [[kDataSingleton getSettings] objectForKey:@"weatherData"];
        float opacity = [[self.widgetData objectForKey:@"opacity"]floatValue];
        self.icon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        if([self.weatherData objectForKey:@"data"]!=nil)
        {
            self.widgetIconSet = [self.weatherData objectForKey:@"weatherIconSet"];
            //Get Weather Data or show nothing
            [self.icon setContentMode:UIViewContentModeScaleAspectFit];
            [self.icon setBackgroundColor:[UIColor clearColor]];
            [self addSubview:self.icon];
            [self.icon setAlpha:opacity];         
            [self refreshWithNewWeatherData];   
        }

    }
	return self;
}

-(void)updateAlpha:(NSString *)alphaVal
{
    [self.icon setAlpha:[alphaVal floatValue]];
}
-(void)setNewWidgetData:(NSDictionary *)wd
{
    self.widgetData = [NSMutableDictionary dictionaryWithDictionary:wd];
    [self refreshWithNewWeatherData];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc
{
    self.widgetData = nil;
    self.iconID = nil;
    self.widgetIconSet = nil;
    self.weatherData = nil;
    self.icon = nil;
    self.indexInList = nil;
}

@end
