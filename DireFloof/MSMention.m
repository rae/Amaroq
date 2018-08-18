//
//  MSMention.m
//  DireFloof
//
//  Created by John Gabelmann on 2/12/17.
//  Copyright © 2017 Keyboard Floofs. All rights reserved.
//
/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#import "MSMention.h"
#import "NSDictionary+Sanitation.h"

@interface MSMention ()

@property (nonatomic, strong, readwrite) NSString *url;
@property (nonatomic, strong, readwrite) NSString *acct;
@property (nonatomic, strong, readwrite) NSString *_id;

@end

@implementation MSMention

#pragma mark - Initializers

- (id)initWithParams:(NSDictionary *)params
{
    self = [super init];
    
    if (self) {
        
        params = [params removeNullValues];
        
        self.url = params[@"url"];
        self.acct = params[@"acct"];
        self._id = params[@"id"];
    }
    
    return self;
}


#pragma mark - Instance Methods

- (NSDictionary *)toJSON
{
    NSMutableDictionary *params = [@{} mutableCopy];
    
    if (self.url) {
        params[@"url"] = self.url;
    }
    
    if (self.acct) {
        params[@"acct"] = self.acct;
    }
    
    if (self._id) {
        params[@"id"] = self._id;
    }
    
    return params;
}

@end
