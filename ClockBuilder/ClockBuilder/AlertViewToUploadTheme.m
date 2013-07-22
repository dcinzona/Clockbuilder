//
//  AlertViewToUploadTheme.m
//  ClockBuilder
//
//  Created by gtadmin on 3/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AlertViewToUploadTheme.h"
#import "soundHelper.h"
#import "JSON.h"

@implementation AlertViewToUploadTheme


-(id)init
{
    
    if((self=[super init]))
    {
        qup = [uploadThemesController new];
    }
    return self;
}

#pragma mark Save Methods
-(void)showAlertToUpload
{
    UITextField* editField = [[UITextField alloc] initWithFrame:CGRectMake(16, 83, 252, 25)];
    [editField setText:@""];
    editField.keyboardType = UIKeyboardTypeNamePhonePad;
    editField.backgroundColor = [UIColor whiteColor];
    editField.tag = 10;
    editField.borderStyle = UITextBorderStyleRoundedRect;
    NSString * uploadAlertTitle = @"Name Theme";
    NSString * uploadAlertMessage = @"Please name your theme.\n\n\n"; // If the theme already exists and was originally created by you, it will be overwritten.";
    UIAlertView *v = [[UIAlertView alloc] initWithTitle:uploadAlertTitle message:uploadAlertMessage delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Upload", nil];
    
    [editField becomeFirstResponder];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 4.0) {
        CGAffineTransform moveUp = CGAffineTransformMakeTranslation(0, 90);
        [v setTransform:moveUp];
    }
    [v addSubview:editField];
    [v show];
    [v release];
    [editField release];
}


- (void) saveToCloud
{
    
    NSString *UDID = @"Not Used";//[UIDevice currentDevice].uniqueIdentifier;
    NSString *blocked = @"blocked";
    NSString *URL = [NSString stringWithFormat:@"http://clockbuilder.gmtaz.com/blockList.php?udid=%@",UDID];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        NSString *isBlocked = [NSString stringWithContentsOfURL:[NSURL URLWithString:URL] encoding:NSUTF8StringEncoding error:nil];
        if(![blocked isEqualToString:isBlocked])
        {                
            NSString *getThemeURL = [NSString stringWithFormat:@"http://clockbuilder.gmtaz.com/getTheme.php?api=SDFB52f4vw9230V45gdfg&themeName=%@",themeNameText];
            [self performSelector:@selector(parseThemeObjectFromURL:) withObject:getThemeURL];
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *blackListed = [[UIAlertView alloc] initWithTitle:@"Error" message:@"It appears your device has been blacklisted. You cannot upload themes." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [blackListed show];
                [blackListed release];
                
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            });
        }
    });
}
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
    [ret release];
	return val;
}
- (NSDictionary *) objectWithUrl:(NSURL *)url
{
    SBJsonParser *jsonParser = [SBJsonParser new];
	NSString *jsonString = [self stringWithUrl:url];
    NSDictionary *json = (NSDictionary *)[jsonParser objectWithString:jsonString];
    [jsonParser release];
	return json;
}
- (void)parseThemeObjectFromURL:(NSString *)themeURL
{
    // Use when fetching text data
    //NSString *responseString = [request responseString];
    
    // Use when fetching binary data
    //NSData *responseData = [request responseData];
    NSString *themeName = themeNameText;
    NSString *UDID = [UIDevice currentDevice].uniqueIdentifier;
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    NSDictionary *themeDict = [self objectWithUrl:[NSURL URLWithString:themeURL]];
    //NSLog(@"themeDict: %@", themeDict);
    dispatch_async(dispatch_get_main_queue(), ^{
        if(themeDict!=nil){
            if([[themeDict objectForKey:@"udid"]isEqualToString:UDID]){
                NSString *curThemeName = [NSString stringWithFormat:@"current/%@",themeName];
                [qup saveCurrentThemeToCloud:curThemeName];
            }
            else
            {
                //alert user theme with name already exists and to rename theme
                [self performSelector:@selector(showAlertToRenameTheme)];
                
                return;
            }
        }
        else        
        {
            NSString *curThemeName = [NSString stringWithFormat:@"current/%@",themeName];
            [qup saveCurrentThemeToCloud:curThemeName];
        }
    });
}


-(void) showAlertToRenameTheme{
    
    
    UITextField* editField = [[UITextField alloc] initWithFrame:CGRectMake(16, 103, 252, 25)];
    editField.keyboardType = UIKeyboardTypeNamePhonePad;
    [editField setDelegate:self];
    [editField setText:@""];
    editField.backgroundColor = [UIColor whiteColor];
    editField.tag = 10;
    editField.borderStyle = UITextBorderStyleRoundedRect;
    NSString * alertTitle = @"Rename Theme";
    NSString * message = @"A theme with this name already exists in the cloud.";
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:alertTitle
                                                   message:[NSString stringWithFormat:@"%@\n\n\n\n" , message]
                                                  delegate:self
                                         cancelButtonTitle:@"Cancel"
                                         otherButtonTitles:@"Rename",nil] ;
    // tagField.
    //[self.alert addTextFieldWithValue:@"" label:@"City Name or Zip"];
    [editField becomeFirstResponder];
    [alert addSubview:editField];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 4.0) {
        CGAffineTransform moveUp = CGAffineTransformMakeTranslation(0, 90);
        [alert setTransform:moveUp];
    }
    [alert show];
    [alert release];
    [editField release];
    
}

// You can add/tailor the acceptable values here...
#define CHARACTERS          @" ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-_1234567890"

/*---------------------------------------------------
 * Called whenever user enters/deletes character
 *--------------------------------------------------*/
- (BOOL)textField:(UITextField *)textField 
shouldChangeCharactersInRange:(NSRange)range 
replacementString:(NSString *)string
{
    // These are the characters that are ~not~ acceptable
    NSCharacterSet *unacceptedInput =
    [[NSCharacterSet characterSetWithCharactersInString:CHARACTERS] invertedSet];
    
    // Create array of strings from incoming string using the unacceptable
    // characters as the trigger of where to split the string.
    // If array has more than one entry, there was at least one unacceptable character
    if ([[string componentsSeparatedByCharactersInSet:unacceptedInput] count] > 1)
        return NO;
    else 
        return YES;
}
-(void) showAlertBlankThemeName{
    
    
    //[editField resignFirstResponder];
    UITextField* editField = [[UITextField alloc] initWithFrame:CGRectMake(16, 83, 252, 25)];
    editField.keyboardType = UIKeyboardTypeNamePhonePad;
    [editField setText:@""];
    editField.backgroundColor = [UIColor whiteColor];
    editField.tag = 10;
    editField.borderStyle = UITextBorderStyleRoundedRect;
    NSString * alertTitle = @"Error";
    NSString * message = @"The name cannot be blank.";
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:alertTitle
                                                   message:[NSString stringWithFormat:@"%@\n\n\n" , message]
                                                  delegate:self
                                         cancelButtonTitle:@"Cancel"
                                         otherButtonTitles:@"OK",nil] ;
    //[self.alert addTextFieldWithValue:@"" label:@"City Name or Zip"];
    [editField becomeFirstResponder];
    [alert addSubview:editField];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 4.0) {
        CGAffineTransform moveUp = CGAffineTransformMakeTranslation(0, 90);
        [alert setTransform:moveUp];
    }
    [alert show];
    [alert release];
    [editField release];
    
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *textFieldString = @"";
    for(UIView *subview in [alertView subviews])
    {
        if([subview class]==[UITextField class])
        {
            textFieldString = [(UITextField*)subview text];                                            
        }
    }
    
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(playclicksoft)];
	NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
	if([title isEqualToString:@"Cancel"])
	{
	}
	else if([textFieldString isEqualToString:@""])
    {
        [self showAlertBlankThemeName];
    }
	else{
        themeNameText = nil;
        themeNameText = [textFieldString retain];
        [self performSelector:@selector(saveToCloud)];
	}
}

- (void)dealloc
{
    [qup release];
    themeNameText = nil;
    [super dealloc];
}

@end
