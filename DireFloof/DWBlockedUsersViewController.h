//
//  DWBlockedUsersViewController.h
//  DireFloof
//
//  Created by John Gabelmann on 2/28/17.
//  Copyright © 2017 Keyboard Floofs. All rights reserved.
//
/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

@import UIKit;

@interface DWBlockedUsersViewController : UIViewController

@property (nonatomic, assign) BOOL mutes;
@property (nonatomic, assign) BOOL requests;
@property (nonatomic, assign) BOOL domains;

@end
