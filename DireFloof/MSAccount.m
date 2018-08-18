//
//  MSAccount.m
//  DireFloof
//
//  Created by John Gabelmann on 2/12/17.
//  Copyright © 2017 Keyboard Floofs. All rights reserved.
//
/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

@import EmojiOne;
#import "MSAccount.h"
#import "NSDictionary+Sanitation.h"
#import "NSString+HtmlStrip.h"
#import "MastodonConstants.h"

@interface MSAccount ()

@property (nonatomic, strong, readwrite) NSString *_id;
@property (nonatomic, strong, readwrite) NSString *username;
@property (nonatomic, strong, readwrite) NSString *acct;
@property (nonatomic, strong, readwrite) NSString *display_name;
@property (nonatomic, strong, readwrite) NSString *note;
@property (nonatomic, strong, readwrite) NSString *url;
@property (nonatomic, strong, readwrite) NSString *avatar;
@property (nonatomic, strong, readwrite) NSString *header;
@property (nonatomic, strong, readwrite) NSString *avatar_static;
@property (nonatomic, strong, readwrite) NSString *header_static;
@property (nonatomic, assign, readwrite) BOOL locked;
@property (nonatomic, strong, readwrite) NSNumber *followers_count;
@property (nonatomic, strong, readwrite) NSNumber *following_count;
@property (nonatomic, strong, readwrite) NSNumber *statuses_count;

@end

@implementation MSAccount

#pragma mark - Initializers

- (id)initWithParams:(NSDictionary *)params
{
    self = [super init];
    
    if (self) {
        
        params = [params removeNullValues];
        
        self._id = [params[@"id"] isKindOfClass:[NSNumber class]] ? [params[@"id"] stringValue] : params[@"id"];
        self.username = params[@"username"];
        self.acct = params[@"acct"];
        
        NSString *display_name = params[@"display_name"];
        
        if (display_name) {
            self.display_name = [Emojione shortnameToUnicode:display_name];
        }
        
        NSString *note = params[@"note"];
        
        if (note) {
            self.note = [note removeHTML];
        }
        
        self.url = params[@"url"];
        self.avatar = [params[@"avatar"] containsString:MS_MISSING_AVATAR_URL] ? [MS_BASE_URL_STRING stringByAppendingString:MS_MISSING_AVATAR_URL] : params[@"avatar"];
        self.avatar_static = [params[@"avatar_static"] containsString:MS_MISSING_AVATAR_URL] ? [MS_BASE_URL_STRING stringByAppendingString:MS_MISSING_AVATAR_URL] : params[@"avatar_static"];
        
        if (!self.avatar_static) {
            self.avatar_static = self.avatar;
        }
        
        self.header = params[@"header"];
        self.header_static = params[@"header_static"];
        
        if (!self.header_static) {
            self.header_static = self.header;
        }
        
        self.locked = [params[@"locked"] boolValue];
        self.followers_count = params[@"followers_count"];
        self.following_count = params[@"following_count"];
        self.statuses_count = params[@"statuses_count"];
    }
    
    return self;
}


#pragma mark - Instance Methods

- (NSDictionary *)toJSON
{
    NSMutableDictionary *params = [@{} mutableCopy];
    
    if (self._id) {
        params[@"id"] = self._id;
    }
    
    if (self.username) {
        params[@"username"] = self.username;
    }
    
    if (self.acct) {
        params[@"acct"] = self.acct;
    }
    
    if (self.display_name) {
        params[@"display_name"] = self.display_name;
    }
    
    if (self.note) {
        params[@"note"] = self.note;
    }
    
    if (self.url) {
        params[@"url"] = self.url;
    }
    
    if (self.avatar) {
        params[@"avatar"] = self.avatar;
    }
    
    if (self.avatar_static) {
        params[@"avatar_static"] = self.avatar_static;
    }
    
    if (self.header) {
        params[@"header"] = self.header;
    }
    
    if (self.header_static) {
        params[@"header_static"] = self.header_static;
    }
    
    params[@"locked"] = @(self.locked);
    
    if (self.followers_count) {
        params[@"followers_count"] = self.followers_count;
    }
    
    if (self.following_count) {
        params[@"following_count"] = self.following_count;
    }
    
    if (self.statuses_count) {
        params[@"statuses_count"] = self.statuses_count;
    }
    
    return params;
}

@end
