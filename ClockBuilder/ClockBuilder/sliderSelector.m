//
//  sliderSelector.m
//  ClockBuilder
//
//  Created by gtadmin on 6/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "sliderSelector.h"
#import "JSON.h"
#import "sliderSelectorCell.h"

@implementation sliderSelector

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
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
	return val;
}
- (NSArray *) objectWithUrl:(NSURL *)url
{
    SBJsonParser *jsonParser = [SBJsonParser new];
	NSString *jsonString = [self stringWithUrl:url];
    NSArray *json = (NSArray *)[jsonParser objectWithString:jsonString];
	return json;
}
-(void) getSlidersList
{
    if(![[[NSUserDefaults standardUserDefaults] objectForKey:@"alertForRespringingBasedOnSliderResetShown"] boolValue]){
        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"alertForRespringingBasedOnSliderResetShown"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        CustomAlertView *alert = [[CustomAlertView alloc] initWithTitle:@"Warning" message:@"Changing the unlock slider image requires a respring." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
    dispatch_queue_t queue = dispatch_queue_create("com.gmtaz.Clockbuilder.getSlidersList", NULL);
    [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:YES];
    dispatch_async(queue, ^{
        if([[GMTHelper sharedInstance]deviceIsConnectedToInet])
        {
            if(_valid){   
                NSURL *gmtaz = [NSURL URLWithString:@"http://clockbuilder.gmtaz.com/resources/unlockSliders/list.txt"];
                NSArray *sliders = [NSArray arrayWithArray:[self objectWithUrl:gmtaz]];
                themesArray = [NSArray arrayWithArray:sliders];                
                dispatch_sync(dispatch_get_main_queue(), ^(void) {   
                    [self.tableView reloadData];
                    [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];                    
                });
                
            }
            
        }
        else{
            
            if(_valid){ 
                [[GMTHelper sharedInstance] alertWithString:@"Internet connection not detected. Could not get available sliders."];  
            }
        }
    });
    
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (kIsIpad) {
        self.contentSizeForViewInPopover = kPopoverSize;
    }
    
    
    [self setTitle:@"Select Slider"];
    
    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tvFooterBG.png"]];
    [bg setContentMode:UIViewContentModeTopLeft];
    [self.tableView setTableFooterView:bg];
    
    /*
    UIImageView *TVbgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"fadedBG.JPG"]];
    [self.tableView setBackgroundView:TVbgView];
    */
    
    UIImageView *bg2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, [UIScreen mainScreen].bounds.size.height)];
    [bg2 setImage:[UIImage imageNamed:@"tableGradient"]];
    [bg2 setContentMode:UIViewContentModeTop];
    UIView *bgView = [[UIView alloc] initWithFrame:self.view.frame];
    [self.tableView setBackgroundView:bgView];
    [bgView addSubview:bg2];
    UIColor *tableBGColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"office"]];
    [bgView setBackgroundColor:tableBGColor];
    [self.tableView setBackgroundColor:tableBGColor];
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setSectionFooterHeight:0];
    if(!kIsIpad){
        UIBarButtonItem *backButton = [CBThemeHelper createBackButtonItemWithTitle:@"Lockscreen Settings" target:self.navigationController action:@selector(popViewControllerAnimated:)];
        [self.navigationItem setLeftBarButtonItem: backButton];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _showRefreshed = NO;
    _valid = YES;
    [self getSlidersList];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    _valid=NO;
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSInteger rows = 0;
    if(themesArray!=nil && [themesArray count]>0)
        rows = [themesArray count];
    return rows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64;//self.view.window.screen.scale * 64;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    sliderSelectorCell *cell = (sliderSelectorCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[sliderSelectorCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    // Configure the cell...
    if(themesArray!=nil && [themesArray count]>0)
    {
        NSString *url2x = [NSString stringWithFormat:@"http://clockbuilder.gmtaz.com/resources/unlockSliders/%@/%@@2x.png",
                         [[themesArray objectAtIndex:indexPath.row] objectForKey:@"name"],
                           [[themesArray objectAtIndex:indexPath.row] objectForKey:@"color"]];
        [cell loadImage:url2x];
    }
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

-(void)popView
{
}

-(NSString *)findThemesfolder
{
    NSString *ret = @"/Library/Themes/TypoClockBuilder.theme";
    return ret;
}
-(void)setSliderImage:(NSURL *)url
{    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *slider = [documentsDirectory stringByAppendingPathComponent:@"/lockscreen/slider.png"];
    NSString *tetheredslider = [documentsDirectory stringByAppendingPathComponent:@"/tethered/slider.png"];
    NSData *data = [NSData dataWithContentsOfURL:url];
    [data writeToFile:slider options:NSDataWritingFileProtectionNone error:nil];    
    [data writeToFile:tetheredslider options:NSDataWritingFileProtectionNone error:nil];
    
    NSString *jbThemes = [self findThemesfolder];
    NSString *tmpSlider = [NSTemporaryDirectory() stringByAppendingPathComponent:@"bottombarknobgray.png"];
    NSString *tmpSliderRed = [NSTemporaryDirectory() stringByAppendingPathComponent:@"bottombarknobred.png"];
    NSString *tmpSliderGreen = [NSTemporaryDirectory() stringByAppendingPathComponent:@"bottombarknobgreen.png"];
    GMTThemeSync *gmt = [GMTThemeSync new];
    if([data writeToFile:tmpSlider atomically:YES]){
        if([gmt syncFileAtPath:tmpSlider toFolderAtPath:[NSString stringWithFormat:@"%@/Bundles/com.apple.TelephonyUI/",jbThemes]]){
            NSLog(@"Slider synced using hook");
        }
    }
    else {
        NSLog(@"hook didn't run for slider");
    }
    
    
    //red
    if([data writeToFile:tmpSliderRed atomically:YES]){
        if([gmt syncFileAtPath:tmpSliderRed toFolderAtPath:[NSString stringWithFormat:@"%@/Bundles/com.apple.TelephonyUI/",jbThemes]]){
            NSLog(@"SliderRed synced using hook");
        }
    }
    else {
        NSLog(@"hook didn't run for sliderRed");
    }
    //green
    if([data writeToFile:tmpSliderGreen atomically:YES]){
        if([gmt syncFileAtPath:tmpSliderGreen toFolderAtPath:[NSString stringWithFormat:@"%@/Bundles/com.apple.TelephonyUI/",jbThemes]]){
            NSLog(@"SliderGreen synced using hook");
        }
    }
    else {
        NSLog(@"hook didn't run for sliderGreen");
    }
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        Done1x = YES;
        if(Done2x)
            [self.navigationController popViewControllerAnimated:YES];       
    });
}
-(void)setSliderImage2x:(NSURL *)url
{    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *slider = [documentsDirectory stringByAppendingPathComponent:@"/lockscreen/slider@2x.png"];
    NSString *tetheredslider = [documentsDirectory stringByAppendingPathComponent:@"/tethered/slider@2x.png"];
    NSData *data = [NSData dataWithContentsOfURL:url];
    [data writeToFile:slider options:NSDataWritingFileProtectionNone error:nil];
    [data writeToFile:tetheredslider options:NSDataWritingFileProtectionNone error:nil];
    
    
    GMTThemeSync *gmt = [GMTThemeSync new];
    NSString *jbThemes = [self findThemesfolder];
    NSString *tmpSlider2x = [NSTemporaryDirectory() stringByAppendingPathComponent:@"bottombarknobgray@2x.png"];
    NSString *tmpSliderRed2x = [NSTemporaryDirectory() stringByAppendingPathComponent:@"bottombarknobred@2x.png"];
    NSString *tmpSliderGreen2x = [NSTemporaryDirectory() stringByAppendingPathComponent:@"bottombarknobgreen@2x.png"];
    if([data writeToFile:tmpSlider2x atomically:YES]){
        if([gmt syncFileAtPath:tmpSlider2x toFolderAtPath:[NSString stringWithFormat:@"%@/Bundles/com.apple.TelephonyUI/",jbThemes]]){
            NSLog(@"Slider2x synced using hook");
        }
    }
    else {
        NSLog(@"hook didn't run for slider2x");
    }
    //red
    if([data writeToFile:tmpSliderRed2x atomically:YES]){
        if([gmt syncFileAtPath:tmpSliderRed2x toFolderAtPath:[NSString stringWithFormat:@"%@/Bundles/com.apple.TelephonyUI/",jbThemes]]){
            NSLog(@"Slider2xRed synced using hook");
        }
    }
    else {
        NSLog(@"hook didn't run for slider2xRed");
    }
    //green    
    if([data writeToFile:tmpSliderGreen2x atomically:YES]){
        if([gmt syncFileAtPath:tmpSliderGreen2x toFolderAtPath:[NSString stringWithFormat:@"%@/Bundles/com.apple.TelephonyUI/",jbThemes]]){
            NSLog(@"Slider2xGreen synced using hook");
        }
    }
    else {
        NSLog(@"hook didn't run for slider2xGreen");
    }
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        Done2x = YES;
        if(Done1x)
            [self.navigationController popViewControllerAnimated:YES];       
    });
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *url2x = [NSString stringWithFormat:@"http://clockbuilder.gmtaz.com/resources/unlockSliders/%@/%@@2x.png",
                       [[themesArray objectAtIndex:indexPath.row] objectForKey:@"name"],
                       [[themesArray objectAtIndex:indexPath.row] objectForKey:@"color"]];
    NSString *url = [NSString stringWithFormat:@"http://clockbuilder.gmtaz.com/resources/unlockSliders/%@/%@.png",
                     [[themesArray objectAtIndex:indexPath.row] objectForKey:@"name"],
                     [[themesArray objectAtIndex:indexPath.row] objectForKey:@"color"]];
    Done1x = NO;
    Done2x = NO;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        [self setSliderImage:[NSURL URLWithString:url]];
        [self setSliderImage2x:[NSURL URLWithString:url2x]];
    }); 
    
}

@end
