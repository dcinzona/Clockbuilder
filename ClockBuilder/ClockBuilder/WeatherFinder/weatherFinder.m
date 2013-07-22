//
//  weatherFinder.m
//  ClockBuilder 2
//
//  Created by Gustavo Tandeciarz on 1/16/12.
//  Copyright (c) 2012 GMTAZ.com. All rights reserved.
//

#import "weatherFinder.h"

NSString *const SMXMLDocumentErrorDomain = @"SMXMLDocumentErrorDomain";

static NSError *SMXMLDocumentError(NSXMLParser *parser, NSError *parseError) {	
	NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:parseError forKey:NSUnderlyingErrorKey];
	NSNumber *lineNumber = [NSNumber numberWithInteger:parser.lineNumber];
	NSNumber *columnNumber = [NSNumber numberWithInteger:parser.columnNumber];
	[userInfo setObject:[NSString stringWithFormat:NSLocalizedString(@"Malformed XML document. Error at line %@:%@.", @""), lineNumber, columnNumber] forKey:NSLocalizedDescriptionKey];
	[userInfo setObject:lineNumber forKey:@"LineNumber"];
	[userInfo setObject:columnNumber forKey:@"ColumnNumber"];
	return [NSError errorWithDomain:SMXMLDocumentErrorDomain code:1 userInfo:userInfo];
}

@implementation SMXMLElement
@synthesize document, parent, name, value, children, attributes;

- (id)initWithDocument:(SMXMLDocument *)aDocument {
	self = [super init];
	if (self)
		self.document = aDocument;
	return self;
}

- (void)dealloc {
	self.document = nil;
	self.parent = nil;
	self.name = nil;
	self.value = nil;
	self.children = nil;
	self.attributes = nil;
	[super dealloc];
}

- (NSString *)descriptionWithIndent:(NSString *)indent {
    
	NSMutableString *s = [NSMutableString string];
	[s appendFormat:@"%@<%@", indent, name];
	
	for (NSString *attribute in attributes)
		[s appendFormat:@" %@=\"%@\"", attribute, [attributes objectForKey:attribute]];
    
	NSString *trimVal = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
	if (trimVal.length > 25)
		trimVal = [NSString stringWithFormat:@"%@…", [trimVal substringToIndex:25]];
	
	if (children.count) {
		[s appendString:@">\n"];
		
		NSString *childIndent = [indent stringByAppendingString:@"  "];
		
		if (trimVal.length)
			[s appendFormat:@"%@%@\n", childIndent, trimVal];
        
		for (SMXMLElement *child in children)
			[s appendFormat:@"%@\n", [child descriptionWithIndent:childIndent]];
		
		[s appendFormat:@"%@</%@>", indent, name];
	}
	else if (trimVal.length) {
		[s appendFormat:@">%@</%@>", trimVal, name];
	}
	else [s appendString:@"/>"];
	
	return s;	
}

- (NSString *)description {
	return [self descriptionWithIndent:@""];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	
	if (!string) return;
	
	if (value)
		[(NSMutableString *)value appendString:string];
	else
		self.value = [NSMutableString stringWithString:string];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
	SMXMLElement *child = [[SMXMLElement alloc] initWithDocument:self.document];
	child.parent = self;
	child.name = elementName;
	child.attributes = attributeDict;
	
	if (children)
		[(NSMutableArray *)children addObject:child];
	else
		self.children = [NSMutableArray arrayWithObject:child];
	
	[parser setDelegate:child];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	[parser setDelegate:parent];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	self.document.error = SMXMLDocumentError(parser, parseError);
}

- (SMXMLElement *)childNamed:(NSString *)nodeName {
	for (SMXMLElement *child in children)
		if ([child.name isEqual:nodeName])
			return child;
	return nil;
}

- (NSArray *)childrenNamed:(NSString *)nodeName {
	NSMutableArray *array = [NSMutableArray array];
	for (SMXMLElement *child in children)
		if ([child.name isEqual:nodeName])
			[array addObject:child];
	return [array copy];
}

- (SMXMLElement *)childWithAttribute:(NSString *)attributeName value:(NSString *)attributeValue {
	for (SMXMLElement *child in children)
		if ([[child attributeNamed:attributeName] isEqual:attributeValue])
			return child;
	return nil;
}

- (NSString *)attributeNamed:(NSString *)attributeName {
	return [attributes objectForKey:attributeName];
}

- (SMXMLElement *)descendantWithPath:(NSString *)path {
	SMXMLElement *descendant = self;
	for (NSString *childName in [path componentsSeparatedByString:@"."])
		descendant = [descendant childNamed:childName];
	return descendant;
}

- (NSString *)valueWithPath:(NSString *)path {
	NSArray *components = [path componentsSeparatedByString:@"@"];
	SMXMLElement *descendant = [self descendantWithPath:[components objectAtIndex:0]];
	return [components count] > 1 ? [descendant attributeNamed:[components objectAtIndex:1]] : descendant.value;
}


- (SMXMLElement *)firstChild { return [children count] > 0 ? [children objectAtIndex:0] : nil; }
- (SMXMLElement *)lastChild { return [children lastObject]; }

@end

@implementation SMXMLDocument
@synthesize root, error;

- (id)initWithData:(NSData *)data error:(NSError **)outError {
    self = [super init];
	if (self) {
		NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
		[parser setDelegate:self];
		[parser setShouldProcessNamespaces:YES];
		[parser setShouldReportNamespacePrefixes:YES];
		[parser setShouldResolveExternalEntities:NO];
		[parser parse];
		
		if (self.error) {
			if (outError)
				*outError = self.error;
			self = nil;
			return self;
		}
	}
	return self;
}

- (void)dealloc {
	self.root = nil;
	self.error = nil;
	[super dealloc];
}

+ (SMXMLDocument *)documentWithData:(NSData *)data error:(NSError **)outError {
	return [[SMXMLDocument alloc] initWithData:data error:outError];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
	
	self.root = [[SMXMLElement alloc] initWithDocument:self];
	root.name = elementName;
	root.attributes = attributeDict;
	[parser setDelegate:root];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	self.error = SMXMLDocumentError(parser, parseError);
}

- (NSString *)description {
	return root.description;
}

@end

/*
 http://xoap.weather.com/search/search?where=bethesda
 <search ver="3.0"><loc id="USMD0034" type="1">Bethesda, MD</loc><loc id="USOH0086" type="1">Bethesda, OH</loc></search>
 */


@implementation weatherFinder
@synthesize location;
@synthesize cancelBlock = _cancelBlock;
@synthesize closeBlock = _closeBlock;
@synthesize pickerView, thePicker, pickerAS;

-(id)init{
    self = [super init];
    if(self){
        locationsArray = nil;
        locationsArray = [NSMutableArray new];
    }
    return self;
}

+(weatherFinder *)weatherFinderInitWithLocation:(NSString *)loc{
    weatherFinder *newFinder = [[weatherFinder alloc] init];
    [newFinder setLocation:loc];
    return newFinder;
}

+(void)getLocationFromString:(NSString *)loc showPickerInView:(UIView *)theView onCancel:(WeatherFinderCancelled)cancelledBlock onPicked:(WeatherLocationsFound)pickedBlock{
    
    weatherFinder *finder = [weatherFinder weatherFinderInitWithLocation:loc];
    [finder setCancelBlock:cancelledBlock];
    [finder setCloseBlock:pickedBlock];
    [finder setPickerView:theView];
    [finder getXMLLocations];
    
}

-(void)getXMLLocations{
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://xoap.weather.com/search/search?where=%@",location]]];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	// create a new SMXMLDocument with the contents of sample.xml
	SMXMLDocument *document = [SMXMLDocument documentWithData:data error:NULL];
    
	// demonstrate -description of document/element classes
    
    [locationsArray removeAllObjects];
	// Pull out the <books> node
	SMXMLElement *results = document.root;
	
	// Look through <books> children of type <book>
	for (SMXMLElement *result in [results childrenNamed:@"loc"]) {
		
		// demonstrate common cases of extracting XML data
		NSString *locID = [result attributeNamed:@"id"]; // XML attribute
		NSString *locName = [result value]; // child node value
        NSLog(@"location: %@", location);
        NSLog(@"location name: %@", locName);
        if([locName rangeOfString:[NSString stringWithFormat:@"(%@)",location]].location != NSNotFound){
            locName = [locName stringByReplacingOccurrencesOfString:location withString:@""];
            locName = [locName stringByReplacingOccurrencesOfString:@"()" withString:@""];
        }
        
        NSMutableDictionary *locDict = [NSMutableDictionary new];
        if(![[locName stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@","]){
            [locDict setObject:locID forKey:@"locID"];
            [locDict setObject:locName forKey:@"locName"];
            
            [locationsArray addObject:locDict];
        }
		
	}
    
    if(locationsArray.count>1){
        //show picker
        [self showLocationPicker];
    }
    else if(locationsArray.count==0)
    {
        //alert no location found
        self.cancelBlock();
    }
    else
    {
        self.closeBlock([locationsArray objectAtIndex:0]);
    }
    
}


-(NSMutableArray *)getXMLLocationsArray{
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSString *urlString = [NSString stringWithFormat:@"http://xoap.weather.com/search/search?where=%@", location];
    urlString = [urlString stringByReplacingOccurrencesOfString:@"&" withString:@""];
    urlString = [urlString stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSURL *xmlurl = [NSURL URLWithString:urlString];
    NSLog(@"weatherFinder xmlurl: %@",xmlurl);
    NSData *data = [NSData dataWithContentsOfURL:xmlurl];
	
	// create a new SMXMLDocument with the contents of sample.xml
    NSError *xmlerr;
	SMXMLDocument *document = [SMXMLDocument documentWithData:data error:&xmlerr];
    
    if(!document){
        
        NSLog(@"weatherFinder error: %@", xmlerr);
        
    }
	// demonstrate -description of document/element classes
    
    [locationsArray removeAllObjects];
	// Pull out the <books> node
	SMXMLElement *results = document.root;
	NSLog(@"weatherfinder Location: %@", location);
	// Look through <books> children of type <book>
    NSLog(@"weatherfinder results: %@", results);
	for (SMXMLElement *result in [results childrenNamed:@"loc"]) {
		
		// demonstrate common cases of extracting XML data
		NSString *locID = [result attributeNamed:@"id"]; // XML attribute
		NSString *locName = [result value]; // child node value
        NSLog(@"location: %@", location);
        NSLog(@"location name: %@", locName);
        if([locName rangeOfString:[NSString stringWithFormat:@"(%@)",location]].location != NSNotFound){
            locName = [locName stringByReplacingOccurrencesOfString:location withString:@""];
            locName = [locName stringByReplacingOccurrencesOfString:@"()" withString:@""];
        }
        
        NSMutableDictionary *locDict = [NSMutableDictionary new];
        if(![[locName stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@","]){
            [locDict setObject:locID forKey:@"locID"];
            [locDict setObject:locName forKey:@"locName"];
            
            [locationsArray addObject:locDict];
        }
		
	}
    return locationsArray;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
}

-(NSMutableArray *)getXMLLocationsArrayWithLocation:(NSString *)loc{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    location = loc;
    NSLog(@"getXMLLocationswithLocation: %@", loc);
    NSString *urlString = [NSString stringWithFormat:@"http://xoap.weather.com/search/search?where=%@", loc];
    urlString = [urlString stringByReplacingOccurrencesOfString:@"&" withString:@""];
    urlString = [urlString stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSURL *xmlurl = [NSURL URLWithString:urlString];
    NSLog(@"weatherFinder xmlurl: %@",xmlurl);
    NSData *data = [NSData dataWithContentsOfURL:xmlurl];
	
	// create a new SMXMLDocument with the contents of sample.xml
    NSError *xmlerr;
	SMXMLDocument *document = [SMXMLDocument documentWithData:data error:&xmlerr];
    
    if(!document){
        
        NSLog(@"weatherFinder error: %@", xmlerr);
        
    }
	// demonstrate -description of document/element classes
    
    [locationsArray removeAllObjects];
	// Pull out the <books> node
	SMXMLElement *results = document.root;
	NSLog(@"weatherfinder Location: %@", location);
	// Look through <books> children of type <book>
    NSLog(@"weatherfinder results: %@", results);
	for (SMXMLElement *result in [results childrenNamed:@"loc"]) {
		
		// demonstrate common cases of extracting XML data
		NSString *locID = [result attributeNamed:@"id"]; // XML attribute
		NSString *locName = [result value]; // child node value
        NSLog(@"location: %@", self.location);
        NSLog(@"location name: %@", locName);
        if([locName rangeOfString:[NSString stringWithFormat:@"(%@)",self.location]].location != NSNotFound){
            locName = [locName stringByReplacingOccurrencesOfString:self.location withString:@""];
            locName = [locName stringByReplacingOccurrencesOfString:@"()" withString:@""];
        }
        
        NSMutableDictionary *locDict = [NSMutableDictionary new];
        if(![[locName stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@","]){
            [locDict setObject:locID forKey:@"locID"];
            [locDict setObject:locName forKey:@"locName"];
            
            [locationsArray addObject:locDict];
        }
		
	}
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    return locationsArray;
    

}

-(BOOL)isiPad{

BOOL iPad;
// Override point for customization after application launch.BOOL iPad = NO;
#ifdef UI_USER_INTERFACE_IDIOM
iPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
#endif
return iPad;
}
-(void) addToolbarToPicker:(NSString *)title
{
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    toolbar.barStyle = UIBarStyleBlackOpaque;
    //[toolbar sizeToFit];
    [CBThemeHelper setBackgroundImage:nil forToolbar:toolbar];
    NSMutableArray *barItems = [[NSMutableArray alloc] init];
    UIBarButtonItem *cancelBtn = [CBThemeHelper createDarkButtonItemWithTitle:@"Cancel" target:self action:@selector(dismissActionSheet)];
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];  
    UIBarButtonItem *doneBtn = [CBThemeHelper createBlueButtonItemWithTitle:@"Done" target:self action:@selector(saveActionSheet)];
    UILabel *titleLabel = [[UILabel alloc] init];
    [titleLabel setText:title];
    [titleLabel setShadowColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:.5]];
    [titleLabel setShadowOffset:CGSizeMake(0, -1.0)];
    [titleLabel setFrame:CGRectMake(0, 0, 150, 22)];
    [titleLabel setTextAlignment:UITextAlignmentCenter];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    //[titleLabel setCenter:toolbar.center];
    UIBarButtonItem *titleItem = [[UIBarButtonItem alloc] initWithCustomView:titleLabel];
    [titleItem setStyle:UIBarButtonItemStylePlain];
    [barItems addObject:cancelBtn];
    [barItems addObject:flexSpace];  
    [barItems addObject:titleItem];
    [barItems addObject:flexSpace];
    [barItems addObject:doneBtn];    [toolbar setItems:barItems animated:NO];
    [self.pickerAS addSubview:toolbar];    
    [self.pickerAS addSubview:self.thePicker];
    [self.pickerAS showInView:pickerView];
    [self.pickerAS setBounds:CGRectMake(0,0,320, 408)];
    
}

-(void)dismissActionSheet{
    [self.pickerAS dismissWithClickedButtonIndex:0 animated:YES];
    self.pickerAS = nil;
    self.thePicker = nil;
    self.cancelBlock();
}
-(void)saveActionSheet{
    [self.pickerAS dismissWithClickedButtonIndex:0 animated:YES];
    self.pickerAS = nil;
    self.thePicker = nil;
    NSDictionary *pickedDict = [locationsArray objectAtIndex:selectedRow];
    self.closeBlock(pickedDict);
}
- (void) showLocationPicker
{
    selectedRow = 0;
    self.thePicker = nil;
    self.thePicker = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 44, 320, 400)];
    [self.thePicker setDelegate:self];
    [self.thePicker setDataSource:self];
    [self.thePicker setShowsSelectionIndicator:YES];
    self.pickerAS = nil;
    self.pickerAS = [[UIActionSheet alloc] initWithTitle:@"Locations Found" delegate:self cancelButtonTitle:@"cancel" destructiveButtonTitle:nil otherButtonTitles:nil];
    [self addToolbarToPicker:@"Locations Found"];
}


#pragma mark - PickerView Delegate and Datasource

- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    return [locationsArray count];
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    return [[locationsArray objectAtIndex:row] objectForKey:@"locName"];
}

- (UIView *)pickerView:(UIPickerView *)pv viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label = (UILabel*) view;
    if (label == nil)
    {
        label = [[UILabel alloc] init];
    }
    [label setShadowColor:[UIColor whiteColor]];
    [label setShadowOffset:CGSizeMake(0, 1)];
    
    // This part just colorizes everything, since you asked about that.
    [label setTextColor:[UIColor blackColor]];
    
    //if([pickerType isEqualToString:@"locations"] && row == 0)
    //   [label setTextColor:[UIColor colorWithRed:.3 green:.3 blue:1.0 alpha:1.0]];
    
    [label setBackgroundColor:[UIColor clearColor]];
    CGSize rowSize = [pv rowSizeForComponent:component];
    CGRect labelRect = CGRectMake (10, 0, rowSize.width-20, rowSize.height);
    [label setFrame:labelRect];
    [label setAdjustsFontSizeToFitWidth:YES];
    [label setText:[NSString stringWithFormat:@"%@ - %@",
                    [[locationsArray objectAtIndex:row] objectForKey:@"locName"],
                    [[locationsArray objectAtIndex:row] objectForKey:@"locID"]
                    ]
     ];
    
    return label;
}
- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    selectedRow = row;
}


- (void)dealloc
{
    thePicker = nil;
    pickerAS = nil;
    [super dealloc];
}


@end
