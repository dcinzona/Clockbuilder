//
//  UIAlertViewBlock.h
//  ClockBuilder
//
//  Created by Gustavo Tandeciarz on 7/6/13.
//
//

#import <UIKit/UIKit.h>

@interface UIAlertViewBlock : UIAlertView <UIAlertViewDelegate>

- (id)initWithTitle:(NSString *)title message:(NSString *)message completion:(void (^)(BOOL cancelled, NSInteger buttonIndex))completion cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

@end