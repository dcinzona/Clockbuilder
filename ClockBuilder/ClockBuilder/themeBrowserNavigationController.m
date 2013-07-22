//
//  themeBrowserNavigationController.m
//  ClockBuilder
//
//  Created by Gustavo Tandeciarz on 4/5/12.
//  Copyright (c) 2012 GMTAZ.com. All rights reserved.
//

#import "themeBrowserNavigationController.h"

@implementation themeBrowserNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (id)initWithRootViewController:(UIViewController *)rootViewController{
    self = [super initWithRootViewController:rootViewController];
    if(self){
        
        
    }
    return self;
    
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[self.navigationBar setBarStyle:UIBarStyleBlackOpaque];
    // Do any additional setup after loading the view from its nib.
    if ([self.navigationController.navigationBar respondsToSelector:@selector( setBackgroundImage:forBarMetrics:)]){
        if(!kIsiOS7){
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"NavigationBarBackground.png"] forBarMetrics:UIBarMetricsDefault];
        }
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self.visibleViewController viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (IBAction)doneButtonClick:(id*)sender{
    [self dismissModalViewControllerAnimated:YES];
}

@end


@implementation UINavigationController (CustomNavController)

-(void)viewDidLoad{
    
    if ([self.navigationController.navigationBar respondsToSelector:@selector( setBackgroundImage:forBarMetrics:)]){
        if(!kIsiOS7){
            [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"NavigationBarBackground.png"] forBarMetrics:UIBarMetricsDefault];
        }
    }
}

@end

