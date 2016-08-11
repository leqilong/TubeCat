//
//  TubeCatTabBarController.swift
//  TubeCat
//
//  Created by Leqi Long on 8/9/16.
//  Copyright © 2016 Student. All rights reserved.
//

import UIKit

class TubeCatTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.tintColor = UIColor.whiteColor()
        UITabBar.appearance().barTintColor = UIColor(red:0.88, green:0.38, blue:0.21, alpha:1.0)
    }

}
