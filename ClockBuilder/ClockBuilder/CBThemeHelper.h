//
//  CBThemeHelper.h
//  ClockBuilder
//
//  Created by Gustavo Tandeciarz on 3/14/12.
//  Copyright (c) 2012 GMTAZ.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreTheme.h"
#import "CoreThemeiPad.h"


@interface CBThemeHelper : NSObject

+(void)convertDocumentsToNSFileWrapper;
+(void)convertThemesToDocuments;
+(BOOL)isIOS5;
+(BOOL)isCloudEnabled;
+(NSURL*)getThemesPath;
+(NSURL*)getThemeCloudPathForName:(NSString *)themeName;
+(NSURL*)getThemePathForName:(NSString *)themeName;
+(NSString*)getFileNameFromURL:(NSURL*)url;
+(UIImage *)getThumbForBG:(UIImage*)image;
+(void)saveThemeNamed:(NSString *)themeName;
+(void)saveThemeNamed:(NSString *)themeName withDict:(NSDictionary *)themeDict;
+(void)saveThemeToCoreDatawithDict:(NSMutableDictionary *)themeDict andObjectID:(NSString *)objectID;
+(void)saveContext:(NSManagedObjectContext *)context;
+(CoreTheme *)getCoreThemeWithName:(NSString *)themeName orObjectID:(NSString *)objectID;
+(void)converAllThemesInDocumentsToCoreData;
+(void)asyncConvertFileToCoreDataAtURL:(NSURL *)url;
+(void)saveThemeToCoreDatawithDict:(NSMutableDictionary *)themeDictInput andObjectID:(NSString *)objectID andThemeName:(NSString *)themeName;
+(void)saveThemeToCoreDataFromEmailWithDict:(NSMutableDictionary *)themeDictInput;
+(void)asyncSaveCurrentActiveThemeToCoreDatawithDict:(NSMutableDictionary *)themeDict andObjectID:(NSString *)objectID;


+(NSMutableArray *)getWidgetsListFromFile:(NSString *)themeName;
+(BOOL)openTheme:(NSString *)themeName;
+(NSDictionary *)getThemeDictFromDoc:(NSURL *)fileURL;
+(UIImage *)getThumbnailFromFile:(NSString *)filePath;
+(UIImage *)getBackgroundFromFile:(NSString *)filePath;
+(BOOL)setWidgetsList:(NSDictionary *)list toFile:(NSString *)filePath;
+(BOOL)setThumbnail:(UIImage *)image toFile:(NSString *)filePath;
+(BOOL)setBackground:(UIImage *)image toFile:(NSString *)filePath;

+(void)setThemeUbiquity:(BOOL)putIniCloud overwrite:(BOOL)overwrite;

+(void)startDownloadingThemeAtURLString:(NSString *)urlString andSaveAs:(NSString *)saveName;
+ (UIBarButtonItem *)createFontAwesomeBlueBarButtonItemWithIcon:(NSString *)iconCSSClass target:(id)tgt action:(SEL)a;
+ (UIBarButtonItem *)createFontAwesomeDarkBarButtonItemWithIcon:(NSString *)iconCSSClass target:(id)tgt action:(SEL)a;
+ (UIBarButtonItem *)createBlueButtonItemWithTitle:(NSString *)t target:(id)tgt action:(SEL)a;
+(UIBarButtonItem *)createDoneButtonItemWithTitle:(NSString *)t target:(id)tgt action:(SEL)a;   
+ (UIBarButtonItem *)createBlueButtonItemWithImage:(UIImage *)image andPressedImage:(UIImage*)imagePressed target:(id)tgt action:(SEL)a;
+(UIBarButtonItem *)createButtonItemWithImage:(UIImage *)image andPressedImage:(UIImage*)imagePressed target:(id)tgt action:(SEL)a;
+ (UIBarButtonItem *)createBackButtonItemWithTitle:(NSString *)t target:(id)tgt action:(SEL)a;
+ (UIBarButtonItem *)createBorderlessButtonItemWithImage:(UIImage *)image andPressedImage:(UIImage*)imagePressed target:(id)tgt action:(SEL)a;
+ (UIBarButtonItem *)createDarkButtonItemWithTitle:(NSString *)t target:(id)tgt action:(SEL)a;
+ (UIBarButtonItem *)createDarkButtonItemForStyledToolbarWithTitle:(NSString *)t target:(id)tgt action:(SEL)a;
+(void)setTitle:(NSString *)title forCustomBarButton:(UIBarButtonItem*)button;
+(NSString*)getTitleCustBarButton:(UIBarButtonItem*)button;

+(UIButton *)createBlueUIButtonWithTitle: (NSString *)t target:(id)tgt action:(SEL)a frame:(CGRect)buttonFrame;
+(UIButton *)createGrayUIButtonWithTitle: (NSString *)t target:(id)tgt action:(SEL)a frame:(CGRect)buttonFrame;
+(void)styleTableView:(UITableView *)tableView;
+(void)styleTableView:(UITableView *)tableView withBackgroundImage:(UIImage *)image;


+(void)showPicker:(UIPickerView*)pickerView aboveUITableView:(UITableView *)tableView onCompletion:(void(^)(void))callback;
+(void)dismissPicker:(UIPickerView *)pickerView fromUITableView:(UITableView *)tableView onCompletion:(void(^)(void))callback;


//Toolbar
+(void)setBackgroundImage:(UIImage*)bg forToolbar:(UIToolbar*)toolbar;
+(BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL;
+(void)checkIfURLIsExcluded:(NSURL *)theURL;

@end
