//
//  TweetieTabBarController.m
//
//  Created by Paulo Fierro on 2/12/10.
//

#import "TweetieTabBarController.h"

@implementation TweetieTabBarController

@synthesize indicatorImage;
@synthesize tabBarController;

/**
 *	Create and add our the tab bar and indicator
 */
- (id) init {
	if ((self = [super init])) {
		// Create the tab bar controller and add it to our view
		tabBarController = [UITabBarController new];
		[tabBarController setDelegate:self];
		[[self view] addSubview:[tabBarController view]];
		
		// Create the indicator image
		indicatorImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow.png"]];
		[[tabBarController tabBar] addSubview:indicatorImage];
    }
	return self;
}
/**
 *	Once the view has appeared animate the arrow to the first tab bar item
 */
BOOL hiddenTabBar;

- (void) hidetabbar {
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    
    for(UIView *view in tabBarController.view.subviews)
    {
        if([view isKindOfClass:[UITabBar class]])
        {
            
            if (hiddenTabBar) {
                [view setFrame:CGRectMake(view.frame.origin.x, 431, view.frame.size.width, view.frame.size.height)];
            } else {
                [view setFrame:CGRectMake(view.frame.origin.x, 480, view.frame.size.width, view.frame.size.height)];
            }
        } else {
            if (hiddenTabBar) {
                [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, 431)];
            } else {
                [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, 480)];
            }
            
        }
    }
    
    [UIView commitAnimations];
    
    hiddenTabBar = !hiddenTabBar;
}
- (void) viewDidAppear:(BOOL)animated {
	[self animateArrowIndicatorToIndex:0];
}
/**
 *	When we're about to select a view controller, animate the indicator arrow on to that item
 */
- (void)tabBarController:(UITabBarController *)tbc didSelectViewController:(UIViewController *)vc {
	[self animateArrowIndicatorToIndex:[tabBarController selectedIndex]];
}
/**
 *	Animate the Tweetie-like arrow indicator to a specific index
 */
- (void) animateArrowIndicatorToIndex:(int)index {
	// Get the total items in the tab bar
	int itemCount     = [[[tabBarController tabBar] items] count];
	// Only show the indicator if we have any items in the tab bar
	if(itemCount > 0) {
		// Find out how wide the individual cells are
		CGFloat cellWidth = [[tabBarController view] frame].size.width / itemCount;
		// Find the center point based on the cell width and the image widht
		CGFloat center = (index * cellWidth) + (cellWidth / 2) - ([indicatorImage frame].size.width/2);
		// Create a frame defining where the indicator image should be placed
		CGRect  frame = CGRectMake(center, -6, [indicatorImage frame].size.width, [indicatorImage frame].size.height);
		// Animate the image to the new position
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration:0.25];
		[indicatorImage setFrame:frame];
		[UIView commitAnimations];
	} else {
		// If there are no items in the tab bar we don't show the indicator
		[indicatorImage removeFromSuperview];
	}

}
/**
 *	Cleanup
 */
- (void)dealloc {
	[tabBarController release];
	[indicatorImage release];
    [super dealloc];
}

@end