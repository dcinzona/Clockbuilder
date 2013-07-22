//
//  AlertViewToUploadTheme.h
//  ClockBuilder
//
//  Created by gtadmin on 3/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "uploadThemesController.h"


@interface AlertViewToUploadTheme : UIView <UIAlertViewDelegate, UITextFieldDelegate> {
    uploadThemesController *qup;
    NSString *themeNameText;
}

-(void)showAlertToUpload;

@end
