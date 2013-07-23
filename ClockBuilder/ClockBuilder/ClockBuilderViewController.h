//
//  ClockBuilderViewController.h
//  ClockBuilder
//
//  Created by Gustavo Tandeciarz on 3/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
#import "getWeatherData.h"
#import "TweetieTabBarController.h"
#import "CustomTabBarViewController.h"
#import "clearThemeAlertView.h"
#import "widgetHelperClass.h"
#import "themeConverter.h"
#import "widgetTools.h"
#import "weatherIconPickerTool.h"
#import "CBTheme.h"
#import "SNPopupView+UsingPrivateMethod.h"

@interface ClockBuilderViewController : UIViewController <UIGestureRecognizerDelegate, UIActionSheetDelegate, UIWebViewDelegate, NSMetadataQueryDelegate, UIPopoverControllerDelegate> {
    
    NSTimer * repeatingTimer;
    
    IBOutlet UIBarButtonItem * addItem;
    IBOutlet UIBarButtonItem * done;
    IBOutlet UIButton * showToolbar;
    IBOutlet UIButton * tapBackground;
    IBOutlet UIToolbar * toolbar;
    IBOutlet UIBarButtonItem * flexibleSpace1;
    IBOutlet UIBarButtonItem *openTools;
    
    IBOutlet UIBarButtonItem * sliderContainer;
    IBOutlet UISlider * scaleSlider;
    IBOutlet UIBarButtonItem *opacitySliderContainer;
    IBOutlet UISlider *opacitySlider;
    IBOutlet UIBarButtonItem *scaleButtonItem;
    IBOutlet UIBarButtonItem *opacityButtonItem;
    
    /*adjust height for iPhone 5*/
    IBOutlet UIImageView *ScaleIconImageView;
    IBOutlet UIImageView *OpacityIconImageView;
    IBOutlet UIView *widgetNameView;
    IBOutlet UILabel *widgetNameLabel;
    
    IBOutlet widgetTools *tools;
    weatherIconPickerTool *weatherIconForecastPicker;
    
    UIView * widgetSelected;
    int touchCount;
	CGPoint startTouchPosition; 
    UIView *pieceForReset;
    NSArray * widgetsAdded;
    BOOL doSlideUp;
    
    CGFloat screenWidth;
    CGFloat screenHeight;
    UIImageView *bgImage;
    UIWebView *bgWebView;
    
    
    NSInteger originalWidgetIndex;
    widgetHelperClass *widgetHelper;
    
    BOOL _editing;
    BOOL _editingWidget;
    BOOL _toolsOpen;
    BOOL _textToolsVisible;
    
    
    NSMutableArray *documents;
    
    BOOL _ranInitialRefresh;
    BOOL _cantFindYouAlertShowing;
    
    SNPopupView *opacityPopup;
    SNPopupView *scalePopup;
    BOOL opacitySliderVisible;
    BOOL scaleSliderVisible;
}
@property (strong, nonatomic) NSMetadataQuery *query;
-(void)setupAndStartQuery;
- (UINavigationController *)customizedNavigationController;

@property (nonatomic, strong) themeConverter *th;
@property (nonatomic, strong) widgetHelperClass *widgetHelper;
@property (strong, nonatomic) NSTimer *repeatingTimer;
@property (strong, nonatomic) UIActionSheet *actionButtonSheet;
@property (nonatomic, strong) clearThemeAlertView *deleteThemeDelegate;
@property (strong, nonatomic) UIBarButtonItem *addItem;
@property (strong, nonatomic) UIBarButtonItem *done;
@property (strong, nonatomic) UIBarButtonItem *sliderContainer;
@property (strong, nonatomic) UISlider *scaleSlider;
@property (strong, nonatomic) UIBarButtonItem *flexibleSpace1;
@property (nonatomic, strong) UIBarButtonItem *openTools;
@property (strong, nonatomic) UIButton *showToolbar;
@property (strong, nonatomic) UIButton *tapBackground;
@property (strong, nonatomic) UIToolbar *toolbar;
@property (strong, nonatomic) NSArray *widgetsAdded;
@property (strong, nonatomic) UIView *widgetSelected;
@property (nonatomic, strong) UIImageView *bgImage;
@property (nonatomic, strong) UITextField *editField;
@property (strong, nonatomic) CustomTabBarViewController *tabsController;
@property (strong, nonatomic) NSArray *tabItems;
@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic, strong) UIView *coordinatesView;
@property (nonatomic, strong) UILabel *coordinatesViewLabelX;
@property (nonatomic, strong) UILabel *coordinatesViewLabelY;

@property (nonatomic, strong) UIPopoverController *pop;


-(void)set_Editing:(BOOL)yesNo;
-(void)toggleTools;
-(IBAction)scaleButtonClicked:(id)sender;
-(IBAction)opacityButtonClicked:(id)sender;

- (void)saveTheme:(NSString *)themeName;
- (void)resetToolbar;
- (void) selectWidget:(UIView *)widget;
- (void) addWidgetsToView;
- (void) forceWidgetRedraw:(UIView *)widget;
-(IBAction)addButtonClick:(id)sender;
-(IBAction)doneButtonClick:(id)sender;
-(IBAction)showToolbarClick:(id)sender;
- (IBAction)SlideToScaleView: (id)sender;
- (IBAction)doneScalingUsingSlider: (id)sender;
- (void) initWidgetsArray;
- (void)addGestureRecognizersToPiece:(UIView *)piece;
- (void) refreshViews;
- (NSInteger) getIndexFromView:(UIView *)v;
-(void)setOriginalWidgetIndex:(UIView *)widget;

@end
