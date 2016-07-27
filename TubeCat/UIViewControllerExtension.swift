//
//  UIViewControllerExtension.swift
//  TubeCat
//
//  Created by Leqi Long on 7/27/16.
//  Copyright © 2016 Student. All rights reserved.
//

import Foundation

extension UIViewController{
    func displayError(message: String) {
        dispatch_async(dispatch_get_main_queue()) {
            let alert = UIAlertController(title: "", message: message, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
}
