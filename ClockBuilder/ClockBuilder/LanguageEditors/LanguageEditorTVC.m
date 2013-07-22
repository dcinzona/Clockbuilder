//
//  LanguageEditorTVC.m
//  ClockBuilder
//
//  Created by Gustavo Tandeciarz on 8/10/12.
//
//

#import "LanguageEditorTVC.h"
#import "languageItemCell.h"

@interface LanguageEditorTVC ()
{
    NSArray *dayKeys;
    NSArray *monthKeys;
    NSArray *conditionKeys;
    NSMutableDictionary *customDays;
    NSMutableDictionary *customMonths;
    NSMutableDictionary *customConditions;
}
@end

@implementation LanguageEditorTVC
@synthesize languageCell;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (kIsIpad) {
        self.contentSizeForViewInPopover = kPopoverSize;
    }
    else{
        UIBarButtonItem *backButton = [CBThemeHelper createBackButtonItemWithTitle:@"Lockscreen Settings" target:self.navigationController action:@selector(popViewControllerAnimated:)];
        [self.navigationItem setLeftBarButtonItem: backButton];
    }
    
    
    
    [self setTitle:@"Language Edits"];
    
    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tvFooterBG.png"]];
    [bg setContentMode:UIViewContentModeTopLeft];
    [self.tableView setTableFooterView:bg];
    /*
    UIImageView *TVbgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"fadedBG.JPG"]];
     [self.tableView setBackgroundView:TVbgView];
     
     
     UIView *bgView = [[UIView alloc]initWithFrame:self.tableView.frame];
     [bgView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"px"]]];
     [self.tableView setBackgroundView:bgView];
     [self.tableView setBackgroundColor:[UIColor blackColor]];
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
    
    UITapGestureRecognizer *resign = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                             action:@selector(resignKeyboard)];
    [self.tableView.backgroundView addGestureRecognizer:resign];
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setSectionFooterHeight:0];
    
    [self.tableView setSeparatorColor:[UIColor colorWithRed:.4 green:.4 blue:.4 alpha:.6]];
    
    //build arrays
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *languageItemsPath = [[NSBundle mainBundle] pathForResource:@"languageItems" ofType:@"plist"];
    NSMutableDictionary *languageItemsDict = [NSMutableDictionary dictionaryWithContentsOfFile:languageItemsPath];
    if (languageItemsDict) {
        dayKeys = [languageItemsDict objectForKey:@"days"];
        monthKeys = [languageItemsDict objectForKey:@"months"];
        conditionKeys = [languageItemsDict objectForKey:@"conditions"];
        customDays = [NSMutableDictionary dictionaryWithDictionary:[defaults objectForKey:@"customDays"]];
        customMonths = [NSMutableDictionary dictionaryWithDictionary:[defaults objectForKey:@"customMonths"]];
        customConditions = [NSMutableDictionary dictionaryWithDictionary:[defaults objectForKey:@"customConditions"]];
    }
    
}

- (void)viewDidUnload
{
    [self setLanguageCell:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)resignKeyboard{
    NSLog(@"resign keyboard");
    if(selectedCell){
        [selectedCell.entryField resignFirstResponder];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return dayKeys.count;
            break;
        case 1:
            return monthKeys.count;
            break;
        case 2:
            return conditionKeys.count;
            break;
            
        default:
            return 0;
            break;
    }
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *headerView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 40)];
    [headerView setShadowColor:[UIColor colorWithRed:.1 green:.1 blue:.1 alpha:.5]];
    [headerView setShadowOffset:CGSizeMake(1, 1)];
    
    if(section == 0)
        [headerView setText:@"  Day Names"];
    if(section == 1)
        [headerView setText:@"  Month Names"];
    if(section == 2)
        [headerView setText:@"  Weather Conditions"];
    
    [headerView setBackgroundColor:[UIColor clearColor]];
    [headerView setTextColor:[UIColor colorWithRed:.8 green:.8 blue:.8 alpha:.9]];
    
    return headerView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"languageCell";
    languageItemCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"languageItemCell" owner:self options:nil];
        cell = languageCell;
        [cell setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:.5]];
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [[cell cellLabel] setTextColor:[UIColor colorWithRed:.8 green:.8 blue:.8 alpha:.8]];
        [[cell cellLabel] setBackgroundColor:[UIColor clearColor]];
        [[cell entryField] setTextColor:[UIColor whiteColor]];
        [cell.entryField setPlaceholderTextColor:[UIColor colorWithRed:.6 green:.6 blue:.6 alpha:.6]];
        [cell.entryField setReturnKeyType:UIReturnKeyDone];
        [cell.entryField setKeyboardType:UIKeyboardTypeNamePhonePad];
        [cell.entryField setDelegate:self];
    }
    
    cell.entryField.text = @"";
    
    //days section
    if (indexPath.section == 0) {
        cell.cellLabel.text = [dayKeys objectAtIndex:indexPath.row];
        [cell.entryField setPlaceholder:cell.cellLabel.text];
        if([customDays objectForKey:cell.cellLabel.text]){
            [cell.entryField setText:[customDays objectForKey:cell.cellLabel.text]];
        }
    }
    //months section
    if (indexPath.section == 1) {
        cell.cellLabel.text = [monthKeys objectAtIndex:indexPath.row];
        [cell.entryField setPlaceholder:cell.cellLabel.text];
        if([customMonths objectForKey:cell.cellLabel.text]){
            [cell.entryField setText:[customMonths objectForKey:cell.cellLabel.text]];
        }
    }
    //conditions section
    if (indexPath.section == 2) {
        cell.cellLabel.text = [[conditionKeys objectAtIndex:indexPath.row] capitalizedString];
        [cell.entryField setPlaceholder:cell.cellLabel.text];
        if([customConditions objectForKey:cell.cellLabel.text]){
            [cell.entryField setText:[customConditions objectForKey:cell.cellLabel.text]];
        }
    }
    
    return cell;
}
#pragma mark - Textfield Delegate
-(void)textFieldDidEndEditing:(UITextField *)textField{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *valueText = textField.placeholder;
    if(textField.text.length>0){
        valueText = textField.text;
    }
    NSString *key = selectedCell.cellLabel.text;
    
    switch (selectedIndexPath.section) {
        case 0:
            //days
            if(textField.text.length == 0){
                if([customDays objectForKey:key]){
                    [customDays removeObjectForKey:key];
                    [defaults setObject:customDays forKey:@"customDays"];
                }
            }else
            {
                [customDays setObject:valueText forKey:key];
                [defaults setObject:customDays forKey:@"customDays"];
            }
            break;
        case 1:
            if(textField.text.length == 0){
                if([customMonths objectForKey:key]){
                    [customMonths removeObjectForKey:key];
                    [defaults setObject:customMonths forKey:@"customMonths"];
                }
            }else
            {
                [customMonths setObject:valueText forKey:key];
                [defaults setObject:customMonths forKey:@"customMonths"];
            }
            break;
        case 2:
            if(textField.text.length == 0){
                if([customConditions objectForKey:key]){
                    [customConditions removeObjectForKey:key];
                    [defaults setObject:customConditions forKey:@"customConditions"];
                }
            }else
            {
                [customConditions setObject:valueText forKey:key];
                [defaults setObject:customConditions forKey:@"customConditions"];
            }
            break;
            
        default:
            break;
    }
    [defaults synchronize];
    //either select next text field or end
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    
    languageItemCell *cell = (languageItemCell *)[[textField superview] superview];
    NSIndexPath *index = [self.tableView indexPathForCell:cell];
    
    [self.tableView scrollToRowAtIndexPath:index atScrollPosition:UITableViewRowAnimationTop animated:YES];
    selectedIndexPath = index;
    selectedCell = cell;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    
    return YES;
}
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    languageItemCell *cell = (languageItemCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    [cell.entryField becomeFirstResponder];
}

@end
