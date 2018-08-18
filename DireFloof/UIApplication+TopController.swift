//
//  UIApplication+TopController.swift
//  DireFloof
//
//  Created by Reid Ellis on 2018-08-18.
//  Copyright © 2018 Keyboard Floofs. All rights reserved.
//

import UIKit

class Foo {
    
}

@objc extension UIApplication {
    func topController() -> UIViewController? {
        guard var rootController = self.keyWindow?.rootViewController
        else {
            return nil
        }
        while let controller = rootController.presentedViewController {
            rootController = controller
        }
        return rootController
    }
}
