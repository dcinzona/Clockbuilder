//
//  Created by Tim Isted on 04/05/2011.
//  Copyright (c) 2011 Tim Isted. All rights reserved.
//


/* Uncomment these #defines and supply the information for your 
 * Dropbox developer account. 

 * This info can be found at: 
 * https://www.dropbox.com/developers/app_info/yourAppID

 * Both need to be Objective-C strings, using @"" notation. */

#define kTICDDropboxSyncKey @"ddn4rog9smcgjua"
#define kTICDDropboxSyncSecret @"i53w8xeuydprlu4"

#define kGlobalAppIdentifier @"Clockbuilder"

//#define kCoreDataStoreName @"clockbuilderdb.sqlite"
//#define kCoreDataStoreNameiPad @"clockbuilderdb-ipad.sqlite"


#ifndef kTICDDropboxSyncKey
#error "You must specify your Dropbox Sync Key"
#endif

#ifndef kTICDDropboxSyncSecret
#error "You must specify your Dropbox Sync Secret"
#endif