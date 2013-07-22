//
//  socialShareActionSheetDelegate.m
//  ClockBuilder
//
//  Created by Gustavo Tandeciarz on 4/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "socialShareActionSheetDelegate.h"
//#import "AddThis.h"


@implementation socialShareActionSheetDelegate 
@synthesize image;

-(id)init
{
    if((self = [super init]))
    {
        
        /* 
         
         TWITPIC
         API: 2a0c7cad91bbe700e9b970a2389238ff
         
         TWITTER
         api:             iv7IQ5GlzGAodPuDhupA2g
         consumer secret: 92guA0fhqiQ9IPyDGfoinDAwPxOhqfV3N3U8kSD9Y
         consumer key: iv7IQ5GlzGAodPuDhupA2g
         callback URL: http://clockbuilder.gmtaz.com
         
         FACEBOOK
         API: 2c1f27036111467f7e0462d7762c4342
         
         [AddThisSDK setTwitPicAPIKey:@"2a0c7cad91bbe700e9b970a2389238ff"];
         
         [AddThisSDK setTwitterAuthenticationMode:ATTwitterAuthenticationTypeOAuth];
         [AddThisSDK setTwitterConsumerKey:@"iv7IQ5GlzGAodPuDhupA2g"];
         [AddThisSDK setTwitterConsumerSecret:@"92guA0fhqiQ9IPyDGfoinDAwPxOhqfV3N3U8kSD9Y"];
         [AddThisSDK setTwitterCallBackURL:@"http://clockbuilder.gmtaz.com"];
         
         [AddThisSDK setFacebookAuthenticationMode:ATFacebookAuthenticationTypeFBConnect];
         [AddThisSDK setFacebookAPIKey:@"2c1f27036111467f7e0462d7762c4342"];
         
         [AddThisSDK setAddThisPubId:@"ra-4db8bbe71bdaf783"];
         [AddThisSDK setAddThisApplicationId:@"4db8bc2914b7b1d7"];
         [AddThisSDK setDelegate:self];
         [AddThisSDK setNavigationBarColor:[UIColor blackColor]];
         
         */
        
        
    }
    return self;
}
-(void)setImageToShare:(UIImage *)_image
{
    image = _image;
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    /*
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    NSLog(@"social action sheet button clicked: %@",title);
    
    if([title isEqualToString:@"Facebook"])
    {
     NSLog(@"%@",[AddThisSDK shareImage:image
                   withService:@"facebook"
                         title:@"Check out my new Theme!"
                   description:@"Check out the new Clock Builder theme I made on my iPhone. http://clockbuilder.gmtaz.com"]);
    }
    if([title isEqualToString:@"Twitter"])
    {
        [AddThisSDK shareImage:image
                   withService:@"twitter"
                         title:@"Check out my new Theme!"
                   description:@"Check out the new Clock Builder theme I made on my iPhone. http://clockbuilder.gmtaz.com"];
    }
    image = nil;
     */
}



@end
