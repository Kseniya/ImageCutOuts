//
//  MySHKConfiguration.m
//  ImageCutOut
//
//  Created by Kseniya Kalyuk Zito on 2/1/14.
//  Copyright (c) 2014 KZito. All rights reserved.
//

#import "MySHKConfiguration.h"

@implementation MySHKConfiguration

/*
 App Description
 ---------------
 */
- (NSString*)appName {
	return @"CutUp";
}

- (NSString*)appURL {
	return @"http://cutup.com";
}

/*
 API Keys
 --------
 This is the longest step to getting set up, it involves filling in API keys for the supported services.
 It should be pretty painless though and should hopefully take no more than a few minutes.
 
 Each key below as a link to a page where you can generate an api key.  Fill in the key for each service below.
 
 A note on services you don't need:
 If, for example, your app only shares URLs then you probably won't need image services like Flickr.
 In these cases it is safe to leave an API key blank.
 
 However, it is STRONGLY recommended that you do your best to support all services for the types of sharing you support.
 The core principle behind ShareKit is to leave the service choices up to the user.  Thus, you should not remove any services,
 leaving that decision up to the user.
 */

// Vkontakte
// SHKVkontakteAppID is the Application ID provided by Vkontakte
- (NSString*)vkontakteAppId {
	return @"4160213";
}

// Facebook - https://developers.facebook.com/apps
// SHKFacebookAppID is the Application ID provided by Facebook
// SHKFacebookLocalAppID is used if you need to differentiate between several iOS apps running against a single Facebook app. Useful, if you have full and lite versions of the same app,
// and wish sharing from both will appear on facebook as sharing from one main app. You have to add different suffix to each version. Do not forget to fill both suffixes on facebook developer ("URL Scheme Suffix"). Leave it blank unless you are sure of what you are doing.
// The CFBundleURLSchemes in your App-Info.plist should be "fb" + the concatenation of these two IDs.
// Example:
//    SHKFacebookAppID = 555
//    SHKFacebookLocalAppID = lite
//
//    Your CFBundleURLSchemes entry: fb555lite
- (NSString*)facebookAppId {
	return @"405937189552420";
}

- (NSString*)facebookLocalAppId {
	return @"beta";
}

//Change if your app needs some special Facebook permissions only. In most cases you can leave it as it is.

// new with the 3.1 SDK facebook wants you to request read and publish permissions separatly. If you don't
// you won't get a smooth login/auth flow. Since ShareKit does not require any read permissions.
- (NSArray*)facebookWritePermissions {
    return [NSArray arrayWithObjects:@"publish_actions", nil];
}
- (NSArray*)facebookReadPermissions {
    return nil;	// this is the defaul value for the SDK and will afford basic read permissions
}

/*
 If you want to force use of old-style, posting path that does not use the native sheet. One of the troubles
 with the native sheet is that it gives IOS6 props on facebook instead of your app. This flag has no effect
 on the auth path. It will try to use native auth if availible.
 */
- (NSNumber*)forcePreIOS6FacebookPosting {
	return [NSNumber numberWithBool:false];
}

/*
 Create a project on Google APIs console,
 https://code.google.com/apis/console . Under "API Access", create a
 client ID as "Installed application" with the type "iOS", and
 register the bundle ID of your application.
 */
- (NSString*)googlePlusClientId {
    return @"";
}


// Twitter

/*
 If you want to force use of old-style, pre-IOS5 twitter authentication, set this to true. This way user will have to enter credentials to the OAuthWebView presented by your app. These credentials will not end up in the device account store. If set to false, sharekit takes user credentials from the builtin device store on iOS6 or later and utilizes social.framework to share content. Much easier, and thus recommended is to leave this false and use iOS builtin authentication.
 */
- (NSNumber*)forcePreIOS5TwitterAccess {
	return [NSNumber numberWithBool:false];
}

/* YOU CAN SKIP THIS SECTION unless you set forcePreIOS5TwitterAccess to true, or if you support iOS 4 or older.
 
 Register your app here - http://dev.twitter.com/apps/new
 
 Differences between OAuth and xAuth
 --
 There are two types of authentication provided for Twitter, OAuth and xAuth.  OAuth is the default and will
 present a web view to log the user in.  xAuth presents a native entry form but requires Twitter to add xAuth to your app (you have to request it from them).
 If your app has been approved for xAuth, set SHKTwitterUseXAuth to 1.
 
 Callback URL (important to get right for OAuth users)
 --
 1. Open your application settings at http://dev.twitter.com/apps/
 2. 'Application Type' should be set to BROWSER (not client)
 3. 'Callback URL' should match whatever you enter in SHKTwitterCallbackUrl.  The callback url doesn't have to be an actual existing url.  The user will never get to it because ShareKit intercepts it before the user is redirected.  It just needs to match.
 */

- (NSString*)twitterConsumerKey {
	return @"YcrRNe3XXuh3Ry2FLOKZw";
}

- (NSString*)twitterSecret {
	return @"xzQhuqXFQKhN4FGRP5ExhCRWzsMdPxXPpAVoNzE";
}
// You need to set this if using OAuth, see note above (xAuth users can skip it)
- (NSString*)twitterCallbackUrl {
	return @"";
}
// To use xAuth, set to 1
- (NSNumber*)twitterUseXAuth {
	return [NSNumber numberWithInt:0];
}
// Enter your app's twitter account if you'd like to ask the user to follow it when logging in. (Only for xAuth)
- (NSString*)twitterUsername {
	return @"";
}


// Tumblr - http://www.tumblr.com/docs/en/api/v2
- (NSString*)tumblrConsumerKey {
	return @"7xHj4zcbPBXEgD668CMw2WnZyuYkmbyZCJrhzChI3qUlVQTwli";
}

- (NSString*)tumblrSecret {
	return @"UF5mg7Sy9l4vb41QlwKAx0FkkRE3hzByYjxfIEvEYmyBh5bSpy";
}

//you can put whatever here. It must be the same you entered in tumblr app registration, eg tumblr.sharekit.com
- (NSString*)tumblrCallbackUrl {
	return @"";
}


// Instagram

// Instagram crops images by default
- (NSNumber*)instagramLetterBoxImages {
    return [NSNumber numberWithBool:NO];
}

- (UIColor *)instagramLetterBoxColor
{
    return [UIColor whiteColor];
}

///only show instagram in the application list (instead of Instagram plus any other public/jpeg-conforming apps)
- (NSNumber *)instagramOnly {
    return [NSNumber numberWithBool:YES];
}


/*
 For sharers supported by Social.framework you can choose to present Apple's UI (SLComposeViewController) or ShareKit's UI (you can customize ShareKit's UI). Note that SLComposeViewController has only limited sharing capabilities, e.g. for file sharing on Twitter (photo files, video files, large UIImages) ShareKit's UI will be used anyway.
 */
- (NSNumber *)useAppleShareUI {
    return @YES;
}

// Toolbars
- (NSString*)barStyle {
	return @"UIBarStyleDefault";// See: http://developer.apple.com/iphone/library/documentation/UIKit/Reference/UIKitDataTypesReference/Reference/reference.html#//apple_ref/c/econst/UIBarStyleDefault
}

- (UIColor*)barTintForView:(UIViewController*)vc {
    return nil;
}

// Forms
- (UIColor *)formFontColor {
    return nil;
}

- (UIColor*)formBackgroundColor {
    return nil;
}

// iPad views. You can change presentation style for different sharers
- (NSString *)modalPresentationStyleForController:(UIViewController *)controller {
	return @"UIModalPresentationFormSheet";// See: http://developer.apple.com/iphone/library/documentation/UIKit/Reference/UIViewController_Class/Reference/Reference.html#//apple_ref/occ/instp/UIViewController/modalPresentationStyle
}

- (NSString*)modalTransitionStyleForController:(UIViewController *)controller {
	return @"UIModalTransitionStyleCoverVertical";// See: http://developer.apple.com/iphone/library/documentation/UIKit/Reference/UIViewController_Class/Reference/Reference.html#//apple_ref/occ/instp/UIViewController/modalTransitionStyle
}
// ShareMenu Ordering
- (NSNumber*)shareMenuAlphabeticalOrder {
	return [NSNumber numberWithInt:0];// Setting this to 1 will show list in Alphabetical Order, setting to 0 will follow the order in SHKShares.plist
}

/* Name of the plist file that defines the class names of the sharers to use. Usually should not be changed, but this allows you to subclass a sharer and have the subclass be used. Also helps, if you want to exclude some sharers - you can create your own plist, and add it to your project. This way you do not need to change original SHKSharers.plist, which is a part of subproject - this allows you upgrade easily as you did not change ShareKit itself
 
 You can specify also your own bundle here, if needed. For example:
 return [[[NSBundle mainBundle] pathForResource:@"Vito" ofType:@"bundle"] stringByAppendingPathComponent:@"VKRSTestSharers.plist"]
 */
- (NSString*)sharersPlistName {
	return @"SHKSharers.plist";
}

// SHKActionSheet settings
- (NSNumber*)showActionSheetMoreButton {
	return [NSNumber numberWithBool:true];// Setting this to true will show More... button in SHKActionSheet, setting to false will leave the button out.
}

/*
 Favorite Sharers
 ----------------
 These values are used to define the default favorite sharers appearing on ShareKit's action sheet.
 */
- (NSArray*)defaultFavoriteURLSharers {
    return [NSArray arrayWithObjects:@"SHKTwitter",@"SHKFacebook", @"SHKPocket", nil];
}
- (NSArray*)defaultFavoriteImageSharers {
    return [NSArray arrayWithObjects:@"SHKMail",@"SHKFacebook", @"SHKCopy", nil];
}
- (NSArray*)defaultFavoriteTextSharers {
    return [NSArray arrayWithObjects:@"SHKMail",@"SHKTwitter",@"SHKFacebook", nil];
}

//ShareKit will remember last used sharers for each particular mime type.

- (NSArray *)defaultFavoriteSharersForFile:(SHKFile *)file {
    
   // NSMutableArray *result = [NSMutableArray arrayWithObjects:@"SHKMail",@"SHKEvernote", nil];
  //  if ([file.mimeType hasPrefix:@"video/"] || [file.mimeType hasPrefix:@"audio/"] || [file.mimeType hasPrefix:@"image/"]) {
  //      [result addObject:@"SHKTumblr"];
 //   }
    return nil; //result;
}

- (NSArray*)defaultFavoriteSharersForMimeType:(NSString *)mimeType {
    return [self defaultFavoriteSharersForFile:nil];
}

- (NSArray *)defaultFavoriteFileSharers {
    return [self defaultFavoriteSharersForFile:nil];
}

//by default, user can see last used sharer on top of the SHKActionSheet. You can switch this off here, so that user is always presented the same sharers for each SHKShareType.
- (NSNumber*)autoOrderFavoriteSharers {
    return [NSNumber numberWithBool:true];
}

/*
 UI Configuration : Advanced
 ---------------------------
 If you'd like to do more advanced customization of the ShareKit UI, like background images and more,
 check out http://getsharekit.com/customize. To use a subclass, you can create your own, and let ShareKit know about it in your configurator, overriding one (or more) of these methods.
 */

- (Class)SHKShareMenuSubclass {
    return NSClassFromString(@"SHKShareMenu");
}

- (Class)SHKShareMenuCellSubclass {
    return NSClassFromString(@"UITableViewCell");
}

///You can override methods from Configuration section (see SHKFormController.h) to use your own cell subclasses.
- (Class)SHKFormControllerSubclass {
    return NSClassFromString(@"SHKFormController");
}

- (Class)SHKActivityIndicatorSubclass {
    return NSClassFromString(@"SHKActivityIndicator");
}

/*
 Advanced Configuration
 ----------------------
 These settings can be left as is.  This only need to be changed for uber custom installs.
 */

- (NSNumber*)maxFavCount {
	return [NSNumber numberWithInt:3];
}

- (NSString*)favsPrefixKey {
	return @"SHK_FAVS_";
}

- (NSString*)authPrefix {
	return @"SHK_AUTH_";
}

- (NSNumber*)allowOffline {
	return [NSNumber numberWithBool:true];
}

- (NSNumber*)allowAutoShare {
	return [NSNumber numberWithBool:true];
}

/*
 Debugging settings
 ------------------
 see Debug.h
 */

/*
 SHKItem sharer specific values defaults
 -------------------------------------
 These settings can be left as is. SHKItem is what you put your data in and inject to ShareKit to actually share. Some sharers might be instructed to share the item in specific ways, e.g. SHKPrint's print quality, SHKMail's send to specified recipients etc. Sometimes you need to change the default behaviour - you can do it here globally, or per share during share item (SHKItem) composing. Example is in the demo app - ExampleShareLink.m - share method */

/* SHKPrint */

- (NSNumber*)printOutputType {
    return [NSNumber numberWithInt:UIPrintInfoOutputPhoto];
}

/* SHKMail */

//You can use this to prefill recipients. User enters them in MFMailComposeViewController by default. Should be array of NSStrings.
- (NSArray *)mailToRecipients {
	return nil;
}

- (NSNumber*)isMailHTML {
    return [NSNumber numberWithInt:1];
}

//used only if you share image. Values from 1.0 to 0.0 (maximum compression).
- (NSNumber*)mailJPGQuality {
    return [NSNumber numberWithFloat:1];
}

// append 'Sent from <appName>' signature to Email
- (NSNumber*)sharedWithSignature {
	return [NSNumber numberWithInt:0];
}

/* SHKFacebook */

//when you share URL on Facebook, FBDialog scans the page and fills picture and description automagically by default. Use these item properties to set your own.
- (NSString *)facebookURLSharePictureURI {
    return nil;
}

- (NSString *)facebookURLShareDescription {
    return nil;
}

/* SHKTextMessage */

//You can use this to prefill recipients. User enters them in MFMessageComposeViewController by default. Should be array of NSStrings.
- (NSArray *)textMessageToRecipients {
    return nil;
}

-(NSString*) popOverSourceRect;
{
    return NSStringFromCGRect(CGRectZero);
}

/* SHKDropbox */
//if set, no UI for choosing the target directory is presented to the user.
- (NSString *)dropboxDestinationDirectory {
    return nil;
}


@end