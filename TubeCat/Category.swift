//
//  Category.swift
//  
//
//  Created by Leqi Long on 7/20/16.
//
//

import Foundation
import CoreData


class Category: NSManagedObject {

    convenience init(id: String, context: NSManagedObjectContext){
        if let ent = NSEntityDescription.entityForName("Category", inManagedObjectContext: context){
            self.init(entity: ent, insertIntoManagedObjectContext: context)
            self.id = id
            self.loadedVideos = false
        }else{
            fatalError("Unable to find entity name!")
        }
    }


}
