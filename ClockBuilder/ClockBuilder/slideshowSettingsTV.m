//
//  slideshowSettingsTV.m
//  ClockBuilder
//
//  Created by gtadmin on 5/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "slideshowSettingsTV.h"
#import "PrettyCell.h"
#import "BGImageCell.h"
#import "ELCImagePickerController.h"
#import "ELCAlbumPickerController.h"
#import "slideShowImageSaverOperation.h"
#import "UIImage+Resize.h"

@implementation slideshowSettingsTV

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
        queue = [NSOperationQueue new];
        [queue addObserver:self forKeyPath:@"operations" options:0 context:NULL];
        [queue setMaxConcurrentOperationCount:1];
        // Custom initialization
        flipWasON = [[[NSUserDefaults standardUserDefaults] objectForKey:@"useSlideshow"] boolValue];
        [onOff setOn:flipWasON];
        onOff = [[UISwitch alloc] initWithFrame:CGRectZero];
        [onOff addTarget: self action: @selector(flip:) forControlEvents: UIControlEventValueChanged];
        onOff.center = CGPointMake(250, 32);
        slidesCount = [[[NSUserDefaults standardUserDefaults] objectForKey:@"slidesCount"] intValue];
        UIImageView *TVbgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"tvBG.jpg"]];
        [self.tableView setBackgroundView:TVbgView];
        [TVbgView release];
        
        UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tvFooterBG.png"]];
        [bg setContentMode:UIViewContentModeTopLeft];
        [self.tableView setTableFooterView:bg];
        [bg release];
        [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];    
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem;    
        

    }
    return self;
}

- (void)dealloc
{
    [queue release], queue = nil;
    [onOff release];
    [super dealloc];
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
    [self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.4];
}
-(void)disableSlideshow{
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"useSlideshow"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    slidesCount = 0;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:slidesCount] forKey:@"slidesCount"];
    [[NSUserDefaults standardUserDefaults] synchronize];   
    [self saveNewList:nil];
    [self.tableView reloadData];
    //build.js
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *buildJS = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"build" ofType:@"js"] encoding:NSUTF8StringEncoding error:nil] ;
    buildJS = [buildJS stringByReplacingOccurrencesOfString:@"var shouldShowSlideShow = true;" withString:@"var shouldShowSlideShow = false;"];
    NSString *buildJSTarget = [documentsDirectory stringByAppendingString:@"/lockscreen/build.js"];
    [buildJS writeToFile:buildJSTarget atomically:NO encoding:NSUTF8StringEncoding error:nil];
    NSInteger i = [[NSDate date] timeIntervalSince1970];
    NSString *html = [documentsDirectory stringByAppendingString:@"/lockscreen/LockBackground.html"];
    
    NSString *htmlTemplate = [NSString stringWithContentsOfFile:html encoding:NSUTF8StringEncoding error:nil];
    
    htmlTemplate = [htmlTemplate stringByReplacingOccurrencesOfString:@"build.js?6513543" withString:[NSString stringWithFormat:@"build.js?%i",i]];
    [htmlTemplate writeToFile:html atomically:NO encoding:NSUTF8StringEncoding error:nil];
    [htmlTemplate writeToFile:[documentsDirectory stringByAppendingString:@"/tethered/LockBackground.html"] atomically:NO encoding:NSUTF8StringEncoding error:nil];
}
- (IBAction) flip: (id) sender {
    if(!flipWasON)
    {
        //show image picker
        ELCAlbumPickerController *albumController = [[ELCAlbumPickerController alloc] initWithNibName:@"ELCAlbumPickerController" bundle:[NSBundle mainBundle]];    
        ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] initWithRootViewController:albumController];
        [albumController setParent:elcPicker];
        [elcPicker setDelegate:self];
        [self presentModalViewController:elcPicker animated:YES];
        [elcPicker release];
        [albumController release];
        
    }        
    else
    {
        [self disableSlideshow];
    }
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:onOff.on] forKey:@"useSlideshow"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    flipWasON = onOff.on;
    
}
- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info{
    slidesCount = [info count];
    [self showLoadingOverlay:[NSString stringWithFormat:@"Scaling %i Images", slidesCount]];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:slidesCount] forKey:@"slidesCount"];
    [[NSUserDefaults standardUserDefaults] synchronize];    
    if(slidesCount > 0)
    {
        dispatch_queue_t queued = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        dispatch_async(queued, ^{   
            int x = 1;     
            NSString *slideslist = @"";
            NSInteger i = [[NSDate date] timeIntervalSince1970];
            NSString *nowTimestamp = [NSString stringWithFormat:@"%i", i ]; 
            NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            for(NSDictionary *dict in info) {        
                UIImage *image = [dict objectForKey:UIImagePickerControllerOriginalImage];   
                NSString *path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/slide%i.jpg",x]];
                if(x<20)
                    path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/slide0%i.jpg",x]];
               // slideShowImageSaverOperation *op = [[slideShowImageSaverOperation alloc] initWithImage:image filePath:path];
               // [queue addOperation:op];
               // [op release];        
                
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

                
                 //UIImage *newImage = [image resizedImageWithContentMode:UIViewContentModeScaleToFill 
                 //bounds:CGSizeMake(640, 960) 
                 //interpolationQuality:kCGInterpolationHigh];
                 UIImage *thumb = [newImage resizedImageWithContentMode:UIViewContentModeScaleAspectFit 
                 bounds:CGSizeMake(50, 50) 
                 interpolationQuality:kCGInterpolationMedium];
                 
                 NSString *appFilePNG = path;
                 NSString *thumbpath = [appFilePNG stringByReplacingOccurrencesOfString:@".jpg" withString:@"_th.png"];
                 
                 NSData *newImageData =  UIImageJPEGRepresentation(newImage, 80);
                 
                 NSData *thumbData =  UIImageJPEGRepresentation(thumb, 80);
                 if([newImageData writeToFile:appFilePNG atomically:YES])
                 {                    
                     NSLog(@"image %@ saved", path);
                     [thumbData writeToFile:thumbpath atomically:YES];
                 }
                
                NSString *slideName = [NSString stringWithFormat:@"/slide%i.jpg", x];
                if(x<10)
                    slideName = [NSString stringWithFormat:@"/slide0%i.jpg", x];
                NSError *bgerr;
                NSString *symLink = [documentsDirectory stringByAppendingString:[NSString stringWithFormat:@"/lockscreen%@", slideName]];   
                [[NSFileManager defaultManager] createDirectoryAtPath:[[documentsDirectory stringByAppendingPathComponent:@"tethered"] stringByAppendingPathComponent:@"slides"] withIntermediateDirectories:NO attributes:nil error:nil];
                NSString *symLinkTethered = [documentsDirectory stringByAppendingString:[NSString stringWithFormat:@"/tethered/slides%@", slideName]]; 
                [newImageData writeToFile:symLinkTethered options:NSDataWritingFileProtectionNone error:nil];
                if(![newImageData writeToFile:symLink options:NSDataWritingFileProtectionNone error:&bgerr])
                {
                    NSLog(@"did not save image: %@", [bgerr localizedDescription]);
                }
                else
                {
                    NSLog(@"symlink: %@", symLink);                    
                }
                
                NSString *slideNum = [NSString stringWithFormat:@"%i",x];
                if(x<10)
                    slideNum = [NSString stringWithFormat:@"0%i", x];
                NSString *percents = [NSString stringWithFormat:@"%i%% %i%%", 1 + arc4random() % 100, 1+ arc4random() % 100];
                
                slideslist = [slideslist stringByAppendingFormat:@"slides/slide%@.jpg?%@, %@\n", slideNum, nowTimestamp, percents];
                
                x++;
            }
            NSLog(@"slidesList: %@", slideslist);
            //set slideindex.txt
            
            [slideslist writeToFile:[documentsDirectory stringByAppendingString:@"/lockscreen/slideindex.txt"] atomically:NO encoding:NSUTF8StringEncoding error:nil];
            
            //build.js
            NSString *buildJS = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"build" ofType:@"js"] encoding:NSUTF8StringEncoding error:nil] ;
            buildJS = [buildJS stringByReplacingOccurrencesOfString:@"var shouldShowSlideShow = false;" withString:@"var shouldShowSlideShow = true;"];
            NSString *buildJSTarget = [documentsDirectory stringByAppendingString:@"/lockscreen/build.js"];
            [buildJS writeToFile:buildJSTarget atomically:NO encoding:NSUTF8StringEncoding error:nil];
            
            NSString *html = [documentsDirectory stringByAppendingString:@"/lockscreen/LockBackground.html"];          
            NSString *htmlTemplate = [NSString stringWithContentsOfFile:html encoding:NSUTF8StringEncoding error:nil];
            htmlTemplate = [htmlTemplate stringByReplacingOccurrencesOfString:@"build.js?6513543" withString:[NSString stringWithFormat:@"build.js?%i",i]];
            [htmlTemplate writeToFile:html atomically:NO encoding:NSUTF8StringEncoding error:nil];
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                [loadingOverlay removeFromSuperview];
                [loadingOverlay release];
                [self.tableView reloadData];                
                //[self dismissModalViewControllerAnimated:YES];
            });

        });
    }
    else
        [self.tableView reloadData];
}
- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker{
	[self dismissModalViewControllerAnimated:YES];    
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(playclick)];
    //build.js
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *buildJS = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"build" ofType:@"js"] encoding:NSUTF8StringEncoding error:nil] ;
    buildJS = [buildJS stringByReplacingOccurrencesOfString:@"var shouldShowSlideShow = true;" withString:@"var shouldShowSlideShow = false;"];

    NSString *buildJSTarget = [documentsDirectory stringByAppendingString:@"/lockscreen/build.js"];
    [buildJS writeToFile:buildJSTarget atomically:NO encoding:NSUTF8StringEncoding error:nil];
    
    NSInteger i = [[NSDate date] timeIntervalSince1970];
    NSString *html = [documentsDirectory stringByAppendingString:@"/lockscreen/LockBackground.html"];
    
    NSString *htmlTemplate = [NSString stringWithContentsOfFile:html encoding:NSUTF8StringEncoding error:nil];

    htmlTemplate = [htmlTemplate stringByReplacingOccurrencesOfString:@"build.js?6513543" withString:[NSString stringWithFormat:@"build.js?%i",i]];
    [htmlTemplate writeToFile:html atomically:NO encoding:NSUTF8StringEncoding error:nil];
    
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
	label.textAlignment = UITextAlignmentCenter;
	label.opaque = NO;
	[label setFont:[UIFont fontWithName:@"Helvetica" size:20]];
	[loader addSubview:label];
	[loadingOverlay addSubview:loader];
	[[[UIApplication sharedApplication] keyWindow] addSubview:loadingOverlay];
    
    [loader release];
    [av release];
    [label release];
    
}

-(void)removeLoadingOverlay
{
	[loadingOverlay removeFromSuperview];
	[loadingOverlay release];
    [self.tableView reloadData];
    
}
- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object 
                         change:(NSDictionary *)change context:(void *)context
{
    if (object == queue && [keyPath isEqualToString:@"operations"]) {
        if ([queue.operations count] == 0) {
            // Do something here when your queue has completed
            NSLog(@"queue has completed");
            [self performSelectorOnMainThread:@selector(removeLoadingOverlay) withObject:nil waitUntilDone:NO];
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object 
                               change:change context:context];
    }
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
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
    NSLog(@"view did unload");
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

- (NSArray *)getSlidesArray
{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    //[self disableSlideshow];
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isdir;
    if([fm fileExistsAtPath:[documentsDirectory stringByAppendingString:@"/lockscreen/slideindex.txt"] isDirectory:&isdir]){
        if(!isdir){
            
            NSString* fileContents = [NSString stringWithContentsOfFile:[documentsDirectory stringByAppendingString:@"/lockscreen/slideindex.txt"] 
                                                               encoding:NSUTF8StringEncoding error:nil];
            
            // first, separate by new line
            NSMutableArray* allLinedStrings = [[fileContents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] mutableCopy];
            [allLinedStrings removeLastObject];
            NSArray *retArray = [NSArray arrayWithArray:allLinedStrings];
            [allLinedStrings release];
            return retArray;
        }
    }
    return [NSArray new];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0)
        return @"Slideshow Toggle";
    else
        return @"Slideshow Images";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
        return 1;
    return [[self getSlidesArray] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64;//self.view.window.screen.scale * 64;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.section==0){
        static NSString *CellIdentifier = @"switchCell";        
        PrettyCell *cell = (PrettyCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[PrettyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];            
            [cell addSubview:onOff];                        
        }
        [[cell textLabel] setText:@"Enable Slideshow"];
        return cell;
    }
    else
    {
        
        static NSString *CellIdentifier = @"slidesCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[BGImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        
        NSArray *list = [self getSlidesArray];
        NSString *item = [list objectAtIndex:indexPath.row];
        // slides/slide04.jpg?1304365725, 7% 67%
        item = [item stringByReplacingOccurrencesOfString:@"slides/slide" withString:@""];
        item = [item substringToIndex:2];        
        [[cell textLabel] setText:[NSString stringWithFormat:@"Slide %i", indexPath.row + 1 ]];
        if(indexPath.row + 1<10)
            [[cell textLabel] setText:[NSString stringWithFormat:@"Slide 0%i", indexPath.row + 1 ]];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *appFilePNG = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/slide%@_th.png", item]];
        UIImage *bgImage = [UIImage imageWithContentsOfFile:appFilePNG];
        cell.imageView.image = bgImage;
        if(bgImage==nil)
        {
            cell.imageView.image = [UIImage imageNamed:@"LockBackgroundThumb.png"];
        }
        return cell;        
    }
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    if(indexPath.section != 0)
        return YES;
    else
        return NO;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        NSLog(@"strings array original: %@",[self getSlidesArray]);    
        
        NSMutableArray *list = [[self getSlidesArray] mutableCopy];
        [list removeObjectAtIndex:indexPath.row];
        
        NSLog(@"strings array NEW: %@",list);
        [self saveNewList:[NSArray arrayWithArray:list]];
        
        [list release];        
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView endUpdates];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    //swap image data
    // read everything from text
    NSLog(@"strings array original: %@",[self getSlidesArray]);    
    
    NSMutableArray *list = [[self getSlidesArray] mutableCopy];
    NSString *temp = [list objectAtIndex:fromIndexPath.row];
    [list removeObject:temp];
    [list insertObject:temp atIndex:toIndexPath.row];
    
    NSLog(@"strings array NEW: %@",list);
    [self saveNewList:[NSArray arrayWithArray:list]];
    
    [list release];
    
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    if(indexPath.section == 0)
        return NO;
    return YES;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

@end
