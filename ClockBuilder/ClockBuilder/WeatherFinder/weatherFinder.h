extern NSString *const SMXMLDocumentErrorDomain;

@class SMXMLDocument;

@interface SMXMLElement : NSObject<NSXMLParserDelegate> {
@private
	SMXMLDocument *document; // nonretained
	SMXMLElement *parent; // nonretained
	NSString *name;
	NSMutableString *value;
	NSMutableArray *children;
	NSDictionary *attributes;
}

@property (nonatomic, assign) SMXMLDocument *document;
@property (nonatomic, assign) SMXMLElement *parent;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, retain) NSString *value;
@property (nonatomic, retain) NSArray *children;
@property (nonatomic, readonly) SMXMLElement *firstChild, *lastChild;
@property (nonatomic, retain) NSDictionary *attributes;

- (id)initWithDocument:(SMXMLDocument *)document;
- (SMXMLElement *)childNamed:(NSString *)name;
- (NSArray *)childrenNamed:(NSString *)name;
- (SMXMLElement *)childWithAttribute:(NSString *)attributeName value:(NSString *)attributeValue;
- (NSString *)attributeNamed:(NSString *)name;
- (SMXMLElement *)descendantWithPath:(NSString *)path;
- (NSString *)valueWithPath:(NSString *)path;

@end

@interface SMXMLDocument : NSObject<NSXMLParserDelegate> {
@private
	SMXMLElement *root;
	NSError *error;
}

@property (nonatomic, retain) SMXMLElement *root;
@property (nonatomic, retain) NSError *error;

- (id)initWithData:(NSData *)data error:(NSError **)outError;

+ (SMXMLDocument *)documentWithData:(NSData *)data error:(NSError **)outError;

@end


//
//  weatherFinder.h
//  ClockBuilder 2
//
//  Created by Gustavo Tandeciarz on 1/16/12.
//  Copyright (c) 2012 GMTAZ.com. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^WeatherFinderCancelled)();
typedef void (^WeatherLocationsFound)(NSDictionary *locationDict);

@interface weatherFinder : NSObject <UIActionSheetDelegate, UIPickerViewDelegate, UIPickerViewDataSource>{
    WeatherFinderCancelled _cancelBlock;
    WeatherLocationsFound _closeBlock;
    NSMutableArray *locationsArray;
    NSInteger selectedRow;
    
}

@property (nonatomic, copy) WeatherFinderCancelled cancelBlock;
@property (nonatomic, copy) WeatherLocationsFound closeBlock;
@property (nonatomic, assign) NSString *location;
@property (nonatomic, assign) UIView *pickerView;
@property (nonatomic, retain) UIActionSheet *pickerAS;
@property (nonatomic, strong) UIPickerView *thePicker;

-(void)getXMLLocations;
-(NSMutableArray *)getXMLLocationsArray;
-(NSMutableArray *)getXMLLocationsArrayWithLocation:(NSString *)location;
- (void) showLocationPicker;
+(weatherFinder *)weatherFinderInitWithLocation:(NSString *)loc;
+(void)getLocationFromString:(NSString *)loc showPickerInView:(UIView *)theView onCancel:(WeatherFinderCancelled)cancelledBlock onPicked:(WeatherLocationsFound)pickedBlock;

@end
