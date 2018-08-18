//
//  MSStatus.m
//  DireFloof
//
//  Created by John Gabelmann on 2/12/17.
//  Copyright © 2017 Keyboard Floofs. All rights reserved.
//
/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

@import EmojiOne;
@import DateTools;
#import "MSStatus.h"
#import "MSMediaAttachment.h"
#import "MSMention.h"
#import "MSEmoji.h"
#import "NSDictionary+Sanitation.h"
#import "NSString+HtmlStrip.h"
#import "DWSettingStore.h"
#import "NSString+Awoo.h"
#import "DWConstants.h"

@interface MSStatus ()

@property (nonatomic, strong, readwrite) NSString *_id;
@property (nonatomic, strong, readwrite) NSString *uri;
@property (nonatomic, strong, readwrite) NSString *url;
@property (nonatomic, strong, readwrite) MSAccount *account;
@property (nonatomic, strong, readwrite) NSString *in_reply_to_id;
@property (nonatomic, strong, readwrite) NSString *in_reply_to_account_id;
@property (nonatomic, strong, readwrite) MSStatus *reblog;
@property (nonatomic, strong, readwrite) NSString *content;
@property (nonatomic, strong, readwrite) NSDate *created_at;
@property (nonatomic, strong, readwrite) NSNumber *reblogs_count;
@property (nonatomic, strong, readwrite) NSNumber *favourites_count;
@property (nonatomic, assign, readwrite) BOOL sensitive;
@property (nonatomic, strong, readwrite) NSString *spoiler_text;
@property (nonatomic, strong, readwrite) NSArray *media_attachments;
@property (nonatomic, strong, readwrite) NSArray *mentions;
@property (nonatomic, strong, readwrite) MSApplication *application;
@property (nonatomic, strong, readwrite) NSString *visibility;
@property (nonatomic, strong, readwrite) NSArray *emojis;

@end

@implementation MSStatus

#pragma mark - Initializers

- (id)initWithParams:(NSDictionary *)params
{
    self = [self init];
    
    if (self) {
        
        params = [params removeNullValues];
        
        self._id = [params[@"id"] isKindOfClass:[NSString class]] ? params[@"id"] : [params[@"id"] stringValue]; // If we're receiving statuses from a pre-2.0 server it'll be a NSNumber - have it dump its stringValue to correct this.
        self.uri = params[@"uri"];
        self.url = params[@"url"];
        self.account = [[MSAccount alloc] initWithParams:params[@"account"]];
        self.in_reply_to_id = params[@"in_reply_to_id"];
        self.in_reply_to_account_id = params[@"in_reply_to_account_id"];
        self.reblog = params[@"reblog"] ? [[MSStatus alloc] initWithParams:params[@"reblog"]] : nil;
        
        NSString *content = params[@"content"];
        NSNumber *cleansed = params[@"__cleansed"];
        
        if (content) {
            
            self.content = cleansed ? content : [content removeHTML];
            
            if ([DWSettingStore.sharedStore awooMode]) {
                self.content = [self.content awooString];
            }
        }
        
        self.created_at = params[@"created_at"] ? [NSDate dateWithString:params[@"created_at"] formatString:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'" timeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]] : nil;
        self.reblogs_count = params[@"reblogs_count"];
        self.favourites_count = params[@"favourites_count"];
        self.reblogged = [params[@"reblogged"] boolValue];
        self.favourited = [params[@"favourited"] boolValue];
        self.sensitive = [params[@"sensitive"] boolValue];
        self.muted = [params[@"muted"] boolValue];
        
        NSString *spoiler_text = params[@"spoiler_text"];
        
        if (spoiler_text) {
            self.spoiler_text = [Emojione shortnameToUnicode:spoiler_text];
        }
        
        self.visibility = params[@"visibility"];
        
        NSArray *media_attachmentsJSON = params[@"media_attachments"];
        
        if (media_attachmentsJSON) {
            
            NSMutableArray *media_attachments = [@[] mutableCopy];
            
            for (NSDictionary *media_attachmentJSON in media_attachmentsJSON) {
                
                MSMediaAttachment *media_attachment = [[MSMediaAttachment alloc] initWithParams:media_attachmentJSON];
                [media_attachments addObject:media_attachment];
            }
            
            self.media_attachments = media_attachments;
        }
        
        NSArray *mentionsJSON = params[@"mentions"];
        
        if (mentionsJSON) {
            
            NSMutableArray *mentions = [@[] mutableCopy];
            
            for (NSDictionary *mentionJSON in mentionsJSON) {
                
                MSMention *mention = [[MSMention alloc] initWithParams:mentionJSON];
                [mentions addObject:mention];
            }
            
            self.mentions = mentions;
        }
        
        self.application = params[@"application"] ? [[MSApplication alloc] initWithParams:params[@"application"]] : nil;
        
        NSArray *emojisJSON = params[@"emojis"];
        
        if (emojisJSON) {
            
            NSMutableArray *emojis = [@[] mutableCopy];
            
            for (NSDictionary *emojiJSON in emojisJSON) {
                
                MSEmoji *emoji = [[MSEmoji alloc] initWithParams:emojiJSON];
                [emojis addObject:emoji];
            }
            
            self.emojis = emojis;
        }
        
    }
    
    return self;
}


- (id)init
{
    self = [super init];
    
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusFavorited:) name:DW_STATUS_FAVORITED_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusUnfavorited:) name:DW_STATUS_UNFAVORITED_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBoosted:) name:DW_STATUS_BOOSTED_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusUnboosted:) name:DW_STATUS_UNBOOSTED_NOTIFICATION object:nil];

    }
    
    return self;
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Instance Methods

- (NSDictionary *)toJSON
{
    NSMutableDictionary *params = [@{} mutableCopy];
    
    if (self._id) {
        params[@"id"] = self._id;
    }
    
    if (self.uri) {
        params[@"uri"] = self.uri;
    }
    
    if (self.url) {
        params[@"url"] = self.url;
    }
    
    if (self.account) {
        params[@"account"] = [self.account toJSON];
    }
    
    if (self.in_reply_to_id) {
        params[@"in_reply_to_id"] = self.in_reply_to_id;
    }
    
    if (self.in_reply_to_account_id) {
        params[@"in_reply_to_account_id"] = self.in_reply_to_account_id;
    }
    
    if (self.reblog) {
        params[@"reblog"] = [self.reblog toJSON];
    }
    
    if (self.content) {
        params[@"content"] = self.content;
        params[@"__cleansed"] = @(YES);
    }
    
    if (self.created_at) {
        params[@"created_at"] = [self.created_at formattedDateWithFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'" timeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    }
    
    if (self.reblogs_count) {
        params[@"reblogs_count"] = self.reblogs_count;
    }
    
    if (self.favourites_count) {
        params[@"favourites_count"] = self.favourites_count;
    }
    
    params[@"reblogged"] = @(self.reblogged);
    params[@"favourited"] = @(self.favourited);
    params[@"sensitive"] = @(self.sensitive);
    params[@"muted"] = @(self.muted);
    
    if (self.spoiler_text) {
        params[@"spoiler_text"] = self.spoiler_text;
    }
    
    if (self.visibility) {
        params[@"visibility"] = self.visibility;
    }
    
    if (self.media_attachments) {
        
        NSMutableArray *mediaAttachmentsJSON = [@[] mutableCopy];
        
        for (MSMediaAttachment *mediaAttachment in self.media_attachments) {
            [mediaAttachmentsJSON addObject:[mediaAttachment toJSON]];
        }
        
        params[@"media_attachments"] = mediaAttachmentsJSON;
    }
    
    if (self.mentions) {
        NSMutableArray *mentionsJSON = [@[] mutableCopy];
        
        for (MSMention *mention in self.mentions) {
            [mentionsJSON addObject:[mention toJSON]];
        }
        
        params[@"mentions"] = mentionsJSON;
    }
    
    if (self.application) {
        params[@"application"] = [self.application toJSON];
    }
    
    if (self.emojis) {
        NSMutableArray *emojisJSON = [@[] mutableCopy];
        
        for (MSEmoji *emoji in self.emojis) {
            [emojisJSON addObject:[emoji toJSON]];
        }
        
        params[@"emojis"] = emojisJSON;
    }
    
    return params;
}


#pragma mark - Observers

- (void)statusFavorited:(NSNotification *)notification
{
    if ([self._id isEqual:notification.object]) {
        self.favourited = YES;
    }
}


- (void)statusUnfavorited:(NSNotification *)notification
{
    if ([self._id isEqual:notification.object]) {
        self.favourited = NO;
    }
}


- (void)statusBoosted:(NSNotification *)notification
{
    if ([self._id isEqual:notification.object]) {
        self.reblogged = YES;
    }
}


- (void)statusUnboosted:(NSNotification *)notification
{
    if ([self._id isEqual:notification.object]) {
        self.reblogged = NO;
    }
}

@end
