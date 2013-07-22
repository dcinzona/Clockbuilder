//
//  weatherSettingsIndex.m
//  ClockBuilder
//
//  Created by gtadmin on 3/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "weatherSettingsIndex.h"
#import "BGImageCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation weatherSettingsIndex
@synthesize SelectedCell, 
slider, 
pickerAS,
picker,
textField,
onOff,
placesArray,
loadingIndicator,
showDegree,
monitorInBG;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        if(weatherData == nil)
            weatherData = [[weatherSingleton sharedInstance] getWeatherData];
        //NSLog(@"weathersettings weather data: %@",weatherData);
            //self.placesArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"dealloc");
    self.SelectedCell = nil;
    self.slider = nil;
    self.pickerAS = nil;
    self.picker = nil;
    self.textField = nil;
    self.placesArray = nil;
    self.loadingIndicator = nil;
    self.onOff = nil;
    self.monitorInBG = nil;
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
    _valid = YES;
    
    if (kIsIpad) {
        self.contentSizeForViewInPopover = kPopoverSize;
    }
    
    [self setTitle:@"Weather Settings"];
    
  //[self.navigationController.navigationBar setBarStyle:UIBarStyleBlackOpaque];
    self.textField = [[UITextField alloc] initWithFrame:CGRectMake(140, 22, 160, 22)];
    [self.textField setBackgroundColor:[UIColor clearColor]];
    [self.textField setTextColor:[UIColor whiteColor]];
    [self.textField setDelegate:self];
    [self.textField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self.textField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [self.textField setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.0]];
    [self.textField setTextColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:.9]];
    [self.textField setKeyboardType:UIKeyboardTypeDefault];
    [self.textField setReturnKeyType:UIReturnKeyDone];
    [self.textField setClearButtonMode:UITextFieldViewModeWhileEditing];
    self.textField.placeholder = @"Current Location";
    [self.textField setTextAlignment:UITextAlignmentRight];
    
    /*
    UIImageView *TVbgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"fadedBG.JPG"]];
    [self.tableView setBackgroundView:TVbgView];
     */
    if(!kIsiOS7){
        UIImageView *bg2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, [UIScreen mainScreen].bounds.size.height)];
        [bg2 setImage:[UIImage imageNamed:@"tableGradient"]];
        [bg2 setContentMode:UIViewContentModeTop];
        UIView *bgView = [[UIView alloc] initWithFrame:self.view.frame];
        [self.tableView setBackgroundView:bgView];
        [bgView addSubview:bg2];
        UIColor *tableBGColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"office"]];
        [bgView setBackgroundColor:tableBGColor];
        [self.tableView setBackgroundColor:tableBGColor];
        
        UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tvFooterBG.png"]];
        [bg setContentMode:UIViewContentModeTopLeft];
        [self.tableView setTableFooterView:bg];
        [self.tableView setSectionFooterHeight:0];
    }
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    self.loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [self.loadingIndicator setFrame:CGRectMake(120, 23, 20, 20)];
    
    self.onOff = [[UISwitch alloc] initWithFrame:CGRectZero];
    [self.onOff setOn:[[weatherData objectForKey:@"useWindchill"] boolValue]];
    [self.onOff addTarget: self action: @selector(flip:) forControlEvents: UIControlEventValueChanged];
    self.onOff.center = CGPointMake(self.tableView.frame.size.width - (onOff.frame.size.width/2) - 10, 32);
    //showDegree
    self.showDegree = [[UISwitch alloc] initWithFrame:CGRectZero];
    [self.showDegree setOn:[[weatherData objectForKey:@"showDegreeSymbol"] boolValue]];
    [self.showDegree addTarget: self action: @selector(setDegreeShow:) forControlEvents: UIControlEventValueChanged];
    self.showDegree.center = CGPointMake(self.tableView.frame.size.width - (showDegree.frame.size.width/2) - 10, 32);
    
    self.monitorInBG = [[UISwitch alloc] initWithFrame:CGRectZero];
    [self.monitorInBG setOn:[[weatherData objectForKey:@"monitorInBackground"] boolValue]];
    [self.monitorInBG addTarget: self action: @selector(setMonitoring:) forControlEvents: UIControlEventValueChanged];
    self.monitorInBG.center = CGPointMake(self.tableView.frame.size.width - (monitorInBG.frame.size.width/2) - 10, 32);
    
    [weatherData setObject:[NSNumber numberWithBool:NO] forKey:@"monitorInBackground"];
    
    if(!kIsIpad){
        [self.navigationItem setLeftBarButtonItem: [CBThemeHelper createBackButtonItemWithTitle:@"Settings" target:self.navigationController action:@selector(popViewControllerAnimated:)]];
    }
    
}
- (IBAction) setMonitoring: (id) sender {
    //NSLog(@"%@", self.onOff.on ? @"On" : @"Off");
    
    [weatherData setObject:[NSNumber numberWithBool:self.monitorInBG.on] forKey:@"monitorInBackground"];
    
}
- (IBAction) setDegreeShow: (id) sender {
    //NSLog(@"%@", self.onOff.on ? @"On" : @"Off");
    
    [weatherData setObject:[NSNumber numberWithBool:self.showDegree.on] forKey:@"showDegreeSymbol"];
    
}
- (IBAction) flip: (id) sender {
    //NSLog(@"%@", self.onOff.on ? @"On" : @"Off");
    
    [weatherData setObject:[NSNumber numberWithBool:self.onOff.on] forKey:@"useWindchill"];
    
}
- (void) saveWeatherData
{
    //[[[UIApplication sharedApplication] delegate] performSelector:@selector(saveWeatherSettings:) withObject:weatherData];
    [[weatherSingleton sharedInstance] saveWeatherDataWithDictionary:weatherData];
}

-(void)refreshWeatherConfig{
    weatherData = [[weatherSingleton sharedInstance] getWeatherData];   
    [self.loadingIndicator stopAnimating];
    [self.tableView reloadData];
}

- (void)viewDidUnload
{
    NSLog(@"view did unload");
    [super viewDidUnload];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //errorGettingLocation
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(errorGettingLocation:) name:@"errorGettingLocation" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cantGeoLocate) name:@"cantGeoLocate" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshWeatherConfig) name:@"weatherDataChanged" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshWeatherConfig) name:@"weatherConfigurationSaved" object:nil];
}
-(void)cantGeoLocate{
    [self.loadingIndicator stopAnimating];
}
-(void)errorGettingLocation:(NSNotification *)note{
    NSError *error = [[note userInfo] objectForKey:@"error"];
    [self cantGeoLocate];
    CustomAlertView *alert = [[CustomAlertView alloc] initWithTitle:@"Error Getting Location" 
                                                            message:[NSString stringWithFormat:@"Error: %@", error.localizedDescription] 
                                                           delegate:nil 
                                                  cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    
    _valid = NO;    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"cantGeoLocate" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"errorGettingLocation" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"weatherDataChanged" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"weatherConfigurationSaved" object:nil];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[weatherSingleton sharedInstance] updateWeatherData];
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
    return 6;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64;//self.view.window.screen.scale * 64;
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
    
    //cell 1 = location
    if(indexPath.row==0){
        static NSString *CellIdentifier = @"Cell";    
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[PrettyCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        [[cell textLabel] setText:@"Location:"];
        [[cell detailTextLabel] setText:[weatherData objectForKey:@"location"]];
        [self.textField setText:[weatherData objectForKey:@"locationName"]];
        if(kIsiOS7){
            [self.textField setTextColor:[UIColor darkGrayColor]];
        }
        if ([[cell subviews] indexOfObject:self.textField]==NSNotFound) {
            [cell addSubview:self.textField];
        }
        if ([[cell subviews] indexOfObject:self.loadingIndicator]==NSNotFound) {
            [cell addSubview:self.loadingIndicator];
        }
        //[self.loadingIndicator startAnimating];
        return cell;
    }
    //cell 2 = refresh interval
    if(indexPath.row==1){
        static NSString *CellIdentifier = @"Cell";    
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[PrettyCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        [[cell textLabel] setText:@"Weather Refresh Rate:"];
        [[cell detailTextLabel] setText:[self getFriendlyIntervalName]];   
        [self addCellAccessory:cell];
        return cell;
    }
    
    
    
    //cell 3 = temperature units
    if(indexPath.row==2){
        static NSString *CellIdentifier = @"Cell";    
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[PrettyCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        [[cell textLabel] setText:@"Temperature Units:"];
        [[cell detailTextLabel] setText:[self getFriendlyTemperatureName]]; 
        [self addCellAccessory:cell];
        return cell;
    }
    
    //cell 4 = use windchill
    if(indexPath.row==3){
        static NSString *CellIdentifier = @"Cell";    
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[PrettyCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        [[cell textLabel] setText:@"Use Windchill:"];
        [[cell detailTextLabel] setText:@"Only affects current temp"];        
        if ([[cell subviews] indexOfObject:self.onOff]==NSNotFound) {
            [cell addSubview:self.onOff];
        }
        return cell;
    }
    if(indexPath.row==4){
        static NSString *CellIdentifier = @"Cell";    
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[PrettyCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        [[cell textLabel] setText:@"Show Degree Symbol:"];      
        if ([[cell subviews] indexOfObject:self.showDegree]==NSNotFound) {
            [cell addSubview:self.showDegree];
        }
        return cell;
    }
    if(indexPath.row==5)
    {
        static NSString *CellIdentifier = @"CellBG";    
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[BGImageCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        
        [[cell textLabel] setText:@"Weather Icon Set"];
        [[cell detailTextLabel] setText:[weatherData objectForKey:@"weatherIconSet"]];
        NSString *iconSet = [weatherData objectForKey:@"weatherIconSet"];
        if(iconSet == nil || [iconSet isEqualToString:@""])
        {
            iconSet = @"Tick";
        }
        [cell.imageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@.png",[iconSet lowercaseString]]]];
        [cell.imageView.layer setBorderWidth:0.0];
        [cell setSelected:NO];
        return cell;
    }
    
    return nil;
    
}


- (NSString *)getFriendlyTemperatureName
{
    NSString *retVal = @"Fahrenheit";
    
    if([[[weatherData objectForKey:@"units"] lowercaseString]isEqualToString:@"c"])
    {
        retVal = @"Celsius";
    }
    
    return retVal;
}

- (NSString *)getFriendlyIntervalName
{
    NSLog(@"weather Interval: %@",[weatherData objectForKey:@"interval"]);
    switch ([[weatherData objectForKey:@"interval"] intValue]) {
        case 60:
            return @"1 Minute";
            break;
        case 300:
            return @"5 Minutes";
            break;
        case 600:
            return @"10 Minutes";
            break;
        case 1800:
            return @"30 Minutes";
            break;
        case 3600:
            return @"1 Hour";
            break;
        case 6000:
            return @"1 Hour 40 Minutes";
            break;
        case 43200:
            return @"12 Hours";
            break;
            
        default:
            break;
    }
    return [NSString stringWithFormat:@"%d",(int)[weatherData objectForKey:@"interval"]];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    isTyping=YES;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.SelectedCell = indexPath;
    NSLog(@"isTyping: %i", isTyping);
    if(indexPath.row==0){
        [self.textField becomeFirstResponder];
        [self.tableView deselectRowAtIndexPath:self.SelectedCell animated:YES];        
    }
    if(indexPath.row==1){
        if(!isTyping)
            [self showIntervalPicker];
        else
            [self.tableView deselectRowAtIndexPath:self.SelectedCell animated:NO];
    }
    if(indexPath.row==2){
        if(!isTyping)
            [self showTemperatureUnitsPicker];
        else
            [self.tableView deselectRowAtIndexPath:self.SelectedCell animated:NO];
    }
    if(indexPath.row==3)
        [self.tableView deselectRowAtIndexPath:self.SelectedCell animated:YES];    
    if(indexPath.row==4)
        [self.tableView deselectRowAtIndexPath:self.SelectedCell animated:YES];  
    if(indexPath.row==5)
    {
        if(!isTyping)
            [self showIconSetPicker];
        else
            [self.tableView deselectRowAtIndexPath:self.SelectedCell animated:NO];
    }
}

#pragma mark Picker Actions


-(void) addToolbarToPicker:(NSString *)title
{
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    if(!kIsIpad)
        [toolbar sizeToFit];
    [CBThemeHelper setBackgroundImage:nil forToolbar:toolbar];
    NSMutableArray *barItems = [[NSMutableArray alloc] init];
    UIBarButtonItem *cancelBtn = [CBThemeHelper createDarkButtonItemWithTitle:@"Cancel" target:self action:@selector(dismissActionSheet)];
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];  
    UIBarButtonItem *doneBtn = [CBThemeHelper createBlueButtonItemWithTitle:@"Done" target:self action:@selector(saveActionSheet)];
    UILabel *titleLabel = [[UILabel alloc] init];
    [titleLabel setText:title];
    [titleLabel setShadowColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:.5]];
    [titleLabel setShadowOffset:CGSizeMake(0, -1.0)];
    [titleLabel setFrame:CGRectMake(0, 0, 150, 22)];
    [titleLabel setTextAlignment:UITextAlignmentCenter];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    
    
    if(kIsiOS7){
        [titleLabel setTextColor:[UIColor darkGrayColor]];
        [titleLabel setShadowColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0]];
        [self.pickerAS setBackgroundColor:[UIColor whiteColor]];
        [toolbar setTintColor:nil];
    }
    
    UIBarButtonItem *titleItem = [[UIBarButtonItem alloc] initWithCustomView:titleLabel];
    [titleItem setStyle:UIBarButtonItemStylePlain];
    [barItems addObject:cancelBtn];
    [barItems addObject:flexSpace];  
    [barItems addObject:titleItem];
    [barItems addObject:flexSpace];
    [barItems addObject:doneBtn];
    [toolbar setItems:barItems animated:YES];
    [self.pickerAS addSubview:toolbar];    
    [self.pickerAS addSubview:self.picker.pickerView];
    if(kIsIpad){
        [self.pickerAS showInView:self.view];
    }
    else{
        [self.pickerAS showInView:[self.view superview]];
    }
    [self.pickerAS setBounds:CGRectMake(0,0,320, 408)];
}
-(void)actionSheetCancel:(UIActionSheet *)actionSheet{
    
    [self.pickerAS dismissWithClickedButtonIndex:0 animated:YES];
    _pickerVisible = NO;
    self.picker = nil;
    self.pickerAS = nil;
    [[self.tableView cellForRowAtIndexPath:self.SelectedCell] setSelected:NO animated:YES];
    self.SelectedCell = nil;
}
-(void)dismissActionSheet{
    [self.pickerAS dismissWithClickedButtonIndex:0 animated:YES];
    _pickerVisible = NO;
    self.picker = nil;
    self.pickerAS = nil;
    [[self.tableView cellForRowAtIndexPath:self.SelectedCell] setSelected:NO animated:YES];
    self.SelectedCell = nil;
}
-(void)saveActionSheet{
    [self.pickerAS dismissWithClickedButtonIndex:1 animated:YES];
    _pickerVisible = NO;
    NSUInteger selectedRow = [self.picker.pickerView selectedRowInComponent:0];
    NSLog(@"weather data to be saved: %@", weatherData);
    if([self.picker.pickerType isEqualToString:@"refreshInteval"]){
        switch (selectedRow) {
            case 0:
                [weatherData setObject:[NSNumber numberWithInt:60] forKey:@"interval"];   
                break;
            case 1:
                [weatherData setObject:[NSNumber numberWithInt:300] forKey:@"interval"];   
                break;
            case 2:
                [weatherData setObject:[NSNumber numberWithInt:600] forKey:@"interval"];   
                break;
            case 3:
                [weatherData setObject:[NSNumber numberWithInt:1800] forKey:@"interval"];   
                break;
            case 4:
                [weatherData setObject:[NSNumber numberWithInt:3600] forKey:@"interval"];   
                break;
            case 5:
                [weatherData setObject:[NSNumber numberWithInt:43200] forKey:@"interval"];   
                break;
                
            default:
                break;
        }
    }
    if([self.picker.pickerType isEqualToString:@"units"])
    {
         switch (selectedRow) {
            case 0:
                [weatherData setObject:@"f" forKey:@"units"];   
                break;
            case 1:
                [weatherData setObject:@"c" forKey:@"units"];   
                break;
         }
        //[[weatherSingleton sharedInstance] saveWeatherDataWithDictionary:weatherData];
        
    }
    if([self.picker.pickerType isEqualToString:@"iconSet"])
    {
        NSString *selected = [self.picker.pickerItems objectAtIndex:selectedRow];//[[[self.picker.pickerItems objectAtIndex:selectedRow] lowercaseString]stringByReplacingOccurrencesOfString:@" " withString:@"_"];
        [weatherData setObject:selected  forKey:@"weatherIconSet"];   
    }
    
    
    [self.tableView deselectRowAtIndexPath:self.SelectedCell animated:YES];    
    [self.tableView reloadData];
    self.SelectedCell = nil;
    self.picker = nil;
    self.pickerAS = nil;
    [self saveWeatherData];
}

- (BOOL)textFieldShouldReturn:(UITextField *)tf {
    [self.loadingIndicator startAnimating];
    isTyping=NO;
	if (tf == self.textField) {
        NSString *query = tf.text;
		[self.textField resignFirstResponder];
        
        //dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        //dispatch_async(queue, ^{
            if([tf.text isEqualToString:@""] || [tf.text isEqualToString:@"Current Location"])
            {
                [[weatherSingleton sharedInstance] setLocation:@"Current Location"];
            }
            else{
                
                BOOL connected = [[GMTHelper sharedInstance]deviceIsConnectedToInet];
                if(connected)
                {
                    //NSLog(@"Query: %@", query);
                    [[weatherSingleton sharedInstance] setLocation:query];
                    //dispatch_sync(dispatch_get_main_queue(), ^{
                        [self.loadingIndicator stopAnimating];
                    //});
                }
                else
                {
                    //dispatch_sync(dispatch_get_main_queue(), ^(void) {
                        
                        [self.loadingIndicator stopAnimating];
                        if(_valid){
                            [[GMTHelper sharedInstance] alertWithString:@"No internet connection detected. Unable to get location."];
                        }
                    //});
                }
            }
        //});
    }
	return YES;
}

#pragma mark Show Pickers
/*

- (void)getLocationsArray:(NSArray *)locationNames woeidsArray:(NSArray *)woeids
{
    //dismiss activity indicator
    NSLog(@"LocationNames: %@", locationNames);
        [self.loadingIndicator stopAnimating];
        if([locationNames count]>1){
            NSMutableArray *pArray = [[NSMutableArray alloc] init];
            //NSString *woeid = [woeids objectAtIndex:0];
            for(int x = 0; x<[woeids count]; x++){
                //if(![woeid isEqualToString:[woeids objectAtIndex:x]]){
                if(x<locationNames.count && x<woeids.count){
                    NSMutableDictionary *place = [[NSMutableDictionary alloc] init];
                    [place setObject:[locationNames objectAtIndex:x] forKey:@"locationName"];
                    [place setObject:[woeids objectAtIndex:x] forKey:@"location"];
                    [pArray addObject:place];
                }
                //}
            }
            if([pArray count]>0){
                self.placesArray = nil;
                self.placesArray = [NSMutableArray arrayWithArray:pArray];
                [self showLocationPicker:self.placesArray];
            }
            else
            {            
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                if([self.textField.text isEqualToString:@""] || [self.textField.text isEqualToString:@"Current Location"])
                {
                    [[cell detailTextLabel]setText:@"Current Location"];
                    [weatherData setObject:@"Current Location" forKey:@"location"];  
                    [weatherData setObject:[locationNames objectAtIndex:0] forKey:@"locationName"];  
                }
                else
                {
                    [[cell detailTextLabel]setText:[woeids objectAtIndex:0]];
                    [weatherData setObject:[woeids objectAtIndex:0] forKey:@"location"];  
                    [weatherData setObject:[locationNames objectAtIndex:0] forKey:@"locationName"];  
                }
                [self.textField setText:[locationNames objectAtIndex:0]];
                
                
                [self saveWeatherData];
                
            }
        }
        else
        {
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            if([self.textField.text isEqualToString:@""] || [self.textField.text isEqualToString:@"Current Location"])
            {
                [[cell detailTextLabel]setText:@"Current Location"];
                
                NSString *location = [woeids objectAtIndex:0];
                NSMutableDictionary *wdict = [NSMutableDictionary dictionaryWithDictionary:[getWeather getWeatherForLocation:location]];
                [weatherData setObject:wdict forKey:@"data"];
                [weatherData setObject:@"Current Location" forKey:@"location"];  
                [weatherData setObject:[locationNames objectAtIndex:0] forKey:@"locationName"]; 
            }
            else
            {
                [[cell detailTextLabel]setText:[woeids objectAtIndex:0]];
                
                NSString *location = [woeids objectAtIndex:0];
                NSMutableDictionary *wdict = [NSMutableDictionary dictionaryWithDictionary:[getWeather getWeatherForLocation:location]];
                [weatherData setObject:wdict forKey:@"data"];
                [weatherData setObject:[woeids objectAtIndex:0] forKey:@"location"];  
                [weatherData setObject:[locationNames objectAtIndex:0] forKey:@"locationName"];  
            }
            [self.textField setText:[locationNames objectAtIndex:0]];
            
            
            [self saveWeatherData];
        }
}
- (void) showLocationPicker:(NSArray *)places
{
    if(!_pickerVisible){
        _pickerVisible = YES;
        NSMutableArray *pickerList = [[NSMutableArray alloc]init];
        NSLog(@"PLACES: %@", places);
        for (NSDictionary *place in self.placesArray) {
            [pickerList addObject:[place objectForKey:@"locationName"]];
        }
        self.picker = [[WidgetPickerViewController alloc] initWithPickerItems:pickerList pickerType:@"locations"];
        NSString *title = @"Select Location";
        self.picker.pickerItems = [pickerList copy];
        self.pickerAS = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"cancel" destructiveButtonTitle:nil otherButtonTitles:nil];
        [self addToolbarToPicker:title];
    }
 }
 */
- (void) showIntervalPicker
{
    if(!_pickerVisible){
        _pickerVisible = YES;
    NSArray *pickerList = [NSArray arrayWithObjects:@"1 Minute",@"5 Minutes",@"10 Minutes",@"30 Minutes",@"1 Hour",@"12 Hours", nil];
    NSString *title = @"Weather Refresh Rate";
    self.picker = [[WidgetPickerViewController alloc] initWithPickerItems:nil pickerType:@"refreshInteval"];
    self.picker.pickerItems = [pickerList copy];
        if(!kIsiOS7)
            self.pickerAS = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"cancel" destructiveButtonTitle:nil otherButtonTitles:nil];
        else
            self.pickerAS = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    [self addToolbarToPicker:title];
    //[pickerList release];    
    }
}

- (void) showTemperatureUnitsPicker
{
    if(!_pickerVisible){
        _pickerVisible = YES;
    NSArray *pickerList = [NSArray arrayWithObjects:@"Fahrenheit",@"Celsius", nil];
    NSString *title = @"Weather Units";
    self.picker = [[WidgetPickerViewController alloc] initWithPickerItems:nil pickerType:@"units"];
        self.picker.pickerItems = [pickerList copy];
        if(!kIsiOS7)
            self.pickerAS = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"cancel" destructiveButtonTitle:nil otherButtonTitles:nil];
        else
            self.pickerAS = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    [self addToolbarToPicker:title];
    //[pickerList release];    
    }
}

- (void) showIconSetPicker
{
    if(!_pickerVisible){
        _pickerVisible = YES;
    NSArray *pickerList = [NSArray arrayWithObjects: @"Climacons", @"Flat", @"HTC", @"Stardock", @"Tick",nil];
    self.picker = [[WidgetPickerViewController alloc] initWithPickerItems:pickerList pickerType:@"iconSet"];
        NSString *title = @"Icon Set:";
        if(!kIsiOS7)
            self.pickerAS = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"cancel" destructiveButtonTitle:nil otherButtonTitles:nil];
        else
            self.pickerAS = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    [self addToolbarToPicker:title];
    }
}



@end
