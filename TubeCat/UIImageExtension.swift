//
//  UIImageExtension.swift
//  TubeCat
//
//  Created by Leqi Long on 7/25/16.
//  Copyright © 2016 Student. All rights reserved.
//

import Foundation


//Source: http://stackoverflow.com/questions/29046571/cut-a-uiimage-into-a-circle-swiftios
extension UIImage{
    var rounded: UIImage? {
        let imageView = UIImageView(image: self)
        imageView.layer.cornerRadius = min(size.height/2, size.width/2)
        imageView.layer.masksToBounds = true
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.renderInContext(context)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    
}