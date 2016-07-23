//
//  DataSource .swift
//  TubeCat
//
//  Created by Leqi Long on 7/22/16.
//  Copyright © 2016 Student. All rights reserved.
//

import Foundation

class DataSource: NSObject{
    
    var user: User?
    
    override init() {
        super.init()
    }
    
    // MARK: Singleton Instance
    
    private static var sharedInstance = DataSource()
    
    class func sharedClient() -> DataSource {
        return sharedInstance
    }

}