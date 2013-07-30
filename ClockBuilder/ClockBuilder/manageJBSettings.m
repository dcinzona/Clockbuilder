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
#import "LSColorSliderPickerView.h"

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
    
    [CBThemeHelper styleTableView:self.tableView];
    
    UIBarButtonItem *backButton = [CBThemeHelper createBackButtonItemWithTitle:@"Settings" target:self.navigationController action:@selector(popViewControllerAnimated:)];
    [self.navigationItem setLeftBarButtonItem: backButton];
    
    
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
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(lsBGColorFinishedPickingWithNote:) name:@"saveLSSliderColor" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(completedSyncingSliderBG:) name:@"SyncCompleted" object:nil];
    
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"saveLSSliderColor" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SyncCompleted" object:nil];
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
        return 6;
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
    if(!kIsIpad && indexPath.row==kBackgroundCell+1 ){
        static NSString *CellIdentifier = @"switchCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[PrettyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            UISwitch *unlockSliderBGSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
            [unlockSliderBGSwitch addTarget:self action:@selector(toggleSliderBG:) forControlEvents:UIControlEventValueChanged];
            [cell setAccessoryView:unlockSliderBGSwitch];
        }
        [[cell textLabel] setText:@"Unlock Slider Background"];
        UISwitch *swtch = (UISwitch*)cell.accessoryView;
        swtch.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"hasSliderBackground"];
        return cell;
    }
    if(!kIsIpad && indexPath.row==kBackgroundCell+2 ){
        static NSString *CellIdentifier = @"bgSliderCell";
        BGImageCell *cell = (BGImageCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[BGImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            UIButton *pickSliderColor = [CBThemeHelper createBlueUIButtonWithTitle:@"Pick Color" target:self action:@selector(pickSliderColor) frame:CGRectMake(0, 0, 100, 32)];
            [cell setAccessoryView:pickSliderColor];
            
        }
        [[cell textLabel] setText:@"Slider Background"];
        cell = [self setLSBackgroundColorForCell:cell];
        return cell;
    }
    if(kIsIpad && indexPath.row==kBackgroundCell+1 ){
        static NSString *CellIdentifier = @"switchCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[PrettyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            UISwitch *unlockSliderBGSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
            [unlockSliderBGSwitch addTarget:self action:@selector(toggleRotateWallpaper:) forControlEvents:UIControlEventValueChanged];
            [cell setAccessoryView:unlockSliderBGSwitch];
        }
        //rotateWallpaper
        [[cell textLabel] setText:@"Wallpaper Rotation"];
        UISwitch *swtch = (UISwitch*)cell.accessoryView;
        swtch.on = [[[NSUserDefaults standardUserDefaults] objectForKey:@"hasSliderBackground"] boolValue];
        
        return cell;
    }
    
    return cell;
}

-(void)lsBGColorFinishedPickingWithNote:(NSNotification *)note{
    
    UIColor *color = [UIColor colorWithRed:0 green:0 blue:0 alpha:.5];
    if(note){
        NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:[[note userInfo] objectForKey:@"color"]];
        [[NSUserDefaults standardUserDefaults] setObject:colorData forKey:@"sliderBGColor"];
        color =[NSKeyedUnarchiver unarchiveObjectWithData:colorData];
        UISwitch *st = (UISwitch *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:kBackgroundCell+1 inSection:0]].accessoryView;
        [st setOn:YES animated:YES];
        if([[NSUserDefaults standardUserDefaults] synchronize]){
            [self saveSliderBG];
        }
    }
    else{
        return;
    }
    
}

-(BGImageCell *)setLSBackgroundColorForCell:(BGImageCell *)cell{
    NSString *jbThemes = [self findThemesfolder];
    NSString *folderTarget = [NSString stringWithFormat:@"%@/Bundles/com.apple.TelephonyUI/",jbThemes];
    
    NSData *data = [NSData dataWithContentsOfFile:[folderTarget stringByAppendingString:@"bottombarbkgndlock@2x.png"]];
    
    if(data){
        UIImage *image = [UIImage imageWithData:data];
        CGRect cropRect = CGRectMake(0, 0, 50,50);
        CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
        [cell.imageView setImage:[UIImage imageWithCGImage:imageRef]];
        CGImageRelease(imageRef);
    }
    return cell;
}
-(void)completedSyncingSliderBG:(NSNotification *)note{
    if(note){
        NSNumber *n = [note object];
        BOOL b = [n boolValue];
        if(b){
            [[GMTHelper sharedInstance] showOverlay:@"Slider Background Updated" iconImage:nil];
        }
        else{
            [[GMTHelper sharedInstance] showOverlay:@"Failed to update slider" iconImage:[UIImage imageNamed:@"errorX"]];
        }
        [self.tableView reloadData];
    }
}
-(void)pickSliderColor{
    
    LSColorSliderPickerView *colorpicker = [[LSColorSliderPickerView alloc] initWithFrame:CGRectMake(0, 0, 320, 360)];
    
    UIColor *color = [UIColor colorWithRed:0 green:0 blue:0 alpha:.5];
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"sliderBGColor"]){
        color = (UIColor *)[NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"sliderBGColor"]];
    }
    
    NSLog(@"selected color: %@", color);
    
    [colorpicker activateInView:self.view withColor:color];
}

-(UIImage *)createSliderImage:(UIColor *)color{
    CGRect rect = CGRectMake(0, 0,  320, 94);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
-(UIImage *)createSliderImage2x:(UIColor *)color{
    CGRect rect = CGRectMake(0, 0,  640, 94*2);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
-(void)saveSliderBG{
    
    if(!gmt){
        gmt = [GMTThemeSync new];
    }
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        UIColor *color = [UIColor colorWithRed:0 green:0 blue:0 alpha:.5];
        UIImage *image;
        UIImage *image2x;
        if([[NSUserDefaults standardUserDefaults] boolForKey:@"hasSliderBackground"] && [[NSUserDefaults standardUserDefaults] objectForKey:@"sliderBGColor"]){
            
            NSData *colorData = [[NSUserDefaults standardUserDefaults] objectForKey:@"sliderBGColor"];
            color = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
            
        }
        image = [self createSliderImage:color];
        image2x = [self createSliderImage2x:color];
        
        NSString *tempDir = NSTemporaryDirectory();
        NSLog(@"%@",tempDir);
        NSData *data = UIImagePNGRepresentation(image);
        NSData *data2x = UIImagePNGRepresentation(image2x);
        NSString *targetName = @"bottombarbkgndlock.png";
        NSString *targetName2x = @"bottombarbkgndlock@2x.png";
        NSString *targetNameWell = @"BarBottomLock.png";
        NSString *targetNameWell2x = @"BarBottomLock@2x.png";
        NSString *origin = [tempDir stringByAppendingPathComponent:targetName];
        NSString *origin2x = [tempDir stringByAppendingPathComponent:targetName2x];
        NSString *originWell = [tempDir stringByAppendingPathComponent:targetNameWell];
        NSString *originWell2x = [tempDir stringByAppendingPathComponent:targetNameWell2x];
        BOOL syncComplete = NO;
        
        NSString *jbThemes = [self findThemesfolder];
        NSString *folderTarget = [NSString stringWithFormat:@"%@/Bundles/com.apple.TelephonyUI/",jbThemes];
        
        if([data writeToFile:origin atomically:YES] &&
           [data writeToFile:originWell atomically:YES]){
            syncComplete = [gmt syncFileAtPath:originWell toFolderAtPath:folderTarget];
            syncComplete = [gmt syncFileAtPath:origin toFolderAtPath:folderTarget];
        }
        if([data2x writeToFile:origin2x atomically:YES] &&
           [data2x writeToFile:originWell2x atomically:YES] &&
           syncComplete){
            syncComplete = [gmt syncFileAtPath:originWell2x toFolderAtPath:folderTarget];
            syncComplete = [gmt syncFileAtPath:origin2x toFolderAtPath:folderTarget];
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SyncCompleted" object:[NSNumber numberWithBool:syncComplete]];
        });
    });

}
-(void)toggleSliderBG:(id)sender{
    UISwitch *swtch = (UISwitch *)sender;
    
    [[NSUserDefaults standardUserDefaults] setBool:swtch.on forKey:@"hasSliderBackground"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self saveSliderBG];
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
    if(!kIsIpad && indexPath.row == kBackgroundCell + 2){
        [self pickSliderColor];
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
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
