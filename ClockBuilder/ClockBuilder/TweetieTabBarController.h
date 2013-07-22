//
//  TweetieTabBarController.h
//  TweetieTabBar
//
//  Created by Paulo Fierro on 2/12/10.
//

#import <UIKit/UIKit.h>

@interface TweetieTabBarController : UIViewController <UITabBarControllerDelegate> {
	UITabBarController *tabBarController;
	UIImageView *indicatorImage;
}

@property (nonatomic, retain) UITabBarController *tabBarController;
@property (nonatomic, retain) UIImageView *indicatorImage;

- (void) animateArrowIndicatorToIndex:(int)index;

@end

