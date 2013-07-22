//
//  UIAlertViewBlock.m
//  ClockBuilder
//
//  Created by Gustavo Tandeciarz on 7/6/13.
//
//

#import "UIAlertViewBlock.h"

@interface UIAlertViewBlock ()
    @property (copy, nonatomic) void (^completion)(BOOL, NSInteger);
@end

@implementation UIAlertViewBlock

@synthesize completion=_completion;

- (id)initWithTitle:(NSString *)title
            message:(NSString *)message
         completion:(void (^)(BOOL cancelled, NSInteger buttonIndex))completion
  cancelButtonTitle:(NSString *)cancelButtonTitle
  otherButtonTitles:(NSString *)otherButtonTitles, ... {
    
    self = [self initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil ];
    
    if (self) {
        _completion = completion;
        
        va_list _arguments;
        va_start(_arguments, otherButtonTitles);
        
        for (NSString *key = otherButtonTitles; key != nil; key = (__bridge NSString *)(va_arg(_arguments, void *))) {
            [self addButtonWithTitle:key];
        }
        va_end(_arguments);
    }
    return self;
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    self.completion(buttonIndex==self.cancelButtonIndex, buttonIndex);
}


@end
