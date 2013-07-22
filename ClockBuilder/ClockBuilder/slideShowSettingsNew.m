//
//  slideShowSettingsNew.m
//  ClockBuilder
//
//  Created by Gustavo Tandeciarz on 5/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "slideShowSettingsNew.h"
#import "PrettyCell.h"
#import "BGImageCell.h"
#import "UIImage+Resize.h"

@implementation slideShowSettingsNew


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        // Custom initialization
        onOff = [[UISwitch alloc] initWithFrame:CGRectZero];
        BOOL flipWasON = [[[NSUserDefaults standardUserDefaults] objectForKey:@"useSlideshow"] boolValue];
        [onOff setOn:flipWasON];
        [onOff addTarget: self action: @selector(toggleSlideShow:) forControlEvents: UIControlEventValueChanged];
        onOff.center = CGPointMake(250, 32);
        
        UIImageView *TVbgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"fadedBG.JPG"]];
        [self.tableView setBackgroundView:TVbgView];
        
        UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tvFooterBG.png"]];
        [bg setContentMode:UIViewContentModeTopLeft];
        [self.tableView setTableFooterView:bg];
        [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];    
        
        
        UIBarButtonItem *backButton = [CBThemeHelper createBackButtonItemWithTitle:@"Settings" target:self.navigationController action:@selector(popViewControllerAnimated:)];
        //[self.navigationItem setBackBarButtonItem:backButton];
        [self.navigationItem setLeftBarButtonItem: backButton];
        
        [self.navigationItem setRightBarButtonItem:[CBThemeHelper createDarkButtonItemWithTitle:@"Edit" target:self action:@selector(EditTable:)]];
        
        arry = [[self getSlidesArray]mutableCopy];
        
        imagePicker = [[UIImagePickerController alloc] init];
        [imagePicker setDelegate:self];
        
        if (kIsIpad) {
            self.contentSizeForViewInPopover = kPopoverSize;
        }
        
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
-(void)disableSlideshow{
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"useSlideshow"];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *buildJS = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"build" ofType:@"js"] encoding:NSUTF8StringEncoding error:nil] ;
    buildJS = [buildJS stringByReplacingOccurrencesOfString:@"var shouldShowSlideShow = true;" withString:@"var shouldShowSlideShow = false;"];
    
    NSString *buildJSTarget = [documentsDirectory stringByAppendingString:@"/lockscreen/build.js"];
    [buildJS writeToFile:buildJSTarget atomically:NO encoding:NSUTF8StringEncoding error:nil];
    buildJSTarget = [documentsDirectory stringByAppendingString:@"/tethered/build.js"];
    [buildJS writeToFile:buildJSTarget atomically:NO encoding:NSUTF8StringEncoding error:nil];
    NSInteger i = [[NSDate date] timeIntervalSince1970];
    NSString *html = [documentsDirectory stringByAppendingString:@"/lockscreen/LockBackground.html"];
    NSString *htmlTemplate = [NSString stringWithContentsOfFile:html encoding:NSUTF8StringEncoding error:nil];
    
    htmlTemplate = [htmlTemplate stringByReplacingOccurrencesOfString:@"build.js?6513543" withString:[NSString stringWithFormat:@"build.js?%i",i]];
    [htmlTemplate writeToFile:html atomically:NO encoding:NSUTF8StringEncoding error:nil];
    html = [documentsDirectory stringByAppendingString:@"/tethered/LockBackground.html"];
    [htmlTemplate writeToFile:html atomically:NO encoding:NSUTF8StringEncoding error:nil];
    
    
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}
-(IBAction)toggleSlideShow: (id*)sender
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:onOff.on] forKey:@"useSlideshow"];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *buildJS = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"build" ofType:@"js"] encoding:NSUTF8StringEncoding error:nil] ;
    if(!onOff.on)
        buildJS = [buildJS stringByReplacingOccurrencesOfString:@"var shouldShowSlideShow = true;" withString:@"var shouldShowSlideShow = false;"];
    else{
        buildJS = [buildJS stringByReplacingOccurrencesOfString:@"var shouldShowSlideShow = false;" withString:@"var shouldShowSlideShow = true;"];
		[super setEditing:YES animated:YES]; 
		[self.tableView setEditing:YES animated:YES];
		[self.tableView reloadData];
		[self.navigationItem.rightBarButtonItem setTitle:@"Done"];
		[self.navigationItem.rightBarButtonItem setStyle:UIBarButtonItemStyleDone];
    }
        
    NSString *buildJSTarget = [documentsDirectory stringByAppendingString:@"/lockscreen/build.js"];
    [buildJS writeToFile:buildJSTarget atomically:NO encoding:NSUTF8StringEncoding error:nil];
    buildJSTarget = [documentsDirectory stringByAppendingString:@"/tethered/build.js"];
    [buildJS writeToFile:buildJSTarget atomically:NO encoding:NSUTF8StringEncoding error:nil];
    NSInteger i = [[NSDate date] timeIntervalSince1970];
    NSString *html = [documentsDirectory stringByAppendingString:@"/lockscreen/LockBackground.html"];
    NSString *htmlTemplate = [NSString stringWithContentsOfFile:html encoding:NSUTF8StringEncoding error:nil];
    
    htmlTemplate = [htmlTemplate stringByReplacingOccurrencesOfString:@"build.js?6513543" withString:[NSString stringWithFormat:@"build.js?%i",i]];
    [htmlTemplate writeToFile:html atomically:NO encoding:NSUTF8StringEncoding error:nil];
    html = [documentsDirectory stringByAppendingString:@"/tethered/LockBackground.html"];
    [htmlTemplate writeToFile:html atomically:NO encoding:NSUTF8StringEncoding error:nil];
    
    
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)showLoadingOverlay:(NSString *)message{
	
    
    loadingOverlay = [[UIView alloc] init];	
    [loadingOverlay setFrame:[[UIScreen mainScreen] applicationFrame]];
    loadingOverlay.opaque = NO;
    loadingOverlay.backgroundColor = [UIColor clearColor];
    CGRect loaderFrame =CGRectMake(loadingOverlay.center.x - 100, loadingOverlay.center.y - 80, 200, 160);
    // CGRectMake(loadingOverlay.center.x - 50, loadingOverlay.center.y - 40, 100, 80);
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        if ((NSInteger)[[UIScreen mainScreen] scale] == 2) {
            loaderFrame = CGRectMake(loadingOverlay.center.x - 100, loadingOverlay.center.y - 80, 200, 160);
        }
    }
	UIView *loader = [[UIView alloc] initWithFrame:loaderFrame];
	[loader setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.7f]];
	if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
		if ((NSInteger)[[UIScreen mainScreen] scale] == 2) {
			loader.layer.cornerRadius = 30;
		}
		else {
			loader.layer.cornerRadius = 15;
		}
        
	}
	UIActivityIndicatorView  *av = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	av.frame=CGRectMake(loader.frame.size.width/2 - 20, loader.frame.size.height/2 -40, 40, 40);
	av.tag  = 1;
	[loader addSubview:av];
	[av startAnimating];
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, loader.frame.size.height/2 +20, loader.frame.size.width, 30)];
	label.text = message;
	label.textColor = [UIColor whiteColor];
	label.backgroundColor = [UIColor clearColor];
	label.textAlignment = NSTextAlignmentCenter;
	label.opaque = NO;
	[label setFont:[UIFont fontWithName:@"Helvetica" size:20]];
	[loader addSubview:label];
	[loadingOverlay addSubview:loader];
    
	[[[UIApplication sharedApplication] keyWindow] addSubview:loadingOverlay];
}
-(void)removeLoadingOverlay
{
	[loadingOverlay removeFromSuperview];
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.tableView reloadData];
}

- (NSArray *)getSlidesArray
{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* fileContents = [NSString stringWithContentsOfFile:[documentsDirectory stringByAppendingString:@"/lockscreen/slideindex.txt"] 
                                                       encoding:NSUTF8StringEncoding error:nil];
    
    // first, separate by new line
    if(fileContents==nil || [fileContents isEqualToString:@""]){
        fileContents = [NSString stringWithContentsOfFile:[documentsDirectory stringByAppendingString:@"/tethered/slideindex.txt"] 
                                                 encoding:NSUTF8StringEncoding error:nil];
    }
    NSMutableArray* allLinedStrings = [[fileContents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] mutableCopy];
    [allLinedStrings removeLastObject];
    NSArray *retArray = [NSArray arrayWithArray:allLinedStrings];
    return retArray;
}

-(void)saveNewList:(NSArray *)list
{
    NSString *strToWr = @"";
    for(NSString *item in list)
    {
        strToWr = [strToWr stringByAppendingFormat:@"%@\n",item];
    } 
    if([strToWr isEqualToString:@""])
        [onOff setOn:NO animated:YES];
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    [strToWr writeToFile:[documentsDirectory stringByAppendingString:@"/lockscreen/slideindex.txt"] atomically:NO encoding:NSUTF8StringEncoding error:nil];
    [strToWr writeToFile:[documentsDirectory stringByAppendingString:@"/tethered/slideindex.txt"] atomically:NO encoding:NSUTF8StringEncoding error:nil];
    [arry removeAllObjects];
    arry = [[self getSlidesArray] mutableCopy];
    NSLog(@"arry: %@", arry);
    [self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.7];
}
-(NSString *)getFirstAvailableNumber
{
    NSMutableArray *numbers = [NSMutableArray new];
    for(int x = 0; x<10; x++)
    {
        [numbers addObject:[NSString stringWithFormat:@"0%i", x+1]];
    }
    for(__strong NSString *arrayItem in arry)
    {
        arrayItem = [arrayItem stringByReplacingOccurrencesOfString:@"slides/slide" withString:@""];
        arrayItem = [arrayItem substringToIndex:2];        
        [numbers removeObject:arrayItem];
    }  
    return [numbers objectAtIndex:0];
    
}

#pragma mark - ACTIONS

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	// Dismiss the image selection and close the program
    
    [self dismissViewControllerAnimated:YES completion:nil];
	//exit(0);
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    [self showLoadingOverlay:@"Scaling Image"];
    
    dispatch_queue_t queued = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(queued, ^{   
        NSString *slide = [self getFirstAvailableNumber];
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/slide%@.jpg",slide]];
        NSString *slideName = [NSString stringWithFormat:@"/slide%@.jpg", slide];
        NSString *slideNum = slide;
    
        UIImage *sourceImage = image;
        UIImage *newImage = nil;        
        CGSize imageSize = sourceImage.size;
        CGSize targetSize = CGSizeMake(320, 480);
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
            if ((NSInteger)[[UIScreen mainScreen] scale] == 2) {
                targetSize = CGSizeMake(640, 960);
            }
        }
        CGFloat width = imageSize.width;
        CGFloat height = imageSize.height;
        CGFloat targetWidth = targetSize.width;
        CGFloat targetHeight = targetSize.height;
        CGFloat scaleFactor = 0.0;
        CGFloat scaledWidth = targetWidth;
        CGFloat scaledHeight = targetHeight;
        CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
        
        if (CGSizeEqualToSize(imageSize, targetSize) == NO) 
        {
            CGFloat widthFactor = targetWidth / width;
            CGFloat heightFactor = targetHeight / height;
            
            if (widthFactor > heightFactor) 
                scaleFactor = widthFactor; // scale to fit height
            else
                scaleFactor = heightFactor; // scale to fit width
            scaledWidth  = width * scaleFactor;
            scaledHeight = height * scaleFactor;
            
            // center the image
            if (widthFactor > heightFactor)
            {
                thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5; 
            }
            else 
                if (widthFactor < heightFactor)
                {
                    thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
                }
        }       
        
        UIGraphicsBeginImageContext(targetSize); // this will crop
        
        CGRect thumbnailRect = CGRectZero;
        thumbnailRect.origin = thumbnailPoint;
        thumbnailRect.size.width  = scaledWidth;
        thumbnailRect.size.height = scaledHeight;
        
        [sourceImage drawInRect:thumbnailRect];
        
        newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIImage *thumb = [newImage resizedImageWithContentMode:UIViewContentModeScaleAspectFit 
                                                        bounds:CGSizeMake(50, 50) 
                                          interpolationQuality:kCGInterpolationMedium];
        
        NSString *appFilePNG = path;
        NSString *thumbpath = [appFilePNG stringByReplacingOccurrencesOfString:@".jpg" withString:@"_th.png"];
        
        NSData *newImageData =  UIImageJPEGRepresentation(newImage, 80);
        
        NSData *thumbData =  UIImageJPEGRepresentation(thumb, 80);
        if([newImageData writeToFile:appFilePNG atomically:YES])
        {                    
            [thumbData writeToFile:thumbpath atomically:YES];
        }
        
        NSError *bgerr;
        NSString *symLink = [documentsDirectory stringByAppendingString:[NSString stringWithFormat:@"/lockscreen%@", slideName]];                
        if(![newImageData writeToFile:symLink options:NSDataWritingFileProtectionNone error:&bgerr])
        {
            NSLog(@"did not save image: %@", [bgerr localizedDescription]);
        }
        symLink = [documentsDirectory stringByAppendingString:[NSString stringWithFormat:@"/tethered%@", slideName]];                
        if(![newImageData writeToFile:symLink options:NSDataWritingFileProtectionNone error:&bgerr])
        {
            NSLog(@"did not save image: %@", [bgerr localizedDescription]);
        }
        
        
        NSString *percents = [NSString stringWithFormat:@"%i%% %i%%", 1 + arc4random() % 100, 1+ arc4random() % 100];
        
        NSInteger i = [[NSDate date] timeIntervalSince1970];
        NSString *nowTimestamp = [NSString stringWithFormat:@"%i", i ]; 
        NSMutableArray *list = [arry mutableCopy];
        [list addObject:[NSString stringWithFormat:@"slides/slide%@.jpg?%@, %@", slideNum, nowTimestamp, percents]];
        NSLog(@"list: %@", list);
        [self saveNewList:list];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self removeLoadingOverlay];
        });
        
    });

    
}

- (IBAction) EditTable:(id)sender
{
	if(self.editing)
	{
		[super setEditing:NO animated:NO]; 
		[self.tableView setEditing:NO animated:NO];
		[self.tableView reloadData];
		[self.navigationItem.rightBarButtonItem setTitle:@"Edit"];
		[self.navigationItem.rightBarButtonItem setStyle:UIBarButtonItemStylePlain];
	}
	else
	{
		[super setEditing:YES animated:YES]; 
		[self.tableView setEditing:YES animated:YES];
		[self.tableView reloadData];
		[self.navigationItem.rightBarButtonItem setTitle:@"Done"];
		[self.navigationItem.rightBarButtonItem setStyle:UIBarButtonItemStyleDone];
	}
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if(!self.editing){
        if([[self getSlidesArray] count]<1){
            [self disableSlideshow];
        }
        NSLog(@"view will disappear");
    }
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section==0)
        return 1;
    else{
        int count = [arry count];
        NSLog(@"count: %i", count);
        if(self.editing) count++;
        return count;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64;//self.view.window.screen.scale * 64;
}
// The editing style for a row is the kind of button displayed to the left of the cell when in editing mode.
- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    // No editing style if not editing or the index path is nil.
    if (self.editing == NO || !indexPath || indexPath.section==0) return UITableViewCellEditingStyleNone;
    // Determine the editing style based on whether the cell is a placeholder for adding content or already 
    // existing content. Existing content can be deleted.    
    if (self.editing && indexPath.row == ([arry count])) 
	{
		return UITableViewCellEditingStyleInsert;
	} else 
	{
		return UITableViewCellEditingStyleDelete;
	}
    return UITableViewCellEditingStyleNone;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.section==0){
        static NSString *CellIdentifier = @"switchCell";        
        PrettyCell *cell = (PrettyCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[PrettyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];            
            [cell addSubview:onOff];                        
        }
        [[cell textLabel] setText:@"Enable Slideshow"];
        return cell;
    }
    else
    {
        // Configure the cell...
        
        int count = 0;
        if(self.editing && indexPath.row != 0)
            count = 1;
        
        
        // Set up the cell...
        if(indexPath.row == ([arry count]) && self.editing)
        {
            static NSString *CellIdentifier = @"addCell";
            PrettyCell *cell = (PrettyCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[PrettyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            
            cell.textLabel.text = @"Add Image";
            return cell;
        }
        else
        {            
            static NSString *CellIdentifier = @"slidesCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[BGImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            NSArray *items = [self getSlidesArray];
            NSString *arrayItem = [items objectAtIndex:indexPath.row];
            arrayItem = [arrayItem stringByReplacingOccurrencesOfString:@"slides/slide" withString:@""];
            arrayItem = [arrayItem substringToIndex:2];        
            [[cell textLabel] setText:[NSString stringWithFormat:@"Slide %i", indexPath.row + 1 ]];
            if(indexPath.row + 1<10)
                [[cell textLabel] setText:[NSString stringWithFormat:@"Slide 0%i", indexPath.row + 1 ]];
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *appFilePNG = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/slide%@_th.png", arrayItem]];
            UIImage *bgImage = [UIImage imageWithContentsOfFile:appFilePNG];
            cell.imageView.image = bgImage;
            if(bgImage==nil)
            {
                cell.imageView.image = [UIImage imageNamed:@"LockBackgroundThumb.png"];
            }
            return cell;    
        }
    }    
    return nil;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
        return NO;
       // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	
    if (editingStyle == UITableViewCellEditingStyleDelete) 
	{
        
        NSMutableArray *list = [[self getSlidesArray] mutableCopy];
        [list removeObjectAtIndex:indexPath.row];
        
        [self saveNewList:[NSArray arrayWithArray:list]];
        
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView endUpdates];

        
    } else if (editingStyle == UITableViewCellEditingStyleInsert)
	{
        if([arry count]<10)
            [self presentViewController:imagePicker animated:YES completion:nil];
        else
        {
            CustomAlertView *alert = [[CustomAlertView alloc] initWithTitle:@"Max Slides Reached" message:@"" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
        }
    } 
}


- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    NSMutableArray *list = [[self getSlidesArray] mutableCopy];
    NSString *temp = [list objectAtIndex:fromIndexPath.row];
    [list removeObject:temp];
    [list insertObject:temp atIndex:toIndexPath.row];
    [self saveNewList:[NSArray arrayWithArray:list]];
    
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
        return NO;
    if(indexPath.row == [arry count])
        return NO;
    return YES;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section==1 && indexPath.row == [arry count])
        [self presentViewController:imagePicker animated:YES completion:nil];
}

@end
