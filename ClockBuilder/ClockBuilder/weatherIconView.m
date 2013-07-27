//
//  weatherIconView.m
//  ClockBuilder
//
//  Created by Gustavo Tandeciarz on 3/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "weatherIconView.h"
#import "UIImageView+WebCache.h"
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
        
        UIImage *iconImageCropped = [iconImage imageByTrimmingTransparentPixels];
        
        CGSize preScaleSize = CGSizeMake(self.frame.size.width, self.frame.size.height);
        
        float ratioWidth = iconImageCropped.size.width / iconImage.size.width;
        float ratioHeight = iconImageCropped.size.height / iconImage.size.height;
        
        float scale = 1;
        
        if([self.widgetData objectForKey:kIconScaleKey]){
            scale = [[self.widgetData objectForKey:kIconScaleKey] floatValue];
        }
        else{
            //calculate scale from frame (compared to self.originalSize) - legacy scaling method
            if(!CGSizeEqualToSize(preScaleSize, self.originalSize)){
                //always going to be a square since scaling is 1:1
                scale = preScaleSize.width / self.originalSize.width;
                //then set it to 1 so that it doesnt rescale unless the user scales it.
                [self.widgetData setObject:[NSNumber numberWithFloat:scale] forKey:kIconScaleKey];
                [kDataSingleton setWidgetData:[self.indexInList intValue]  withData:self.widgetData];
            }
        }
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //[self setBackgroundColor:[UIColor colorWithRed:0 green:1 blue:0 alpha:.4]];
            //[self.icon setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:1 alpha:.4]];
            [self.icon setImage:iconImageCropped];
            
            CGRect iconframe = self.icon.frame;
            iconframe.size = iconImageCropped.size;
            CGRect selfFrame = self.frame;
            selfFrame.size = iconframe.size;
        
            //float smallestRatio = (ratioWidth < ratioHeight) ? ratioWidth : ratioHeight;
            
            CGSize transformedSize = CGSizeApplyAffineTransform(iconImageCropped.size, CGAffineTransformMakeScale(ratioWidth*scale, ratioHeight*scale));
            iconframe.size.width = (int)transformedSize.width;
            iconframe.size.height = (int)transformedSize.height;
            selfFrame.size = iconframe.size;
            
            [self.icon setFrame:iconframe];
            [self setFrame:selfFrame];
            
            //self.originalSize = selfFrame.size;
            /*
            CGRect frame = self.frame;
            transformedSize = CGSizeApplyAffineTransform(frame.size, CGAffineTransformMakeScale(scale, scale));
            iconframe.size = transformedSize;
            selfFrame.size = transformedSize;
            //[self.icon setFrame:iconframe];
            //[self setFrame:selfFrame];
             */
            
            /*
            CGPoint topCenter = CGPointMake(CGRectGetMinX(frame), CGRectGetMinY(frame));
            [self.layer setAnchorPoint:CGPointMake(0, 0)];
            self.transform = CGAffineTransformScale(self.transform, scale, scale);
            self.layer.position = topCenter;
            */
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
        self.originalSize = CGSizeMake(128, 128);
        
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
