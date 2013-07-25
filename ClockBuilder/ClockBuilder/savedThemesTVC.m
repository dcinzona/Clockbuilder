//
//  savedThemesTVC.m
//  ClockBuilder
//
//  Created by gtadmin on 4/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "savedThemesTVC.h"
#import <QuartzCore/QuartzCore.h>
#import "instructionsForTheme.h"
#import "savedThemesCell.h"
#import "SDImageCache.h"
#import "ThemeUploader.h"
#import "ClockBuilderAppDelegate.h"
#import "CoreDataController.h"
#import "UIImage+Resize.h"


@interface savedThemesTVC ()
{
    MBProgressHUD *HUD;
}


@end


@implementation savedThemesTVC

@synthesize pickerItems, pickerType, pickerView,pickerAS;
@synthesize cancelBlock = _cancelBlock;
@synthesize closeBlock = _closeBlock;
@synthesize uploadOperation = _uploadOperation;
@synthesize fetchedResultsController;
@synthesize managedObjectContext = _managedObjectContext;


#pragma mark -
#pragma mark Notifications
- (void)persistentStoresDidChange:(NSNotification *)aNotification
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    NSError *anyError = nil;
    BOOL success = [[self fetchedResultsController] performFetch:&anyError];
    if( !success ) {
        NSLog(@"Error fetching: %@", anyError);
    }
    [[self tableView] reloadData];
}


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.managedObjectContext = ApplicationDelegate.managedObjectContext;//ApplicationDelegate.coreDataController.mainThreadContext;
        th = [themeConverter new];
        if(!kIsiOS7){
            UIImageView *bg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, [UIScreen mainScreen].bounds.size.height)];
            [bg setImage:[UIImage imageNamed:@"tableGradient"]];
            [bg setContentMode:UIViewContentModeTop];
            UIView *bgView = [[UIView alloc] initWithFrame:self.view.frame];
            [self.tableView setBackgroundView:bgView];
            [bgView addSubview:bg];
            UIColor *tableBGColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"office"]];
            [bgView setBackgroundColor:tableBGColor];
            [self.tableView setBackgroundColor:tableBGColor];
        }
        //[self.tableView setBackgroundColor:[UIColor clearColor]];
        
        
        [self.tableView setSeparatorColor:[UIColor clearColor]];
        [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];        
        [self.tableView setPagingEnabled:NO];//[[[NSUserDefaults standardUserDefaults] objectForKey:@"pagingEnabled"] boolValue]];
        [self.tableView setBounces:YES];
        
        syncingView = [[UIView alloc] initWithFrame:CGRectMake(0, -30, 320, 40)];
        
        
        activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [activityIndicator setFrame:CGRectMake(160-21/2, 0, 21, 21)];
        [activityIndicator setHidesWhenStopped:NO];
        [activityIndicator startAnimating];
        [syncingView addSubview:activityIndicator];
        
        UILabel *syncLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 23, 320, 18)];
        [syncLabel setTextAlignment:NSTextAlignmentCenter];
        [syncLabel setText:@"Syncing with Dropbox"];
        [syncLabel setTextColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:.7]];
        [syncLabel setFont:[UIFont fontWithName:@"Helvetica" size:12]];
        [syncLabel setBackgroundColor:[UIColor clearColor]];
        
        [syncingView addSubview:syncLabel];
        
        
        //[self.view addSubview:syncingView];
        
        [self resetNavBarItems];
    }
    return self;
}

//////////////////////////////////////////////////////
#pragma mark - View lifecycle
//////////////////////////////////////////////////////

- (void)reloadFetchedResults:(NSNotification *)note {
    dispatch_async(dispatch_get_main_queue(), ^{
        // we can now allow for inserting new names and editing
        [self fetchFromCoreData];
    });
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (kIsIpad) {
        if(!kIsiOS7){
            self.contentSizeForViewInPopover = kPopoverSize;
        }
        else{
            self.preferredContentSize = kPopoverSize;
        }
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud hide:YES afterDelay:15];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    

    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    activityIndicator = nil;
}

-(void)viewWillAppear:(BOOL)animated{
    //NSLog(@"SAVED THEMES VIEW WILL APPEAR");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishedConvertingDocuments) name:@"finishedConvertingDocumentsToCoreData" object:nil];
    //completedUploadingTheme
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(completedUploadingTheme:) name:@"completedUploadingTheme" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(activityDecreasedToZero) name:@"DBSyncActivityChanged" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(persistentStoresDidChange:) name:NSPersistentStoreCoordinatorStoresDidChangeNotification object:[[self managedObjectContext] persistentStoreCoordinator]];
    
    [self checkDropboxActivity];
    

}
-(void)viewWillDisappear:(BOOL)animated{
    //NSLog(@"SAVED THEMES VIEW DISAPPEAR");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"finishedConvertingDocumentsToCoreData" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DBSyncActivityChanged" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"completedUploadingTheme" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSPersistentStoreCoordinatorStoresDidChangeNotification object:[[self managedObjectContext] persistentStoreCoordinator]];
    
}

-(void)checkDropboxActivity{
    /*
    if([[DBSession sharedSession] isLinked] && [AppDelegate isDropboxSyncing]){
        [syncingView setAlpha:1];
        [self.tableView setContentInset:UIEdgeInsetsMake(50, 0, 0, 0)];
    }
    else{
        [syncingView setAlpha:0];
        [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
        if(kIsiOS7){
            self.tableView.contentInset = UIEdgeInsetsMake(64, 0, self.navigationController.navigationBar.frame.size.height, 0);
            self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(64, 0, self.navigationController.navigationBar.frame.size.height, 0);
        }
    }
    */
}

-(void)activityDecreasedToZero{
    /*
    if([AppDelegate isDropboxSyncing]){
        [syncingView setAlpha:1];
        [self.tableView setContentInset:UIEdgeInsetsMake(50, 0, 0, 0)];
    }
    else{
        [UIView animateWithDuration:.2 animations:^{
            [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
            if(kIsiOS7){
                self.tableView.contentInset = UIEdgeInsetsMake(64, 0, self.navigationController.navigationBar.frame.size.height, 0);
                self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(64, 0, self.navigationController.navigationBar.frame.size.height, 0);
            }
            [syncingView setAlpha:0];
        } completion:^(BOOL finished) {
            
        }];
    }
    */
    
}

-(void)finishedConvertingDocuments{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    converting = NO;
    [self reloadFetchedResults:nil];
}

-(BOOL)fetchFromCoreData{
    
    BOOL fetch = YES;
    //NSLog(@"fetchFromCoreDATA");
    
    //CHECK IF DEDUPING
    if(fetch){
        
        if(!fetching){
            
            fetching = YES;
            NSError *error = nil;
            
            if (self.fetchedResultsController != nil) {
                
                if (![[self fetchedResultsController] performFetch:&error]) {
                    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    fetching = NO;
                }
                else {
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    [self.tableView reloadData];
                    fetching = NO;
                }
            }
            
            fetching = NO;
        }

    }
    /*
    else{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"Syncing...";
        [hud hide:YES afterDelay:10];
    }*/
    
    return fetch;
}

-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    BOOL processedLocalThemesAlready = [[NSUserDefaults standardUserDefaults] boolForKey:@"processedThemesToCoreData"];
    
    NSURL *url = [CBThemeHelper getThemesPath];
    NSError *errorGettingThemes;
    NSArray *arrayOfThemeURLs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:url.path error:&errorGettingThemes];
    
    if(!processedLocalThemesAlready || YES){
        //process local themes
        if(arrayOfThemeURLs.count>0 && !converting){
            converting = YES;
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.contentMode = MBProgressHUDModeText;
            hud.labelText = @"Updating";
            [hud hide:YES afterDelay:10];
            [CBThemeHelper converAllThemesInDocumentsToCoreData];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"processedThemesToCoreData"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    
    
    if(![self fetchFromCoreData]){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchFromCoreData) name:kFinishedDeduping object:nil];
    }    
    
    
    //THEME PROCESSING    
}
//////////////////////////////////////////////////////
#pragma mark NOTIFICATION CENTER STUFF
//////////////////////////////////////////////////////
-(void)completedUploadingTheme:(NSNotification*)notification{

    [[GMTHelper sharedInstance] notifyToShowGlobalHudWithDict:[[GMTHelper sharedInstance] 
                                                              buildDictForHUDWithLabelText:@"Theme Uploaded!" 
                                                              andImage:nil 
                                                              andHide:YES 
                                                            withDelay:1
                                                            andDim:NO] 
     ];
}
-(void)refreshThemesDisplayed{
    selectedThemeName = nil;
    selectedCellIndex = nil;
    if([CBThemeHelper isIOS5] && [CBThemeHelper isCloudEnabled]){
        HUD = ApplicationDelegate.globalHUD;
        HUD.labelText = @"Syncing with iCloud";
        HUD.dimBackground = YES;
        HUD.mode = MBProgressHUDModeIndeterminate;
        HUD.animationType = MBProgressHUDAnimationFade;
        //[HUD showWhileExecuting:@selector(getThemesListAndReloadData) onTarget:self withObject:nil animated:YES];
        [HUD hide:YES afterDelay:10];
    }
}
-(void)refreshTableData{
    
    //[self getThemesList];
    selectedThemeName = nil;
    selectedCellIndex = nil;
    //[self getThemesListAndReloadData];
    NSLog(@"refreshTableData");
    
}
-(void)showOnlineThemes{
    
    gridViewController *gv = [[gridViewController alloc] init];
    [gv setDelegate:self];
    [self.navigationController pushViewController:gv animated:YES];
    
}

-(void) exitModal
{
    [[[UIApplication sharedApplication]delegate]performSelector:@selector(goBackToRootView)];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    NSLog(@"did receive memory warning (SAVED THEMES)");
    if(!kIsiOS7){
        UIImageView *bg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, [UIScreen mainScreen].bounds.size.height)];
        [bg setImage:[UIImage imageNamed:@"tableGradient"]];
        [bg setContentMode:UIViewContentModeTop];
        UIView *bgView = [[UIView alloc] initWithFrame:self.view.frame];
        [self.tableView setBackgroundView:bgView];
        [bgView addSubview:bg];
        UIColor *tableBGColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"office"]];
        [bgView setBackgroundColor:tableBGColor];
        [self.tableView setBackgroundColor:tableBGColor];
    }
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    // Release any cached data, images, etc that aren't in use.
    [[SDImageCache sharedImageCache] clearMemory];
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


-(NSMutableDictionary *)getSelectedThemeDict{
    
    if(selectedCellIndex){
        
        CoreTheme *managedObject = [fetchedResultsController objectAtIndexPath:selectedCellIndex];
        return managedObject.themeDictData;
    }
    return nil;
}

#pragma mark - Table view data source

- (void)configureCell:(savedThemesCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    CoreTheme *managedObject = [fetchedResultsController objectAtIndexPath:indexPath];
    if(managedObject.themeDictData){
        [cell setCellDictData:managedObject.themeDictData];
    }
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[fetchedResultsController fetchedObjects] count];//[themesArray count];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 342;//372;//self.view.window.screen.bounds.size.height;//self.view.window.screen.scale * 64;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    savedThemesCell *cell = (savedThemesCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[savedThemesCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    /*
    // Configure the cell...
    NSFileManager *fm = [NSFileManager defaultManager];
    if([fm fileExistsAtPath:[CBThemeHelper getThemePathForName:[themesArray objectAtIndex:indexPath.row]].path])
        [cell setCellData:[themesArray objectAtIndex:indexPath.row]];
    
    */
    
    return cell;
}


#pragma mark - Table view delegate

-(CoreTheme *)getSelectedCoreTheme{
    CoreTheme *theme;
    if(selectedCellIndex){
        theme = [fetchedResultsController objectAtIndexPath:selectedCellIndex];
    }
    return theme;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedCellIndex = nil;
    selectedCellIndex = indexPath;
    //selectedThemeName = [self getSelectedCoreTheme].themeName;//[themesArray objectAtIndex:selectedCellIndex.row];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if(!_pickerVisible && !_actionSheetVisible){
        _actionSheetVisible = YES;
        [self performSelector:@selector(showActionsheet)];
    }
}


-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    NSLog(@"done deleting");
}

#pragma mark -
#pragma mark Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (fetchedResultsController != nil) {
        return fetchedResultsController;
    }
    
    // Set up the fetched results controller
    //
    // Create the fetch request for the entity
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CoreTheme"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number
    //[fetchRequest setFetchBatchSize:20];
    
    
    NSSortDescriptor *saveDateSortDesc = [[NSSortDescriptor alloc] initWithKey:@"saveDate" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:saveDateSortDesc, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController *aFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:self.managedObjectContext
                                          sectionNameKeyPath:nil
                                                   cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    
    return fetchedResultsController;
} 

#pragma mark -
#pragma mark Fetched results controller delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:(savedThemesCell*)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

/*
 // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
 {
 // In the simplest, most efficient, case, reload the table view.
 [self.tableView reloadData];
 }
 */



#pragma mark Save/Delete Methods

-(void)deleteThemeFromCoreData{
    
    // Delete the managed object for the given index path
    NSManagedObjectContext *context = [fetchedResultsController managedObjectContext];
    
    CoreTheme *objToDelete = [fetchedResultsController objectAtIndexPath:selectedCellIndex];
    NSString *delURI = [objToDelete.objectID URIRepresentation].absoluteString;
    NSString *activeURI = [[NSUserDefaults standardUserDefaults] objectForKey:kActiveThemeCoreDataIDKey];
    if(activeURI && [activeURI isEqualToString:delURI]){
        //deleting currently active theme - 
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kActiveThemeCoreDataIDKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
    
    [context deleteObject:objToDelete];
    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        //abort();
    }
}
UIImage * resizeImage(UIImage * img, CGSize newSize){
    UIGraphicsBeginImageContext(newSize);
    
    //or other CGInterpolationQuality value
    CGContextSetInterpolationQuality(UIGraphicsGetCurrentContext(), kCGInterpolationDefault);
    
    [img drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
-(void)makeThemeActiveAtIndexPath:(NSIndexPath *)indexPath{
    
    CoreTheme *managedObject = [fetchedResultsController objectAtIndexPath:indexPath];
    NSMutableDictionary *themeDict = managedObject.themeDictData;
    if(themeDict){
        if(kIsIpad){
            [[GMTHelper sharedInstance] notifyToShowGlobalHudWithSpinner:@"Activating Theme" andHide:YES withDelay:15 andDim:NO];
            //[[GMTHelper sharedInstance] notifyToShowGlobalHudWithSpinner:@"Activating Theme" andHide:YES withDelay:15 andDim:NO];
        }
        dispatch_queue_t queue = dispatch_queue_create("com.gmtaz.clockbuilder.sync", 0ul);//dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        dispatch_async(queue, ^{
            NSString *objID = managedObject.recordUUID;//[[[managedObject objectID] URIRepresentation] absoluteString];
            //NSLog(@"objectID: %@",objID);
            
            [[NSUserDefaults standardUserDefaults] setObject:objID forKey:kActiveThemeCoreDataIDKey];
            
            //NSLog(@"activating: %@", managedObject);
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSArray *widgetsList = [themeDict objectForKey:@"widgetsList"];
            NSMutableDictionary *sets = [[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"] mutableCopy]; 
            if(!sets)
                sets = [NSMutableDictionary new];
            
            [sets setObject:widgetsList forKey:@"widgetsList"];
            [[NSUserDefaults standardUserDefaults] setObject:sets forKey:@"settings"];    
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            //background image
            NSData *background = [themeDict objectForKey:@"LockBackground.png"];
            if(background!=nil){
                /*NSString *appFilePNG = [documentsDirectory stringByAppendingPathComponent:@"LockBackground.png"];*/
                if(kIsIpad){
                    
                    UIImage *bg2x = [UIImage imageWithData:background];
                    
                    [[GMTHelper sharedInstance] resizeImageToBackground:bg2x];
                    
                }
                else{
                    UIImage *image = [UIImage imageWithData:background];
                    NSLog(@"image size height: %f",image.size.height);
                    [[GMTHelper sharedInstance] resizeImageToBackground:image];
                                    }
            }
            //background thumb
            NSData *backgroundThumb = [themeDict objectForKey:@"LockBackgroundThumb.png"];
            if(backgroundThumb!=nil){
                NSString *appFilePNGThumb = [documentsDirectory stringByAppendingPathComponent:@"LockBackgroundThumb.png"];
                if(![backgroundThumb writeToFile:appFilePNGThumb atomically:YES]){
                    
                }
                if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
                    if ((NSInteger)[[UIScreen mainScreen] scale] == 2) {
                        
                        UIImage *image = [UIImage imageWithData:backgroundThumb];
                        if(image.size.width < 100){
                            UIImage *thumb = [CBThemeHelper getThumbForBG:[UIImage imageWithData:background]];
                            backgroundThumb = UIImagePNGRepresentation(thumb);
                        }
                        appFilePNGThumb = [documentsDirectory stringByAppendingPathComponent:@"LockBackgroundThumb@2x.png"];
                        if([backgroundThumb writeToFile:appFilePNGThumb atomically:YES])
                        {
                        }
                    }
                }
            }
            else if(background!=nil){
                //make thumb from bg
                UIImage *image = [UIImage imageWithData:background];
                NSString *appFilePNGThumb = [documentsDirectory stringByAppendingPathComponent:@"LockBackgroundThumb.png"];
                UIImage *thumb = [CBThemeHelper getThumbForBG:image];
                NSData *backgroundThumb = UIImagePNGRepresentation(thumb);
                [backgroundThumb writeToFile:appFilePNGThumb atomically:YES];
                if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
                    if ((NSInteger)[[UIScreen mainScreen] scale] == 2) {
                        appFilePNGThumb = [documentsDirectory stringByAppendingPathComponent:@"LockBackgroundThumb@2x.png"];
                        if([backgroundThumb writeToFile:appFilePNGThumb atomically:YES])
                        {
                        }
                    }
                }
                [themeDict setObject:backgroundThumb forKey:@"LockBackgroundThumb.png"];
            }
            
            [[[UIApplication sharedApplication]delegate]performSelector:@selector(activateTheme:) withObject:widgetsList];

        });
    }
    else {
        NSLog(@"unable to load themeDict");
    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        NSString *textFieldString = @"";
        for(UIView *subview in [alertView subviews])
        {
            if([subview class]==[UITextField class])
            {
                textFieldString = [(UITextField*)subview text];                                            
            }
        }
        
        if([title isEqualToString:@"Delete"])
        {
            [self performSelector:@selector(removePiece)];
        }
        else if([title isEqualToString:@"How?"])
        {
            [self showInstructions];
            
        }
        else if([title isEqualToString:@"Upload"])
        {
            [[GMTHelper sharedInstance] alertWithString:@"Shouldnt see this"];
            //[self performSelector:@selector(saveToCloud)];
        }
        else if([title isEqualToString:@"Rename"])
        {
            NSString *fieldVal = textFieldString;
            NSLog(@"text: %@", textFieldString);
            if(fieldVal != nil && ![fieldVal isEqualToString:@""]) {
                [self performSelector:@selector(renameTheme:) withObject:fieldVal];
            }
            else
            {
                [MKEntryPanel showPanelWithTitle:@"Rename Theme" inView:self.view onTextEntered:^(NSString *inputString) {
                    [self performSelector:@selector(renameTheme:) withObject:inputString];
                }];
            }
        }
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

-(void)saveToLockscreenFromCoreData{
    
    NSMutableDictionary *themeDict = [self getSelectedThemeDict];
    [th runFromCoreData:@"NO" withDict:themeDict];
    /*
    dispatch_sync(dispatch_get_main_queue(), ^(void) {
        //[TestFlight passCheckpoint:[NSString stringWithFormat:@"Run: theme is NOT installed - WeatherOnly: %@", weatherOnly]];
        [[GMTHelper sharedInstance] alertWithString:@"You must activate this theme and set it as your lockscreen from theme editor."];
    });
     */
}

-(void)showInstructions
{
    instructionsForTheme *instructions = [[instructionsForTheme alloc] initWithNibName:@"instructionsForTheme" bundle:[NSBundle mainBundle]];
    
    [self.navigationController pushViewController:instructions animated:YES];
    
};



#pragma mark - remove methods

// animate back to the default anchor point and transform
- (void)removePiece
{
    [self deleteThemeFromCoreData];
}




#pragma mark - Actions

-(void)showSocialActionSheet
{
    
}


-(void)showActionsheet
{

    UIActionSheet *actionButtonSheet;
    if([th checkIfJB])
    {
        
        actionButtonSheet = [[UIActionSheet alloc] initWithTitle:@"Theme Actions"
                                                        delegate:self
                                               cancelButtonTitle:@"Cancel"
                                          destructiveButtonTitle:@"Delete Theme"
                                               otherButtonTitles:@"Activate Theme", @"Email",@"Upload",@"Set as Lockscreen", nil];
    }
    else
    {
        actionButtonSheet = [[UIActionSheet alloc] initWithTitle:@"Theme Actions"
                                                        delegate:self
                                               cancelButtonTitle:@"Cancel"
                                          destructiveButtonTitle:@"Delete Theme"
                                               otherButtonTitles:@"Activate Theme",@"Email",@"Upload", nil];
    }
    
    
    [actionButtonSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    if(kIsIpad){
        [actionButtonSheet showInView:ApplicationDelegate.window.rootViewController.view];
    }
    else{
        [actionButtonSheet showInView:self.view];
    }
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"Delete Theme"])
    {
        CustomAlertView *alert = [[CustomAlertView alloc] initWithTitle:@"Confirm" message:@"Are you sure you want to delete this theme?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
        [alert show];
    }
    if([title isEqualToString:@"Activate Theme"])
    {
        [self makeThemeActiveAtIndexPath:selectedCellIndex];
    }
    if([title isEqualToString:@"Rename Theme"])
    {
        [MKEntryPanel showPanelWithTitle:@"Rename Theme" inView:self.view onTextEntered:^(NSString *inputString) {
            [self performSelector:@selector(renameTheme:) withObject:inputString];
        }];
    }
    if([title isEqualToString:@"Upload"])
    {    
        if(![[NSUserDefaults standardUserDefaults] boolForKey:@"blocked"]){
            [actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];

            NSArray *categoriesArray = [NSArray arrayWithArray:[[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"] objectForKey:@"categoriesArray"]];
            if(categoriesArray!=nil && categoriesArray.count > 0){
                _pickerVisible = YES;
                [self showCategoriesPickerWithCloseBlock:^(NSString *inputString) {
                    
                    _pickerVisible = NO;
                    
                    NSString *category = inputString;
                    
                    HUD = [MBProgressHUD showHUDAddedTo:self.view
                                                              animated:YES];
                    HUD.animationType = MBProgressHUDAnimationZoom;
                    HUD.labelText = @"Upload Started...";
                    HUD.mode = MBProgressHUDModeText;
                    [HUD hide:YES afterDelay:1];
                    CoreTheme *managedObject = [fetchedResultsController objectAtIndexPath:selectedCellIndex];
                    NSMutableDictionary *themeDict = managedObject.themeDictData;
                    self.uploadOperation = [ApplicationDelegate.engine uploadThemeDict:themeDict forCategory:category onCompletionBlock:^(NSString *inputString) {
                        NSLog(@"upload completed %@", inputString);
                        NSString *selectedCategory = [[NSUserDefaults standardUserDefaults] objectForKey:@"onlineThemesArrayCategory"];
                        if ([category isEqualToString:selectedCategory]) {
                            //clear onlineThemesArray
                            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"onlineThemesArray"];
                        }
                        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:selectedCategory forKey:@"category"];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"completedUploadingTheme" object:nil userInfo:userInfo];
                        
                    } andOnError:^(NSString *inputString) {
                        NSLog(@"error uploading %@", inputString);
                    }];
                   
                    
                } andCancelBlock:^{
                    _pickerVisible = NO;
                    //[[GMTHelper sharedInstance] alertWithString:@"A category is required to upload your theme"];
                }];
            }
        }
        else {
            [[GMTHelper sharedInstance] alertWithString:@"Your device has been blocked due to inappropriate theme uploads."];
        }

    }
    if([title isEqualToString:@"Set as Lockscreen"])
    {
        [self saveToLockscreenFromCoreData];
    }
    if([title isEqualToString:@"Email"])
    {
        [self performSelector:@selector(composeEmailToShareTheme)];
    }
    _actionSheetVisible = NO;
}


- (void)composeEmailToShareTheme
{
        
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	
	[picker setSubject:@"I sent you my ClockBuilder theme"];
	
    NSData *attachment;
    NSDictionary *theme = [self getSelectedThemeDict];
    if(theme){
        attachment = [NSKeyedArchiver archivedDataWithRootObject:theme];
        
        [picker addAttachmentData:attachment mimeType:@"application/com.gmtaz.clockbuilder.theme" fileName:@"MyTheme.cbTheme"];
        
        // Fill out the email body text
        NSString *emailBody = @"I'm sharing a Clockbuilder theme with you.  You must have <a href=\"http://itunes.apple.com/us/app/clock-builder/id429716375?ls=1&mt=8\">Clockbuilder</a> version 1.6.3 or greater to view it.";
        [picker setMessageBody:emailBody isHTML:YES];
        
        
        if(picker)
            [self presentViewController:picker animated:YES completion:nil];
        else{
            [[GMTHelper sharedInstance] alertWithString:@"Email window failed to display - Do you have an email account configured?"];
        }
    }
    else{
        [[GMTHelper sharedInstance] alertWithString:@"Error getting theme data"];
    }
    
    
}


// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{	
    //NSLog(@"email result: %@",result);
	[self dismissViewControllerAnimated:YES completion:nil];
}

-(void)setNavBarItemsForPicker{
    
    UIBarButtonItem *cancelBtn = [CBThemeHelper createBlueButtonItemWithTitle:@"Cancel" target:self action:@selector(dismissActionSheet)];
    UIBarButtonItem *doneBtn = [CBThemeHelper createBlueButtonItemWithTitle:@"Upload" target:self action:@selector(saveActionSheet)];
    self.navigationItem.leftBarButtonItem = cancelBtn;
    self.navigationItem.rightBarButtonItem = doneBtn;
    [self setTitle:@"Select Category"];
}

-(void)resetNavBarItems{
    
    UIBarButtonItem *doneButton = [CBThemeHelper createDoneButtonItemWithTitle:@"Done" target:self action:@selector(exitModal)];
    self.navigationItem.leftBarButtonItem = doneButton;
    UIBarButtonItem *bb = [CBThemeHelper createFontAwesomeBlueBarButtonItemWithIcon:@"icon-globe" target:self action:@selector(showOnlineThemes)];
    self.navigationItem.rightBarButtonItem = bb;
    
    [self setTitle:@"Saved Themes"];
    _pickerVisible = NO;
}


-(void)showCategoriesPickerWithCloseBlock:(CloseBlock)cb andCancelBlock:(CancelBlock)cancel{
    self.closeBlock = cb;
    self.cancelBlock = cancel;
    if(kIsiOS7){
        CGRect pickerFrame = CGRectMake(0, self.view.frame.size.height, 320, 400);
        if(!pickerView){
            pickerView = [[UIPickerView alloc] initWithFrame:pickerFrame];
            pickerView.dataSource = self;
            pickerView.delegate = self;
            [pickerView setShowsSelectionIndicator:YES];
            [pickerView selectRow:0 inComponent:0 animated:NO];
        }
        [CBThemeHelper showPicker:pickerView aboveUITableView:self.tableView onCompletion:^{
            [self setNavBarItemsForPicker];
        }];
    }
    else{
        CGRect pickerFrame = CGRectMake(0, 0, 320, 400);
        if(!pickerView){
            pickerView = [[UIPickerView alloc] initWithFrame:pickerFrame];
            pickerView.dataSource = self;
            pickerView.delegate = self;
            [pickerView setShowsSelectionIndicator:YES];
            [pickerView selectRow:0 inComponent:0 animated:NO];
        }
        pickerAS = [[UIActionSheet alloc] initWithTitle:@"Select Category" delegate:self cancelButtonTitle:@"cancel" destructiveButtonTitle:nil otherButtonTitles:nil];
        [pickerAS addSubview:pickerView];
            UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        if (!kIsIpad)
            [toolbar sizeToFit];
        [CBThemeHelper setBackgroundImage:nil forToolbar:toolbar];
        NSMutableArray *barItems = [[NSMutableArray alloc] init];
        UIBarButtonItem *cancelBtn = [CBThemeHelper createBlueButtonItemWithTitle:@"Cancel" target:self action:@selector(dismissActionSheet)];
        UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];  
        UIBarButtonItem *doneBtn = [CBThemeHelper createBlueButtonItemWithTitle:@"Done" target:self action:@selector(saveActionSheet)];
        UILabel *titleLabel = [[UILabel alloc] init];
        [titleLabel setText:@"Select Category"];
        [titleLabel setFrame:CGRectMake(0, 0, 150, 22)];
        [titleLabel setTextAlignment:NSTextAlignmentCenter];
        if(!kIsiOS7){
            [titleLabel setTextColor:[UIColor whiteColor]];
            [titleLabel setShadowColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:.5]];
            [titleLabel setShadowOffset:CGSizeMake(0, -1.0)];
        }
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        UIBarButtonItem *titleItem = [[UIBarButtonItem alloc] initWithCustomView:titleLabel];
        [titleItem setStyle:UIBarButtonItemStylePlain];
        [barItems addObject:cancelBtn];
        [barItems addObject:flexSpace];  
        [barItems addObject:titleItem];
        [barItems addObject:flexSpace];
        [barItems addObject:doneBtn];
        [toolbar setItems:barItems animated:YES];
        [pickerAS addSubview:toolbar];
        [pickerAS showInView:self.view];
        [pickerAS setBounds:CGRectMake(0,0,320, 408)];
        
    }
}
-(void)dismissActionSheet{
    if(pickerAS)
        [pickerAS dismissWithClickedButtonIndex:0 animated:YES];
    [CBThemeHelper dismissPicker:pickerView fromUITableView:self.tableView onCompletion:^{
        self.cancelBlock();
        pickerAS = nil;
        pickerView = nil;
        [self resetNavBarItems];
    }];
}


-(void)saveActionSheet{
    if(pickerAS)
        [pickerAS dismissWithClickedButtonIndex:1 animated:YES];
    
    [CBThemeHelper dismissPicker:pickerView fromUITableView:self.tableView onCompletion:^{
        NSUInteger selectedRow = [pickerView selectedRowInComponent:0];
        NSArray *list = [NSArray arrayWithArray:[[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"] objectForKey:@"categoriesArray"]];
        NSString *selected = [list objectAtIndex:selectedRow];
        self.closeBlock(selected);
        pickerAS = nil;
        pickerView = nil;
        [self resetNavBarItems];
    }];
    
}

#pragma mark Picker DataSource

- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    return [[NSArray arrayWithArray:[[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"] objectForKey:@"categoriesArray"]] count];
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    NSArray *list = [NSArray arrayWithArray:[[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"] objectForKey:@"categoriesArray"]];
    return [[list objectAtIndex:row] capitalizedString];
}

- (UIView *)pickerView:(UIPickerView *)pv viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label = (UILabel*) view;
    if (label == nil)
    {
        label = [[UILabel alloc] init];
    }
    NSArray *list = [NSArray arrayWithArray:[[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"] objectForKey:@"categoriesArray"]];
    [label setText:[[list objectAtIndex:row] capitalizedString]];
    [label setShadowColor:[UIColor whiteColor]];
    [label setShadowOffset:CGSizeMake(1, 1)];
    
    // This part just colorizes everything, since you asked about that.
    [label setTextColor:[UIColor blackColor]];
    [label setTextAlignment:NSTextAlignmentCenter];
    if(kIsiOS7){
        [label setFont:[UIFont systemFontOfSize:16]];
    }
    //if([pickerType isEqualToString:@"locations"] && row == 0)
    //   [label setTextColor:[UIColor colorWithRed:.3 green:.3 blue:1.0 alpha:1.0]];
    
    [label setBackgroundColor:[UIColor clearColor]];
    CGSize rowSize = [pv rowSizeForComponent:component];
    CGRect labelRect = CGRectMake (10, 0, rowSize.width-20, rowSize.height);
    [label setFrame:labelRect];
    
    return label;
}
- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
}


- (NSManagedObjectContext *)getManagedObjectContext{
    NSManagedObjectContext *context = [fetchedResultsController managedObjectContext];
    return context;
}
- (void)gridViewController:(gridViewController *)controller didFinishWithSave:(BOOL)save{
    /*
    NSManagedObjectContext *context = [fetchedResultsController managedObjectContext];
    [context performBlock:^{
        // merging changes causes the fetched results controller to update its results
        NSError *error = nil;
        if (NO == [self.fetchedResultsController performFetch:&error]) {
            NSLog(@"Fetch error: %@", error);
        }
        [self.tableView reloadData];
    }];
     */
}



@end
