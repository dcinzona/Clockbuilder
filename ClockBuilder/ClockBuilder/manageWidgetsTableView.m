//
//  manageWidgets.m
//  ClockBuilder
//
//  Created by Gustavo Tandeciarz on 3/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "manageWidgetsTableView.h"
#import "ClockBuilderAppDelegate.h"
#import "textSettingsTableViewIndex.h"
#import "ImagePickerView.h"
#import "PrettyCell.h"
#import "BGImageCell.h"
#import "weatherSettingsIndex.h"
#import "weatherIconSettings.h"
#import "ClockBuilderViewController.h"
#import "widgetHelperClass.h"

@implementation manageWidgetsTableView
@synthesize widgetsAdded, widgetsAddedData,tv;
@synthesize pickerAS, picker, widgetClasses,pickerList;
@synthesize toolbar;
@synthesize editField;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        [self setWidgetObjects];
    }
    return self;
}
- (void)setWidgetObjects
{
    self.widgetsAdded = [NSMutableArray arrayWithArray:[[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"] objectForKey:@"widgetsList"]];
}
- (void)dealloc
{
    self.widgetsAdded = nil;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void) editWidget:(NSInteger) index
{
    NSString *type = [[self.widgetsAdded objectAtIndex:index] objectForKey:@"type"];
    if([type isEqualToString:@"textWidget"])
    {
        textSettingsTableViewIndex *v = [[textSettingsTableViewIndex alloc]initWithStyle:UITableViewStylePlain];
        [self.navigationController pushViewController:v animated:YES];
    }
    if([type isEqualToString:@"imageWidget"])
    {
        if([[[self.widgetsAdded objectAtIndex:index] objectForKey:@"class"]isEqualToString:@"weatherIconView"])
        {
            weatherIconSettings *v = [[weatherIconSettings alloc] initWithStyle:UITableViewStylePlain];
            [self.navigationController pushViewController:v animated:YES];
        }
        
    }
    
    [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:YES];
}

-(void) exitModal
{
    [[[UIApplication sharedApplication]delegate]performSelector:@selector(goBackToRootView)];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    if (kIsIpad) {
        self.contentSizeForViewInPopover = kPopoverSize;
    }
    
    [self setWidgetObjects];
    self.widgetClasses = [[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"]objectForKey:@"widgetClasses"];
    tv = self.tableView;
    [CBThemeHelper styleTableView:self.tableView];
    
    [self resetNavBarButtons];
    
    [self setTitle:@"Items"];
    [self.tableView setEditing:YES];
    
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewWillDisappear:(BOOL)animated
{
    
    if([[[UIApplication sharedApplication]delegate]performSelector:@selector(isThereAWeatherWidget)]){
        if(![[weatherSingleton sharedInstance] currentWeatherData]){
            [[weatherSingleton sharedInstance] updateWeatherData];
        }
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setWidgetObjects];
    [self.tableView reloadData];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
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
    NSInteger ret = 0;
    if(section==0)
        ret = [self.widgetsAdded count];
    if(section==1)
       ret = 2;
       
    return ret;
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
    if(indexPath.section==0){
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[PrettyCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        NSDictionary *widgetClass = [self.widgetsAdded  objectAtIndex:indexPath.row];
        NSString *widgetName = [widgetClass objectForKey:@"className"];
        NSString *subClass = [widgetClass objectForKey:@"subClass"];
        [[cell textLabel] setText:widgetName];
        if([subClass isEqualToString:@"weather"])
        {
            [cell.textLabel setText:widgetName];
            //switch based on textitemtype
            if([widgetName isEqualToString:@"Temperature"]){
                if(![[widgetClass objectForKey:@"textItemType"]isEqualToString:@"Temperature"])
                {
                    NSString *detail = [NSString stringWithFormat:@"%@'s %@",[[widgetClass objectForKey:@"forecast"]capitalizedString],[widgetClass objectForKey:@"textItemType"]];
                    if([[widgetClass objectForKey:@"forecast"]isEqualToString:@"current"]){
                        detail = [NSString stringWithFormat:@"%@ %@",[[widgetClass objectForKey:@"forecast"]capitalizedString],[widgetClass objectForKey:@"textItemType"]];
                    }
                    [cell.detailTextLabel setText:detail];
                }
                else
                {
                    [cell.detailTextLabel setText:@"Current Temperature"];
                }
            }
            if([widgetName isEqualToString:@"Location"]){
                NSDictionary* weatherData = [[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"] objectForKey:@"weatherData"];
                [cell.detailTextLabel setText:[weatherData objectForKey:@"locationName"]];
            }
            if([widgetName isEqualToString:@"Weather Icon"]){
                NSString *detail = [NSString stringWithFormat:@"%@'s Conditions",[[widgetClass objectForKey:@"forecast"]capitalizedString]];
                if([[widgetClass objectForKey:@"forecast"]isEqualToString:@"current"]){
                    detail = [NSString stringWithFormat:@"%@ Conditions",[[widgetClass objectForKey:@"forecast"]capitalizedString]];
                }
                [cell.detailTextLabel setText:detail];
            }
            if([widgetName isEqualToString:@"Conditions"]){
                NSString *detail = [NSString stringWithFormat:@"%@'s Conditions",[[widgetClass objectForKey:@"forecast"]capitalizedString]];
                if([[widgetClass objectForKey:@"forecast"]isEqualToString:@"current"]){
                    detail = [NSString stringWithFormat:@"%@ Conditions",[[widgetClass objectForKey:@"forecast"]capitalizedString]];
                }
                [cell.detailTextLabel setText:detail];
            }
        }
        if([subClass isEqualToString:@"text"])
        {
            [cell.textLabel setText:widgetName];
            [cell.detailTextLabel setText:[widgetClass objectForKey:@"text"]];
            if ([cell.detailTextLabel.text isEqualToString:@""]) {
                [cell.detailTextLabel setText:@"(No Text)"];
            }
        }
        if([subClass isEqualToString:@"datetime"])
        {
            [cell.textLabel setText:widgetName];
            [cell.detailTextLabel setText:[NSString stringWithFormat:@"DateTime Format: %@",[widgetClass objectForKey:@"dateFormatOverride"]]];
        }
        [self addCellAccessory:cell];
        [cell.backgroundView setClipsToBounds:YES];
        
        
        UIImageView *bgImage =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"snowflakeOverlay.png"]];
        if([subClass isEqualToString:@"weather"])
        {
            [bgImage setImage:[UIImage imageNamed:@"snowflakeOverlay.png"]];
        }
        if([subClass isEqualToString:@"datetime"])
        {
            [bgImage setImage:[UIImage imageNamed:@"clockOverlay.png"]];
        }
        [bgImage setFrame:CGRectMake(-5, -5, 40, 41)];
        [bgImage setTag:5];
        BOOL shouldAdd = TRUE;
        for (UIImageView* iv in cell.backgroundView.subviews) {
            if(iv.tag==5){
                shouldAdd=FALSE;
                break;
            }            
        }
        if([subClass isEqualToString:@"text"])
            shouldAdd = FALSE;
        if(shouldAdd)
            [cell.backgroundView addSubview:bgImage];
        
        
        return cell;
    }
    
    return nil;
}
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    /*
    if(indexPath.section==0)
    {
        NSString *cls = [NSString stringWithFormat:@"%d", indexPath.row];
        [[NSUserDefaults standardUserDefaults]setObject:cls forKey:@"widgetIndex"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        [self editWidget:indexPath.row];
    }
     */
}
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    if(indexPath.section==0)
        return YES;
    else
        return NO;
}
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"widgetIndex"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
        widgetHelperClass *wh = [widgetHelperClass new];
        [wh removeWidgetAtIndex:indexPath.row];
        
        [self setWidgetObjects];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64;//self.view.window.screen.scale * 64;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return nil;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    if(indexPath.section==0){
        [[NSUserDefaults standardUserDefaults]setObject:[NSString stringWithFormat:@"%d", indexPath.row] forKey:@"widgetIndex"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        [self editWidget:indexPath.row];
    }*/
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];  
}


 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
     if(fromIndexPath != toIndexPath)
     {
         NSDictionary *wdata = [[self.widgetsAdded objectAtIndex:fromIndexPath.row] copy];
         [self.widgetsAdded removeObjectAtIndex:fromIndexPath.row];
         [self.widgetsAdded insertObject:wdata atIndex:toIndexPath.row];         
         widgetHelperClass *wh = [widgetHelperClass new];
         [wh setWidgetsListArray:self.widgetsAdded];
     }
     
 }

- (void)didTransitionToState:(UITableViewCellStateMask)state {     
    
	if ((state & UITableViewCellStateShowingDeleteConfirmationMask) == UITableViewCellStateShowingDeleteConfirmationMask) {    
		for (UIView *subview in self.view.subviews) {   
            NSLog(@"subview class: %@",NSStringFromClass([subview class]));
			if ([NSStringFromClass([subview class]) isEqualToString:@"UITableViewCellDeleteConfirmationControl"]) {
                
            }
        }
    }
}

 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }



#pragma mark Action Sheet / Picker shit

-(NSInteger)getNumberOfWeatherIcons
{
    NSInteger weatherIcons = 0;
    for(NSDictionary *widget in self.widgetsAdded)
    {
        if([[widget objectForKey:@"class"] isEqualToString:@"weatherIconView"])
        {
            weatherIcons++;
        }
    }
    return weatherIcons;
}
-(NSInteger)getNumberOfDateTimeWidgets:(NSString*)cls
{
    NSInteger ret = 0;
    for(NSDictionary *widget in self.widgetsAdded)
    {
        if([[widget objectForKey:@"superClass"]isEqualToString:cls])
        {
            ret++;
        }
    }
    return ret;
}
-(NSInteger)getNumberOfWeatherLocationWidgets:(NSString*)cls
{
    NSInteger ret = 0;
    for(NSDictionary *widget in self.widgetsAdded)
    {
        if([[widget objectForKey:@"superClass"]isEqualToString:cls] && [[widget objectForKey:@"textItemType"]isEqualToString:@"Location"])
        {
            ret++;
        }
    }
    return ret;
}



-(BOOL) canAddWidget:(NSString*)cls
{
    return YES;
    CustomAlertView *widgetExists = [[CustomAlertView alloc] initWithTitle:@"Sorry" message:@"Limit of this widget has been reached." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    if([cls isEqualToString:@"weatherIconView"]){
        if([self getNumberOfWeatherIcons]<3){
            return YES;
        }
        else
        {//show alert
            [widgetExists show];
            return NO;
        }
    }    
    else if([self.picker.widgetType isEqualToString:@"dateTime"]){
        if([self getNumberOfDateTimeWidgets:cls]==0){
            return YES;
        }
        else
        {//show alert
            [widgetExists show];
            return NO;
        }
    }
    else if([self.picker.widgetType isEqualToString:@"Location"]){
        if([self getNumberOfWeatherLocationWidgets:cls]==0){
            return YES;
        }
        else
        {//show alert
            [widgetExists show];
            return NO;
        }
    }
    else
    {
        return YES;
    }
    return NO;
}

-(void) addToolbarToPicker:(NSString *)title
{
    UIToolbar *pickertoolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    pickertoolbar.barStyle = UIBarStyleBlackOpaque;
    if (!kIsIpad) {
        [pickertoolbar sizeToFit];
    }
    [CBThemeHelper setBackgroundImage:nil forToolbar:pickertoolbar];
    NSMutableArray *barItems = [[NSMutableArray alloc] init];
    UIBarButtonItem *cancelBtn = [CBThemeHelper createBlueButtonItemWithTitle:@"Cancel" target:self action:@selector(dismissActionSheet)];
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];  
    UIBarButtonItem *doneBtn = [CBThemeHelper createDoneButtonItemWithTitle:@"Done" target:self action:@selector(saveActionSheet)];
    UILabel *titleLabel = [[UILabel alloc] init];
    [titleLabel setText:title];
    [titleLabel setShadowColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:.5]];
    [titleLabel setShadowOffset:CGSizeMake(0, -1.0)];
    [titleLabel setFrame:CGRectMake(0, 0, 150, 22)];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    UIBarButtonItem *titleItem = [[UIBarButtonItem alloc] initWithCustomView:titleLabel];
    [titleItem setStyle:UIBarButtonItemStylePlain];
    
    if(kIsiOS7){
        [titleLabel setTextColor:[UIColor darkGrayColor]];
        [titleLabel setShadowColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0]];
        [self.pickerAS setBackgroundColor:[UIColor whiteColor]];
        [pickertoolbar setTintColor:nil];
        [self.picker.pickerView setBackgroundColor:[UIColor whiteColor]];
        
        
    }
    
    [barItems addObject:cancelBtn];
    [barItems addObject:flexSpace];  
    [barItems addObject:titleItem];
    [barItems addObject:flexSpace];
    [barItems addObject:doneBtn];
    [pickertoolbar setItems:barItems animated:YES];
    [self.pickerAS addSubview:pickertoolbar];    
    [self.pickerAS addSubview:self.picker.pickerView];
    [self.pickerAS showInView:self.view.superview];
    [self.pickerAS setBounds:self.view.superview.bounds];//CGRectMake(0,0,320, self.view.superview.bounds.size.height)];
}

-(void)dismissActionSheet{
    [self.pickerAS dismissWithClickedButtonIndex:0 animated:YES];
    self.picker = nil;
    self.pickerAS = nil;
}

-(void)saveActionSheet{
    if(self.pickerAS)
        [self.pickerAS dismissWithClickedButtonIndex:1 animated:YES];

    NSUInteger selectedTypeRow = [self.picker.pickerView selectedRowInComponent:0];
    NSUInteger selectedItemRow = [self.picker.pickerView selectedRowInComponent:1];
    NSLog(@"selectedItemRow: %i",selectedItemRow);
    NSLog(@"selectedTypeRow: %i",selectedTypeRow);

    if(!selectedItemRow){
        
    }
    if(!selectedTypeRow){
        
    }
    NSString *widgetType = self.picker.widgetType;
    NSString *widgetClass = self.picker.widgetClass;
    
    //NSLog(@"widgetType: %@", widgetType);
    //NSLog(@"widgetClass: %@", widgetClass);
    
    NSMutableDictionary *widget = [NSMutableDictionary dictionaryWithDictionary:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"] objectForKey:@"widgetClasses"] objectForKey:widgetClass]];
    if([self canAddWidget:widgetClass]){
        if(selectedTypeRow == 1)
        {//Configure weather widget
            if(selectedItemRow==0)
            {//weather icon // max 3
                
                if([[weatherSingleton sharedInstance]isClimacon]){
                    //add climacon options
                    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:[UIColor whiteColor]];
                    [widget setObject:colorData forKey:@"fontColor"];
                    NSData *glowColorData = [NSKeyedArchiver archivedDataWithRootObject:[UIColor colorWithRed:0 green:0 blue:0 alpha:1]];
                    [widget setObject:glowColorData forKey:@"glowColor"];
                    [widget setObject:@"30" forKey:@"fontSize"];
                    
                }
                
                switch ([self getNumberOfWeatherIcons]) {
                    case 0:
                        //current
                        [widget setObject:@"current" forKey:@"forecast"];
                        break;
                    case 1:
                        //today
                        [widget setObject:@"today" forKey:@"forecast"];
                        break;
                    case 2:
                        //tomorrow
                        [widget setObject:@"tomorrow" forKey:@"forecast"];
                        break;
                        
                    default:
                        break;
                }
            }
            else
            {
                //textItemType
                [widget setObject:widgetType forKey:@"className"];
                if([widgetType isEqualToString:@"Temperature"])
                {
                    [widget setObject:@"Temperature" forKey:@"textItemType"];
                    [widget setObject:NSStringFromCGRect(CGRectMake(0, 0, 80, 50)) forKey:@"frame"];
                }
                if([widgetType isEqualToString:@"Conditions"])
                {
                    [widget setObject:@"Conditions" forKey:@"textItemType"];
                    [widget setObject:NSStringFromCGRect(CGRectMake(0, 0, 320, 50)) forKey:@"frame"];
                }
            }
            
        }
        if(widget!=nil){
            //NSLog(@"widget data: %@", widget);
            //NSLog(@"widgetClasses: %@",[[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"] objectForKey:@"widgetClasses"]);
            CGRect frame = CGRectFromString([widget objectForKey:@"frame"]);
            frame.origin.x = 20;
            //Fix for sensitive notification center
            frame.origin.y = kScreenHeight / 2;
            [widget setObject:NSStringFromCGRect(frame) forKey:@"frame"];
            [[[UIApplication sharedApplication]delegate]performSelector:@selector(addWidgetToArray:) withObject:widget];
            [self setWidgetObjects];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[self.widgetsAdded count]-1 inSection:0]] withRowAnimation:YES];
        }
        else {
            NSLog(@"something went wrong");
            NSLog(@"widgetClasses: %@",[[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"] objectForKey:@"widgetClasses"]);
        }
    }
    if(kIsiOS7){
        [self dismissPicker];
    }
    self.picker = nil;
    self.pickerAS = nil;
}

-(void)launchWidgetPicker
{   
    //if(!kIsiOS7){
    NSString *title = @"Items";
        if(!kIsiOS7){
            self.picker = [[addWidgetPicker alloc] init];
            if(!self.pickerAS){
                self.pickerAS = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"cancel" destructiveButtonTitle:nil otherButtonTitles:nil];
                [self addToolbarToPicker:title];
            }
        }
        else{
            //self.pickerAS = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
            
            [self showPickerWithoutAS];
        }
    /*}
    else{
        if(!self.pickerAS)
            self.pickerAS = [[UIActionSheet alloc] initWithTitle:@"Items" delegate:self cancelButtonTitle:@"cancel" destructiveButtonTitle:Nil otherButtonTitles:@"Add", nil];
        if(!self.picker)
            self.picker = [[addWidgetPicker alloc] init];
        [self.pickerAS addSubview:self.picker.pickerView];
        [self.pickerAS showInView:self.view];
        [self.pickerAS setBounds:CGRectMake(0,0,320, 464)];
    }
     */
}
-(void)resetNavBarButtons{
    
    UIBarButtonItem *doneButton = [CBThemeHelper createDoneButtonItemWithTitle:@"Done" target:self action:@selector(exitModal)];
    self.navigationItem.leftBarButtonItem = doneButton;
    
    self.navigationItem.rightBarButtonItem = [CBThemeHelper createFontAwesomeBlueBarButtonItemWithIcon:@"icon-plus-sign" target:self action:@selector(launchWidgetPicker)];
    
    [self setTitle:@"Items"];
}
-(void)dismissPicker{
    
    [self resetNavBarButtons];
    [CBThemeHelper dismissPicker:self.picker.pickerView fromUITableView:self.tableView onCompletion:^{
        self.picker = nil;
    }];
    /*
    [UIView animateWithDuration:0.2
                          delay:0
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         [self.picker.pickerView setFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, 320, 180)];
                         [self.view setAlpha:1];
                         [self.view setTransform:CGAffineTransformMakeScale(1, 1)];
                     }
                     completion:^(BOOL finished){
                         [self.picker.pickerView removeFromSuperview],self.picker = nil;
                         //[self refreshThemes];
                     }];
     */
}
-(void)setNavBarButtonsForActionView{
    UIBarButtonItem *cancelButton = [CBThemeHelper createBlueButtonItemWithTitle:@"Cancel" target:self action:@selector(dismissPicker)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    UIBarButtonItem *donePicking = [CBThemeHelper createBlueButtonItemWithTitle:@"Done" target:self action:@selector(saveActionSheet)];
    self.navigationItem.rightBarButtonItem = donePicking;
    [self setTitle:@"Add Item"];
}
-(void)showPickerWithoutAS{
    CGRect pickerRect = CGRectMake(0, self.view.frame.size.height, 320, 180);
        //pickerRect = CGRectMake(0, 0, 320, 180);
    if(!self.picker){
        self.picker = [[addWidgetPicker alloc] initWithFrame:pickerRect];
    }
    self.picker.pickerView.delegate = self.picker;
    self.picker.pickerView.showsSelectionIndicator = YES;
    [self setNavBarButtonsForActionView];
    
    [CBThemeHelper showPicker:self.picker.pickerView aboveUITableView:self.tableView onCompletion:^{
        
    }];
    
    /*
    [self.view.superview insertSubview:self.picker.pickerView aboveSubview:[self.view.superview.subviews objectAtIndex:0]];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.tableView setBackgroundColor:[UIColor whiteColor]];
    [self.tableView.superview setBackgroundColor:[UIColor whiteColor]];
    
    [UIView animateWithDuration:0.2
                          delay:0
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         [self.picker.pickerView setFrame:CGRectMake(0, self.view.frame.size.height - 180, 320, 180)];
                         [self.tableView setAlpha:.1];
                         [self.tableView setTransform:CGAffineTransformMakeScale(.9, .9)];
                     }
                     completion:^(BOOL finished){
                         
                         
                     }];
     */
}





@end
