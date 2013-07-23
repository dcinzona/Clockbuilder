//
//  manageJBSettings.m
//  ClockBuilder
//
//  Created by gtadmin on 6/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "manageJBSettings.h"
#import "PrettyCell.h"
#import "BGImageCell.h"
#import "themeConverter.h"
#import "sliderSelector.h"
#import "LanguageEditors/LanguageEditorTVC.h"

#define kBackgroundCell 3

@implementation manageJBSettings

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

-(NSString *)findThemesfolder
{
    NSString *ret = @"/Library/Themes/TypoClockBuilder.theme";
    return ret;
}
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (kIsIpad) {
        self.contentSizeForViewInPopover = kPopoverSize;
    }
    
    [self setTitle:@"Lockscreen Settings"];
    
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
        UIBarButtonItem *backButton = [CBThemeHelper createBackButtonItemWithTitle:@"Settings" target:self.navigationController action:@selector(popViewControllerAnimated:)];
        [self.navigationItem setLeftBarButtonItem: backButton];
    }
    
    
    adjustShadowForStatusBar = [[UISwitch alloc] initWithFrame:CGRectZero];
    [adjustShadowForStatusBar addTarget: self action: @selector(toggleShadowAdjust:) forControlEvents: UIControlEventValueChanged];
    adjustShadowForStatusBar.center = CGPointMake(250, 32);    
    BOOL as = [[[NSUserDefaults standardUserDefaults] objectForKey:@"adjustShadowForStatusBar"] boolValue];
    adjustShadowForStatusBar.on = as;
    
    rotateWallpaper = [[UISwitch alloc] initWithFrame:CGRectZero];
    [rotateWallpaper addTarget: self action: @selector(toggleRotateWallpaper:) forControlEvents: UIControlEventValueChanged];
    BOOL rw = [[[NSUserDefaults standardUserDefaults] objectForKey:@"rotateWallpaper"] boolValue];
    rotateWallpaper.on = rw;
}

- (IBAction)toggleRotateWallpaper:(id)sender
{
    if(![[[NSUserDefaults standardUserDefaults] objectForKey:@"showedWallpaperAlert"] boolValue]){
        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"showedWallpaperAlert"];
        [[GMTHelper sharedInstance] alertWithString:@"Homescreen changes require setting the theme again AND a respring."];
    }
    NSString *keyValue = @"NO";
    if(rotateWallpaper.on){
        keyValue = @"YES";
    }
    [[NSUserDefaults standardUserDefaults]setObject:keyValue forKey:@"rotateWallpaper"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (IBAction)toggleSetWallpaper:(id)sender
{
    UISwitch *setWallpaper = (UISwitch*)sender;
    if(![[[NSUserDefaults standardUserDefaults] objectForKey:@"showedWallpaperAlert"] boolValue]){
        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"showedWallpaperAlert"];
        [[GMTHelper sharedInstance] alertWithString:@"Homescreen changes require setting the theme again AND a respring."];
    }
    NSString *keyValue = @"NO";
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *wpThumb = [documentsDirectory stringByAppendingPathComponent:@"WallpaperThumb.png"];
    NSString *wpThumb2x = [documentsDirectory stringByAppendingPathComponent:@"WallpaperThumb@2x.png"];
    NSString *wpLarge = [documentsDirectory stringByAppendingPathComponent:@"Wallpaper.png"];
    NSString *wpLarge2x = [documentsDirectory stringByAppendingPathComponent:@"Wallpaper@2x.png"];
    
    if(setWallpaper.on){
        keyValue = @"YES";
        //sync wallpaper to tethered folder
        //check if wallpaper was previously created (if not, show picker)
        if(![[NSFileManager defaultManager] fileExistsAtPath:wpThumb]){
            //show picker
            [self launchWallpaperPicker];
        }
        
        [[NSUserDefaults standardUserDefaults]setObject:keyValue forKey:@"setWallpaper"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else{
        if([[NSFileManager defaultManager] fileExistsAtPath:wpThumb]){
            NSError *err;
            if(![[NSFileManager defaultManager] removeItemAtPath:wpThumb error:&err]){
                NSLog(@"error deleting wp thumb: %@", [err description]);
            }
        }
        if([[NSFileManager defaultManager] fileExistsAtPath:wpThumb2x]){
            NSError *err;
            if(![[NSFileManager defaultManager] removeItemAtPath:wpThumb2x error:&err]){
                NSLog(@"error deleting wp thumb 2x: %@", [err description]);
            }
        }
        if([[NSFileManager defaultManager] fileExistsAtPath:wpLarge]){
            NSError *err;
            [[NSFileManager defaultManager] removeItemAtPath:wpLarge error:&err];
        }
        
        if([[NSFileManager defaultManager] fileExistsAtPath:wpLarge2x]){
            NSError *err;
            [[NSFileManager defaultManager] removeItemAtPath:wpLarge2x error:&err];
        }
        
        BGImageCell *cell = (BGImageCell *)[[self tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:kBackgroundCell inSection:0]];
        [cell.imageView setImage:[UIImage imageNamed:@"blackBG"]];
        [cell.imageView setNeedsDisplay];
        
        if(!tc){
            tc = [[themeConverter alloc]init];
        }
        [[NSUserDefaults standardUserDefaults]setObject:keyValue forKey:@"setWallpaper"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [tc updateWallpaper];
    }
    
}
- (IBAction)toggleShadowAdjust:(id)sender
{
    if(![[[NSUserDefaults standardUserDefaults] objectForKey:@"showedShadowAlert"] boolValue]){
        [[NSUserDefaults standardUserDefaults]setObject:@"YES" forKey:@"showedRespringAlert"];
        [[GMTHelper sharedInstance] alertWithString:@"Whenever you change this option, you must set the theme as the lockscreen again"];
    }
    NSString *keyValue = @"NO";
    if(adjustShadowForStatusBar.on)
        keyValue = @"YES";
    [[NSUserDefaults standardUserDefaults]setObject:keyValue forKey:@"adjustShadowForStatusBar"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
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
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *jbThemes = [self findThemesfolder];
    NSString *sliderTarget2x = [NSString stringWithFormat:@"%@/Bundles/com.apple.TelephonyUI/bottombarknobgray@2x.png",jbThemes];
    NSString *sliderTarget = [NSString stringWithFormat:@"%@/Bundles/com.apple.TelephonyUI/bottombarknobgray.png",jbThemes];
    [fm removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:@"/lockscreen/slider@2x.png"] error:nil];
    [fm removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:@"/lockscreen/slider.png"] error:nil];
    [fm createSymbolicLinkAtPath:[documentsDirectory stringByAppendingPathComponent:@"/lockscreen/slider.png"] withDestinationPath:sliderTarget error:nil];
    [fm createSymbolicLinkAtPath:[documentsDirectory stringByAppendingPathComponent:@"/lockscreen/slider@2x.png"] withDestinationPath:sliderTarget2x error:nil];
    
    
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
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
    if(kIsIpad)
        return 5;
    else
        return 4;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64;//self.view.window.screen.scale * 64;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return nil;
}


-(void)addCellAccessory:(UITableViewCell *) cell{
    if(!kIsiOS7){
        UIImageView *accessory = [[ UIImageView alloc ]
                                  initWithImage:[UIImage imageNamed:@"tvCellAccessory.png" ]];
        cell.accessoryView = accessory;
    }
    else{
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[PrettyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    if(indexPath.row==0){
        static NSString *CellIdentifier = @"CellBGSlider";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[BGImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        [[cell textLabel] setText:@"Lockscreen Slider"];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *appFilePNG = [documentsDirectory stringByAppendingPathComponent:@"/lockscreen/slider@2x.png"];
        UIImage *bgImage = [UIImage imageWithContentsOfFile:appFilePNG];
        cell.imageView.image = bgImage;
        [self addCellAccessory:cell];
        return cell;
    }
    if(indexPath.row == 1){
        
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[PrettyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        cell.textLabel.text = @"Customize Language Elements";
        
        [self addCellAccessory:cell];
        return cell;
    }
    
    
    if(indexPath.row==2 ){
        static NSString *CellIdentifier = @"switchCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[PrettyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            UISwitch *wallSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
            [wallSwitch addTarget:self action:@selector(toggleSetWallpaper:) forControlEvents:UIControlEventValueChanged];
            [cell setAccessoryView:wallSwitch];
        }
        UISwitch *wallSwitch = (UISwitch*)[cell accessoryView];
        BOOL sw = [[[NSUserDefaults standardUserDefaults] objectForKey:@"setWallpaper"] boolValue];
        wallSwitch.on = sw;
        
        [[cell textLabel] setText:@"Parallax Wallpaper"];
        
        return cell;
    }
    
    if(indexPath.row==kBackgroundCell){
        static NSString *CellIdentifier = @"CellBG";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[BGImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        [[cell textLabel] setText:@"Homescreen Background"];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *appFilePNG = [documentsDirectory stringByAppendingPathComponent:@"WallpaperThumb.png"];
        UIImage *bgImage = [UIImage imageWithContentsOfFile:appFilePNG];
        if(bgImage==nil)
        {
            cell.imageView.image = [UIImage imageNamed:@"blackBG.png"];
        }
        else{
            cell.imageView.image = bgImage;
        }
        return cell;
    }
    if(indexPath.row==kBackgroundCell+1 ){
        static NSString *CellIdentifier = @"switchCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[PrettyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            [cell addSubview:rotateWallpaper];
            [rotateWallpaper setFrame:CGRectMake(320-rotateWallpaper.frame.size.width-20,
                                              (64 - rotateWallpaper.frame.size.height)/2,
                                              rotateWallpaper.frame.size.width,
                                              rotateWallpaper.frame.size.height)];
        }
        [[cell textLabel] setText:@"Wallpaper Rotation"];
        
        return cell;
    }
    
    return cell;
}



#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row==0)
    {
        sliderSelector *slides = [[sliderSelector alloc] initWithStyle:UITableViewStylePlain];
        [self.navigationController pushViewController:slides animated:YES];
    }
    if(indexPath.row == 1){
        
        LanguageEditorTVC *le = [[LanguageEditorTVC alloc]initWithStyle:UITableViewStyleGrouped];
        [self.navigationController pushViewController:le animated:YES];
        
    }
    if(indexPath.row == 2){
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    
    if(indexPath.row == kBackgroundCell)
    {
        [self launchWallpaperPicker];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}
-(void)launchWallpaperPicker{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:kBackgroundCell inSection:0];
    UITableView *tableView = self.tableView;
    UIImagePickerController *wallpaperPicker = [[UIImagePickerController alloc] init];
    [wallpaperPicker setDelegate:self];
    if(kIsIpad)
    {
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
        if(!pop)
            pop = [[UIPopoverController alloc] initWithContentViewController:wallpaperPicker];
        
        BGImageCell *cell = (BGImageCell*)[tableView cellForRowAtIndexPath:indexPath];
        [pop presentPopoverFromRect:cell.imageView.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else
    {
        [self presentViewController:wallpaperPicker animated:YES completion:nil];
    }
}

-(void)removeLoadingOverlay
{
    [[GMTHelper sharedInstance] notifyToHideGlobalHud];
    
    NSIndexPath *bgIndex = [NSIndexPath indexPathForRow:kBackgroundCell inSection:0];
    BGImageCell *cell = (BGImageCell*)[[self tableView] cellForRowAtIndexPath:bgIndex];
    [cell.imageView setNeedsDisplay];
    if([self.parentViewController respondsToSelector:@selector(viewWillAppear:)])
        [self.parentViewController performSelector:@selector(viewWillAppear:) withObject:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    [[GMTHelper sharedInstance] notifyToShowGlobalHudWithSpinner:@"Scaling Image" andHide:YES withDelay:20 andDim:YES];
    NSOperationQueue *q = [NSOperationQueue new];
    NSInvocationOperation *save = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(saveImageAsynchUsingImage:) object:image];
    [q addOperation:save];
}

-(void)saveImageAsynchUsingImage:(UIImage *)image
{
    if([[GMTHelper sharedInstance] resizeImageToWallpaper:image]){
        //sync
        if(!tc){
            tc = [[themeConverter alloc]init];
        }
        [tc updateWallpaper];
        
        if(!gmt){
            gmt = [GMTThemeSync new];
        }
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        /*
        NSString *bgsource = [documentsDirectory stringByAppendingPathComponent:@"/tethered/WallpaperBG.png"];
        NSString *wphtmlsource = [documentsDirectory stringByAppendingPathComponent:@"/tethered/Wallpaper.html"];
        NSString *targetPath = [[self findThemesfolder] stringByAppendingString:@"/Wallpaper.html"];
        NSString *targetImagePath = [[self findThemesfolder] stringByAppendingString:@"/WallpaperBG.png"];
        */
        /*
        if([[NSFileManager defaultManager] fileExistsAtPath:bgsource]){
            [gmt syncFileAtPath:bgsource toFolderAtPath:targetImagePath];
        }
        if([[NSFileManager defaultManager] fileExistsAtPath:wphtmlsource]){
            [gmt syncFileAtPath:wphtmlsource toFolderAtPath:targetPath];
        }
         */
        
        if([gmt syncFilesFromPath:[documentsDirectory stringByAppendingPathComponent:@"/tethered/"] toPath:[self findThemesfolder]]){
            NSLog(@"files synced using hook");
        }
        else {
            NSLog(@"hook didn't run");
        }
    }
    [self performSelector:@selector(removeLoadingOverlay)  onThread:[NSThread mainThread] withObject:nil waitUntilDone:YES];
    if(kIsIpad)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [pop dismissPopoverAnimated:YES];
            //refresh cells
            [self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:kBackgroundCell inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView endUpdates];
        });
    }
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	// Dismiss the image selection and close the program    
    if(kIsIpad)
    {
        [pop dismissPopoverAnimated:YES];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
	//exit(0);
}


@end
