//
//  UIViewController+NearestNavigationController.swift
//  DireFloof
//
//  Created by Reid Ellis on 2018-08-18.
//  Copyright © 2018 Keyboard Floofs. All rights reserved.
//

import Foundation

@objc extension UIViewController {
    func nearestPresentingNavigationController() -> UIViewController {
        var nearestNav = self;
        
        while let nav = nearestNav.presentingViewController, !(nearestNav is UINavigationController), !(nearestNav is UITabBarController) {
            nearestNav = nav
        }
        
        return nearestNav
    }
}
